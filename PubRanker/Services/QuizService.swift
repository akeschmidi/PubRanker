//
//  QuizService.swift
//  PubRanker
//
//  Service für Quiz-Management (CRUD Operationen)
//

import Foundation
import SwiftData

/// Service für Quiz-bezogene Operationen
/// Verantwortlich für: Quiz erstellen, löschen, Status ändern
final class QuizService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Quiz CRUD

    /// Erstellt ein neues Quiz und speichert es in der Datenbank
    /// - Parameters:
    ///   - name: Name des Quiz
    ///   - venue: Veranstaltungsort
    ///   - date: Datum des Quiz
    /// - Returns: Das erstellte Quiz oder nil bei Fehler
    @discardableResult
    func createQuiz(name: String, venue: String = "", date: Date = Date()) -> Quiz? {
        let quiz = Quiz(name: name, venue: venue, date: date)
        modelContext.insert(quiz)

        do {
            try modelContext.save()
            return quiz
        } catch {
            print("Error creating quiz: \(error)")
            return nil
        }
    }

    /// Erstellt ein temporäres Quiz ohne es zu speichern (für Wizard-Mode)
    /// - Parameters:
    ///   - name: Name des Quiz
    ///   - venue: Veranstaltungsort
    ///   - date: Datum
    /// - Returns: Temporäres Quiz-Objekt
    func createTemporaryQuiz(name: String, venue: String, date: Date) -> Quiz {
        return Quiz(name: name, venue: venue, date: date)
    }

    /// Speichert ein temporäres Quiz final mit allen verknüpften Entities
    /// - Parameter quiz: Das zu speichernde Quiz mit Teams und Runden
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func saveQuizFinal(_ quiz: Quiz) -> Bool {
        print("📝 QuizService.saveQuizFinal: Starte Speicherung für '\(quiz.name)'")
        print("   - Teams: \(quiz.teams?.count ?? 0)")
        print("   - Runden: \(quiz.rounds?.count ?? 0)")

        // Quiz in Context einfügen
        modelContext.insert(quiz)
        print("   ✓ Quiz in Context eingefügt")

        // Alle Teams in Context einfügen
        if let teams = quiz.teams {
            for team in teams {
                modelContext.insert(team)
            }
            print("   ✓ \(teams.count) Teams in Context eingefügt")
        }

        // Alle Runden in Context einfügen
        if let rounds = quiz.rounds {
            for round in rounds {
                modelContext.insert(round)
            }
            print("   ✓ \(rounds.count) Runden in Context eingefügt")
        }

        do {
            try modelContext.save()
            print("✅ QuizService.saveQuizFinal: Erfolgreich gespeichert!")
            return true
        } catch {
            print("❌ QuizService.saveQuizFinal: Fehler beim Speichern: \(error)")
            return false
        }
    }

    /// Löscht ein Quiz aus der Datenbank
    /// - Parameter quiz: Das zu löschende Quiz
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func deleteQuiz(_ quiz: Quiz) -> Bool {
        modelContext.delete(quiz)

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error deleting quiz: \(error)")
            return false
        }
    }

    // MARK: - Quiz Status

    /// Startet ein Quiz (setzt isActive = true)
    /// - Parameter quiz: Das zu startende Quiz
    func startQuiz(_ quiz: Quiz) {
        quiz.isActive = true
        saveContext()
    }

    /// Schließt ein Quiz ab (setzt isActive = false, isCompleted = true)
    /// - Parameter quiz: Das abzuschließende Quiz
    func completeQuiz(_ quiz: Quiz) {
        quiz.isActive = false
        quiz.isCompleted = true
        saveContext()
    }

    /// Bricht ein Quiz ab und setzt es zurück
    /// - Parameter quiz: Das abzubrechende Quiz
    func cancelQuiz(_ quiz: Quiz) {
        quiz.isActive = false
        quiz.isCompleted = false

        // Setze alle Runden auf nicht abgeschlossen zurück
        for round in quiz.safeRounds {
            round.isCompleted = false
        }

        saveContext()
    }

    // MARK: - Helper

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
