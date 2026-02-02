//
//  RoundService.swift
//  PubRanker
//
//  Service für Round-Management
//

import Foundation
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.pubranker", category: "RoundService")

/// Service für Round-bezogene Operationen
/// Verantwortlich für: Runden erstellen, löschen, aktualisieren, Reihenfolge verwalten
final class RoundService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Round CRUD

    /// Erstellt eine neue Runde und fügt sie einem Quiz hinzu
    /// - Parameters:
    ///   - quiz: Das Quiz, dem die Runde hinzugefügt wird
    ///   - name: Name der Runde
    ///   - maxPoints: Maximale Punktzahl (optional)
    /// - Returns: Die erstellte Runde
    /// - Throws: ServiceError wenn Validierung oder Speichern fehlschlägt
    func addRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) throws -> Round {
        let sanitizedName = name.sanitizedName
        guard sanitizedName.isValidName else {
            throw ServiceError.validationFailed(field: "Name", reason: "Runden-Name darf nicht leer sein")
        }

        if quiz.rounds == nil {
            quiz.rounds = []
        }

        let orderIndex = quiz.rounds?.count ?? 0
        let round = Round(name: sanitizedName, maxPoints: maxPoints, orderIndex: orderIndex)
        round.quiz = quiz
        quiz.rounds?.append(round)
        modelContext.insert(round)

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        do {
            try modelContext.save()
            logger.info("Runde '\(sanitizedName)' zu Quiz '\(quiz.name)' hinzugefügt")
            return round
        } catch {
            logger.error("Fehler beim Hinzufügen der Runde '\(sanitizedName)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Erstellt eine temporäre Runde ohne sie zu speichern (für Wizard-Mode)
    /// - Parameters:
    ///   - quiz: Das Quiz, dem die Runde hinzugefügt wird
    ///   - name: Name der Runde
    ///   - maxPoints: Maximale Punktzahl (optional)
    func addTemporaryRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) {
        if quiz.rounds == nil {
            quiz.rounds = []
        }
        let orderIndex = quiz.rounds?.count ?? 0
        let round = Round(name: name, maxPoints: maxPoints, orderIndex: orderIndex)
        round.quiz = quiz
        quiz.rounds?.append(round)
    }

    /// Löscht eine Runde aus einem Quiz und ordnet verbleibende Runden neu
    /// - Parameters:
    ///   - round: Die zu löschende Runde
    ///   - quiz: Das Quiz, aus dem die Runde entfernt werden soll
    /// - Throws: ServiceError wenn das Löschen fehlschlägt
    func deleteRound(_ round: Round, from quiz: Quiz) throws {
        let roundName = round.name
        if let index = quiz.rounds?.firstIndex(where: { $0.id == round.id }) {
            quiz.rounds?.remove(at: index)
        }
        modelContext.delete(round)

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        // Reorder remaining rounds
        for (index, remainingRound) in quiz.sortedRounds.enumerated() {
            remainingRound.orderIndex = index
        }

        do {
            try modelContext.save()
            logger.info("Runde '\(roundName)' aus Quiz '\(quiz.name)' gelöscht")
        } catch {
            logger.error("Fehler beim Löschen der Runde '\(roundName)': \(error.localizedDescription)")
            throw ServiceError.deleteFailed(underlying: error)
        }
    }

    // MARK: - Round Status & Updates

    /// Markiert eine Runde als abgeschlossen
    /// - Parameter round: Die abzuschließende Runde
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func completeRound(_ round: Round) throws {
        round.isCompleted = true

        do {
            try modelContext.save()
            logger.info("Runde '\(round.name)' abgeschlossen")
        } catch {
            logger.error("Fehler beim Abschließen der Runde '\(round.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Aktualisiert den Namen einer Runde
    /// - Parameters:
    ///   - round: Die zu aktualisierende Runde
    ///   - newName: Der neue Name
    /// - Throws: ServiceError wenn Validierung oder Speichern fehlschlägt
    func updateRoundName(_ round: Round, newName: String) throws {
        let sanitizedName = newName.sanitizedName
        guard sanitizedName.isValidName else {
            throw ServiceError.validationFailed(field: "Name", reason: "Runden-Name darf nicht leer sein")
        }

        let oldName = round.name
        round.name = sanitizedName

        do {
            try modelContext.save()
            logger.info("Runde umbenannt: '\(oldName)' -> '\(sanitizedName)'")
        } catch {
            logger.error("Fehler beim Umbenennen der Runde '\(oldName)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Aktualisiert die maximalen Punkte einer Runde
    /// - Parameters:
    ///   - round: Die zu aktualisierende Runde
    ///   - maxPoints: Die neuen maximalen Punkte (nil = keine Begrenzung)
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func updateRoundMaxPoints(_ round: Round, maxPoints: Int?) throws {
        round.maxPoints = maxPoints

        do {
            try modelContext.save()
            logger.info("Max. Punkte für Runde '\(round.name)' aktualisiert: \(maxPoints.map { String($0) } ?? "unbegrenzt")")
        } catch {
            logger.error("Fehler beim Aktualisieren der max. Punkte für Runde '\(round.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    // MARK: - Round Ordering

    /// Ordnet Runden in einem Quiz neu
    /// - Parameter quiz: Das Quiz mit den neu zu ordnenden Runden
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func reorderRounds(in quiz: Quiz) throws {
        for (index, round) in quiz.sortedRounds.enumerated() {
            round.orderIndex = index
        }

        do {
            try modelContext.save()
            logger.info("Runden in Quiz '\(quiz.name)' neu geordnet")
        } catch {
            logger.error("Fehler beim Neuordnen der Runden in Quiz '\(quiz.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }
}
