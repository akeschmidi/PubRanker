//
//  ExportService.swift
//  PubRanker
//
//  Service für Quiz Export (JSON/CSV)
//

import Foundation
import SwiftData

/// Service für Export-bezogene Operationen
/// Verantwortlich für: Quiz als JSON oder CSV exportieren
final class ExportService {

    // MARK: - Export Functions

    /// Exportiert ein Quiz als JSON-String
    /// - Parameter quiz: Das zu exportierende Quiz
    /// - Returns: JSON-String oder leeres JSON bei Fehler
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

    /// Exportiert ein Quiz als CSV-String
    /// - Parameter quiz: Das zu exportierende Quiz
    /// - Returns: CSV-String
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

        // Rounds
        csv += "\n\(NSLocalizedString("csv.rounds", comment: "Rounds"))\n"
        csv += "\(NSLocalizedString("csv.roundName", comment: "Round Name")),\(NSLocalizedString("csv.maxPoints", comment: "Max Points")),\(NSLocalizedString("csv.completed", comment: "Completed"))\n"
        for round in quiz.sortedRounds {
            csv += "\(round.name),\(round.maxPoints ?? 0),\(round.isCompleted ? NSLocalizedString("csv.yes", comment: "Yes") : NSLocalizedString("csv.no", comment: "No"))\n"
        }

        // Round Scores
        csv += "\n\(NSLocalizedString("csv.scoresPerRound", comment: "Scores per Round"))\n"
        var header = "\(NSLocalizedString("csv.team", comment: "Team"))"
        for round in quiz.sortedRounds {
            header += ",\(round.name)"
        }
        header += ",\(NSLocalizedString("csv.total", comment: "Total"))\n"
        csv += header

        for team in quiz.sortedTeamsByScore {
            var row = team.name
            for round in quiz.sortedRounds {
                let score = team.getScore(for: round) ?? 0
                row += ",\(score)"
            }
            row += ",\(team.totalScore)\n"
            csv += row
        }

        return csv
    }

    /// Exportiert ein Quiz in eine Datei
    /// - Parameters:
    ///   - quiz: Das zu exportierende Quiz
    ///   - format: Das Export-Format (JSON oder CSV)
    /// - Returns: URL zur erstellten Datei oder nil bei Fehler
    func exportQuizToFile(quiz: Quiz, format: ExportFormat) -> URL? {
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

// MARK: - Export Format

enum ExportFormat: String, CaseIterable {
    case json = "json"
    case csv = "csv"

    var fileExtension: String {
        return self.rawValue
    }

    var displayName: String {
        switch self {
        case .json: return "JSON"
        case .csv: return "CSV"
        }
    }
}

// MARK: - Export Data Models

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
    let maxPoints: Int?
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
