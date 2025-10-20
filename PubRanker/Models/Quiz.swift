//
//  Quiz.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import Foundation
import SwiftData

@Model
final class Quiz {
    var id: UUID
    var name: String
    var venue: String
    var date: Date
    var isActive: Bool
    var isCompleted: Bool
    var createdAt: Date
    
    @Relationship(deleteRule: .cascade)
    var teams: [Team]
    
    @Relationship(deleteRule: .cascade)
    var rounds: [Round]
    
    init(name: String, venue: String = "", date: Date = Date()) {
        self.id = UUID()
        self.name = name
        self.venue = venue
        self.date = date
        self.isActive = false
        self.isCompleted = false
        self.createdAt = Date()
        self.teams = []
        self.rounds = []
    }
    
    var sortedRounds: [Round] {
        rounds.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var sortedTeamsByScore: [Team] {
        teams.sorted { $0.totalScore > $1.totalScore }
    }
    
    var currentRound: Round? {
        sortedRounds.first { !$0.isCompleted }
    }
    
    var completedRoundsCount: Int {
        rounds.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        guard !rounds.isEmpty else { return 0 }
        return Double(completedRoundsCount) / Double(rounds.count)
    }
}
