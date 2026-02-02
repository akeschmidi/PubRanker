//
//  ValidationHelper.swift
//  PubRanker
//
//  Zentralisierte Validierungsfunktionen für Eingaben
//

import Foundation

/// Validierungshelfer für Benutzereingaben
enum ValidationHelper {

    // MARK: - Email Validation

    /// Validiert eine E-Mail-Adresse
    /// - Parameter email: Die zu validierende E-Mail-Adresse
    /// - Returns: true wenn die E-Mail gültig ist oder leer
    static func isValidEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)

        // Leere E-Mail ist erlaubt (optional)
        if trimmed.isEmpty {
            return true
        }

        // RFC 5322 vereinfachter Regex für E-Mail-Validierung
        let emailRegex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        guard let regex = try? NSRegularExpression(pattern: emailRegex, options: .caseInsensitive) else {
            return false
        }

        let range = NSRange(trimmed.startIndex..., in: trimmed)
        return regex.firstMatch(in: trimmed, options: [], range: range) != nil
    }

    /// Gibt eine bereinigte E-Mail-Adresse zurück
    /// - Parameter email: Die zu bereinigende E-Mail
    /// - Returns: Bereinigte E-Mail (lowercase, getrimmt)
    static func sanitizeEmail(_ email: String) -> String {
        return email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    // MARK: - Name Validation

    /// Validiert einen Namen (Team, Quiz, Runde)
    /// - Parameter name: Der zu validierende Name
    /// - Returns: true wenn der Name gültig ist (nicht leer/nur Whitespace)
    static func isValidName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return !trimmed.isEmpty
    }

    /// Gibt einen bereinigten Namen zurück
    /// - Parameter name: Der zu bereinigende Name
    /// - Returns: Bereinigter Name (getrimmt)
    static func sanitizeName(_ name: String) -> String {
        return name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - Score Validation

    /// Validiert einen Score-Wert
    /// - Parameters:
    ///   - score: Der zu validierende Score
    ///   - maxPoints: Optionales Maximum
    /// - Returns: true wenn der Score gültig ist
    static func isValidScore(_ score: Int, maxPoints: Int? = nil) -> Bool {
        if score < 0 {
            return false
        }

        if let max = maxPoints, score > max {
            return false
        }

        return true
    }

    /// Klemmt einen Score auf gültige Grenzen
    /// - Parameters:
    ///   - score: Der zu klemmende Score
    ///   - maxPoints: Optionales Maximum
    /// - Returns: Geklemmter Score-Wert
    static func clampScore(_ score: Int, maxPoints: Int? = nil) -> Int {
        let minClamped = max(0, score)

        if let max = maxPoints {
            return min(minClamped, max)
        }

        return minClamped
    }
}

// MARK: - String Extensions

extension String {
    /// Prüft ob der String eine gültige E-Mail-Adresse ist
    var isValidEmail: Bool {
        ValidationHelper.isValidEmail(self)
    }

    /// Prüft ob der String ein gültiger Name ist (nicht leer)
    var isValidName: Bool {
        ValidationHelper.isValidName(self)
    }

    /// Gibt eine bereinigte Version des Strings als E-Mail zurück
    var sanitizedEmail: String {
        ValidationHelper.sanitizeEmail(self)
    }

    /// Gibt eine bereinigte Version des Strings als Name zurück
    var sanitizedName: String {
        ValidationHelper.sanitizeName(self)
    }
}
