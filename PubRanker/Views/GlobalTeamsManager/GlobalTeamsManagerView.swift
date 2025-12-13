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
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]

    @State private var showingAddTeamSheet = false
    @State private var showingEmailComposer = false
    @State private var searchText = ""
    @State private var selectedTeam: Team?
    @State private var showingDeleteAlert = false
    @State private var showingEditSheet = false
    @State private var sortOption: TeamSortOption = .dateNewest

    // Multi-Select Mode
    @State private var isMultiSelectMode = false
    @State private var selectedTeamIDs: Set<Team.ID> = []
    @State private var showingMultiDeleteAlert = false

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
                isMultiSelectMode: $isMultiSelectMode,
                selectedTeamIDs: $selectedTeamIDs,
                showingMultiDeleteAlert: $showingMultiDeleteAlert,
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
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // Empty group to override default sidebar toggle
            }
        }
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
        .alert("Teams löschen", isPresented: $showingMultiDeleteAlert) {
            Button("Abbrechen", role: .cancel) {
                // Keep selection
            }
            Button("Alle \(selectedTeamIDs.count) Teams löschen", role: .destructive) {
                deleteMultipleTeams()
            }
        } message: {
            Text("Möchten Sie wirklich \(selectedTeamIDs.count) Teams löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
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
                    viewModel: viewModel,
                    selectedWorkflow: $selectedWorkflow,
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

    private func deleteMultipleTeams() {
        let teamsToDelete = allTeams.filter { selectedTeamIDs.contains($0.id) }

        for team in teamsToDelete {
            modelContext.delete(team)
        }

        do {
            try modelContext.save()
            selectedTeamIDs.removeAll()
            isMultiSelectMode = false
            selectedTeam = allTeams.first
        } catch {
            print("❌ Fehler beim Löschen der Teams: \(error)")
        }
    }
    
    #if DEBUG
    private func createTestData() {
        // MARK: - Deutsche Team-Namen (klar strukturiert für Testing)
        let teamNames = [
            "Die Wissensjäger", "Schlaue Füchse", "Quiz-Könige", "Denksportler",
            "Besserwisser", "Rateteam Alpha", "Die Alleswisser", "Knobelfreunde",
            "Gehirnakrobaten", "Quizmaster", "Schlaumeier", "Denkfabrik"
        ]

        // MARK: - Deutsche Kontaktpersonen
        let contacts = [
            "Max Mustermann", "Anna Schmidt", "Thomas Weber", "Lisa Müller",
            "Peter Fischer", "Julia Wagner", "Michael Becker", "Sarah Klein",
            "Daniel Wolf", "Laura Hoffmann", "Sebastian Braun", "Nina Schröder"
        ]

        // Farben für Teams
        let colors = [
            "#007AFF", "#FF3B30", "#34C759", "#FF9500",
            "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
            "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
        ]

        // MARK: - Quizzes mit verschiedenen Status erstellen

        // Quiz 1: Abgeschlossen (zum Testen von fertigen Quizzes mit vollständigen Scores)
        let quiz1 = Quiz(
            name: "Pub-Quiz Oktoberfest",
            venue: "Biergarten München",
            date: Date().addingTimeInterval(-7 * 86400) // Vor 7 Tagen
        )
        quiz1.isActive = false
        quiz1.isCompleted = true
        quiz1.teams = []
        quiz1.rounds = []

        // Runden für Quiz 1
        let round1_1 = Round(name: "Allgemeinwissen", maxPoints: 10, orderIndex: 0)
        let round1_2 = Round(name: "Musik & Film", maxPoints: 10, orderIndex: 1)
        let round1_3 = Round(name: "Sport", maxPoints: 15, orderIndex: 2)
        let round1_4 = Round(name: "Geographie", maxPoints: 10, orderIndex: 3)
        let round1_5 = Round(name: "Finale", maxPoints: 20, orderIndex: 4)

        [round1_1, round1_2, round1_3, round1_4, round1_5].forEach { round in
            round.quiz = quiz1
            round.isCompleted = true
            quiz1.rounds?.append(round)
        }

        modelContext.insert(quiz1)

        // Quiz 2: Aktiv (zum Testen während eines laufenden Quiz)
        let quiz2 = Quiz(
            name: "Winter-Quiz 2024",
            venue: "Gasthaus zum Hirsch",
            date: Date() // Heute
        )
        quiz2.isActive = true
        quiz2.isCompleted = false
        quiz2.teams = []
        quiz2.rounds = []

        // Runden für Quiz 2 (teilweise abgeschlossen)
        let round2_1 = Round(name: "Geschichte", maxPoints: 10, orderIndex: 0)
        round2_1.isCompleted = true
        let round2_2 = Round(name: "Wissenschaft", maxPoints: 10, orderIndex: 1)
        round2_2.isCompleted = true
        let round2_3 = Round(name: "Aktuell", maxPoints: 10, orderIndex: 2)
        round2_3.isCompleted = false
        let round2_4 = Round(name: "Schätzfragen", maxPoints: 15, orderIndex: 3)
        round2_4.isCompleted = false

        [round2_1, round2_2, round2_3, round2_4].forEach { round in
            round.quiz = quiz2
            quiz2.rounds?.append(round)
        }

        modelContext.insert(quiz2)

        // Quiz 3: Geplant (zum Testen zukünftiger Quizzes)
        let quiz3 = Quiz(
            name: "Frühlings-Quiz",
            venue: "Brauhaus am See",
            date: Date().addingTimeInterval(14 * 86400) // In 14 Tagen
        )
        quiz3.isActive = false
        quiz3.isCompleted = false
        quiz3.teams = []
        quiz3.rounds = []

        // Runden für Quiz 3
        let round3_1 = Round(name: "Literatur", maxPoints: 10, orderIndex: 0)
        let round3_2 = Round(name: "Natur", maxPoints: 10, orderIndex: 1)
        let round3_3 = Round(name: "Bonusrunde", maxPoints: 25, orderIndex: 2)

        [round3_1, round3_2, round3_3].forEach { round in
            round.quiz = quiz3
            quiz3.rounds?.append(round)
        }

        modelContext.insert(quiz3)

        // Quiz 4: Ohne Teams (zum Testen leerer Quizzes)
        let quiz4 = Quiz(
            name: "Sommer-Quiz",
            venue: "Biergarten am Park",
            date: Date().addingTimeInterval(30 * 86400) // In 30 Tagen
        )
        quiz4.teams = []
        quiz4.rounds = []

        let round4_1 = Round(name: "Runde 1", maxPoints: 10, orderIndex: 0)
        round4_1.quiz = quiz4
        quiz4.rounds?.append(round4_1)

        modelContext.insert(quiz4)

        // MARK: - Teams mit verschiedenen Eigenschaften erstellen
        var allTeams: [Team] = []

        // Team 1-4: Vollständige Teams (alle in Quiz 1, komplett mit Scores)
        for i in 0..<4 {
            let team = Team(name: teamNames[i], color: colors[i])
            team.contactPerson = contacts[i]
            team.email = "\(contacts[i].replacingOccurrences(of: " ", with: ".").lowercased())@quiz-team.de"
            team.isConfirmed = true
            team.quizzes = [quiz1]

            // Scores für alle Runden in Quiz 1
            team.addScore(for: round1_1, points: Int.random(in: 5...10))
            team.addScore(for: round1_2, points: Int.random(in: 6...10))
            team.addScore(for: round1_3, points: Int.random(in: 8...15))
            team.addScore(for: round1_4, points: Int.random(in: 4...10))
            team.addScore(for: round1_5, points: Int.random(in: 10...20))

            quiz1.teams?.append(team)
            modelContext.insert(team)
            allTeams.append(team)
        }

        // Team 5-7: Teams in aktivem Quiz 2 (teilweise Scores)
        for i in 4..<7 {
            let team = Team(name: teamNames[i], color: colors[i])
            team.contactPerson = contacts[i]
            team.email = "\(contacts[i].replacingOccurrences(of: " ", with: ".").lowercased())@quiz-team.de"
            team.isConfirmed = i % 2 == 0 // Manche bestätigt, manche nicht
            team.quizzes = [quiz2]

            // Nur Scores für abgeschlossene Runden
            team.addScore(for: round2_1, points: Int.random(in: 5...10))
            team.addScore(for: round2_2, points: Int.random(in: 4...10))

            quiz2.teams?.append(team)
            modelContext.insert(team)
            allTeams.append(team)
        }

        // Team 8-9: Teams für zukünftiges Quiz 3 (ohne Scores)
        for i in 7..<9 {
            let team = Team(name: teamNames[i], color: colors[i])
            team.contactPerson = contacts[i]
            team.email = "\(contacts[i].replacingOccurrences(of: " ", with: ".").lowercased())@quiz-team.de"
            team.isConfirmed = false
            team.quizzes = [quiz3]

            quiz3.teams?.append(team)
            modelContext.insert(team)
            allTeams.append(team)
        }

        // Team 10: Team in mehreren Quizzes (Quiz 1 und Quiz 2)
        let team10 = Team(name: teamNames[9], color: colors[9])
        team10.contactPerson = contacts[9]
        team10.email = "\(contacts[9].replacingOccurrences(of: " ", with: ".").lowercased())@quiz-team.de"
        team10.isConfirmed = true
        team10.quizzes = [quiz1, quiz2]

        // Scores für Quiz 1
        team10.addScore(for: round1_1, points: 9)
        team10.addScore(for: round1_2, points: 8)
        team10.addScore(for: round1_3, points: 12)
        team10.addScore(for: round1_4, points: 7)
        team10.addScore(for: round1_5, points: 18)

        // Scores für Quiz 2
        team10.addScore(for: round2_1, points: 8)
        team10.addScore(for: round2_2, points: 9)

        quiz1.teams?.append(team10)
        quiz2.teams?.append(team10)
        modelContext.insert(team10)
        allTeams.append(team10)

        // Team 11: Team ohne Quiz-Zuordnung (nur in globaler Liste)
        let team11 = Team(name: teamNames[10], color: colors[10])
        team11.contactPerson = contacts[10]
        team11.email = "\(contacts[10].replacingOccurrences(of: " ", with: ".").lowercased())@quiz-team.de"
        team11.isConfirmed = false
        team11.quizzes = []
        modelContext.insert(team11)
        allTeams.append(team11)

        // Team 12: Team ohne Kontaktdaten
        let team12 = Team(name: teamNames[11], color: colors[11])
        team12.contactPerson = ""
        team12.email = ""
        team12.isConfirmed = false
        team12.quizzes = []
        modelContext.insert(team12)
        allTeams.append(team12)

        // MARK: - Test-Teams für alphabetische Sortierung
        // Diese Teams sind speziell zum Testen der alphabetischen Sortierung
        // Sie sind NICHT einem Quiz zugeordnet und sollten in der Auswahl erscheinen

        let sortTestTeams = [
            ("Zebras", "#FF3B30"),           // Z - sollte ganz unten sein
            ("Adler", "#007AFF"),            // A - sollte ganz oben sein
            ("Bären", "#34C759"),            // B mit Umlaut
            ("Öchsner", "#FF9500"),          // Ö - nach O sortiert
            ("Meister", "#5856D6"),          // M - in der Mitte
            ("Ärzte", "#FF2D55"),            // Ä - nach A sortiert
            ("Überraschung", "#5AC8FA")      // Ü - nach U sortiert
        ]

        for (index, (name, color)) in sortTestTeams.enumerated() {
            let team = Team(name: name, color: color)
            team.contactPerson = "Test Person \(index + 1)"
            team.email = "test\(index + 1)@sortierung.de"
            team.isConfirmed = false
            team.quizzes = [] // WICHTIG: Nicht zugeordnet, damit sie in der Auswahl erscheinen
            modelContext.insert(team)
            allTeams.append(team)
        }

        // Speichern
        do {
            try modelContext.save()
            print("✅ Testdaten erfolgreich erstellt:")
            print("   - 4 Quizzes (abgeschlossen, aktiv, geplant, leer)")
            print("   - 12 Teams (verschiedene Zustände)")
            print("   - Alle Scores gesetzt")

            // Erstes Team auswählen
            if !allTeams.isEmpty {
                selectedTeam = allTeams.first
            }
        } catch {
            print("❌ Fehler beim Erstellen der Testdaten: \(error)")
        }
    }
    #endif
}
