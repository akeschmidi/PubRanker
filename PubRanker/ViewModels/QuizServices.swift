// Stubs to fix build errors for missing types referenced in QuizViewModel.swift
import Foundation
import SwiftData

// MARK: - ExportFormat Enum

enum ExportFormat {
    case json
    case csv
}

// MARK: - Service Stubs

class QuizService {
    init(modelContext: ModelContext) {}
    func createQuiz(name: String, venue: String) -> Quiz? { nil }
    func createTemporaryQuiz(name: String, venue: String, date: Date) -> Quiz { Quiz(name: name, venue: venue, date: date) }
    func saveQuizFinal(_ quiz: Quiz) -> Bool { false }
    func deleteQuiz(_ quiz: Quiz) -> Bool { false }
    func startQuiz(_ quiz: Quiz) {}
    func completeQuiz(_ quiz: Quiz) {}
    func cancelQuiz(_ quiz: Quiz) {}
}

class TeamService {
    init(modelContext: ModelContext) {}
    func addTeam(to quiz: Quiz, name: String, color: String, contactPerson: String, email: String, isConfirmed: Bool, imageData: Data?) {}
    func addTemporaryTeam(to quiz: Quiz, name: String, color: String, contactPerson: String, email: String, isConfirmed: Bool, imageData: Data?) {}
    func addExistingTeam(_ team: Team, to quiz: Quiz) {}
    func deleteTeam(_ team: Team, from quiz: Quiz) {}
    func updateTeamName(_ team: Team, newName: String) {}
    func updateTeamDetails(_ team: Team, contactPerson: String, email: String, isConfirmed: Bool, forQuiz quiz: Quiz?) {}
}

class RoundService {
    init(modelContext: ModelContext) {}
    func addRound(to quiz: Quiz, name: String, maxPoints: Int?) {}
    func addTemporaryRound(to quiz: Quiz, name: String, maxPoints: Int?) {}
    func deleteRound(_ round: Round, from quiz: Quiz) {}
    func completeRound(_ round: Round) {}
    func updateRoundName(_ round: Round, newName: String) {}
    func updateRoundMaxPoints(_ round: Round, maxPoints: Int?) {}
}

class ScoreService {
    init(modelContext: ModelContext) {}
    func updateScore(for team: Team, in round: Round, points: Int) {}
    func clearScore(for team: Team, in round: Round) {}
    func getTeamRank(for team: Team, in quiz: Quiz) -> Int { 1 }
}

class ExportService {
    func exportQuizAsJSON(quiz: Quiz) -> String { "" }
    func exportQuizAsCSV(quiz: Quiz) -> String { "" }
    func exportQuizToFile(quiz: Quiz, format: ExportFormat) -> URL? { nil }
}
