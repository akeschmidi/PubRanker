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

    // MARK: - Score Cache (nicht persistent)
    @Transient private var cachedTeamScores: [UUID: Int] = [:]
    @Transient private var cachedRankings: [(team: Team, rank: Int)] = []
    @Transient private var cacheIsValid: Bool = false
    
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
        if !cacheIsValid {
            updateScoreCache()
        }
        return safeTeams.sorted {
            (cachedTeamScores[$0.id] ?? 0) > (cachedTeamScores[$1.id] ?? 0)
        }
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
        if !cacheIsValid {
            updateScoreCache()
        }

        // Verwende gecachte Rankings wenn verfügbar
        if !cachedRankings.isEmpty && cacheIsValid {
            return cachedRankings
        }

        let sortedTeams = sortedTeamsByScore
        var rankings: [(team: Team, rank: Int)] = []
        var currentRank = 1
        var previousScore: Int?

        for team in sortedTeams {
            let teamScore = cachedTeamScores[team.id] ?? 0

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

        cachedRankings = rankings
        return rankings
    }
    
    /// Gibt den Rang eines bestimmten Teams zurück
    func getTeamRank(for team: Team) -> Int {
        let rankings = getTeamRankings()
        return rankings.first(where: { $0.team.id == team.id })?.rank ?? 1
    }

    // MARK: - Cache Management

    /// Invalidiert den Score-Cache - sollte aufgerufen werden wenn sich Scores ändern
    func invalidateScoreCache() {
        cacheIsValid = false
        cachedTeamScores.removeAll()
        cachedRankings.removeAll()
    }

    /// Aktualisiert den Score-Cache
    private func updateScoreCache() {
        cachedTeamScores.removeAll()
        for team in safeTeams {
            cachedTeamScores[team.id] = team.getTotalScore(for: self)
        }
        cacheIsValid = true
        cachedRankings.removeAll() // Rankings müssen neu berechnet werden
    }

    /// Gibt gecachten Score für Team zurück (mit Fallback auf Berechnung)
    func getCachedScore(for team: Team) -> Int {
        if !cacheIsValid {
            updateScoreCache()
        }
        return cachedTeamScores[team.id] ?? team.getTotalScore(for: self)
    }
}
