//
//  TeamService.swift
//  PubRanker
//
//  Service für Team-Management
//

import Foundation
import SwiftData

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
    /// - Returns: Das erstellte Team oder nil bei Fehler
    @discardableResult
    func addTeam(
        to quiz: Quiz,
        name: String,
        color: String = "#007AFF",
        contactPerson: String = "",
        email: String = "",
        isConfirmed: Bool = false,
        imageData: Data? = nil
    ) -> Team? {
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
        modelContext.insert(team)

        // Invalidiere Quiz-Cache
        quiz.invalidateScoreCache()

        do {
            try modelContext.save()
            return team
        } catch {
            print("Error adding team: \(error)")
            return nil
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
        color: String = "#007AFF",
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
    /// - Returns: true bei Erfolg, false wenn Team bereits im Quiz oder bei Fehler
    @discardableResult
    func addExistingTeam(_ team: Team, to quiz: Quiz) -> Bool {
        // Prüfe ob Team bereits im Quiz ist
        if quiz.teams?.contains(where: { $0.id == team.id }) ?? false {
            return false
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
            return true
        } catch {
            print("Error adding existing team: \(error)")
            return false
        }
    }

    /// Entfernt ein Team aus einem Quiz (löscht es NICHT aus der Datenbank)
    /// - Parameters:
    ///   - team: Das zu entfernende Team
    ///   - quiz: Das Quiz, aus dem das Team entfernt werden soll
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func deleteTeam(_ team: Team, from quiz: Quiz) -> Bool {
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
            return true
        } catch {
            print("Error deleting team from quiz: \(error)")
            return false
        }
    }

    /// Aktualisiert den Namen eines Teams
    /// - Parameters:
    ///   - team: Das zu aktualisierende Team
    ///   - newName: Der neue Name
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func updateTeamName(_ team: Team, newName: String) -> Bool {
        team.name = newName

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error updating team name: \(error)")
            return false
        }
    }

    /// Aktualisiert die Details eines Teams
    /// - Parameters:
    ///   - team: Das zu aktualisierende Team
    ///   - contactPerson: Kontaktperson
    ///   - email: E-Mail-Adresse
    ///   - isConfirmed: Bestätigungsstatus
    ///   - quiz: Optional: Quiz für Quiz-spezifische Bestätigung
    /// - Returns: true bei Erfolg, false bei Fehler
    @discardableResult
    func updateTeamDetails(
        _ team: Team,
        contactPerson: String,
        email: String,
        isConfirmed: Bool,
        forQuiz quiz: Quiz? = nil
    ) -> Bool {
        team.contactPerson = contactPerson
        team.email = email

        if let quiz = quiz {
            // Quiz-spezifische Bestätigung setzen
            team.setConfirmed(for: quiz, isConfirmed: isConfirmed)
        } else {
            // Fallback für alte Implementierung (Rückwärtskompatibilität)
            team.isConfirmed = isConfirmed
        }

        do {
            try modelContext.save()
            return true
        } catch {
            print("Error updating team details: \(error)")
            return false
        }
    }
}
