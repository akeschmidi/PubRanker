//
//  QuizServiceTests.swift
//  PubRankerTests
//
//  Tests für QuizService
//

import Foundation
import SwiftData
import XCTest
@testable import PubRanker

final class QuizServiceTests: XCTestCase {
    var testContainer: TestModelContainer!
    var quizService: QuizService!

    override func setUp() async throws {
        testContainer = try TestModelContainer()
        quizService = QuizService(modelContext: testContainer.context)
    }

    override func tearDown() async throws {
        try testContainer.clearAllData()
        testContainer = nil
        quizService = nil
    }

    // MARK: - Create Quiz Tests

    func testCreateQuiz() throws {
        // When
        let quiz = quizService.createQuiz(name: "Test Quiz", venue: "Test Venue")

        // Then
        XCTAssertNotNil(quiz)
        XCTAssertEqual(quiz?.name, "Test Quiz")
        XCTAssertEqual(quiz?.venue, "Test Venue")
        XCTAssertFalse(quiz?.isActive ?? true)
        XCTAssertFalse(quiz?.isCompleted ?? true)

        // Verify it's saved in context
        let descriptor = FetchDescriptor<Quiz>()
        let savedQuizzes = try testContainer.context.fetch(descriptor)
        XCTAssertEqual(savedQuizzes.count, 1)
        XCTAssertEqual(savedQuizzes.first?.id, quiz?.id)
    }

    func testCreateQuizWithEmptyStrings() throws {
        // When
        let quiz = quizService.createQuiz(name: "", venue: "")

        // Then
        XCTAssertNotNil(quiz)
        XCTAssertEqual(quiz?.name, "")
        XCTAssertEqual(quiz?.venue, "")
    }

    func testCreateTemporaryQuiz() throws {
        // When
        let quiz = quizService.createTemporaryQuiz(
            name: "Temp Quiz",
            venue: "Temp Venue",
            date: Date()
        )

        // Then
        XCTAssertEqual(quiz.name, "Temp Quiz")
        XCTAssertEqual(quiz.venue, "Temp Venue")

        // Verify it's NOT saved in context
        let descriptor = FetchDescriptor<Quiz>()
        let savedQuizzes = try testContainer.context.fetch(descriptor)
        XCTAssertEqual(savedQuizzes.count, 0)
    }

    // MARK: - Save Quiz Final Tests

    func testSaveQuizFinal() throws {
        // Given
        let quiz = TestDataGenerator.createSampleQuiz()

        let team1 = TestDataGenerator.createSampleTeam(name: "Team 1")
        let team2 = TestDataGenerator.createSampleTeam(name: "Team 2")
        quiz.teams = [team1, team2]
        team1.quizzes = [quiz]
        team2.quizzes = [quiz]

        let round1 = TestDataGenerator.createSampleRound(name: "Round 1", orderIndex: 0)
        let round2 = TestDataGenerator.createSampleRound(name: "Round 2", orderIndex: 1)
        quiz.rounds = [round1, round2]
        round1.quiz = quiz
        round2.quiz = quiz

        // When
        let success = quizService.saveQuizFinal(quiz)

        // Then
        XCTAssertTrue(success)

        // Verify quiz is saved
        let quizDescriptor = FetchDescriptor<Quiz>()
        let savedQuizzes = try testContainer.context.fetch(quizDescriptor)
        XCTAssertEqual(savedQuizzes.count, 1)

        // Verify teams are saved
        let teamDescriptor = FetchDescriptor<Team>()
        let savedTeams = try testContainer.context.fetch(teamDescriptor)
        XCTAssertEqual(savedTeams.count, 2)

        // Verify rounds are saved
        let roundDescriptor = FetchDescriptor<Round>()
        let savedRounds = try testContainer.context.fetch(roundDescriptor)
        XCTAssertEqual(savedRounds.count, 2)
    }

    func testSaveQuizFinalEmpty() throws {
        // Given
        let quiz = TestDataGenerator.createSampleQuiz()
        quiz.teams = []
        quiz.rounds = []

        // When
        let success = quizService.saveQuizFinal(quiz)

        // Then
        XCTAssertTrue(success)

        let descriptor = FetchDescriptor<Quiz>()
        let savedQuizzes = try testContainer.context.fetch(descriptor)
        XCTAssertEqual(savedQuizzes.count, 1)
        XCTAssertEqual(savedQuizzes.first?.safeTeams.count, 0)
        XCTAssertEqual(savedQuizzes.first?.safeRounds.count, 0)
    }

    // MARK: - Delete Quiz Tests

    func testDeleteQuiz() throws {
        // Given
        let quiz = quizService.createQuiz(name: "To Delete")!

        // Verify it exists
        var descriptor = FetchDescriptor<Quiz>()
        var savedQuizzes = try testContainer.context.fetch(descriptor)
        XCTAssertEqual(savedQuizzes.count, 1)

        // When
        let success = quizService.deleteQuiz(quiz)

        // Then
        XCTAssertTrue(success)

        descriptor = FetchDescriptor<Quiz>()
        savedQuizzes = try testContainer.context.fetch(descriptor)
        XCTAssertEqual(savedQuizzes.count, 0)
    }

    func testDeleteQuizWithRelationships() throws {
        // Given
        let quiz = try TestDataGenerator.createCompleteQuiz(
            teamCount: 2,
            roundCount: 3,
            context: testContainer.context
        )

        // When
        let success = quizService.deleteQuiz(quiz)

        // Then
        XCTAssertTrue(success)

        // Quiz sollte gelöscht sein
        let quizDescriptor = FetchDescriptor<Quiz>()
        let quizzes = try testContainer.context.fetch(quizDescriptor)
        XCTAssertEqual(quizzes.count, 0)

        // Rounds sollten auch gelöscht sein (cascade delete)
        let roundDescriptor = FetchDescriptor<Round>()
        let rounds = try testContainer.context.fetch(roundDescriptor)
        XCTAssertEqual(rounds.count, 0)

        // Teams sollten noch existieren (nullify relationship)
        let teamDescriptor = FetchDescriptor<Team>()
        let teams = try testContainer.context.fetch(teamDescriptor)
        XCTAssertEqual(teams.count, 2)
    }

    // MARK: - Quiz State Management Tests

    func testStartQuiz() throws {
        // Given
        let quiz = quizService.createQuiz(name: "Quiz to Start")!
        XCTAssertFalse(quiz.isActive)

        // When
        quizService.startQuiz(quiz)

        // Then
        XCTAssertTrue(quiz.isActive)
        XCTAssertFalse(quiz.isCompleted)
    }

    func testCompleteQuiz() throws {
        // Given
        let quiz = quizService.createQuiz(name: "Quiz to Complete")!
        quizService.startQuiz(quiz)

        // When
        quizService.completeQuiz(quiz)

        // Then
        XCTAssertFalse(quiz.isActive)
        XCTAssertTrue(quiz.isCompleted)
    }

    func testCancelQuiz() throws {
        // Given
        let quiz = try TestDataGenerator.createCompleteQuiz(
            teamCount: 1,
            roundCount: 3,
            context: testContainer.context
        )
        quizService.startQuiz(quiz)

        // Mark some rounds as completed
        quiz.safeRounds[0].isCompleted = true
        quiz.safeRounds[1].isCompleted = true

        // When
        quizService.cancelQuiz(quiz)

        // Then
        XCTAssertFalse(quiz.isActive)
        XCTAssertFalse(quiz.isCompleted)

        // All rounds should be reset
        for round in quiz.safeRounds {
            XCTAssertFalse(round.isCompleted)
        }
    }

    // MARK: - Edge Cases

    func testCreateMultipleQuizzes() throws {
        // When
        let quiz1 = quizService.createQuiz(name: "Quiz 1", venue: "Venue 1")
        let quiz2 = quizService.createQuiz(name: "Quiz 2", venue: "Venue 2")
        let quiz3 = quizService.createQuiz(name: "Quiz 3", venue: "Venue 3")

        // Then
        XCTAssertNotNil(quiz1)
        XCTAssertNotNil(quiz2)
        XCTAssertNotNil(quiz3)

        let descriptor = FetchDescriptor<Quiz>()
        let savedQuizzes = try testContainer.context.fetch(descriptor)
        XCTAssertEqual(savedQuizzes.count, 3)
    }

    func testQuizWithSpecialCharacters() throws {
        // When
        let quiz = quizService.createQuiz(
            name: "Test 🎉 Quiz \"Special\" & <Tags>",
            venue: "Café Müller's Place"
        )

        // Then
        XCTAssertNotNil(quiz)
        XCTAssertEqual(quiz?.name, "Test 🎉 Quiz \"Special\" & <Tags>")
        XCTAssertEqual(quiz?.venue, "Café Müller's Place")
    }
}
