//
//  TestHelpers.swift
//  PubRankerTests
//
//  Test utilities and helpers for SwiftData testing
//

import Foundation
import SwiftData
import XCTest
@testable import PubRanker

/// Helper class for creating in-memory SwiftData contexts for testing
final class TestModelContainer {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let schema = Schema([
            Quiz.self,
            Team.self,
            Round.self
        ])

        let configuration = ModelConfiguration(
            isStoredInMemoryOnly: true
        )

        container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        context = ModelContext(container)
    }

    /// Erstellt einen neuen Context für Tests
    func makeContext() -> ModelContext {
        return ModelContext(container)
    }

    /// Löscht alle Daten aus dem Test-Container
    func clearAllData() throws {
        try context.delete(model: Quiz.self)
        try context.delete(model: Team.self)
        try context.delete(model: Round.self)
        try context.save()
    }
}

/// Sample data generators for testing
struct TestDataGenerator {

    // MARK: - Quiz Generators

    static func createSampleQuiz(
        name: String = "Test Quiz",
        venue: String = "Test Venue",
        date: Date = Date()
    ) -> Quiz {
        return Quiz(name: name, venue: venue, date: date)
    }

    static func createActiveQuiz() -> Quiz {
        let quiz = createSampleQuiz(name: "Active Quiz")
        quiz.isActive = true
        return quiz
    }

    static func createCompletedQuiz() -> Quiz {
        let quiz = createSampleQuiz(name: "Completed Quiz")
        quiz.isActive = false
        quiz.isCompleted = true
        return quiz
    }

    // MARK: - Team Generators

    static func createSampleTeam(
        name: String = "Test Team",
        color: String = "#007AFF",
        contactPerson: String = "John Doe",
        email: String = "test@example.com"
    ) -> Team {
        let team = Team(name: name, color: color)
        team.contactPerson = contactPerson
        team.email = email
        return team
    }

    static func createTeamsArray(count: Int, prefix: String = "Team") -> [Team] {
        return (1...count).map { index in
            createSampleTeam(
                name: "\(prefix) \(index)",
                color: "#\(String(format: "%06X", Int.random(in: 0...0xFFFFFF)))"
            )
        }
    }

    // MARK: - Round Generators

    static func createSampleRound(
        name: String = "Test Round",
        maxPoints: Int? = 10,
        orderIndex: Int = 0
    ) -> Round {
        return Round(name: name, maxPoints: maxPoints, orderIndex: orderIndex)
    }

    static func createRoundsArray(count: Int, prefix: String = "Round", maxPoints: Int = 10) -> [Round] {
        return (0..<count).map { index in
            createSampleRound(
                name: "\(prefix) \(index + 1)",
                maxPoints: maxPoints,
                orderIndex: index
            )
        }
    }

    // MARK: - Complex Test Scenarios

    /// Erstellt ein vollständiges Quiz mit Teams und Runden
    static func createCompleteQuiz(
        teamCount: Int = 3,
        roundCount: Int = 5,
        context: ModelContext
    ) throws -> Quiz {
        let quiz = createSampleQuiz(name: "Complete Test Quiz")
        context.insert(quiz)

        // Teams hinzufügen
        let teams = createTeamsArray(count: teamCount)
        for team in teams {
            team.quizzes = [quiz]
            context.insert(team)
        }
        quiz.teams = teams

        // Runden hinzufügen
        let rounds = createRoundsArray(count: roundCount)
        for round in rounds {
            round.quiz = quiz
            context.insert(round)
        }
        quiz.rounds = rounds

        try context.save()
        return quiz
    }

    /// Erstellt ein Quiz mit Scores
    static func createQuizWithScores(
        teamCount: Int = 3,
        roundCount: Int = 3,
        context: ModelContext
    ) throws -> Quiz {
        let quiz = try createCompleteQuiz(teamCount: teamCount, roundCount: roundCount, context: context)

        // Füge Scores hinzu
        for (teamIndex, team) in quiz.safeTeams.enumerated() {
            for (roundIndex, round) in quiz.safeRounds.enumerated() {
                // Unterschiedliche Scores für verschiedene Teams
                let points = (teamIndex + 1) * (roundIndex + 1) * 5
                team.addScore(for: round, points: points)
            }
        }

        try context.save()
        return quiz
    }
}

// MARK: - Testing Extensions

extension Quiz {
    /// Konvenienzmethode für Tests: Fügt ein Team hinzu
    func addTestTeam(_ team: Team) {
        if teams == nil {
            teams = []
        }
        teams?.append(team)
        team.quizzes = [self]
    }

    /// Konvenienzmethode für Tests: Fügt eine Runde hinzu
    func addTestRound(_ round: Round) {
        if rounds == nil {
            rounds = []
        }
        rounds?.append(round)
        round.quiz = self
    }
}

extension Team {
    /// Konvenienzmethode für Tests: Setzt Score für eine Runde
    func setTestScore(for round: Round, points: Int) {
        addScore(for: round, points: points)
    }
}
