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
        static let appTitle = NSLocalizedString("quiz.appTitle", comment: "App title")
        static let newQuiz = NSLocalizedString("quiz.newQuiz", comment: "New quiz button")
        static let details = NSLocalizedString("quiz.details", comment: "Quiz details")
        static let namePlaceholder = NSLocalizedString("quiz.name.placeholder", comment: "Quiz name placeholder")
        static let venue = NSLocalizedString("quiz.venue", comment: "Venue")
        static let venuePlaceholder = NSLocalizedString("quiz.venue.placeholder", comment: "Venue placeholder")
        static let dateTime = NSLocalizedString("quiz.dateTime", comment: "Date and time")
        static let maxPoints = NSLocalizedString("quiz.maxPoints", comment: "Max points")
        static let noAvailableTeams = NSLocalizedString("quiz.noAvailableTeams", comment: "No available teams")
        static func noAvailableTeamsDescription() -> String {
            NSLocalizedString("quiz.noAvailableTeams.description", comment: "All teams assigned")
        }
        static let searchTeams = NSLocalizedString("quiz.searchTeams", comment: "Search teams")
        static func addCount(_ count: Int) -> String {
            String(format: NSLocalizedString("quiz.addCount", comment: "Add count"), count)
        }
        static let editTitle = NSLocalizedString("quiz.edit.title", comment: "Edit quiz")
        static let createTitle = NSLocalizedString("quiz.create.title", comment: "Create quiz")
        static let createDescription = NSLocalizedString("quiz.create.description", comment: "Start with basic info")
        static let addTeamsTitle = NSLocalizedString("quiz.addTeams.title", comment: "Add teams")
        static let addTeamsDescription = NSLocalizedString("quiz.addTeams.description", comment: "Add participating teams")
        static let noTeamsYet = NSLocalizedString("quiz.noTeamsYet", comment: "No teams added yet")
        static let noTeamsYetDescription = NSLocalizedString("quiz.noTeamsYet.description", comment: "Add teams individually or create multiple")
        static let multipleTeams = NSLocalizedString("quiz.multipleTeams", comment: "Multiple teams")
        static let singleTeam = NSLocalizedString("quiz.singleTeam", comment: "Single team")
        static func selectFromExisting(_ count: Int) -> String {
            String(format: NSLocalizedString("quiz.selectFromExisting", comment: "Select from existing"), count)
        }
        static let defineRounds = NSLocalizedString("quiz.defineRounds", comment: "Define rounds")
        static let defineRoundsDescription = NSLocalizedString("quiz.defineRounds.description", comment: "Create rounds for your quiz")
        static let noRoundsYet = NSLocalizedString("quiz.noRoundsYet", comment: "No rounds added yet")
        static let noRoundsYetDescription = NSLocalizedString("quiz.noRoundsYet.description", comment: "Add rounds individually or create multiple")
        static let multipleRounds = NSLocalizedString("quiz.multipleRounds", comment: "Multiple rounds")
        static let singleRound = NSLocalizedString("quiz.singleRound", comment: "Single round")
        static func roundPoints(_ points: Int) -> String {
            String(format: NSLocalizedString("quiz.roundPoints", comment: "Round points"), points)
        }
        
        enum Delete {
            static let confirm = NSLocalizedString("quiz.delete.confirm", comment: "Delete quiz confirmation")
            static let message = NSLocalizedString("quiz.delete.message", comment: "Delete quiz message")
            static func confirmMessage(_ name: String) -> String {
                String(format: NSLocalizedString("quiz.delete.confirmMessage", comment: "Delete quiz confirm message"), name)
            }
        }
        
        enum Status {
            static let live = NSLocalizedString("quiz.status.live", comment: "Live status")
            static let finished = NSLocalizedString("quiz.status.finished", comment: "Finished status")
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
        static let addTeam = NSLocalizedString("team.addTeam", comment: "Add team")
        static let information = NSLocalizedString("team.information", comment: "Team information")
        static let icon = NSLocalizedString("team.icon", comment: "Team icon")
        static let statistics = NSLocalizedString("team.statistics", comment: "Team statistics")
        static let allQuizzesOverview = NSLocalizedString("team.allQuizzesOverview", comment: "Overview of all quizzes")
        static let coreStatistics = NSLocalizedString("team.coreStatistics", comment: "Core statistics")
        static let performanceOverview = NSLocalizedString("team.performanceOverview", comment: "Performance overview")
        static let podiumRate = NSLocalizedString("team.podiumRate", comment: "Podium rate")
        static let bestPlacement = NSLocalizedString("team.bestPlacement", comment: "Best placement")
        static let worstPlacement = NSLocalizedString("team.worstPlacement", comment: "Worst placement")
        static let quizHistory = NSLocalizedString("team.quizHistory", comment: "Quiz history")
        static let finishQuizToSeeStats = NSLocalizedString("team.finishQuizToSeeStats", comment: "Finish quizzes to see stats")
        static func wins(_ count: Int) -> String {
            String(format: NSLocalizedString("team.wins", comment: "Wins count"), count)
        }
        static func quizzes(_ count: Int) -> String {
            String(format: NSLocalizedString("team.quizzes", comment: "Quizzes count"), count)
        }
        
        enum Wizard {
            static let howMany = NSLocalizedString("team.wizard.howMany", comment: "How many teams")
            static let create = NSLocalizedString("team.wizard.create", comment: "Create teams")
            static let createTitle = NSLocalizedString("team.wizard.createTitle", comment: "Create teams title")
            static let createDescription = NSLocalizedString("team.wizard.createDescription", comment: "Create multiple teams at once")
            static let numberOfTeams = NSLocalizedString("team.wizard.numberOfTeams", comment: "Number of teams")
            static let teamNames = NSLocalizedString("team.wizard.teamNames", comment: "Team names")
            static let randomNames = NSLocalizedString("team.wizard.randomNames", comment: "Random names")
            static let newTeamsMethod = NSLocalizedString("team.wizard.newTeamsMethod", comment: "Create new teams")
            static let existingTeamsMethod = NSLocalizedString("team.wizard.existingTeamsMethod", comment: "Select from existing")
            static let noAvailableTeams = NSLocalizedString("team.wizard.noAvailableTeams", comment: "No available teams")
            static let noAvailableTeamsDescription = NSLocalizedString("team.wizard.noAvailableTeamsDescription", comment: "Create teams in Teams Manager first")
            static let addToQuiz = NSLocalizedString("team.wizard.addToQuiz", comment: "Add teams to quiz")
            static func createCount(_ count: Int) -> String {
                String(format: NSLocalizedString("team.wizard.createCount", comment: "Create count teams"), count)
            }
            static func andMore(_ count: Int) -> String {
                String(format: NSLocalizedString("team.wizard.andMore", comment: "And more teams"), count)
            }
        }
        
        enum Delete {
            static let confirm = NSLocalizedString("team.delete.confirm", comment: "Delete team confirmation")
            static func message(_ teamName: String) -> String {
                String(format: NSLocalizedString("team.delete.message", comment: "Delete team message"), teamName)
            }
            static func removeFromQuiz(_ teamName: String) -> String {
                String(format: NSLocalizedString("team.delete.removeFromQuiz", comment: "Remove team from quiz"), teamName)
            }
        }
        
        static func count(_ count: Int) -> String {
            String(format: NSLocalizedString("team.count", comment: "Team count"), count)
        }
        
        static func teamsSection(_ count: Int) -> String {
            String(format: NSLocalizedString("team.teamsSection", comment: "Teams section"), count)
        }
        
        static func deleteConfirmMessage(_ name: String) -> String {
            String(format: NSLocalizedString("team.deleteConfirmMessage", comment: "Delete team confirm"), name)
        }
    }
    
    // MARK: - Round
    enum Round {
        static let title = NSLocalizedString("round.title", comment: "Round title")
        static let new = NSLocalizedString("round.new", comment: "New round")
        static let name = NSLocalizedString("round.name", comment: "Round name")
        static let maxPoints = NSLocalizedString("round.maxPoints", comment: "Max points")
        static let noMaxPoints = NSLocalizedString("round.noMaxPoints", comment: "No max points")
        static let noMaxPointsShort = NSLocalizedString("round.noMaxPointsShort", comment: "No max points short")
        static let unlimited = NSLocalizedString("round.unlimited", comment: "Unlimited")
        static let noMaxPointsSet = NSLocalizedString("round.noMaxPointsSet", comment: "No max points set")
        static let currentRound = NSLocalizedString("round.currentRound", comment: "Current round")
        static let wizard = NSLocalizedString("round.wizard", comment: "Round wizard")
        static let addRound = NSLocalizedString("round.addRound", comment: "Add round")
        static let editRounds = NSLocalizedString("round.editRounds", comment: "Edit rounds")
        static func pointsDisplay(_ points: Int) -> String {
            String(format: NSLocalizedString("round.pointsDisplay", comment: "Points display"), points)
        }
        static func teamsCompleted(_ completed: Int, _ total: Int) -> String {
            String(format: NSLocalizedString("round.teamsCompleted", comment: "Teams completed"), completed, total)
        }
        static func teamsOf(_ completed: Int, _ total: Int) -> String {
            String(format: NSLocalizedString("round.teamsOf", comment: "Teams of total"), completed, total)
        }
        static func andMore(_ count: Int) -> String {
            String(format: NSLocalizedString("round.andMore", comment: "And more"), count)
        }
        
        static func number(_ number: Int) -> String {
            String(format: NSLocalizedString("round.number", comment: "Round number"), number)
        }
        
        static func count(_ count: Int) -> String {
            String(format: NSLocalizedString("round.count", comment: "Round count"), count)
        }
        
        enum Wizard {
            static let howMany = NSLocalizedString("round.wizard.howMany", comment: "How many rounds")
            static let create = NSLocalizedString("round.wizard.create", comment: "Create rounds")
            static let numberOfRounds = NSLocalizedString("round.wizard.numberOfRounds", comment: "Number of rounds")
            static func createCount(_ count: Int) -> String {
                String(format: NSLocalizedString("round.wizard.createCount", comment: "Create count rounds"), count)
            }
            static func andMore(_ count: Int) -> String {
                String(format: NSLocalizedString("round.wizard.andMore", comment: "And more rounds"), count)
            }
        }
        
        enum Delete {
            static let confirm = NSLocalizedString("round.delete.confirm", comment: "Delete round confirmation")
            static let message = NSLocalizedString("round.delete.message", comment: "Delete round message")
            static func confirmMessage(_ name: String) -> String {
                String(format: NSLocalizedString("round.delete.confirmMessage", comment: "Delete round confirm message"), name)
            }
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
    
    // MARK: - Execution View
    enum Execution {
        static let liveQuiz = NSLocalizedString("execution.liveQuiz", comment: "Live Quiz")
        static let enterScores = NSLocalizedString("execution.enterScores", comment: "Enter scores")
        static let noActiveQuizzes = NSLocalizedString("execution.noActiveQuizzes", comment: "No active quizzes")
        static func noActiveQuizzesDescription() -> String {
            NSLocalizedString("execution.noActiveQuizzes.description", comment: "No active quizzes description")
        }
        static func activeQuizzesSection(_ count: Int) -> String {
            String(format: NSLocalizedString("execution.activeQuizzes.section", comment: "Active quizzes section"), count)
        }
        static let live = NSLocalizedString("execution.live", comment: "LIVE")
        static let roundCurrent = NSLocalizedString("execution.round.current", comment: "Current round")
        static let roundCompleted = NSLocalizedString("execution.round.completed", comment: "Completed round")
        static let roundsEdit = NSLocalizedString("execution.rounds.edit", comment: "Edit rounds")
        static let roundsEditHelp = NSLocalizedString("execution.rounds.edit.help", comment: "Edit rounds help")
        static let presentationEnd = NSLocalizedString("execution.presentation.end", comment: "End presentation")
        static let presentationStart = NSLocalizedString("execution.presentation.start", comment: "Start presentation")
        static let presentationHelp = NSLocalizedString("execution.presentation.help", comment: "Presentation help")
        static let cancelHelp = NSLocalizedString("execution.cancel.help", comment: "Cancel help")
        static let complete = NSLocalizedString("execution.complete", comment: "Complete")
        static let completeHelp = NSLocalizedString("execution.complete.help", comment: "Complete help")
        static let progress = NSLocalizedString("execution.progress", comment: "Progress")
        static func roundsProgress(_ completed: Int, _ total: Int) -> String {
            String(format: NSLocalizedString("execution.rounds.progress", comment: "Rounds progress"), completed, total)
        }
        static func roundPrevious(_ name: String) -> String {
            String(format: NSLocalizedString("execution.round.previous", comment: "Previous round"), name)
        }
        static func roundNext(_ name: String) -> String {
            String(format: NSLocalizedString("execution.round.next", comment: "Next round"), name)
        }
        static let noRoundSelected = NSLocalizedString("execution.noRound.selected", comment: "No round selected")
        static func noRoundDescription() -> String {
            NSLocalizedString("execution.noRound.description", comment: "No round description")
        }
        static let noTeams = NSLocalizedString("execution.noTeams", comment: "No teams")
        static func noTeamsDescription() -> String {
            NSLocalizedString("execution.noTeams.description", comment: "No teams description")
        }
        static func scoreSaved(_ score: Int) -> String {
            String(format: NSLocalizedString("execution.score.saved", comment: "Score saved"), score)
        }
        static let actions = NSLocalizedString("execution.actions", comment: "Actions")
        static let reset = NSLocalizedString("execution.reset", comment: "Reset")
        static let saveAll = NSLocalizedString("execution.saveAll", comment: "Save all")
        static let roundCompleteAndContinue = NSLocalizedString("execution.round.completeAndContinue", comment: "Complete and continue")
        static let roundCompleteLast = NSLocalizedString("execution.round.completeLast", comment: "Complete last round")
        static let leaderboardLive = NSLocalizedString("execution.leaderboard.live", comment: "Live leaderboard")
        
        enum Cancel {
            static let title = NSLocalizedString("execution.cancel.title", comment: "Cancel quiz title")
            static let returnToPlanning = NSLocalizedString("execution.cancel.returnToPlanning", comment: "Return to planning")
            static let message = NSLocalizedString("execution.cancel.message", comment: "Cancel message")
        }
        
        enum EditRounds {
            static let title = NSLocalizedString("execution.editRounds.title", comment: "Edit rounds title")
            static let rounds = NSLocalizedString("execution.editRounds.rounds", comment: "Rounds")
            static let selectRound = NSLocalizedString("execution.editRounds.selectRound", comment: "Select round")
            static func selectRoundDescription() -> String {
                NSLocalizedString("execution.editRounds.selectRound.description", comment: "Select round description")
            }
            static let editScores = NSLocalizedString("execution.editRounds.editScores", comment: "Edit scores")
            static let done = NSLocalizedString("execution.editRounds.done", comment: "Done")
            static let roundNamePlaceholder = NSLocalizedString("execution.editRounds.roundName.placeholder", comment: "Round name placeholder")
            static let maxPointsLabel = NSLocalizedString("execution.editRounds.maxPoints.label", comment: "Max points label")
            static let maxPointsPerTeam = NSLocalizedString("execution.editRounds.maxPoints.perTeam", comment: "Per team")
            static func maxPointsDisplay(_ points: Int) -> String {
                String(format: NSLocalizedString("execution.editRounds.maxPoints.display", comment: "Max points display"), points)
            }
            static let editSettings = NSLocalizedString("execution.editRounds.editSettings", comment: "Edit settings")
            static let editSettingsHelp = NSLocalizedString("execution.editRounds.editSettings.help", comment: "Edit settings help")
            static let completed = NSLocalizedString("execution.editRounds.completed", comment: "Completed")
            static let unsavedChanges = NSLocalizedString("execution.editRounds.unsavedChanges", comment: "Unsaved changes")
            static let warningMaxPoints = NSLocalizedString("execution.editRounds.warning.maxPoints", comment: "Warning max points")
            static func warningAffectedTeams(_ teams: String) -> String {
                String(format: NSLocalizedString("execution.editRounds.warning.affectedTeams", comment: "Warning affected teams"), teams)
            }
            static func warningLimit(_ points: Int) -> String {
                String(format: NSLocalizedString("execution.editRounds.warning.limit", comment: "Warning limit"), points)
            }
            static let roundComplete = NSLocalizedString("execution.editRounds.round.complete", comment: "Round complete")
            static let roundReopen = NSLocalizedString("execution.editRounds.round.reopen", comment: "Round reopen")
        }

        enum AddTeam {
            static let title = NSLocalizedString("execution.addTeam.title", comment: "Add team title")
            static let button = NSLocalizedString("execution.addTeam.button", comment: "Add team button")
            static let help = NSLocalizedString("execution.addTeam.help", comment: "Add team help")
            static let modeNew = NSLocalizedString("execution.addTeam.mode.new", comment: "New team mode")
            static let modeExisting = NSLocalizedString("execution.addTeam.mode.existing", comment: "Existing teams mode")
            static let createAndAdd = NSLocalizedString("execution.addTeam.createAndAdd", comment: "Create and add")
            static func addSelected(_ count: Int) -> String {
                String(format: NSLocalizedString("execution.addTeam.addSelected", comment: "Add selected teams"), count)
            }
            static let noAvailableTeams = NSLocalizedString("execution.addTeam.noAvailableTeams", comment: "No available teams")
            static let noAvailableTeamsDescription = NSLocalizedString("execution.addTeam.noAvailableTeams.description", comment: "No available teams description")
        }
    }
    
    // MARK: - About Sheet
    enum About {
        static let title = NSLocalizedString("about.title", comment: "About title")
        static let quizMasterHub = NSLocalizedString("about.quizMasterHub", comment: "QuizMaster Hub")
        static func version(_ version: String, _ build: String) -> String {
            String(format: NSLocalizedString("about.version", comment: "Version"), version, build)
        }
        static let description = NSLocalizedString("about.description", comment: "About description")
        
        enum Features {
            static let title = NSLocalizedString("about.features.title", comment: "Features title")
            static let teamManagement = NSLocalizedString("about.features.teamManagement", comment: "Team management")
            static let planning = NSLocalizedString("about.features.planning", comment: "Planning")
            static let liveScoring = NSLocalizedString("about.features.liveScoring", comment: "Live scoring")
            static let analysis = NSLocalizedString("about.features.analysis", comment: "Analysis")
            static let email = NSLocalizedString("about.features.email", comment: "Email")
        }
        
        enum Technical {
            static let title = NSLocalizedString("about.technical.title", comment: "Technical title")
            static let version = NSLocalizedString("about.technical.version", comment: "Version")
            static let bundleId = NSLocalizedString("about.technical.bundleId", comment: "Bundle ID")
            static let platform = NSLocalizedString("about.technical.platform", comment: "Platform")
            static let copyright = NSLocalizedString("about.technical.copyright", comment: "Copyright")
        }
        
        enum Feedback {
            static let rate = NSLocalizedString("about.feedback.rate", comment: "Rate and feedback")
            static let title = NSLocalizedString("about.feedback.title", comment: "Feedback title")
            static let message = NSLocalizedString("about.feedback.message", comment: "Feedback message")
            static let rateAppStore = NSLocalizedString("about.feedback.rateAppStore", comment: "Rate in App Store")
            static let missingFeatures = NSLocalizedString("about.feedback.missingFeatures", comment: "Missing features")
            static let send = NSLocalizedString("about.feedback.send", comment: "Send feedback")
            static let emailMessage = NSLocalizedString("about.feedback.email.message", comment: "Email message")
            static let emailOpen = NSLocalizedString("about.feedback.email.open", comment: "Open email")
            static let emailCopy = NSLocalizedString("about.feedback.email.copy", comment: "Copy email")
            static let emailCopied = NSLocalizedString("about.feedback.email.copied", comment: "Email copied")
            static let emailCopiedMessage = NSLocalizedString("about.feedback.email.copied.message", comment: "Email copied message")
        }
        
        enum AppStore {
            static let review = NSLocalizedString("about.appStore.review", comment: "App Store review")
            static let notAvailable = NSLocalizedString("about.appStore.notAvailable", comment: "App not available")
        }
    }
    
    // MARK: - Analysis View
    enum Analysis {
        static let title = NSLocalizedString("analysis.title", comment: "Analysis title")
        static let subtitle = NSLocalizedString("analysis.subtitle", comment: "Analysis subtitle")
        static let noQuizzes = NSLocalizedString("analysis.noQuizzes", comment: "No quizzes")
        static func noQuizzesDescription() -> String {
            NSLocalizedString("analysis.noQuizzes.description", comment: "No quizzes description")
        }
        static func activeQuizzesSection(_ count: Int) -> String {
            String(format: NSLocalizedString("analysis.activeQuizzes.section", comment: "Active quizzes section"), count)
        }
        static func completedQuizzesSection(_ count: Int) -> String {
            String(format: NSLocalizedString("analysis.completedQuizzes.section", comment: "Completed quizzes section"), count)
        }
        static func interimAfterRounds(_ completed: Int, _ total: Int) -> String {
            String(format: NSLocalizedString("analysis.interimAfterRounds", comment: "Interim after rounds"), completed, total)
        }
        static let exportResults = NSLocalizedString("analysis.exportResults", comment: "Export results")
        static let leaderboard = NSLocalizedString("analysis.leaderboard", comment: "Leaderboard")
        static let points = NSLocalizedString("analysis.points", comment: "Points")
        static let statistics = NSLocalizedString("analysis.statistics", comment: "Statistics")
        static let roundBreakdown = NSLocalizedString("analysis.roundBreakdown", comment: "Round breakdown")
        static func maxPoints(_ points: Int) -> String {
            String(format: NSLocalizedString("analysis.maxPoints", comment: "Max points"), points)
        }
        static let allQuizzes = NSLocalizedString("analysis.allQuizzes", comment: "All quizzes")
        static let sorting = NSLocalizedString("analysis.sorting", comment: "Sorting")
        static func noTeamStatsDescription() -> String {
            NSLocalizedString("analysis.noTeamStats.description", comment: "No team stats description")
        }
        static func teamsSection(_ count: Int) -> String {
            String(format: NSLocalizedString("analysis.teams.section", comment: "Teams section"), count)
        }
        static let coreStats = NSLocalizedString("analysis.coreStats", comment: "Core stats")
        static let performance = NSLocalizedString("analysis.performance", comment: "Performance")
        static let podiumRate = NSLocalizedString("analysis.podiumRate", comment: "Podium rate")
        static let bestRank = NSLocalizedString("analysis.bestRank", comment: "Best rank")
        static let worstRank = NSLocalizedString("analysis.worstRank", comment: "Worst rank")
        static let quizHistory = NSLocalizedString("analysis.quizHistory", comment: "Quiz history")
        static let overview = NSLocalizedString("analysis.overview", comment: "Overview")
        static let overviewDescription = NSLocalizedString("analysis.overview.description", comment: "Overview description")
        static let teamLevel = NSLocalizedString("analysis.teamLevel", comment: "Team level")
        static let maxScore = NSLocalizedString("analysis.maxScore", comment: "Max score")
        static let achievedScore = NSLocalizedString("analysis.achievedScore", comment: "Achieved score")
        static let totalLevel = NSLocalizedString("analysis.totalLevel", comment: "Total level")
        static let quizListing = NSLocalizedString("analysis.quizListing", comment: "Quiz listing")
    }
    
    // MARK: - Planning View
    enum Planning {
        static let title = NSLocalizedString("planning.title", comment: "Planning title")
        static let subtitle = NSLocalizedString("planning.subtitle", comment: "Planning subtitle")
        static let newQuiz = NSLocalizedString("planning.newQuiz", comment: "New quiz")
        static let newQuizHelp = NSLocalizedString("planning.newQuiz.help", comment: "New quiz help")
        static let noQuizzes = NSLocalizedString("planning.noQuizzes", comment: "No quizzes")
        static func noQuizzesDescription() -> String {
            NSLocalizedString("planning.noQuizzes.description", comment: "No quizzes description")
        }
        static func plannedQuizzesSection(_ count: Int) -> String {
            String(format: NSLocalizedString("planning.plannedQuizzes.section", comment: "Planned quizzes section"), count)
        }
        static let deleteConfirm = NSLocalizedString("planning.delete.confirm", comment: "Delete confirm")
        static func deleteMessage(_ name: String) -> String {
            String(format: NSLocalizedString("planning.delete.message", comment: "Delete message"), name)
        }
        
        // Empty State
        static let emptyStateTitle = NSLocalizedString("planning.emptyState.title", comment: "Empty state title")
        static let emptyStateDescription = NSLocalizedString("planning.emptyState.description", comment: "Empty state description")
        static let emptyStateStart = NSLocalizedString("planning.emptyState.start", comment: "Empty state start")
        
        // Tabs
        static let tabOverview = NSLocalizedString("planning.tab.overview", comment: "Overview tab")
        static let tabTeams = NSLocalizedString("planning.tab.teams", comment: "Teams tab")
        static let tabRounds = NSLocalizedString("planning.tab.rounds", comment: "Rounds tab")
        static let viewSelection = NSLocalizedString("planning.view.selection", comment: "View selection")
        
        // Actions
        static let manage = NSLocalizedString("planning.manage", comment: "Manage")
        static let startQuiz = NSLocalizedString("planning.startQuiz", comment: "Start quiz")
        static let editHelp = NSLocalizedString("planning.edit.help", comment: "Edit quiz help")
        static let deleteHelp = NSLocalizedString("planning.delete.help", comment: "Delete quiz help")
        
        // Overview
        static let teamsTitle = NSLocalizedString("planning.teams.title", comment: "Teams")
        static let roundsTitle = NSLocalizedString("planning.rounds.title", comment: "Rounds")
        static let teamsReady = NSLocalizedString("planning.teams.ready", comment: "Teams ready")
        static let teamsMissing = NSLocalizedString("planning.teams.missing", comment: "Teams missing")
        static let roundsReady = NSLocalizedString("planning.rounds.ready", comment: "Rounds ready")
        static let roundsMissing = NSLocalizedString("planning.rounds.missing", comment: "Rounds missing")
        static let readyToStart = NSLocalizedString("planning.ready.toStart", comment: "Ready to start")
        static let notReady = NSLocalizedString("planning.not.ready", comment: "Not ready")
        static func teamsWithCount(_ count: Int) -> String {
            String(format: NSLocalizedString("planning.teams.withCount", comment: "Teams with count"), count)
        }
        static func roundsWithCount(_ count: Int) -> String {
            String(format: NSLocalizedString("planning.rounds.withCount", comment: "Rounds with count"), count)
        }
        static func roundShort(_ number: Int) -> String {
            String(format: NSLocalizedString("planning.round.short", comment: "Round short"), number)
        }
        static func pointsShort(_ points: Int) -> String {
            String(format: NSLocalizedString("planning.points.short", comment: "Points short"), points)
        }
    }
    
    // MARK: - Common UI
    enum CommonUI {
        static let edit = NSLocalizedString("common.edit", comment: "Edit")
        static let delete = NSLocalizedString("common.delete", comment: "Delete")
        static let remove = NSLocalizedString("common.remove", comment: "Remove")
        static let add = NSLocalizedString("common.add", comment: "Add")
        static let create = NSLocalizedString("common.create", comment: "Create")
        static let done = NSLocalizedString("common.done", comment: "Done")
        static let manage = NSLocalizedString("common.manage", comment: "Manage")
        static let sorting = NSLocalizedString("common.sorting", comment: "Sorting")
        static let preview = NSLocalizedString("common.preview", comment: "Preview")
        static let method = NSLocalizedString("common.method", comment: "Method")
        static let active = NSLocalizedString("common.active", comment: "Active")
        static let preparation = NSLocalizedString("common.preparation", comment: "Preparation")
        static let selectImage = NSLocalizedString("common.selectImage", comment: "Select image")
        static let removeImage = NSLocalizedString("common.removeImage", comment: "Remove image")
        static let selectColor = NSLocalizedString("common.selectColor", comment: "Select color")
        static let selectTeamIcon = NSLocalizedString("common.selectTeamIcon", comment: "Select team icon")
        static let contactPerson = NSLocalizedString("common.contactPerson", comment: "Contact person")
        static let testData = NSLocalizedString("common.testData", comment: "Create test data")
        static let live = NSLocalizedString("common.live", comment: "Live")
        static let liveRunning = NSLocalizedString("common.liveRunning", comment: "Live - running")
        static let interimResult = NSLocalizedString("common.interimResult", comment: "Interim result")
        static let json = NSLocalizedString("common.json", comment: "JSON")
        static let csv = NSLocalizedString("common.csv", comment: "CSV")
        static let winner = NSLocalizedString("common.winner", comment: "Winner")
        static let visualizations = NSLocalizedString("common.visualizations", comment: "Visualizations")
        static let pointDistribution = NSLocalizedString("common.pointDistribution", comment: "Point distribution")
        static let performanceOverRounds = NSLocalizedString("common.performanceOverRounds", comment: "Performance over rounds")
        static let legend = NSLocalizedString("common.legend", comment: "Legend")
        static let showsTop5 = NSLocalizedString("common.showsTop5", comment: "Shows top 5 teams")
        static let pointDistributionPerRound = NSLocalizedString("common.pointDistributionPerRound", comment: "Point distribution per round")
        static let average = NSLocalizedString("common.average", comment: "Average")
        static let maximum = NSLocalizedString("common.maximum", comment: "Maximum")
        static let topThreeRanks = NSLocalizedString("common.topThreeRanks", comment: "Top 3 ranks")
        static let designSystem = NSLocalizedString("common.designSystem", comment: "Design System")
        static func roundNumber(_ number: Int) -> String {
            String(format: NSLocalizedString("common.roundNumber", comment: "Round number"), number)
        }
        static func teamNumber(_ number: Int) -> String {
            String(format: NSLocalizedString("common.teamNumber", comment: "Team number"), number)
        }
        static let round = NSLocalizedString("common.round", comment: "Round")
        static let roundName = NSLocalizedString("common.roundName", comment: "Round name")
        static let rounds = NSLocalizedString("common.rounds", comment: "Rounds")
        static let teams = NSLocalizedString("common.teams", comment: "Teams")
        static func teamsCount(_ count: Int) -> String {
            String(format: NSLocalizedString("common.teams.count", comment: "Teams count"), count)
        }
        static let currentRound = NSLocalizedString("common.currentRound", comment: "Current round")
        static func maxPoints(_ points: Int) -> String {
            String(format: NSLocalizedString("common.maxPoints", comment: "Max points"), points)
        }
        static func maxPointsPerTeam(_ points: Int) -> String {
            String(format: NSLocalizedString("common.maxPointsPerTeam", comment: "Max points per team"), points)
        }
        static let roundSetup = NSLocalizedString("common.roundSetup", comment: "Round setup")
        static let roundSetupDescription = NSLocalizedString("common.roundSetup.description", comment: "Round setup description")
        static let numberOfRounds = NSLocalizedString("common.numberOfRounds", comment: "Number of rounds")
        static let customNames = NSLocalizedString("common.customNames", comment: "Custom names")
        static func roundPreview(_ number: Int) -> String {
            String(format: NSLocalizedString("common.roundPreview", comment: "Round preview"), number)
        }
        static let teamSetup = NSLocalizedString("common.teamSetup", comment: "Team setup")
        static let teamSetupDescription = NSLocalizedString("common.teamSetup.description", comment: "Team setup description")
        static let numberOfTeams = NSLocalizedString("common.numberOfTeams", comment: "Number of teams")
        static let teamNames = NSLocalizedString("common.teamNames", comment: "Team names")
        static let noTeamsAvailable = NSLocalizedString("common.noTeamsAvailable", comment: "No teams available")
        static func noTeamsAvailableDescription() -> String {
            NSLocalizedString("common.noTeamsAvailable.description", comment: "No teams available description")
        }
        static let addTeams = NSLocalizedString("common.addTeams", comment: "Add teams")
        static let totalScore = NSLocalizedString("common.totalScore", comment: "Total score")
        static let additionalPlaces = NSLocalizedString("common.additionalPlaces", comment: "Additional places")
        static let maxPointsLabel = NSLocalizedString("common.maxPointsLabel", comment: "Max points label")
        static let points = NSLocalizedString("common.points", comment: "Points")
        static func created(_ date: String) -> String {
            String(format: NSLocalizedString("common.created", comment: "Created"), date)
        }
        static let quizAssignments = NSLocalizedString("common.quizAssignments", comment: "Quiz assignments")
        static let notAssigned = NSLocalizedString("common.notAssigned", comment: "Not assigned")
        static let planned = NSLocalizedString("common.planned", comment: "Planned")
        static let running = NSLocalizedString("common.running", comment: "Running")
        static let completed = NSLocalizedString("common.completed", comment: "Completed")
        static let confirmed = NSLocalizedString("common.confirmed", comment: "Confirmed")
        static let teamIcon = NSLocalizedString("common.teamIcon", comment: "Team icon")
        static let teamIconSelect = NSLocalizedString("common.teamIcon.select", comment: "Select team icon")
        static let color = NSLocalizedString("common.color", comment: "Color")
        static let colorSelect = NSLocalizedString("common.color.select", comment: "Select color")
        static let teamName = NSLocalizedString("common.teamName", comment: "Team name")
        static let contactInfo = NSLocalizedString("common.contactInfo", comment: "Contact info")
        static let teamInfo = NSLocalizedString("common.teamInfo", comment: "Team info")
        static let status = NSLocalizedString("common.status", comment: "Status")
        static let quizAssignment = NSLocalizedString("common.quizAssignment", comment: "Quiz assignment")
        static let noPlannedQuizzes = NSLocalizedString("common.noPlannedQuizzes", comment: "No planned quizzes")
        static let teamDetails = NSLocalizedString("common.teamDetails", comment: "Team details")
        static let addTeam = NSLocalizedString("common.addTeam", comment: "Add team")
        static let editTeam = NSLocalizedString("common.editTeam", comment: "Edit team")
        static let createTeam = NSLocalizedString("common.createTeam", comment: "Create team")
        static func deleteTeamsConfirm(_ count: Int) -> String {
            String(format: NSLocalizedString("common.deleteTeams.confirm", comment: "Delete teams confirm"), count)
        }
        static let manageTeams = NSLocalizedString("common.manageTeams", comment: "Manage teams")
        static let newTeam = NSLocalizedString("common.newTeam", comment: "New team")
        static let start = NSLocalizedString("common.start", comment: "Start")
    }

    // MARK: - Email
    enum Email {
        enum Results {
            static let send = NSLocalizedString("email.results.send", comment: "Email results button")
            static let generating = NSLocalizedString("email.results.generating", comment: "Generating image status")

            enum Attachment {
                static let name = NSLocalizedString("email.results.attachment.name", comment: "Attachment filename")
            }

            enum Error {
                static let title = NSLocalizedString("email.results.error.title", comment: "Email error title")
                static let generation = NSLocalizedString("email.results.error.generation", comment: "Image generation error")
                static let nomail = NSLocalizedString("email.results.error.nomail", comment: "No mail app error")
            }
        }
    }

    // MARK: - Presentation Mode
    enum Presentation {
        static let nextPlace = NSLocalizedString("presentation.nextPlace", comment: "Next place button")
        static let reset = NSLocalizedString("presentation.reset", comment: "Reset button")
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
