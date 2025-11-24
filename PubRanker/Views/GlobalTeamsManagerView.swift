//
//  GlobalTeamsManagerView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

enum TeamSortOption: String, CaseIterable {
    case nameAscending = "Name (A-Z)"
    case nameDescending = "Name (Z-A)"
    case dateNewest = "Neueste zuerst"
    case dateOldest = "Älteste zuerst"
    case mostQuizzes = "Meiste Zuordnungen"
    case leastQuizzes = "Wenigste Zuordnungen"
    
    var icon: String {
        switch self {
        case .nameAscending, .nameDescending:
            return "textformat.abc"
        case .dateNewest, .dateOldest:
            return "calendar"
        case .mostQuizzes, .leastQuizzes:
            return "link.circle"
        }
    }
}

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

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if allTeams.isEmpty {
                emptyStateView
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
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Team-Manager", systemImage: "person.3.fill")
                        .font(.title2)
                        .bold()
                    Text("Teams verwalten und organisieren")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                // Moderner + Button
                Button {
                    showingAddTeamSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.body)
                        Text("Neues Team")
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .help("Neues Team erstellen")
                
                // E-Mail Button
                Button {
                    showingEmailComposer = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .font(.body)
                        Text(NSLocalizedString("email.send.all", comment: "Email to all teams"))
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .orange.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .help(NSLocalizedString("email.send.all", comment: "Email to all teams"))
                
                #if DEBUG
                // Debug Button für Testdaten
                Button {
                    createTestData()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.body)
                        Text("🧪 Testdaten erstellen")
                            .font(.body)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.purple.opacity(0.7), .pink.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .purple.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .help("Erstellt Test-Teams und Quizzes (nur Debug)")
                #endif
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Search Bar
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                    .font(.body)
                    .frame(width: 20)
                TextField("Teams durchsuchen...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                            .font(.body)
                    }
                    .buttonStyle(.plain)
                    .help("Suche zurücksetzen")
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(nsColor: .controlBackgroundColor))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    }
            )
            .padding(.horizontal)
            .padding(.vertical, 12)
            
            Divider()
            
            // Sort Menu
            HStack(spacing: 10) {
                Image(systemName: "arrow.up.arrow.down")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .frame(width: 16)
                
                Menu {
                    ForEach(TeamSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            HStack {
                                Image(systemName: option.icon)
                                    .font(.caption)
                                    .frame(width: 16)
                                Text(option.rawValue)
                                Spacer()
                                if sortOption == option {
                                    Image(systemName: "checkmark")
                                        .font(.caption)
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text("Sortieren:")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(sortOption.rawValue)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.5))
            )
            .padding(.horizontal)
            .padding(.vertical, 8)
            
            Divider()
            
            // Teams List
            List(selection: $selectedTeam) {
                if filteredTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams gefunden",
                        systemImage: "magnifyingglass",
                        description: Text(searchText.isEmpty ? "Erstelle dein erstes Team" : "Keine Teams gefunden für '\(searchText)'")
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    Section {
                        ForEach(filteredTeams) { team in
                            GlobalTeamSidebarRow(team: team)
                                .tag(team)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let team = filteredTeams[index]
                                selectedTeam = team
                                showingDeleteAlert = true
                            }
                        }
                    } header: {
                        Text("Teams (\(filteredTeams.count))")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .frame(minWidth: 280, idealWidth: 320)
    }
    
    // MARK: - Detail View
    
    private var detailView: some View {
        VStack(spacing: 0) {
            if let team = selectedTeam {
                teamDetailView(team: team)
            } else {
                teamsGridView
            }
        }
    }
    
    private func teamDetailView(team: Team) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Team Header
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        TeamIconView(team: team, size: 80)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(team.name)
                                .font(.system(size: 32, weight: .bold))
                        }
                        
                        Spacer()
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
                
                // Team Info
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                        Text("Team-Informationen")
                            .font(.title3)
                            .bold()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if !team.contactPerson.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.blue)
                                    .font(.body)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kontaktperson")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(team.contactPerson)
                                        .font(.body)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        if !team.email.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.blue)
                                    .font(.body)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("E-Mail")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(team.email)
                                        .font(.body)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                                .font(.body)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Erstellt am")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(team.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.body)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.blue.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
                
                // Quiz-Zuordnungen
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "link.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.purple)
                        Text("Quiz-Zuordnungen")
                            .font(.title3)
                            .bold()
                        if let quizzes = team.quizzes, !quizzes.isEmpty {
                            Text("(\(quizzes.count))")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let quizzes = team.quizzes, !quizzes.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(quizzes) { quiz in
                                quizAssignmentRow(quiz: quiz)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "circle.dotted")
                                .foregroundStyle(.secondary)
                                .font(.body)
                                .frame(width: 24)
                            Text("Nicht zugeordnet")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.secondary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.body)
                            Text("Bearbeiten")
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.circle.fill")
                                .font(.body)
                            Text("Löschen")
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.15), Color.red.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
    }
    
    private var teamsGridView: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
            ], spacing: 20) {
                ForEach(filteredTeams) { team in
                    TeamCard(team: team, viewModel: viewModel, onDelete: {
                        selectedTeam = team
                        showingDeleteAlert = true
                    })
                }
            }
            .padding(24)
        }
    }
    
    private func quizAssignmentRow(quiz: Quiz) -> some View {
        HStack(spacing: 16) {
            // Quiz Icon/Color Indicator
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(quiz.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(.primary)
                
                HStack(spacing: 16) {
                    if !quiz.venue.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                            Text(quiz.venue)
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text(quiz.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                }
        )
    }

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .cyan.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 12) {
                    Text("Keine Teams vorhanden")
                        .font(.title2)
                        .bold()

                    Text("Erstellen Sie Ihr erstes Team, um es später einfach zu Quizzes hinzuzufügen")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 450)
                }
            }

            Button {
                showingAddTeamSheet = true
            } label: {
                Label("Erstes Team erstellen", systemImage: "plus.circle.fill")
                    .font(.body)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

// MARK: - Global Team Sidebar Row
struct GlobalTeamSidebarRow: View {
    let team: Team
    
    var body: some View {
        HStack(spacing: 12) {
            TeamIconView(team: team, size: 36)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(team.name)
                    .font(.body)
                    .bold()
                    .lineLimit(1)
                
                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "link.circle.fill")
                            .font(.caption)
                        Text("\(quizzes.count)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundStyle(.purple)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}

// MARK: - Team Card
struct TeamCard: View {
    @Bindable var team: Team
    @Bindable var viewModel: QuizViewModel
    let onDelete: () -> Void

    @State private var showingEditSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                TeamIconView(team: team, size: 40)

                Text(team.name)
                    .font(.body)
                    .bold()
                    .lineLimit(1)

                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        (Color(hex: team.color) ?? .blue).opacity(0.1),
                        (Color(hex: team.color) ?? .blue).opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                if !team.contactPerson.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(team.contactPerson)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !team.email.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(team.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "link.circle.fill")
                            .foregroundStyle(.purple)
                            .frame(width: 20)
                        if quizzes.count == 1 {
                            Text("Zugeordnet zu: \(quizzes[0].name)")
                                .font(.body)
                                .foregroundStyle(.purple)
                        } else {
                            Text("Zugeordnet zu \(quizzes.count) Quizzes")
                                .font(.body)
                                .foregroundStyle(.purple)
                        }
                    }
                    .padding(.top, 4)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.dotted")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                            .font(.body)
                        Text("Nicht zugeordnet")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                        .font(.body)
                    Text("Erstellt: \(team.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            Divider()

            HStack(spacing: 8) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Spacer()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingEditSheet) {
            GlobalEditTeamSheet(team: team, viewModel: viewModel)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .bold()
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                }
        )
    }
}

// MARK: - Global Add Team Sheet
struct GlobalAddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: QuizViewModel
    let modelContext: ModelContext

    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil

    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Team-Informationen") {
                    TextField("Team-Name", text: $teamName)
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team-Icon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            // Vorschau
                            Group {
                                if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                        }
                                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                                } else {
                                    Circle()
                                        .fill(Color(hex: selectedColor) ?? .blue)
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Circle()
                                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                        }
                                        .shadow(color: Color(hex: selectedColor)?.opacity(0.4) ?? .clear, radius: 4)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("Bild auswählen", systemImage: "photo")
                                }
                                .buttonStyle(.bordered)
                                
                                if imageData != nil {
                                    Button {
                                        imageData = nil
                                    } label: {
                                        Label("Bild entfernen", systemImage: "trash")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Farbauswahl
                        Text("Farbe")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        if selectedColor == colorHex {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 3)
                                        }
                                    }
                                    .onTapGesture {
                                        selectedColor = colorHex
                                        imageData = nil // Bild entfernen wenn Farbe gewählt wird
                                    }
                            }
                        }
                    }
                }

                Section("Kontaktinformationen") {
                    TextField("Kontaktperson (optional)", text: $contactPerson)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)

                    TextField("E-Mail (optional)", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Neues Team erstellen")
            .fileImporter(
                isPresented: $showingImagePicker,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        loadImage(from: url)
                    }
                case .failure(let error):
                    print("Fehler beim Auswählen des Bildes: \(error.localizedDescription)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Erstellen") {
                        createTeam()
                        dismiss()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 450)
    }

    private func createTeam() {
        let team = Team(name: teamName, color: selectedColor)
        team.contactPerson = contactPerson
        team.email = email
        team.isConfirmed = isConfirmed
        team.imageData = imageData

        modelContext.insert(team)
        try? modelContext.save()
    }
    
    private func loadImage(from url: URL) {
        // Security-Scoped Resource Zugriff anfordern
        // fileImporter gibt bereits Security-Scoped URLs zurück, aber wir müssen
        // explizit den Zugriff anfordern, um die Datei lesen zu können
        guard url.startAccessingSecurityScopedResource() else {
            print("⚠️ Fehler: Kein Zugriff auf die Datei - Security-Scoped Resource konnte nicht gestartet werden")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Prüfen ob die Datei existiert und lesbar ist
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️ Fehler: Datei existiert nicht: \(url.path)")
            return
        }
        
        // Bild laden und validieren
        do {
            let imageData = try Data(contentsOf: url)
            
            // Prüfen ob es tatsächlich ein Bild ist
            guard NSImage(data: imageData) != nil else {
                print("⚠️ Fehler: Datei ist kein gültiges Bild")
                return
            }
            
            // Bild speichern
            self.imageData = imageData
            print("✅ Bild erfolgreich geladen: \(url.lastPathComponent)")
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }
}

// MARK: - Global Edit Team Sheet
struct GlobalEditTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var team: Team
    @Bindable var viewModel: QuizViewModel
    @Query(filter: #Predicate<Quiz> { !$0.isActive && !$0.isCompleted }, sort: \Quiz.date, order: .reverse)
    private var plannedQuizzes: [Quiz]

    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false
    @State private var selectedQuizIds: Set<UUID> = []
    @State private var showingImagePicker = false

    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Team-Informationen") {
                    TextField("Team-Name", text: $teamName)
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team-Icon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            // Aktuelles Icon anzeigen
                            TeamIconView(team: team, size: 60)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("Bild auswählen", systemImage: "photo")
                                }
                                .buttonStyle(.bordered)
                                
                                if team.imageData != nil {
                                    Button {
                                        team.imageData = nil
                                    } label: {
                                        Label("Bild entfernen", systemImage: "trash")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Farbauswahl
                        Text("Farbe")
                            .font(.body)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        if selectedColor == colorHex {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 3)
                                        }
                                    }
                                    .onTapGesture {
                                        selectedColor = colorHex
                                        team.imageData = nil // Bild entfernen wenn Farbe gewählt wird
                                    }
                            }
                        }
                    }
                }

                Section("Kontaktinformationen") {
                    TextField("Kontaktperson (optional)", text: $contactPerson)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)

                    TextField("E-Mail (optional)", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                }

                Section("Status") {
                    Toggle("Team ist bestätigt", isOn: $isConfirmed)
                        .help("Team hat die Teilnahme bestätigt")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Quiz-Zuordnung")
                                .font(.title3)
                                .bold()
                            Spacer()
                            Text("\(selectedQuizIds.count) ausgewählt")
                                .font(.body)
                                .foregroundStyle(.secondary)
                        }

                        if plannedQuizzes.isEmpty {
                            HStack {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                                    .font(.body)
                                Text("Keine geplanten Quizzes verfügbar")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            VStack(spacing: 8) {
                                ForEach(plannedQuizzes) { quiz in
                                    QuizCheckboxRow(
                                        quiz: quiz,
                                        isSelected: selectedQuizIds.contains(quiz.id)
                                    ) {
                                        toggleQuiz(quiz)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Team bearbeiten")
            .fileImporter(
                isPresented: $showingImagePicker,
                allowedContentTypes: [.image],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        loadImage(from: url)
                    }
                case .failure(let error):
                    print("Fehler beim Auswählen des Bildes: \(error.localizedDescription)")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .frame(minWidth: 550, minHeight: 600)
        .onAppear {
            teamName = team.name
            selectedColor = team.color
            contactPerson = team.contactPerson
            email = team.email
            isConfirmed = team.isConfirmed
            selectedQuizIds = Set(team.quizzes?.map { $0.id } ?? [])
        }
    }

    private func saveChanges() {
        team.name = teamName
        team.color = selectedColor
        team.contactPerson = contactPerson
        team.email = email
        team.isConfirmed = isConfirmed

        // Update quiz assignments
        let currentQuizIds = Set(team.quizzes?.map { $0.id } ?? [])

        // Remove from quizzes that are no longer selected
        for quizId in currentQuizIds {
            if !selectedQuizIds.contains(quizId), let quiz = team.quizzes?.first(where: { $0.id == quizId }) {
                if let index = quiz.teams?.firstIndex(where: { $0.id == team.id }) {
                    quiz.teams?.remove(at: index)
                }
                if let teamIndex = team.quizzes?.firstIndex(where: { $0.id == quizId }) {
                    team.quizzes?.remove(at: teamIndex)
                }
            }
        }

        // Add to newly selected quizzes
        for quizId in selectedQuizIds {
            if !currentQuizIds.contains(quizId), let quiz = plannedQuizzes.first(where: { $0.id == quizId }) {
                if team.quizzes == nil {
                    team.quizzes = []
                }
                if !team.quizzes!.contains(where: { $0.id == quizId }) {
                    team.quizzes!.append(quiz)
                }
                if quiz.teams == nil {
                    quiz.teams = []
                }
                if !quiz.teams!.contains(where: { $0.id == team.id }) {
                    quiz.teams!.append(team)
                }
            }
        }

        try? modelContext.save()
    }
    
    private func loadImage(from url: URL) {
        // Security-Scoped Resource Zugriff anfordern
        // fileImporter gibt bereits Security-Scoped URLs zurück, aber wir müssen
        // explizit den Zugriff anfordern, um die Datei lesen zu können
        guard url.startAccessingSecurityScopedResource() else {
            print("⚠️ Fehler: Kein Zugriff auf die Datei - Security-Scoped Resource konnte nicht gestartet werden")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Prüfen ob die Datei existiert und lesbar ist
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️ Fehler: Datei existiert nicht: \(url.path)")
            return
        }
        
        // Bild laden und validieren
        do {
            let imageData = try Data(contentsOf: url)
            
            // Prüfen ob es tatsächlich ein Bild ist
            guard NSImage(data: imageData) != nil else {
                print("⚠️ Fehler: Datei ist kein gültiges Bild")
                return
            }
            
            // Bild speichern
            team.imageData = imageData
            print("✅ Bild erfolgreich geladen: \(url.lastPathComponent)")
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }

    private func toggleQuiz(_ quiz: Quiz) {
        if selectedQuizIds.contains(quiz.id) {
            selectedQuizIds.remove(quiz.id)
        } else {
            selectedQuizIds.insert(quiz.id)
        }
    }
}

// MARK: - Quiz Checkbox Row
struct QuizCheckboxRow: View {
    let quiz: Quiz
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.body)
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }

                // Quiz Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.body)
                        .bold()
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                            .font(.subheadline)
                        Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}

