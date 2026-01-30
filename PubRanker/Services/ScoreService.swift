//
//  ScoreService.swift
//  PubRanker
//
//  Service für Score-Management
//

import Foundation
import SwiftData

/// Service für Score-bezogene Operationen
/// Verantwortlich für: Punkte aktualisieren, löschen, Cache invalidieren
final class ScoreService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Score Operations

    /// Aktualisiert den Score eines Teams für eine Runde
    /// - Parameters:
    ///   - team: Das Team
    ///   - round: Die Runde
    ///   - points: Die Punktzahl
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func updateScore(for team: Team, in round: Round, points: Int) -> Bool {
        team.addScore(for: round, points: points)

        // Invalidiere Quiz-Cache wenn vorhanden
        round.quiz?.invalidateScoreCache()

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error updating score: \(error)")
            return false
        }
    }

    /// Löscht den Score eines Teams für eine Runde
    /// - Parameters:
    ///   - team: Das Team
    ///   - round: Die Runde
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func clearScore(for team: Team, in round: Round) -> Bool {
        team.roundScores.removeAll(where: { $0.roundId == round.id })
        team.calculateTotalScore()

        // Invalidiere Quiz-Cache wenn vorhanden
        round.quiz?.invalidateScoreCache()

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error clearing score: \(error)")
            return false
        }
    }

    // MARK: - Score Queries

    /// Gibt den Rang eines Teams in einem Quiz zurück
    /// - Parameters:
    ///   - team: Das Team
    ///   - quiz: Das Quiz
    /// - Returns: Der Rang des Teams (1-basiert)
    func getTeamRank(for team: Team, in quiz: Quiz) -> Int {
        return quiz.getTeamRank(for: team)
    }

    /// Gibt alle Rankings eines Quiz zurück
    /// - Parameter quiz: Das Quiz
    /// - Returns: Array mit (team, rank) Tuples
    func getTeamRankings(for quiz: Quiz) -> [(team: Team, rank: Int)] {
        return quiz.getTeamRankings()
    }
}
