//
//  RoundService.swift
//  PubRanker
//
//  Service für Round-Management
//

import Foundation
import SwiftData

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
    /// - Returns: Die erstellte Runde oder nil bei Fehler
    @discardableResult
    func addRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) -> Round? {
        if quiz.rounds == nil {
            quiz.rounds = []
        }

        let orderIndex = quiz.rounds?.count ?? 0
        let round = Round(name: name, maxPoints: maxPoints, orderIndex: orderIndex)
        round.quiz = quiz
        quiz.rounds?.append(round)
        modelContext.insert(round)

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        do {
            try modelContext.save()
            return round
        } catch {
            print("Error adding round: \(error)")
            return nil
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
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func deleteRound(_ round: Round, from quiz: Quiz) -> Bool {
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
            return true
        } catch {
            print("Error deleting round: \(error)")
            return false
        }
    }

    // MARK: - Round Status & Updates

    /// Markiert eine Runde als abgeschlossen
    /// - Parameter round: Die abzuschließende Runde
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func completeRound(_ round: Round) -> Bool {
        round.isCompleted = true

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error completing round: \(error)")
            return false
        }
    }

    /// Aktualisiert den Namen einer Runde
    /// - Parameters:
    ///   - round: Die zu aktualisierende Runde
    ///   - newName: Der neue Name
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func updateRoundName(_ round: Round, newName: String) -> Bool {
        round.name = newName

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error updating round name: \(error)")
            return false
        }
    }

    /// Aktualisiert die maximalen Punkte einer Runde
    /// - Parameters:
    ///   - round: Die zu aktualisierende Runde
    ///   - maxPoints: Die neuen maximalen Punkte (nil = keine Begrenzung)
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func updateRoundMaxPoints(_ round: Round, maxPoints: Int?) -> Bool {
        round.maxPoints = maxPoints

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error updating round max points: \(error)")
            return false
        }
    }

    // MARK: - Round Ordering

    /// Ordnet Runden in einem Quiz neu
    /// - Parameter quiz: Das Quiz mit den neu zu ordnenden Runden
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func reorderRounds(in quiz: Quiz) -> Bool {
        for (index, round) in quiz.sortedRounds.enumerated() {
            round.orderIndex = index
        }

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error reordering rounds: \(error)")
            return false
        }
    }
}
