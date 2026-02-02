//
//  TeamService.swift
//  PubRanker
//
//  Service für Team-Management
//

import Foundation
import SwiftData
import os.log

private let logger = Logger(subsystem: "com.pubranker", category: "TeamService")

/// Service für Team-bezogene Operationen
/// Verantwortlich für: Teams erstellen, löschen, aktualisieren, Quiz-Zuordnungen
final class TeamService {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Team CRUD

    /// Erstellt ein neues Team und fügt es einem Quiz hinzu
    /// - Parameters:
    ///   - quiz: Das Quiz, dem das Team hinzugefügt wird
    ///   - name: Name des Teams
    ///   - color: Farbe des Teams (Hex)
    ///   - contactPerson: Kontaktperson
    ///   - email: E-Mail-Adresse
    ///   - isConfirmed: Ob das Team bestätigt ist
    ///   - imageData: Optionales Bild
    /// - Returns: Das erstellte Team
    /// - Throws: ServiceError wenn Validierung oder Speichern fehlschlägt
    func addTeam(
        to quiz: Quiz,
        name: String,
        color: String = "AppConstants.defaultTeamColor",
        contactPerson: String = "",
        email: String = "",
        isConfirmed: Bool = false,
        imageData: Data? = nil
    ) throws -> Team {
        // Validierung
        let sanitizedName = name.sanitizedName
        guard sanitizedName.isValidName else {
            throw ServiceError.validationFailed(field: "Name", reason: "Team-Name darf nicht leer sein")
        }

        let sanitizedEmail = email.sanitizedEmail
        guard sanitizedEmail.isValidEmail else {
            throw ServiceError.validationFailed(field: "E-Mail", reason: "Ungültiges E-Mail-Format")
        }

        let team = Team(name: sanitizedName, color: color)
        team.contactPerson = contactPerson.sanitizedName
        team.email = sanitizedEmail
        team.imageData = imageData
        team.setConfirmed(for: quiz, isConfirmed: isConfirmed)
        team.quizzes = [quiz]

        if quiz.teams == nil {
            quiz.teams = []
        }
        quiz.teams?.append(team)
        modelContext.insert(team)

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        do {
            try modelContext.save()
            logger.info("Team '\(sanitizedName)' zu Quiz '\(quiz.name)' hinzugefügt")
            return team
        } catch {
            logger.error("Fehler beim Hinzufügen des Teams '\(sanitizedName)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Erstellt ein temporäres Team ohne es zu speichern (für Wizard-Mode)
    /// - Parameters:
    ///   - quiz: Das Quiz, dem das Team hinzugefügt wird
    ///   - name: Name des Teams
    ///   - color: Farbe des Teams (Hex)
    ///   - contactPerson: Kontaktperson
    ///   - email: E-Mail-Adresse
    ///   - isConfirmed: Ob das Team bestätigt ist
    ///   - imageData: Optionales Bild
    func addTemporaryTeam(
        to quiz: Quiz,
        name: String,
        color: String = "AppConstants.defaultTeamColor",
        contactPerson: String = "",
        email: String = "",
        isConfirmed: Bool = false,
        imageData: Data? = nil
    ) {
        let team = Team(name: name, color: color)
        team.contactPerson = contactPerson
        team.email = email
        team.imageData = imageData
        team.setConfirmed(for: quiz, isConfirmed: isConfirmed)
        team.quizzes = [quiz]

        if quiz.teams == nil {
            quiz.teams = []
        }
        quiz.teams?.append(team)
    }

    /// Fügt ein existierendes Team einem Quiz hinzu
    /// - Parameters:
    ///   - team: Das existierende Team
    ///   - quiz: Das Quiz, dem das Team hinzugefügt werden soll
    /// - Throws: ServiceError.alreadyExists wenn Team bereits im Quiz, oder saveFailed bei Speicherfehler
    func addExistingTeam(_ team: Team, to quiz: Quiz) throws {
        // Prüfe ob Team bereits im Quiz ist
        if quiz.teams?.contains(where: { $0.id == team.id }) ?? false {
            throw ServiceError.alreadyExists(entityType: "Team", name: team.name)
        }

        // Füge Quiz zur Team's quizzes Liste hinzu
        if team.quizzes == nil {
            team.quizzes = []
        }
        if !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false) {
            team.quizzes?.append(quiz)
        }

        // Füge Team zum Quiz hinzu
        if quiz.teams == nil {
            quiz.teams = []
        }
        quiz.teams?.append(team)

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        do {
            try modelContext.save()
            logger.info("Bestehendes Team '\(team.name)' zu Quiz '\(quiz.name)' hinzugefügt")
        } catch {
            logger.error("Fehler beim Hinzufügen des bestehenden Teams '\(team.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Entfernt ein Team aus einem Quiz (löscht es NICHT aus der Datenbank)
    /// - Parameters:
    ///   - team: Das zu entfernende Team
    ///   - quiz: Das Quiz, aus dem das Team entfernt werden soll
    /// - Throws: ServiceError wenn das Speichern fehlschlägt
    func deleteTeam(_ team: Team, from quiz: Quiz) throws {
        let teamName = team.name

        // Team aus dem Quiz entfernen
        if let index = quiz.teams?.firstIndex(where: { $0.id == team.id }) {
            quiz.teams?.remove(at: index)
        }

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        // Quiz aus der Team's quizzes Liste entfernen
        team.quizzes?.removeAll(where: { $0.id == quiz.id })

        // Team NICHT aus dem Context löschen - es bleibt in der globalen Team-Liste
        // Das Team wird nur aus diesem Quiz entfernt

        do {
            try modelContext.save()
            logger.info("Team '\(teamName)' aus Quiz '\(quiz.name)' entfernt")
        } catch {
            logger.error("Fehler beim Entfernen des Teams '\(teamName)' aus Quiz: \(error.localizedDescription)")
            throw ServiceError.deleteFailed(underlying: error)
        }
    }

    /// Aktualisiert den Namen eines Teams
    /// - Parameters:
    ///   - team: Das zu aktualisierende Team
    ///   - newName: Der neue Name
    /// - Throws: ServiceError wenn Validierung oder Speichern fehlschlägt
    func updateTeamName(_ team: Team, newName: String) throws {
        let sanitizedName = newName.sanitizedName
        guard sanitizedName.isValidName else {
            throw ServiceError.validationFailed(field: "Name", reason: "Team-Name darf nicht leer sein")
        }

        let oldName = team.name
        team.name = sanitizedName

        do {
            try modelContext.save()
            logger.info("Team umbenannt: '\(oldName)' -> '\(sanitizedName)'")
        } catch {
            logger.error("Fehler beim Umbenennen des Teams '\(oldName)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }

    /// Aktualisiert die Details eines Teams
    /// - Parameters:
    ///   - team: Das zu aktualisierende Team
    ///   - contactPerson: Kontaktperson
    ///   - email: E-Mail-Adresse
    ///   - isConfirmed: Bestätigungsstatus
    ///   - quiz: Optional: Quiz für Quiz-spezifische Bestätigung
    /// - Throws: ServiceError wenn Validierung oder Speichern fehlschlägt
    func updateTeamDetails(
        _ team: Team,
        contactPerson: String,
        email: String,
        isConfirmed: Bool,
        forQuiz quiz: Quiz? = nil
    ) throws {
        // E-Mail validieren
        let sanitizedEmail = email.sanitizedEmail
        guard sanitizedEmail.isValidEmail else {
            throw ServiceError.validationFailed(field: "E-Mail", reason: "Ungültiges E-Mail-Format")
        }

        team.contactPerson = contactPerson.sanitizedName
        team.email = sanitizedEmail

        if let quiz = quiz {
            // Quiz-spezifische Bestätigung setzen
            team.setConfirmed(for: quiz, isConfirmed: isConfirmed)
        } else {
            // Fallback für alte Implementierung (Rückwärtskompatibilität)
            team.isConfirmed = isConfirmed
        }

        do {
            try modelContext.save()
            logger.info("Team-Details für '\(team.name)' aktualisiert")
        } catch {
            logger.error("Fehler beim Aktualisieren der Team-Details für '\(team.name)': \(error.localizedDescription)")
            throw ServiceError.saveFailed(underlying: error)
        }
    }
}
