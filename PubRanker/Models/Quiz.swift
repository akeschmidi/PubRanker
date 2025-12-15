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
    var maxTeams: Int? = nil
    
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
        safeTeams.sorted { $0.getTotalScore(for: self) > $1.getTotalScore(for: self) }
    }
    
    var confirmedTeamsCount: Int {
        safeTeams.filter { $0.isConfirmed(for: self) }.count
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
    
    /// Berechnet die Ränge mit geteilten Plätzen (Dense-Ranking)
    /// Beispiel: 1, 2, 2, 3 (bei zwei Teams auf Platz 2 kommt der nächste auf Platz 3, nicht 4)
    func getTeamRankings() -> [(team: Team, rank: Int)] {
        let sortedTeams = sortedTeamsByScore
        var rankings: [(team: Team, rank: Int)] = []
        var currentRank = 1
        var previousScore: Int?
        
        for team in sortedTeams {
            let teamScore = team.getTotalScore(for: self)
            
            if let prevScore = previousScore {
                if teamScore != prevScore {
                    // Neue Punktzahl - Rang um 1 erhöhen (Dense Ranking)
                    currentRank += 1
                }
                // Bei gleicher Punktzahl bleibt currentRank gleich
            }
            
            rankings.append((team: team, rank: currentRank))
            previousScore = teamScore
        }
        
        return rankings
    }
    
    /// Gibt den Rang eines bestimmten Teams zurück
    func getTeamRank(for team: Team) -> Int {
        let rankings = getTeamRankings()
        return rankings.first(where: { $0.team.id == team.id })?.rank ?? 1
    }
}
