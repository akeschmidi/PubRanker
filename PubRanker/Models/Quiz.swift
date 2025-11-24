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
    var id: UUID = UUID()
    var name: String = ""
    var venue: String = ""
    var date: Date = Date()
    var isActive: Bool = false
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    
    @Relationship(deleteRule: .nullify)
    var teams: [Team]? = []
    
    @Relationship(deleteRule: .cascade)
    var rounds: [Round]? = []
    
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
    
    // Safe accessors for optional arrays
    var safeTeams: [Team] {
        teams ?? []
    }
    
    var safeRounds: [Round] {
        rounds ?? []
    }
    
    var sortedRounds: [Round] {
        safeRounds.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var sortedTeamsByScore: [Team] {
        safeTeams.sorted { $0.totalScore > $1.totalScore }
    }
    
    var currentRound: Round? {
        sortedRounds.first { !$0.isCompleted }
    }
    
    var completedRoundsCount: Int {
        safeRounds.filter { $0.isCompleted }.count
    }
    
    var progress: Double {
        guard !safeRounds.isEmpty else { return 0 }
        return Double(completedRoundsCount) / Double(safeRounds.count)
    }
}
