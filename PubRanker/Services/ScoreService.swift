//
//  ScoreService.swift
//  PubRanker
//
//  Service für Score-Management
//

import Foundation
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.pubranker", category: "ScoreService")

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
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func updateScore(for team: Team, in round: Round, points: Int) throws {
        team.addScore(for: round, points: points)

        // Invalidiere Quiz-Cache wenn vorhanden
        round.quiz?.invalidateScoreCache()

        do {
            try modelContext.save()
            logger.debug("Score für Team '\(team.name)' in Runde '\(round.name)' auf \(points) aktualisiert")
        } catch {
            logger.error("Fehler beim Aktualisieren des Scores für Team '\(team.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Löscht den Score eines Teams für eine Runde
    /// - Parameters:
    ///   - team: Das Team
    ///   - round: Die Runde
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func clearScore(for team: Team, in round: Round) throws {
        team.roundScores.removeAll(where: { $0.roundId == round.id })
        team.calculateTotalScore()

        // Invalidiere Quiz-Cache wenn vorhanden
        round.quiz?.invalidateScoreCache()

        do {
            try modelContext.save()
            logger.debug("Score für Team '\(team.name)' in Runde '\(round.name)' gelöscht")
        } catch {
            logger.error("Fehler beim Löschen des Scores für Team '\(team.name)': \(error.localizedDescription)")
            throw ServiceError.deleteFailed(underlying: error)
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
