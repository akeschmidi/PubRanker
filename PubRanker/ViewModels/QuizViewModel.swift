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
    
    init() {}
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Quiz Management
    
    func createQuiz(name: String, venue: String) {
        guard let context = modelContext else { return }
        
        let quiz = Quiz(name: name, venue: venue)
        context.insert(quiz)
        
        do {
            try context.save()
            selectedQuiz = quiz
        } catch {
            print("Error creating quiz: \(error)")
        }
    }
    
    /// Erstellt ein Quiz-Objekt ohne es in den Context einzufügen (für temporäre Verwendung im Wizard)
    func createTemporaryQuiz(name: String, venue: String, date: Date) -> Quiz {
        let quiz = Quiz(name: name, venue: venue, date: date)
        return quiz
    }
    
    /// Fügt ein Team temporär zu einem Quiz hinzu (ohne Speichern)
    func addTemporaryTeam(to quiz: Quiz, name: String, color: String = "#007AFF", contactPerson: String = "", email: String = "", isConfirmed: Bool = false, imageData: Data? = nil) {
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
    
    /// Fügt eine Runde temporär zu einem Quiz hinzu (ohne Speichern)
    func addTemporaryRound(to quiz: Quiz, name: String, maxPoints: Int = 10) {
        if quiz.rounds == nil {
            quiz.rounds = []
        }
        let orderIndex = quiz.rounds?.count ?? 0
        let round = Round(name: name, maxPoints: maxPoints, orderIndex: orderIndex)
        round.quiz = quiz
        quiz.rounds?.append(round)
    }
    
    /// Speichert ein Quiz final mit allen Teams und Runden in den Context
    func saveQuizFinal(_ quiz: Quiz) {
        guard let context = modelContext else { return }
        
        // Quiz in Context einfügen
        context.insert(quiz)
        
        // Alle Teams in Context einfügen
        if let teams = quiz.teams {
            for team in teams {
                context.insert(team)
            }
        }
        
        // Alle Runden in Context einfügen
        if let rounds = quiz.rounds {
            for round in rounds {
                context.insert(round)
            }
        }
        
        do {
            try context.save()
            selectedQuiz = quiz
            
            // Analytics: Quiz erstellt
// AnalyticsService.shared.trackEvent(.quizCreated)
// sendAnalyticsIfNeeded()
        } catch {
            print("Error saving quiz final: \(error)")
        }
    }
    
    func deleteQuiz(_ quiz: Quiz) {
        guard let context = modelContext else { return }
        
        context.delete(quiz)
        
        do {
            try context.save()
            if selectedQuiz?.id == quiz.id {
                selectedQuiz = nil
            }
        } catch {
            print("Error deleting quiz: \(error)")
        }
    }
    
    func startQuiz(_ quiz: Quiz) {
        quiz.isActive = true
        saveContext()
        
        // Analytics: Quiz gestartet
// AnalyticsService.shared.trackEvent(.quizStarted)
    }
    
    func completeQuiz(_ quiz: Quiz) {
        quiz.isActive = false
        quiz.isCompleted = true
        saveContext()
        
        // Analytics: Quiz abgeschlossen
// AnalyticsService.shared.trackEvent(.quizCompleted)
// sendAnalyticsIfNeeded()
    }
    
    func cancelQuiz(_ quiz: Quiz) {
        quiz.isActive = false
        quiz.isCompleted = false
        // Setze alle Runden auf nicht abgeschlossen zurück
        for round in quiz.safeRounds {
            round.isCompleted = false
        }
        saveContext()
    }
    
    // MARK: - Team Management
    
    func addTeam(to quiz: Quiz, name: String, color: String = "#007AFF", contactPerson: String = "", email: String = "", isConfirmed: Bool = false, imageData: Data? = nil) {
        // Wenn wir im Wizard-Modus sind und das Quiz noch nicht gespeichert ist, verwende temporäre Methode
        if isWizardMode && temporaryQuiz?.id == quiz.id {
            addTemporaryTeam(to: quiz, name: name, color: color, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, imageData: imageData)
            return
        }
        
        guard let context = modelContext else { return }

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
        context.insert(team)

        saveContext()
        
        // Analytics: Team erstellt
// AnalyticsService.shared.trackEvent(.teamCreated)
    }
    
    func addExistingTeam(_ team: Team, to quiz: Quiz) {
        guard modelContext != nil else { return }
        
        // Prüfe ob Team bereits im Quiz ist
        if quiz.teams?.contains(where: { $0.id == team.id }) ?? false {
            return
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
        
        saveContext()
    }
    
    func deleteTeam(_ team: Team, from quiz: Quiz) {
        guard modelContext != nil else { return }

        // Team aus dem Quiz entfernen
        if let index = quiz.teams?.firstIndex(where: { $0.id == team.id }) {
            quiz.teams?.remove(at: index)
        }

        // Quiz aus der Team's quizzes Liste entfernen
        team.quizzes?.removeAll(where: { $0.id == quiz.id })

        // Team NICHT aus dem Context löschen - es bleibt in der globalen Team-Liste
        // Das Team wird nur aus diesem Quiz entfernt

        saveContext()
    }
    
    func updateTeamName(_ team: Team, newName: String) {
        team.name = newName
        saveContext()
    }
    
    func updateTeamDetails(_ team: Team, contactPerson: String, email: String, isConfirmed: Bool, forQuiz quiz: Quiz? = nil) {
        team.contactPerson = contactPerson
        team.email = email
        if let quiz = quiz {
            // Quiz-spezifische Bestätigung setzen
            team.setConfirmed(for: quiz, isConfirmed: isConfirmed)
        } else {
            // Fallback für alte Implementierung (Rückwärtskompatibilität)
            team.isConfirmed = isConfirmed
        }
        saveContext()
    }
    
    // MARK: - Round Management
    
    func addRound(to quiz: Quiz, name: String, maxPoints: Int = 10) {
        // Wenn wir im Wizard-Modus sind und das Quiz noch nicht gespeichert ist, verwende temporäre Methode
        if isWizardMode && temporaryQuiz?.id == quiz.id {
            addTemporaryRound(to: quiz, name: name, maxPoints: maxPoints)
            return
        }
        
        guard let context = modelContext else { return }
        
        if quiz.rounds == nil {
            quiz.rounds = []
        }
        let orderIndex = quiz.rounds?.count ?? 0
        let round = Round(name: name, maxPoints: maxPoints, orderIndex: orderIndex)
        round.quiz = quiz
        quiz.rounds?.append(round)
        context.insert(round)
        
        saveContext()
        
        // Analytics: Runde erstellt
// AnalyticsService.shared.trackEvent(.roundCreated)
    }
    
    func deleteRound(_ round: Round, from quiz: Quiz) {
        guard let context = modelContext else { return }
        
        if let index = quiz.rounds?.firstIndex(where: { $0.id == round.id }) {
            quiz.rounds?.remove(at: index)
        }
        context.delete(round)
        
        // Reorder remaining rounds
        for (index, remainingRound) in quiz.sortedRounds.enumerated() {
            remainingRound.orderIndex = index
        }
        
        saveContext()
    }
    
    func completeRound(_ round: Round) {
        round.isCompleted = true
        saveContext()
    }
    
    func updateRoundName(_ round: Round, newName: String) {
        round.name = newName
        saveContext()
    }
    
    func updateRoundMaxPoints(_ round: Round, maxPoints: Int) {
        round.maxPoints = maxPoints
        saveContext()
    }
    
    // MARK: - Score Management
    
    func updateScore(for team: Team, in round: Round, points: Int) {
        team.addScore(for: round, points: points)
        saveContext()
        
        // Analytics: Punkte eingegeben
// AnalyticsService.shared.trackEvent(.scoreEntered)
    }
    
    func clearScore(for team: Team, in round: Round) {
        team.roundScores.removeAll(where: { $0.roundId == round.id })
        team.calculateTotalScore()
        saveContext()
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
    
    // MARK: - Analytics
    
    /// Sendet aggregierte Statistiken an CloudKit (nur bei wichtigen Events)
    private func sendAnalyticsIfNeeded() {
        guard let context = modelContext else { return }
        
        // Query für Statistiken
        let quizDescriptor = FetchDescriptor<Quiz>()
        let teamDescriptor = FetchDescriptor<Team>()
        
        do {
            let quizzes = try context.fetch(quizDescriptor)
            let teams = try context.fetch(teamDescriptor)
            
            let totalQuizzes = quizzes.count
            let totalTeams = teams.count
            let totalRounds = quizzes.reduce(0) { $0 + $1.safeRounds.count }
            let totalPoints = quizzes.reduce(into: 0) { total, quiz in
                total += quiz.safeTeams.reduce(0) { $0 + $1.getTotalScore(for: quiz) }
            }
            
            // Sende anonymisierte Statistiken
            // AnalyticsService.shared.sendAnalytics(
            //     totalQuizzes: totalQuizzes,
            //     totalTeams: totalTeams,
            //     totalRounds: totalRounds,
            //     totalPoints: totalPoints
            // )
        } catch {
            print("Error fetching analytics data: \(error)")
        }
    }
    
    func getTeamRank(for team: Team, in quiz: Quiz) -> Int {
        return quiz.getTeamRank(for: team)
    }
    
    // MARK: - Export Functions
    
    func exportQuizAsJSON(quiz: Quiz) -> String {
        let exportData = QuizExportData(from: quiz)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        if let jsonData = try? encoder.encode(exportData),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            return jsonString
        }
        return "{}"
    }
    
    func exportQuizAsCSV(quiz: Quiz) -> String {
        var csv = "Quiz: \(quiz.name)\n"
        csv += "\(NSLocalizedString("csv.venue", comment: "Venue")): \(quiz.venue)\n"
        csv += "\(NSLocalizedString("csv.date", comment: "Date")): \(quiz.date.formatted(date: .long, time: .shortened))\n"
        csv += "\(NSLocalizedString("csv.completed", comment: "Completed")): \(quiz.isCompleted ? NSLocalizedString("csv.yes", comment: "Yes") : NSLocalizedString("csv.no", comment: "No"))\n\n"
        
        // Teams Ranking
        csv += "\(NSLocalizedString("csv.finalRanking", comment: "Final Ranking"))\n"
        csv += "\(NSLocalizedString("csv.rank", comment: "Rank")),\(NSLocalizedString("csv.team", comment: "Team")),\(NSLocalizedString("csv.totalScore", comment: "Total Score")),\(NSLocalizedString("csv.color", comment: "Color"))\n"
        for (index, team) in quiz.sortedTeamsByScore.enumerated() {
            csv += "\(index + 1),\(team.name),\(team.totalScore),\(team.color)\n"
        }
        
        csv += "\n\n\(NSLocalizedString("csv.detailedScores", comment: "Detailed Scores"))\n"
        csv += "\(NSLocalizedString("csv.team", comment: "Team"))," + quiz.sortedRounds.map { $0.name }.joined(separator: ",") + ",\(NSLocalizedString("csv.total", comment: "Total"))\n"
        
        for team in quiz.sortedTeamsByScore {
            var row = team.name
            for round in quiz.sortedRounds {
                if let score = team.getScore(for: round) {
                    row += ",\(score)"
                } else {
                    row += ",-"
                }
            }
            row += ",\(team.getTotalScore(for: quiz))\n"
            csv += row
        }
        
        return csv
    }
    
    func saveQuizExport(quiz: Quiz, format: ExportFormat) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmm"
        let dateString = dateFormatter.string(from: Date())
        
        let fileName = "\(quiz.name.replacingOccurrences(of: " ", with: "_"))_\(dateString).\(format.fileExtension)"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        let content: String
        switch format {
        case .json:
            content = exportQuizAsJSON(quiz: quiz)
        case .csv:
            content = exportQuizAsCSV(quiz: quiz)
        }
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Error saving export: \(error)")
            return nil
        }
    }
}

// MARK: - Export Models

enum ExportFormat {
    case json
    case csv
    
    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        }
    }
    
    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        }
    }
}

struct QuizExportData: Codable {
    let id: String
    let name: String
    let venue: String
    let date: Date
    let isActive: Bool
    let isCompleted: Bool
    let createdAt: Date
    let teams: [TeamExportData]
    let rounds: [RoundExportData]
    
    init(from quiz: Quiz) {
        self.id = quiz.id.uuidString
        self.name = quiz.name
        self.venue = quiz.venue
        self.date = quiz.date
        self.isActive = quiz.isActive
        self.isCompleted = quiz.isCompleted
        self.createdAt = quiz.createdAt
        self.teams = quiz.sortedTeamsByScore.map { TeamExportData(from: $0) }
        self.rounds = quiz.sortedRounds.map { RoundExportData(from: $0) }
    }
}

struct TeamExportData: Codable {
    let id: String
    let name: String
    let color: String
    let totalScore: Int
    let roundScores: [RoundScoreExportData]
    
    init(from team: Team) {
        self.id = team.id.uuidString
        self.name = team.name
        self.color = team.color
        self.totalScore = team.totalScore
        self.roundScores = team.roundScores.map { RoundScoreExportData(from: $0) }
    }
}

struct RoundExportData: Codable {
    let id: String
    let name: String
    let maxPoints: Int
    let orderIndex: Int
    let isCompleted: Bool
    
    init(from round: Round) {
        self.id = round.id.uuidString
        self.name = round.name
        self.maxPoints = round.maxPoints
        self.orderIndex = round.orderIndex
        self.isCompleted = round.isCompleted
    }
}

struct RoundScoreExportData: Codable {
    let roundId: String
    let roundName: String
    let points: Int
    
    init(from roundScore: RoundScore) {
        self.roundId = roundScore.roundId.uuidString
        self.roundName = roundScore.roundName
        self.points = roundScore.points
    }
}

