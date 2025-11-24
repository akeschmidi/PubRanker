//
//  GlobalTeamsManagerView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct GlobalTeamsManagerView: View {
    @Bindable var viewModel: QuizViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]

    @State private var showingAddTeamSheet = false
    @State private var showingEmailComposer = false
    @State private var searchText = ""
    @State private var selectedTeam: Team?
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var sortOption: TeamSortOption = .dateNewest

    var filteredTeams: [Team] {
        let filtered = searchText.isEmpty ? allTeams : allTeams.filter { team in
            team.name.localizedCaseInsensitiveContains(searchText) ||
            team.contactPerson.localizedCaseInsensitiveContains(searchText) ||
            team.email.localizedCaseInsensitiveContains(searchText)
        }
        
        return sortedTeams(filtered)
    }
    
    private func sortedTeams(_ teams: [Team]) -> [Team] {
        switch sortOption {
        case .nameAscending:
            return teams.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .nameDescending:
            return teams.sorted { $0.name.localizedCompare($1.name) == .orderedDescending }
        case .dateNewest:
            return teams.sorted { 
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt > $1.createdAt
                }
                return $0.name.localizedCompare($1.name) == .orderedAscending
            }
        case .dateOldest:
            return teams.sorted { 
                if $0.createdAt != $1.createdAt {
                    return $0.createdAt < $1.createdAt
                }
                return $0.name.localizedCompare($1.name) == .orderedAscending
            }
        case .mostQuizzes:
            return teams.sorted { 
                let count0 = $0.quizzes?.count ?? 0
                let count1 = $1.quizzes?.count ?? 0
                if count0 != count1 {
                    return count0 > count1
                }
                return $0.name.localizedCompare($1.name) == .orderedAscending
            }
        case .leastQuizzes:
            return teams.sorted { 
                let count0 = $0.quizzes?.count ?? 0
                let count1 = $1.quizzes?.count ?? 0
                if count0 != count1 {
                    return count0 < count1
                }
                return $0.name.localizedCompare($1.name) == .orderedAscending
            }
        }
    }
    
    private var onCreateTestDataClosure: (() -> Void)? {
        #if DEBUG
        return { createTestData() }
        #else
        return nil
        #endif
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            SidebarView(
                searchText: $searchText,
                sortOption: $sortOption,
                selectedTeam: $selectedTeam,
                showingAddTeamSheet: $showingAddTeamSheet,
                showingEmailComposer: $showingEmailComposer,
                showingDeleteAlert: $showingDeleteAlert,
                filteredTeams: filteredTeams,
                onCreateTestData: onCreateTestDataClosure
            )
        } detail: {
            if allTeams.isEmpty {
                EmptyStateView {
                    showingAddTeamSheet = true
                }
            } else {
                detailView
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingAddTeamSheet) {
            GlobalAddTeamSheet(viewModel: viewModel, modelContext: modelContext)
        }
        .sheet(isPresented: $showingEmailComposer) {
            EmailComposerView(teams: allTeams)
        }
        .sheet(isPresented: $showingEditSheet) {
            if let team = selectedTeam {
                GlobalEditTeamSheet(team: team, viewModel: viewModel)
            }
        }
        .alert("Team löschen", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) {
                selectedTeam = nil
            }
            Button("Löschen", role: .destructive) {
                if let team = selectedTeam {
                    deleteTeam(team)
                }
            }
        } message: {
            if let team = selectedTeam {
                Text("Möchten Sie das Team '\(team.name)' wirklich löschen?")
            }
        }
        .onAppear {
            if selectedTeam == nil && !allTeams.isEmpty {
                selectedTeam = allTeams.first
            }
        }
        .onChange(of: allTeams) { oldValue, newValue in
            if let selected = selectedTeam, !newValue.contains(where: { $0.id == selected.id }) {
                selectedTeam = newValue.first
            } else if selectedTeam == nil && !newValue.isEmpty {
                selectedTeam = newValue.first
            }
        }
    }
    
    // MARK: - Detail View
    
    private var detailView: some View {
        VStack(spacing: 0) {
            if let team = selectedTeam {
                TeamDetailView(
                    team: team,
                    showingEditSheet: $showingEditSheet,
                    showingDeleteAlert: $showingDeleteAlert
                )
            } else {
                TeamsGridView(
                    teams: filteredTeams,
                    viewModel: viewModel,
                    onDelete: { team in
                        selectedTeam = team
                        showingDeleteAlert = true
                    }
                )
            }
        }
    }

    private func deleteTeam(_ team: Team) {
        modelContext.delete(team)
        try? modelContext.save()
        selectedTeam = nil
    }
    
    #if DEBUG
    private func createTestData() {
        // Sehr kreative Team-Namen mit verschiedenen Themen
        let teamNames = [
            // Klassiker
            "Die Quizmeister", "Brainstorm Champions", "Trivia Titans", "Genie-Gang",
            "Schlaue Füchse", "Quiz-Könige", "Wissens-Wölfe", "Brainiacs",
            // Tier-Themen
            "Clever Clowns", "Smart Squad", "Quiz Ninjas", "Wissens-Warrior",
            "Brain Boosters", "Wissensdurstige", "Trivia Tigers", "Genius Giraffen",
            // Action-Themen
            "Quiz Commandos", "Brain Warriors", "Trivia Troopers", "Mind Masters",
            "Knowledge Knights", "Quiz Crusaders", "Brain Busters", "Trivia Terminators",
            // Spaß-Themen
            "Die Schlauberger", "Quiz Quacksalber", "Brain Bubbles", "Trivia Troublemakers",
            "Wissens-Witzbolde", "Genius Geeks", "Smart Alecs", "Quiz Quirks",
            // Premium-Teams
            "Elite Einsteins", "Master Minds", "Quiz Legends", "Brain Dynasty",
            "Trivia Titans Elite", "Genius Guild", "Quiz Champions", "Brain Brotherhood"
        ]
        
        // Kreative Quiz-Namen mit verschiedenen Themen
        let quizThemes: [(name: String, venue: String)] = [
            // Pub-Quiz Themen
            ("Pub Night Extravaganza", "The Golden Barrel"),
            ("Wissens-Battle Royal", "Bar Central"),
            ("Trivia Thunder", "The Quiz Corner"),
            ("Brain Blast Championship", "The Scholar's Pub"),
            ("Quiz Quest Adventure", "The Brain Bar"),
            ("Genius Games", "Trivia Tavern"),
            ("Smart Showdown", "The Knowledge Inn"),
            ("Trivia Tournament", "The Wise Owl"),
            // Spezielle Themen
            ("Science Slam", "The Lab Bar"),
            ("History Heroes", "The Museum Pub"),
            ("Pop Culture Clash", "The Retro Lounge"),
            ("Movie Mania", "Cinema Bar"),
            ("Music Masters", "The Sound Stage"),
            ("Sports Spectacle", "The Arena Pub"),
            ("Geography Genius", "The Globe Tavern"),
            ("Literature Legends", "The Bookworm Bar"),
            ("Food Fight Quiz", "The Gourmet Pub"),
            ("Tech Trivia", "The Digital Den"),
            ("Art Attack", "The Gallery Bar")
        ]
        
        // Kreative Runden-Namen nach Kategorien
        let roundCategories: [[String]] = [
            // Action-Runden
            ["Warm-Up Runde", "Speed Round", "Lightning Round", "Turbo Trivia", "Power Play", "Rapid Fire"],
            // Spannende Runden
            ["Brain Teaser", "Final Countdown", "Sudden Death", "Champion Challenge", "Epic Finale", "Mega Round"],
            // Thematische Runden
            ["Wissens-Runde", "Genius Round", "Master Challenge", "Elite Battle", "Profi-Runde", "Expert Level"],
            // Spezielle Runden
            ["Bonus Battle", "Double Points", "Joker Round", "Wildcard", "Lucky Strike", "Golden Round"],
            // Finale-Runden
            ["Grand Finale", "Ultimate Challenge", "Final Showdown", "Championship Round", "Victory Round", "Crown Round"]
        ]
        
        // Kreative Kontaktpersonen-Namen
        let contactPersons = [
            "Max Mustermann", "Anna Schmidt", "Tom Weber", "Lisa Müller", "Peter Fischer",
            "Sarah Johnson", "Michael Chen", "Emma Williams", "David Brown", "Sophie Davis",
            "Alex Martinez", "Julia Anderson", "Chris Taylor", "Maria Garcia", "Daniel Lee",
            "Laura Wilson", "James Moore", "Nicole Jackson", "Robert White", "Amanda Harris",
            "Kevin Thompson", "Jennifer Martin", "Ryan Clark", "Michelle Lewis", "Brian Walker",
            nil, nil, nil // Einige Teams ohne Kontaktperson
        ]
        
        // Kreative E-Mail-Adressen
        let emailDomains = [
            "quizmasters.de", "brainiacs.com", "triviatitans.org", "geniusgang.net",
            "quizchampions.io", "smartteam.de", "wissenshelden.com", "quizkings.net",
            "brainbusters.de", "triviamasters.com", "quizlegends.org", "geniusclub.de"
        ]
        let emailPrefixes = [
            "team", "info", "contact", "hello", "quiz", "champions", "masters", "heroes",
            "contact", "info", "team", "hello", "quiz", "contact", "info"
        ]
        
        // Farben für Teams
        let colors = [
            "#007AFF", "#FF3B30", "#34C759", "#FF9500",
            "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
            "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
        ]
        
        // Erstelle 3-5 Quizzes mit verschiedenen Themen
        let numberOfQuizzes = Int.random(in: 3...5)
        var createdQuizzes: [Quiz] = []
        
        for i in 0..<numberOfQuizzes {
            let theme = quizThemes.randomElement() ?? (name: "Test Quiz \(i + 1)", venue: "Test Venue")
            let date = Date().addingTimeInterval(Double.random(in: -86400 * 60...86400 * 30)) // -60 bis +30 Tage
            
            let quiz = Quiz(name: theme.name, venue: theme.venue, date: date)
            quiz.teams = []
            quiz.rounds = []
            
            // Erstelle 4-7 Runden pro Quiz mit verschiedenen Kategorien
            let numberOfRounds = Int.random(in: 4...7)
            let selectedCategory = roundCategories.randomElement() ?? roundCategories[0]
            
            for j in 0..<numberOfRounds {
                let roundName: String
                if j < selectedCategory.count {
                    roundName = selectedCategory[j]
                } else {
                    // Falls mehr Runden als Namen, verwende generische Namen
                    roundName = ["Runde \(j + 1)", "Challenge \(j + 1)", "Round \(j + 1)"].randomElement() ?? "Runde \(j + 1)"
                }
                
                // Variiere die Punkte kreativer
                let maxPoints = [5, 10, 15, 20, 25, 30, 40, 50].randomElement() ?? 10
                let round = Round(name: roundName, maxPoints: maxPoints, orderIndex: j)
                round.quiz = quiz
                if quiz.rounds == nil {
                    quiz.rounds = []
                }
                quiz.rounds?.append(round)
            }
            
            modelContext.insert(quiz)
            createdQuizzes.append(quiz)
        }
        
        // Erstelle 10-15 Teams
        let numberOfTeams = Int.random(in: 10...15)
        let selectedTeamNames = Array(teamNames.shuffled().prefix(numberOfTeams))
        
        for (index, teamName) in selectedTeamNames.enumerated() {
            let team = Team(name: teamName, color: colors[index % colors.count])
            
            // Kreative Kontaktinformationen
            if let contact = contactPersons.randomElement(), contact != nil {
                team.contactPerson = contact!
            }
            
            // Kreative E-Mail-Adressen
            if Bool.random() { // 50% Chance auf E-Mail
                let prefix = emailPrefixes.randomElement() ?? "team"
                let domain = emailDomains.randomElement() ?? "example.com"
                team.email = "\(prefix)@\(domain)"
            }
            
            // Zufällig 0-3 Quizzes zuordnen (mehr Variation)
            let maxAssignments = min(3, createdQuizzes.count)
            let assignedQuizzes = createdQuizzes.shuffled().prefix(Int.random(in: 0...maxAssignments))
            team.quizzes = Array(assignedQuizzes)
            
            // Teams zu Quizzes hinzufügen
            for quiz in assignedQuizzes {
                if quiz.teams == nil {
                    quiz.teams = []
                }
                quiz.teams?.append(team)
            }
            
            modelContext.insert(team)
        }
        
        // Speichern
        do {
            try modelContext.save()
            // Erstes Team auswählen
            if let firstTeam = allTeams.first {
                selectedTeam = firstTeam
            }
        } catch {
            print("Fehler beim Erstellen der Testdaten: \(error)")
        }
    }
    #endif
}
