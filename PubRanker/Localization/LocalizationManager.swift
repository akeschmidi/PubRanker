// swift-tools-version:5.9
import Foundation
import SwiftUI

/// Manager für Lokalisierung der App
/// Bietet einfachen Zugriff auf lokalisierte Strings
enum L10n {
    
    // MARK: - App Navigation
    enum Navigation {
        static let back = NSLocalizedString("navigation.back", comment: "Back button")
        static let done = NSLocalizedString("navigation.done", comment: "Done button")
        static let cancel = NSLocalizedString("navigation.cancel", comment: "Cancel button")
        static let save = NSLocalizedString("navigation.save", comment: "Save button")
        static let edit = NSLocalizedString("navigation.edit", comment: "Edit button")
        static let delete = NSLocalizedString("navigation.delete", comment: "Delete button")
        static let add = NSLocalizedString("navigation.add", comment: "Add button")
    }
    
    // MARK: - Quiz
    enum Quiz {
        static let title = NSLocalizedString("quiz.title", comment: "Quiz title")
        static let new = NSLocalizedString("quiz.new", comment: "New quiz")
        static let name = NSLocalizedString("quiz.name", comment: "Quiz name")
        static let location = NSLocalizedString("quiz.location", comment: "Quiz location")
        static let date = NSLocalizedString("quiz.date", comment: "Quiz date")
        static let teams = NSLocalizedString("quiz.teams", comment: "Teams")
        static let rounds = NSLocalizedString("quiz.rounds", comment: "Rounds")
        static let totalPoints = NSLocalizedString("quiz.totalPoints", comment: "Total points")
        
        enum Delete {
            static let confirm = NSLocalizedString("quiz.delete.confirm", comment: "Delete quiz confirmation")
            static let message = NSLocalizedString("quiz.delete.message", comment: "Delete quiz message")
        }
    }
    
    // MARK: - Team
    enum Team {
        static let title = NSLocalizedString("team.title", comment: "Team title")
        static let new = NSLocalizedString("team.new", comment: "New team")
        static let name = NSLocalizedString("team.name", comment: "Team name")
        static let color = NSLocalizedString("team.color", comment: "Team color")
        static let points = NSLocalizedString("team.points", comment: "Team points")
        static let rank = NSLocalizedString("team.rank", comment: "Team rank")
        static let wizard = NSLocalizedString("team.wizard", comment: "Team wizard")
        static let management = NSLocalizedString("team.management", comment: "Team management")
        
        enum Wizard {
            static let howMany = NSLocalizedString("team.wizard.howMany", comment: "How many teams")
            static let create = NSLocalizedString("team.wizard.create", comment: "Create teams")
        }
        
        enum Delete {
            static let confirm = NSLocalizedString("team.delete.confirm", comment: "Delete team confirmation")
            static func message(_ teamName: String) -> String {
                String(format: NSLocalizedString("team.delete.message", comment: "Delete team message"), teamName)
            }
        }
        
        static func count(_ count: Int) -> String {
            String(format: NSLocalizedString("team.count", comment: "Team count"), count)
        }
    }
    
    // MARK: - Round
    enum Round {
        static let title = NSLocalizedString("round.title", comment: "Round title")
        static let new = NSLocalizedString("round.new", comment: "New round")
        static let name = NSLocalizedString("round.name", comment: "Round name")
        static let maxPoints = NSLocalizedString("round.maxPoints", comment: "Max points")
        static let currentRound = NSLocalizedString("round.currentRound", comment: "Current round")
        static let wizard = NSLocalizedString("round.wizard", comment: "Round wizard")
        
        static func number(_ number: Int) -> String {
            String(format: NSLocalizedString("round.number", comment: "Round number"), number)
        }
        
        static func count(_ count: Int) -> String {
            String(format: NSLocalizedString("round.count", comment: "Round count"), count)
        }
        
        enum Wizard {
            static let howMany = NSLocalizedString("round.wizard.howMany", comment: "How many rounds")
            static let create = NSLocalizedString("round.wizard.create", comment: "Create rounds")
        }
        
        enum Delete {
            static let confirm = NSLocalizedString("round.delete.confirm", comment: "Delete round confirmation")
            static let message = NSLocalizedString("round.delete.message", comment: "Delete round message")
        }
        
        enum Status {
            static let active = NSLocalizedString("round.status.active", comment: "Active status")
            static let completed = NSLocalizedString("round.status.completed", comment: "Completed status")
            static let pending = NSLocalizedString("round.status.pending", comment: "Pending status")
        }
    }
    
    // MARK: - Leaderboard
    enum Leaderboard {
        static let title = NSLocalizedString("leaderboard.title", comment: "Leaderboard title")
        static let rank = NSLocalizedString("leaderboard.rank", comment: "Rank")
        static let team = NSLocalizedString("leaderboard.team", comment: "Team")
        static let points = NSLocalizedString("leaderboard.points", comment: "Points")
        static let winner = NSLocalizedString("leaderboard.winner", comment: "Winner")
        static let podium = NSLocalizedString("leaderboard.podium", comment: "Podium")
        static let topThree = NSLocalizedString("leaderboard.topThree", comment: "Top three")
        static let noTeams = NSLocalizedString("leaderboard.noTeams", comment: "No teams")
        static let noPoints = NSLocalizedString("leaderboard.noPoints", comment: "No points")
    }
    
    // MARK: - Score
    enum Score {
        static let title = NSLocalizedString("score.title", comment: "Score title")
        static let enter = NSLocalizedString("score.enter", comment: "Enter score")
        static let save = NSLocalizedString("score.save", comment: "Save score")
        static let saved = NSLocalizedString("score.saved", comment: "Saved")
        static let autoSave = NSLocalizedString("score.autoSave", comment: "Auto-save")
        static let autoSaveEnabled = NSLocalizedString("score.autoSave.enabled", comment: "Auto-save enabled")
        static let total = NSLocalizedString("score.total", comment: "Total")
        static let perRound = NSLocalizedString("score.perRound", comment: "Per round")
    }
    
    // MARK: - Alert
    enum Alert {
        static let error = NSLocalizedString("alert.error", comment: "Error")
        static let success = NSLocalizedString("alert.success", comment: "Success")
        static let warning = NSLocalizedString("alert.warning", comment: "Warning")
        static let info = NSLocalizedString("alert.info", comment: "Info")
        static let ok = NSLocalizedString("alert.ok", comment: "OK")
        static let yes = NSLocalizedString("alert.yes", comment: "Yes")
        static let no = NSLocalizedString("alert.no", comment: "No")
    }
    
    // MARK: - Error
    enum Error {
        static let generic = NSLocalizedString("error.generic", comment: "Generic error")
        static let saveFailed = NSLocalizedString("error.saveFailed", comment: "Save failed")
        static let loadFailed = NSLocalizedString("error.loadFailed", comment: "Load failed")
        static let deleteFailed = NSLocalizedString("error.deleteFailed", comment: "Delete failed")
        static let invalidInput = NSLocalizedString("error.invalidInput", comment: "Invalid input")
        static let nameRequired = NSLocalizedString("error.nameRequired", comment: "Name required")
        static let pointsRequired = NSLocalizedString("error.pointsRequired", comment: "Points required")
    }
    
    // MARK: - Success
    enum Success {
        static let saved = NSLocalizedString("success.saved", comment: "Successfully saved")
        static let deleted = NSLocalizedString("success.deleted", comment: "Successfully deleted")
        static let created = NSLocalizedString("success.created", comment: "Successfully created")
    }
    
    // MARK: - Common
    enum Common {
        static let name = NSLocalizedString("common.name", comment: "Name")
        static let description = NSLocalizedString("common.description", comment: "Description")
        static let date = NSLocalizedString("common.date", comment: "Date")
        static let time = NSLocalizedString("common.time", comment: "Time")
        static let location = NSLocalizedString("common.location", comment: "Location")
        static let search = NSLocalizedString("common.search", comment: "Search")
        static let filter = NSLocalizedString("common.filter", comment: "Filter")
        static let sort = NSLocalizedString("common.sort", comment: "Sort")
        static let settings = NSLocalizedString("common.settings", comment: "Settings")
        static let about = NSLocalizedString("common.about", comment: "About")
        static let help = NSLocalizedString("common.help", comment: "Help")
        static let close = NSLocalizedString("common.close", comment: "Close")
    }
    
    // MARK: - Placeholder
    enum Placeholder {
        static let quizName = NSLocalizedString("placeholder.quizName", comment: "Quiz name placeholder")
        static let teamName = NSLocalizedString("placeholder.teamName", comment: "Team name placeholder")
        static let roundName = NSLocalizedString("placeholder.roundName", comment: "Round name placeholder")
        static let location = NSLocalizedString("placeholder.location", comment: "Location placeholder")
        static let points = NSLocalizedString("placeholder.points", comment: "Points placeholder")
    }
    
    // MARK: - Stats
    enum Stats {
        static let average = NSLocalizedString("stats.average", comment: "Average")
        static let highest = NSLocalizedString("stats.highest", comment: "Highest")
        static let lowest = NSLocalizedString("stats.lowest", comment: "Lowest")
        static let total = NSLocalizedString("stats.total", comment: "Total")
    }
    
    // MARK: - Empty States
    enum Empty {
        static let noQuizzes = NSLocalizedString("empty.noQuizzes", comment: "No quizzes")
        static let noQuizzesMessage = NSLocalizedString("empty.noQuizzes.message", comment: "No quizzes message")
        static let noTeams = NSLocalizedString("empty.noTeams", comment: "No teams")
        static let noTeamsMessage = NSLocalizedString("empty.noTeams.message", comment: "No teams message")
        static let noRounds = NSLocalizedString("empty.noRounds", comment: "No rounds")
        static let noRoundsMessage = NSLocalizedString("empty.noRounds.message", comment: "No rounds message")
        static let noScores = NSLocalizedString("empty.noScores", comment: "No scores")
        static let noScoresMessage = NSLocalizedString("empty.noScores.message", comment: "No scores message")
    }
}

// MARK: - SwiftUI Extension für einfachen Zugriff
extension LocalizedStringKey {
    /// Erstellt einen LocalizedStringKey mit dem gegebenen Key
    static func localized(_ key: String) -> LocalizedStringKey {
        LocalizedStringKey(key)
    }
}

// MARK: - String Extension
extension String {
    /// Lokalisiert einen String mit dem gegebenen Key
    func localized(comment: String = "") -> String {
        NSLocalizedString(self, comment: comment)
    }
}
