//
//  AppConstants.swift
//  PubRanker
//
//  Zentralisierte App-Konstanten
//

import Foundation

/// Zentralisierte Konstanten für die App
enum AppConstants {

    // MARK: - App Store

    /// App Store ID für PubRanker
    static let appStoreId = "6754255330"

    /// App Store URL (Schweiz)
    static let appStoreURL = "https://apps.apple.com/ch/app/pubranker/id\(appStoreId)"

    /// App Store Review URL für macOS
    static var macAppStoreReviewURL: String {
        "macappstore://apps.apple.com/app/id\(appStoreId)?action=write-review"
    }

    /// App Store Review URL für iOS
    static var iOSAppStoreReviewURL: String {
        "https://apps.apple.com/app/id\(appStoreId)?action=write-review"
    }

    // MARK: - Feedback

    /// Support E-Mail-Adresse
    static let supportEmail = "ake_schmidi@me.com"

    // MARK: - Default Values

    /// Standard Team-Farbe (Apple Blue)
    static let defaultTeamColor = "#007AFF"

    /// Standard maximale Team-Anzahl
    static let defaultMaxTeams = 30

    // MARK: - Limits

    /// Maximale Anzahl Teams pro Quiz
    static let maxTeamsPerQuiz = 100

    /// Maximale Punktzahl pro Runde
    static let maxPointsPerRound = 1000

    // MARK: - Team Color Palette

    /// Verfügbare Team-Farben (Hex-Werte)
    static let teamColorPalette = [
        "#007AFF", // Apple Blue (Default)
        "#FF3B30", // Red
        "#34C759", // Green
        "#FF9500", // Orange
        "#5856D6", // Purple
        "#FF2D55", // Pink
        "#5AC8FA", // Light Blue
        "#FFCC00", // Yellow
        "#AF52DE", // Violet
        "#00C7BE", // Teal
        "#32ADE6", // Sky Blue
        "#FF6482"  // Coral
    ]

    /// Erweiterte Team-Farben für große Quizze
    static let extendedTeamColorPalette = teamColorPalette + [
        "#8E8E93", // Gray
        "#30B0C7", // Cyan
        "#AC8E68", // Brown
        "#A2845E"  // Tan
    ]
}
