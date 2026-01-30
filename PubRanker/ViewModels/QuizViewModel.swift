//
//  QuizViewModel.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import Foundation
import SwiftData
import Observation

@Observable
final class QuizViewModel {
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

        if let quiz = service.createQuiz(name: name, venue: venue) {
            selectedQuiz = quiz
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
            print("❌ QuizViewModel.saveQuizFinal: quizService ist nil - modelContext nicht gesetzt!")
            return
        }

        if service.saveQuizFinal(quiz) {
            print("✅ Quiz erfolgreich gespeichert: \(quiz.name)")
            selectedQuiz = quiz
        } else {
            print("❌ Fehler beim Speichern des Quiz: \(quiz.name)")
        }
    }

    func deleteQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }

        if service.deleteQuiz(quiz) {
            if selectedQuiz?.id == quiz.id {
                selectedQuiz = nil
            }
        }
    }

    func startQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }
        service.startQuiz(quiz)
    }

    func completeQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }
        service.completeQuiz(quiz)
    }

    func cancelQuiz(_ quiz: Quiz) {
        guard let service = quizService else { return }
        service.cancelQuiz(quiz)
    }

    // MARK: - Team Management

    func addTeam(to quiz: Quiz, name: String, color: String = "#007AFF", contactPerson: String = "", email: String = "", isConfirmed: Bool = false, imageData: Data? = nil) {
        // Wenn wir im Wizard-Modus sind und das Quiz noch nicht gespeichert ist, verwende temporäre Methode
        if isWizardMode && temporaryQuiz?.id == quiz.id {
            addTemporaryTeam(to: quiz, name: name, color: color, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, imageData: imageData)
            return
        }

        guard let service = teamService else { return }
        service.addTeam(
            to: quiz,
            name: name,
            color: color,
            contactPerson: contactPerson,
            email: email,
            isConfirmed: isConfirmed,
            imageData: imageData
        )
    }

    /// Fügt ein Team temporär zu einem Quiz hinzu (ohne Speichern) - für Wizard-Mode
    func addTemporaryTeam(to quiz: Quiz, name: String, color: String = "#007AFF", contactPerson: String = "", email: String = "", isConfirmed: Bool = false, imageData: Data? = nil) {
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
        service.addExistingTeam(team, to: quiz)
    }

    func deleteTeam(_ team: Team, from quiz: Quiz) {
        guard let service = teamService else { return }
        service.deleteTeam(team, from: quiz)
    }

    func updateTeamName(_ team: Team, newName: String) {
        guard let service = teamService else { return }
        service.updateTeamName(team, newName: newName)
    }

    func updateTeamDetails(_ team: Team, contactPerson: String, email: String, isConfirmed: Bool, forQuiz quiz: Quiz? = nil) {
        guard let service = teamService else { return }
        service.updateTeamDetails(team, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, forQuiz: quiz)
    }

    // MARK: - Round Management

    func addRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) {
        // Wenn wir im Wizard-Modus sind und das Quiz noch nicht gespeichert ist, verwende temporäre Methode
        if isWizardMode && temporaryQuiz?.id == quiz.id {
            addTemporaryRound(to: quiz, name: name, maxPoints: maxPoints)
            return
        }

        guard let service = roundService else { return }
        service.addRound(to: quiz, name: name, maxPoints: maxPoints)
    }

    /// Fügt eine Runde temporär zu einem Quiz hinzu (ohne Speichern) - für Wizard-Mode
    func addTemporaryRound(to quiz: Quiz, name: String, maxPoints: Int? = nil) {
        guard let service = roundService else { return }
        service.addTemporaryRound(to: quiz, name: name, maxPoints: maxPoints)
    }

    func deleteRound(_ round: Round, from quiz: Quiz) {
        guard let service = roundService else { return }
        service.deleteRound(round, from: quiz)
    }

    func completeRound(_ round: Round) {
        guard let service = roundService else { return }
        service.completeRound(round)
    }

    func updateRoundName(_ round: Round, newName: String) {
        guard let service = roundService else { return }
        service.updateRoundName(round, newName: newName)
    }

    func updateRoundMaxPoints(_ round: Round, maxPoints: Int?) {
        guard let service = roundService else { return }
        service.updateRoundMaxPoints(round, maxPoints: maxPoints)
    }

    // MARK: - Score Management

    func updateScore(for team: Team, in round: Round, points: Int) {
        guard let service = scoreService else { return }
        service.updateScore(for: team, in: round, points: points)
    }

    func clearScore(for team: Team, in round: Round) {
        guard let service = scoreService else { return }
        service.clearScore(for: team, in: round)
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
            print("Error saving context: \(error)")
        }
    }
}
