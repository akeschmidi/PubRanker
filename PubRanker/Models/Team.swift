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
    var id: UUID
    var name: String
    var color: String
    var totalScore: Int
    var roundScores: [RoundScore]
    var createdAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \Quiz.teams)
    var quiz: Quiz?
    
    init(name: String, color: String = "#007AFF") {
        self.id = UUID()
        self.name = name
        self.color = color
        self.totalScore = 0
        self.roundScores = []
        self.createdAt = Date()
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
    
    func getScore(for round: Round) -> Int {
        return roundScores.first(where: { $0.roundId == round.id })?.points ?? 0
    }
}

// MARK: - RoundScore
struct RoundScore: Codable {
    var roundId: UUID
    var roundName: String
    var points: Int
}
