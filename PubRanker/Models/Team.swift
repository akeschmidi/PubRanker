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
    var color: String = "#007AFF"
    var totalScore: Int = 0
    var roundScores: [RoundScore] = []
    var createdAt: Date = Date()
    
    // Team Details
    var contactPerson: String = ""
    var email: String = ""
    var isConfirmed: Bool = false
    var imageData: Data? = nil
    
    @Relationship(deleteRule: .nullify, inverse: \Quiz.teams)
    var quizzes: [Quiz]?
    
    init(name: String, color: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.color = color
        self.totalScore = 0
        self.roundScores = []
        self.createdAt = Date()
        self.contactPerson = ""
        self.email = ""
        self.isConfirmed = false
    }
    
    func addScore(for round: Round, points: Int) {
        if let index = roundScores.firstIndex(where: { $0.roundId == round.id }) {
            roundScores[index].points = points
        } else {
            roundScores.append(RoundScore(roundId: round.id, roundName: round.name, points: points))
        }
        calculateTotalScore()
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
}

// MARK: - RoundScore
struct RoundScore: Codable {
    var roundId: UUID
    var roundName: String
    var points: Int
}
