//
//  QuizViewModel.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import Foundation
import SwiftData
import Observation
import os.log

@Observable
final class QuizViewModel {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PubRanker", category: "QuizViewModel")
    var modelContext: ModelContext?
    var selectedQuiz: Quiz?
    var searchText: String = ""
    var showingNewQuizSheet: Bool = false
    var showingTeamSheet: Bool = false
    var showingRoundSheet: Bool = false
    var isWizardMode: Bool = false
    var temporaryQuiz: Quiz?

    // MARK: - Services (Lazy Initialized)

    private var _quizService: QuizService?
    private var _teamService: TeamService?
    private var _roundService: RoundService?
    private var _scoreService: ScoreService?
    private var exportService: ExportService = ExportService()

    /// Lazy accessor für QuizService - erstellt Service bei Bedarf
    private var quizService: QuizService? {
        if _quizService == nil, let context = modelContext {
            _quizService = QuizService(modelContext: context)
        }
        return _quizService
    }

    /// Lazy accessor für TeamService - erstellt Service bei Bedarf
    private var teamService: TeamService? {
        if _teamService == nil, let context = modelContext {
            _teamService = TeamService(modelContext: context)
        }
        return _teamService
    }

    /// Lazy accessor für RoundService - erstellt Service bei Bedarf
    private var roundService: RoundService? {
        if _roundService == nil, let context = modelContext {
            _roundService = RoundService(modelContext: context)
        }
        return _roundService
    }

    /// Lazy accessor für ScoreService - erstellt Service bei Bedarf
    private var scoreService: ScoreService? {
        if _scoreService == nil, let context = modelContext {
            _scoreService = ScoreService(modelContext: context)
        }
        return _scoreService
    }

    init() {}

    func setContext(_ context: ModelContext) {
        self.modelContext = context

        // Services werden bei Bedarf lazy initialisiert
        // Hier setzen wir sie explizit zurück, falls der Context sich ändert
        self._quizService = QuizService(modelContext: context)
        self._teamService = TeamService(modelContext: context)
        self._roundService = RoundService(modelContext: context)
        self._scoreService = ScoreService(modelContext: context)
    }

    // MARK: - Quiz Management

    func createQuiz(name: String, venue: String) {
        guard let service = quizService else { return }

        do {
            let quiz = try service.createQuiz(name: name, venue: venue)
            selectedQuiz = quiz
        } catch {
            Self.logger.error("Fehler beim Erstellen des Quiz: \(error.localizedDescription)")
        }
    }

    /// Erstellt ein Quiz-Objekt ohne es in den Context einzufügen (für temporäre Verwendung im Wizard)
    func createTemporaryQuiz(name: String, venue: String, date: Date) -> Quiz {
        guard let service = quizService else {
            return Quiz(name: name, venue: venue, date: date)
        }
        return service.createTemporaryQuiz(name: name, venue: venue, date: date)
    }

    /// Speichert ein Quiz final mit allen Teams und Runden in den Context
    func saveQuizFinal(_ quiz: Quiz) {
        guard let service = quizService else {
            Self.logger.error("QuizViewModel.saveQuizFinal: quizService ist nil - modelContext nicht gesetzt!")
            return
        }

        do {
            try service.saveQuizFinal(quiz)
            Self.logger.info("Quiz erfolgreich gespeichert: \(quiz.name)")
            selectedQuiz = quiz
        } catch {
            Self.logger.error("Fehler beim Speichern des Quiz: \(error.localizedDescription)")
        }
    }

    func deleteQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }

        do {
            try service.deleteQuiz(quiz)
            if selectedQuiz?.id == quiz.id {
                selectedQuiz = nil
            }
        } catch {
            Self.logger.error("Fehler beim Löschen des Quiz: \(error.localizedDescription)")
        }
    }

    func startQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }
        do {
            try service.startQuiz(quiz)
        } catch {
            Self.logger.error("Fehler beim Starten des Quiz: \(error.localizedDescription)")
        }
    }

    func completeQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }
        do {
            try service.completeQuiz(quiz)
        } catch {
            Self.logger.error("Fehler beim Abschließen des Quiz: \(error.localizedDescription)")
        }
    }

    func cancelQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }
        do {
            try service.cancelQuiz(quiz)
        } catch {
            Self.logger.error("Fehler beim Abbrechen des Quiz: \(error.localizedDescription)")
        }
    }

    // MARK: - Team Management

    func addTeam(to quiz: Quiz, name: String, color: String = AppConstants.defaultTeamColor, contactPerson: String = "", email: String = "", isConfirmed: Bool = false, imageData: Data? = nil) {
        // Wenn wir im Wizard-Modus sind und das Quiz noch nicht gespeichert ist, verwende temporäre Methode
        if isWizardMode && temporaryQuiz?.id == quiz.id {
            addTemporaryTeam(to: quiz, name: name, color: color, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, imageData: imageData)
            return
        }

        guard let service = teamService else { return }
        do {
            _ = try service.addTeam(
                to: quiz,
                name: name,
                color: color,
                contactPerson: contactPerson,
                email: email,
                isConfirmed: isConfirmed,
                imageData: imageData
            )
        } catch {
            Self.logger.error("Fehler beim Hinzufügen des Teams: \(error.localizedDescription)")
        }
    }

    /// Fügt ein Team temporär zu einem Quiz hinzu (ohne Speichern) - für Wizard-Mode
    func addTemporaryTeam(to quiz: Quiz, name: String, color: String = AppConstants.defaultTeamColor, contactPerson: String = "", email: String = "", isConfirmed: Bool = false, imageData: Data? = nil) {
        guard let service = teamService else { return }
        service.addTemporaryTeam(
            to: quiz,
            name: name,
            color: color,
            contactPerson: contactPerson,
            email: email,
            isConfirmed: isConfirmed,
            imageData: imageData
        )
    }

    func addExistingTeam(_ team: Team, to quiz: Quiz) {
        guard let service = teamService else { return }
        do {
            try service.addExistingTeam(team, to: quiz)
        } catch {
            Self.logger.error("Fehler beim Hinzufügen des bestehenden Teams: \(error.localizedDescription)")
        }
    }

    func deleteTeam(_ team: Team, from quiz: Quiz) {
        guard let service = teamService else { return }
        do {
            try service.deleteTeam(team, from: quiz)
        } catch {
            Self.logger.error("Fehler beim Entfernen des Teams: \(error.localizedDescription)")
        }
    }

    func updateTeamName(_ team: Team, newName: String) {
        guard let service = teamService else { return }
        do {
            try service.updateTeamName(team, newName: newName)
        } catch {
            Self.logger.error("Fehler beim Aktualisieren des Team-Namens: \(error.localizedDescription)")
        }
    }

    func updateTeamDetails(_ team: Team, contactPerson: String, email: String, isConfirmed: Bool, forQuiz quiz: Quiz? = nil) {
        guard let service = teamService else { return }
        do {
            try service.updateTeamDetails(team, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, forQuiz: quiz)
        } catch {
            Self.logger.error("Fehler beim Aktualisieren der Team-Details: \(error.localizedDescription)")
        }
    }

    // MARK: - Round Management

    func addRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) {
        // Wenn wir im Wizard-Modus sind und das Quiz noch nicht gespeichert ist, verwende temporäre Methode
        if isWizardMode && temporaryQuiz?.id == quiz.id {
            addTemporaryRound(to: quiz, name: name, maxPoints: maxPoints)
            return
        }

        guard let service = roundService else { return }
        do {
            _ = try service.addRound(to: quiz, name: name, maxPoints: maxPoints)
        } catch {
            Self.logger.error("Fehler beim Hinzufügen der Runde: \(error.localizedDescription)")
        }
    }

    /// Fügt eine Runde temporär zu einem Quiz hinzu (ohne Speichern) - für Wizard-Mode
    func addTemporaryRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) {
        guard let service = roundService else { return }
        service.addTemporaryRound(to: quiz, name: name, maxPoints: maxPoints)
    }

    func deleteRound(_ round: Round, from quiz: Quiz) {
        guard let service = roundService else { return }
        do {
            try service.deleteRound(round, from: quiz)
        } catch {
            Self.logger.error("Fehler beim Löschen der Runde: \(error.localizedDescription)")
        }
    }

    func completeRound(_ round: Round) {
        guard let service = roundService else { return }
        do {
            try service.completeRound(round)
        } catch {
            Self.logger.error("Fehler beim Abschließen der Runde: \(error.localizedDescription)")
        }
    }

    func updateRoundName(_ round: Round, newName: String) {
        guard let service = roundService else { return }
        do {
            try service.updateRoundName(round, newName: newName)
        } catch {
            Self.logger.error("Fehler beim Aktualisieren des Runden-Namens: \(error.localizedDescription)")
        }
    }

    func updateRoundMaxPoints(_ round: Round, maxPoints: Int?) {
        guard let service = roundService else { return }
        do {
            try service.updateRoundMaxPoints(round, maxPoints: maxPoints)
        } catch {
            Self.logger.error("Fehler beim Aktualisieren der maximalen Punkte: \(error.localizedDescription)")
        }
    }

    // MARK: - Score Management

    func updateScore(for team: Team, in round: Round, points: Int) {
        guard let service = scoreService else { return }
        do {
            try service.updateScore(for: team, in: round, points: points)
        } catch {
            Self.logger.error("Fehler beim Aktualisieren des Scores: \(error.localizedDescription)")
        }
    }

    func clearScore(for team: Team, in round: Round) {
        guard let service = scoreService else { return }
        do {
            try service.clearScore(for: team, in: round)
        } catch {
            Self.logger.error("Fehler beim Löschen des Scores: \(error.localizedDescription)")
        }
    }

    func getTeamRank(for team: Team, in quiz: Quiz) -> Int {
        guard let service = scoreService else { return 1 }
        return service.getTeamRank(for: team, in: quiz)
    }

    // MARK: - Export Functions

    func exportQuizAsJSON(quiz: Quiz) -> String {
        return exportService.exportQuizAsJSON(quiz: quiz)
    }

    func exportQuizAsCSV(quiz: Quiz) -> String {
        return exportService.exportQuizAsCSV(quiz: quiz)
    }

    func saveQuizExport(quiz: Quiz, format: ExportFormat) -> URL? {
        return exportService.exportQuizToFile(quiz: quiz, format: format)
    }

    // MARK: - Helper Methods

    func saveContext() {
        guard let context = modelContext else { return }

        do {
            try context.save()
        } catch {
            Self.logger.error("Error saving context: \(error)")
        }
    }
}
