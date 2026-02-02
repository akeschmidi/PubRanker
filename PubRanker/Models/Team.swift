//
//  Team.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import Foundation
import SwiftData

@Model
final class Team {
    var id: UUID = UUID()
    var name: String = ""
    var color: String = "AppConstants.defaultTeamColor"
    var totalScore: Int = 0
    var roundScores: [RoundScore] = []
    var quizConfirmations: [QuizConfirmation] = []
    var createdAt: Date = Date()
    var lastModified: Date = Date()
    
    // Team Details
    var contactPerson: String = ""
    var email: String = ""
    /// Globaler Bestätigungsstatus des Teams (für Team-Verwaltung ohne Quiz-Kontext).
    /// Für quiz-spezifische Bestätigung verwende `isConfirmed(for:)` und `setConfirmed(for:isConfirmed:)`.
    var isConfirmed: Bool = false
    var imageData: Data? = nil
    
    @Relationship(deleteRule: .nullify, inverse: \Quiz.teams)
    var quizzes: [Quiz]?
    
    init(name: String, color: String = "AppConstants.defaultTeamColor") {
        self.id = UUID()
        self.name = name
        self.color = color
        self.totalScore = 0
        self.roundScores = []
        self.createdAt = Date()
        self.lastModified = Date()
        self.contactPerson = ""
        self.email = ""
        self.isConfirmed = false
    }
    
    func addScore(for round: Round, points: Int) {
        // Erstelle eine neue Kopie des Arrays, um SwiftData/CloudKit zu triggern
        var updatedScores = roundScores

        if let index = updatedScores.firstIndex(where: { $0.roundId == round.id }) {
            updatedScores[index].points = points
        } else {
            updatedScores.append(RoundScore(roundId: round.id, roundName: round.name, points: points))
        }

        // Setze das gesamte Array neu (triggert CloudKit-Sync)
        roundScores = updatedScores
        calculateTotalScore()

        // Trigger CloudKit-Sync durch lastModified-Update
        lastModified = Date()
    }
    
    func calculateTotalScore() {
        totalScore = roundScores.reduce(0) { $0 + $1.points }
    }
    
    func getScore(for round: Round) -> Int? {
        return roundScores.first(where: { $0.roundId == round.id })?.points
    }
    
    func hasScore(for round: Round) -> Bool {
        return roundScores.contains(where: { $0.roundId == round.id })
    }
    
    /// Berechnet die Gesamtpunkte nur für ein bestimmtes Quiz
    func getTotalScore(for quiz: Quiz) -> Int {
        let quizRoundIds = Set(quiz.safeRounds.map { $0.id })
        return roundScores
            .filter { quizRoundIds.contains($0.roundId) }
            .reduce(0) { $0 + $1.points }
    }
    
    // MARK: - Quiz Confirmation Methods
    
    /// Setzt die Bestätigung für ein bestimmtes Quiz
    func setConfirmed(for quiz: Quiz, isConfirmed: Bool) {
        if let index = quizConfirmations.firstIndex(where: { $0.quizId == quiz.id }) {
            quizConfirmations[index].isConfirmed = isConfirmed
        } else {
            quizConfirmations.append(QuizConfirmation(quizId: quiz.id, quizName: quiz.name, isConfirmed: isConfirmed))
        }
    }
    
    /// Gibt zurück, ob das Team für ein bestimmtes Quiz bestätigt ist
    func isConfirmed(for quiz: Quiz) -> Bool {
        return quizConfirmations.first(where: { $0.quizId == quiz.id })?.isConfirmed ?? false
    }
}

// MARK: - RoundScore
struct RoundScore: Codable {
    var roundId: UUID
    var roundName: String
    var points: Int
}

// MARK: - QuizConfirmation
struct QuizConfirmation: Codable {
    var quizId: UUID
    var quizName: String
    var isConfirmed: Bool
}
