//
//  QuizService.swift
//  PubRanker
//
//  Service für Quiz-Management (CRUD Operationen)
//

import Foundation
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.pubranker", category: "QuizService")

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
    /// - Returns: Das erstellte Quiz
    /// - Throws: ServiceError wenn Validierung oder Speichern fehlschlägt
    func createQuiz(name: String, venue: String = "", date: Date = Date()) throws -> Quiz {
        let sanitizedName = name.sanitizedName
        guard sanitizedName.isValidName else {
            throw ServiceError.validationFailed(field: "Name", reason: "Quiz-Name darf nicht leer sein")
        }

        let quiz = Quiz(name: sanitizedName, venue: venue.sanitizedName, date: date)
        modelContext.insert(quiz)

        do {
            try modelContext.save()
            logger.info("Quiz '\(sanitizedName)' erfolgreich erstellt")
            return quiz
        } catch {
            logger.error("Fehler beim Erstellen des Quiz: \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
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
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func saveQuizFinal(_ quiz: Quiz) throws {
        logger.debug("Starte Speicherung für Quiz '\(quiz.name)' mit \(quiz.teams?.count ?? 0) Teams und \(quiz.rounds?.count ?? 0) Runden")

        // Quiz in Context einfügen
        modelContext.insert(quiz)

        // Alle Teams in Context einfügen
        if let teams = quiz.teams {
            for team in teams {
                modelContext.insert(team)
            }
        }

        // Alle Runden in Context einfügen
        if let rounds = quiz.rounds {
            for round in rounds {
                modelContext.insert(round)
            }
        }

        do {
            try modelContext.save()
            logger.info("Quiz '\(quiz.name)' erfolgreich gespeichert")
        } catch {
            logger.error("Fehler beim Speichern des Quiz '\(quiz.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Löscht ein Quiz aus der Datenbank
    /// - Parameter quiz: Das zu löschende Quiz
    /// - Throws: ServiceError wenn das Löschen fehlschlägt
    func deleteQuiz(_ quiz: Quiz) throws {
        let quizName = quiz.name
        modelContext.delete(quiz)

        do {
            try modelContext.save()
            logger.info("Quiz '\(quizName)' erfolgreich gelöscht")
        } catch {
            logger.error("Fehler beim Löschen des Quiz '\(quizName)': \(error.localizedDescription)")
            throw ServiceError.deleteFailed(underlying: error)
        }
    }

    // MARK: - Quiz Status

    /// Startet ein Quiz (setzt isActive = true)
    /// - Parameter quiz: Das zu startende Quiz
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func startQuiz(_ quiz: Quiz) throws {
        quiz.isActive = true
        try saveContext()
        logger.info("Quiz '\(quiz.name)' gestartet")
    }

    /// Schließt ein Quiz ab (setzt isActive = false, isCompleted = true)
    /// - Parameter quiz: Das abzuschließende Quiz
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func completeQuiz(_ quiz: Quiz) throws {
        quiz.isActive = false
        quiz.isCompleted = true
        try saveContext()
        logger.info("Quiz '\(quiz.name)' abgeschlossen")
    }

    /// Bricht ein Quiz ab und setzt es zurück
    /// - Parameter quiz: Das abzubrechende Quiz
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func cancelQuiz(_ quiz: Quiz) throws {
        quiz.isActive = false
        quiz.isCompleted = false

        // Setze alle Runden auf nicht abgeschlossen zurück
        for round in quiz.safeRounds {
            round.isCompleted = false
        }

        try saveContext()
        logger.info("Quiz '\(quiz.name)' abgebrochen")
    }

    // MARK: - Helper

    private func saveContext() throws {
        do {
            try modelContext.save()
        } catch {
            logger.error("Fehler beim Speichern des Contexts: \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }
}
