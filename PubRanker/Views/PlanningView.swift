//
//  PlanningView.swift
//  PubRanker
//
//  Created on 31.10.2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct PlanningView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Quiz> { !$0.isActive && !$0.isCompleted }, sort: \Quiz.date, order: .reverse) 
    private var plannedQuizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @State private var showingNewQuizSheet = false
    @State private var showingEditQuizSheet = false
    @State private var selectedQuiz: Quiz?
    @State private var quizToDelete: Quiz?
    @State private var showingDeleteConfirmation = false
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    @State private var showingGlobalTeamPicker = false
    @State private var selectedDetailTab: PlanningDetailTab = .overview
    
    enum PlanningDetailTab: String, CaseIterable, Identifiable {
        case overview = "Übersicht"
        case teams = "Teams"
        case rounds = "Runden"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .teams: return "person.3.fill"
            case .rounds: return "list.number"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if let quiz = selectedQuiz {
                planningDetailView(for: quiz)
            } else {
                emptyState
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            viewModel.setContext(modelContext)
            if selectedQuiz == nil && !plannedQuizzes.isEmpty {
                selectedQuiz = plannedQuizzes.first
            }
        }
        .onChange(of: plannedQuizzes) { oldValue, newValue in
            // Wenn das aktuell ausgewählte Quiz gelöscht wurde
            if let selected = selectedQuiz, !newValue.contains(where: { $0.id == selected.id }) {
                selectedQuiz = newValue.first
            }
        }
        .sheet(isPresented: $showingEditQuizSheet) {
            if let quiz = selectedQuiz {
                EditQuizSheet(quiz: quiz, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingGlobalTeamPicker) {
            if let quiz = selectedQuiz {
                GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams(for: quiz), modelContext: modelContext)
            }
        }
        .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                quizToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                if let quiz = quizToDelete {
                    viewModel.deleteQuiz(quiz)
                    quizToDelete = nil
                }
            }
        } message: {
            if let quiz = quizToDelete {
                Text("Möchtest du '\(quiz.name)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
    }
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Quiz Planen", systemImage: "calendar.badge.plus")
                        .font(.title2)
                        .bold()
                    Text("Bereite deine Quiz vor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Moderner + Button
                Button {
                    showingNewQuizSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Neues Quiz")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
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
                .keyboardShortcut("n", modifiers: .command)
                .help("Neues Quiz erstellen (⌘N)")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Quiz List
            List(selection: $selectedQuiz) {
                if plannedQuizzes.isEmpty {
                    ContentUnavailableView(
                        "Keine geplanten Quiz",
                        systemImage: "calendar.badge.plus",
                        description: Text("Erstelle dein erstes Quiz")
                    )
                } else {
                    Section("Geplante Quiz (\(plannedQuizzes.count))") {
                        ForEach(plannedQuizzes) { quiz in
                            PlannedQuizRow(quiz: quiz)
                                .tag(quiz)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .sheet(isPresented: $showingNewQuizSheet, onDismiss: {
            // Wähle das neu erstellte Quiz aus
            if let newQuiz = viewModel.selectedQuiz {
                selectedQuiz = newQuiz
            }
        }) {
            NewQuizSheet(viewModel: viewModel)
        }
    }
    
    private func planningDetailView(for quiz: Quiz) -> some View {
        VStack(spacing: 0) {
            // Kompakter Header
            compactQuizHeader(quiz)
            
            Divider()
            
            // Tab Picker
            Picker("Ansicht", selection: $selectedDetailTab) {
                ForEach(PlanningDetailTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Tab Content
            Group {
                switch selectedDetailTab {
                case .overview:
                    overviewTabContent(quiz: quiz)
                case .teams:
                    teamsTabContent(quiz: quiz)
                case .rounds:
                    roundsTabContent(quiz: quiz)
                }
            }
        }
    }
    
    // MARK: - Tab Content Views
    
    private func overviewTabContent(quiz: Quiz) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Stats
                quickStatsGrid(quiz)
                
                // Status Cards
                statusCardsSection(quiz)
                
                // Team-Übersicht (kompakt)
                if !quiz.safeTeams.isEmpty {
                    compactTeamOverview(quiz: quiz)
                }
                
                // Runden-Übersicht (kompakt)
                if !quiz.safeRounds.isEmpty {
                    compactRoundsOverview(quiz: quiz)
                }
            }
            .padding()
        }
    }
    
    private func teamsTabContent(quiz: Quiz) -> some View {
        TeamManagementView(quiz: quiz, viewModel: viewModel)
    }
    
    private func roundsTabContent(quiz: Quiz) -> some View {
        RoundManagementView(quiz: quiz, viewModel: viewModel)
    }
    
    // MARK: - Header & Overview Components
    
    private func compactQuizHeader(_ quiz: Quiz) -> some View {
        HStack(spacing: 16) {
            // Quiz Info
            HStack(spacing: 12) {
                Image(systemName: "calendar.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.title2)
                        .bold()
                    
                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.body)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.body)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Action Buttons (kompakter)
            HStack(spacing: 8) {
                Button {
                    showingEditQuizSheet = true
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Quiz bearbeiten")
                
                Button {
                    quizToDelete = quiz
                    showingDeleteConfirmation = true
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .help("Quiz löschen")
                
                if !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                    Button {
                        viewModel.startQuiz(quiz)
                        selectedWorkflow = .execution
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.circle.fill")
                                .font(.body)
                            Text("Starten")
                                .font(.body)
                                .bold()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .green.opacity(0.3), radius: 4)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Quiz starten (⌘S)")
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    private func quickStatsGrid(_ quiz: Quiz) -> some View {
        HStack(spacing: 12) {
            compactStatCard(
                title: "Teams",
                value: "\(quiz.safeTeams.count)",
                icon: "person.3.fill",
                color: .blue,
                isComplete: !quiz.safeTeams.isEmpty
            )
            
            compactStatCard(
                title: "Runden",
                value: "\(quiz.safeRounds.count)",
                icon: "list.number",
                color: .green,
                isComplete: !quiz.safeRounds.isEmpty
            )
            
            compactStatCard(
                title: "Max. Punkte",
                value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })",
                icon: "star.fill",
                color: .orange,
                isComplete: !quiz.safeRounds.isEmpty
            )
        }
    }
    
    private func compactStatCard(title: String, value: String, icon: String, color: Color, isComplete: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .bold()
                    .monospacedDigit()
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func statusCardsSection(_ quiz: Quiz) -> some View {
        HStack(spacing: 12) {
            statusCard(
                title: quiz.safeTeams.isEmpty ? "Teams fehlen" : "Teams bereit",
                icon: quiz.safeTeams.isEmpty ? "person.3.slash.fill" : "person.3.fill",
                color: quiz.safeTeams.isEmpty ? .orange : .green
            )
            
            statusCard(
                title: quiz.safeRounds.isEmpty ? "Runden fehlen" : "Runden bereit",
                icon: quiz.safeRounds.isEmpty ? "list.number" : "checkmark.circle.fill",
                color: quiz.safeRounds.isEmpty ? .orange : .green
            )
            
            statusCard(
                title: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? "Bereit zum Start" : "Nicht bereit",
                icon: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                color: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? .green : .gray
            )
        }
    }
    
    private func statusCard(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            
            Text(title)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
    
    private func compactTeamOverview(quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Teams (\(quiz.safeTeams.count))", systemImage: "person.3.fill")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button {
                    selectedDetailTab = .teams
                } label: {
                    Text("Verwalten")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(quiz.safeTeams) { team in
                        compactTeamCard(team: team)
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func compactTeamCard(team: Team) -> some View {
        HStack(spacing: 10) {
            TeamIconView(team: team, size: 40)
            
            Text(team.name)
                .font(.body)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: team.color)?.opacity(0.3) ?? .clear, lineWidth: 1)
        }
    }
    
    private func compactRoundsOverview(quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Runden (\(quiz.safeRounds.count))", systemImage: "list.number")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button {
                    selectedDetailTab = .rounds
                } label: {
                    Text("Verwalten")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                ForEach(Array(quiz.sortedRounds.enumerated()), id: \.element.id) { index, round in
                    compactRoundCard(round: round, index: index)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func compactRoundCard(round: Round, index: Int) -> some View {
        VStack(spacing: 6) {
            Text("R\(index + 1)")
                .font(.body)
                .bold()
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.blue)
                .clipShape(Circle())
            
            Text(round.name)
                .font(.body)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(round.maxPoints) Pkt")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    
    private func availableGlobalTeams(for quiz: Quiz) -> [Team] {
        return allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Bereit für dein erstes Quiz?")
                        .font(.title2)
                        .bold()
                    
                    Text("Plane und organisiere dein Pub Quiz ganz einfach")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Großer CTA Button
                Button {
                    showingNewQuizSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Neues Quiz erstellen")
                                .font(.body)
                                .bold()
                            Text("Starte mit der Planung")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlannedQuizRow: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(quiz.name)
                .font(.headline)
            
            HStack(spacing: 12) {
                if !quiz.venue.isEmpty {
                    Label(quiz.venue, systemImage: "mappin.circle")
                        .font(.caption)
                }
                Text(quiz.date, style: .date)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                    .font(.caption2)
                Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Edit Quiz Sheet
struct EditQuizSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    
    @State private var quizName: String = ""
    @State private var venueName: String = ""
    @State private var quizDate: Date = Date()
    @State private var showingDeleteConfirmation = false
    @State private var selectedTab: EditTab = .details
    @State private var showingGlobalTeamPicker = false
    
    enum EditTab: String, CaseIterable, Identifiable {
        case details = "Details"
        case teams = "Teams"
        case rounds = "Runden"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .details: return "info.circle.fill"
            case .teams: return "person.3.fill"
            case .rounds: return "list.number"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Bereich", selection: $selectedTab) {
                    ForEach(EditTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Tab Content
                Group {
                    switch selectedTab {
                    case .details:
                        detailsView
                    case .teams:
                        teamsEditView
                    case .rounds:
                        roundsEditView
                    }
                }
            }
            .navigationTitle("Quiz bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        saveChanges()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
            .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    deleteQuiz()
                }
            } message: {
                Text("Möchtest du '\(quiz.name)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
            .sheet(isPresented: $showingGlobalTeamPicker) {
                GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams(for: quiz), modelContext: modelContext)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            quizName = quiz.name
            venueName = quiz.venue
            quizDate = quiz.date
        }
    }
    
    private var detailsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quiz-Details Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("Quiz-Details")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Quiz-Name
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Quiz-Name", systemImage: "textformat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("Name eingeben", text: $quizName)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                    }
                    
                    // Veranstaltungsort
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Veranstaltungsort", systemImage: "mappin.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("Ort eingeben", text: $venueName)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    
                    // Datum & Uhrzeit
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Datum & Uhrzeit", systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        DatePicker("", 
                                  selection: $quizDate,
                                  displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                }
                
                // Statistiken Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        Text("Statistiken")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Stats Grid
                    HStack(spacing: 12) {
                        statBox(
                            title: "Teams",
                            value: "\(quiz.safeTeams.count)",
                            icon: "person.3.fill",
                            color: .blue
                        )
                        
                        statBox(
                            title: "Runden",
                            value: "\(quiz.safeRounds.count)",
                            icon: "list.number",
                            color: .green
                        )
                        
                        statBox(
                            title: "Max. Punkte",
                            value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })",
                            icon: "star.fill",
                            color: .orange
                        )
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                }
                
                // Status Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "flag.fill")
                            .font(.title2)
                            .foregroundStyle(.purple)
                        Text("Status")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        statusIndicator(
                            title: quiz.isActive ? "Aktiv" : "Geplant",
                            icon: quiz.isActive ? "play.circle.fill" : "calendar",
                            color: quiz.isActive ? .green : .gray
                        )
                        
                        statusIndicator(
                            title: quiz.isCompleted ? "Abgeschlossen" : "Vorbereitung",
                            icon: quiz.isCompleted ? "checkmark.circle.fill" : "hourglass.circle",
                            color: quiz.isCompleted ? .blue : .orange
                        )
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                }
            }
            .padding(20)
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func statusIndicator(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text("Status")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var teamsEditView: some View {
        let availableTeams = availableGlobalTeams(for: quiz)
        
        return VStack(spacing: 0) {
            // Header mit Add Button
            HStack {
                Text("Teams verwalten")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    Button {
                        addNewTeam()
                    } label: {
                        Label("Neues Team erstellen", systemImage: "plus.circle")
                    }
                    
                    if !availableTeams.isEmpty {
                        Divider()
                        
                        Button {
                            showingGlobalTeamPicker = true
                        } label: {
                            Label("Aus vorhandenen wählen (\(availableTeams.count))", systemImage: "square.stack.3d.up.fill")
                        }
                    }
                } label: {
                    Label("Team hinzufügen", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .menuStyle(.button)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            if quiz.safeTeams.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("Keine Teams")
                        .font(.title2)
                        .bold()
                    
                    Text("Füge Teams hinzu, um mit dem Quiz zu starten")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        addNewTeam()
                    } label: {
                        Label("Neues Team hinzufügen", systemImage: "plus.circle.fill")
                    }
                    if !availableTeams.isEmpty {
                        Button {
                            showingGlobalTeamPicker = true
                        } label: {
                            Label("Aus vorhandenen wählen (\(availableTeams.count))", systemImage: "square.stack.3d.up.fill")
                                .font(.headline)
                        }
                    }                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(quiz.safeTeams) { team in
                        EditableTeamRow(team: team, quiz: quiz, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTeam(quiz.safeTeams[index], from: quiz)
                        }
                    }
                }
            }
        }
    }
    
    private func availableGlobalTeams(for quiz: Quiz) -> [Team] {
        return allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }
    
    private func addNewTeam() {
        let teamNumber = quiz.safeTeams.count + 1
        let colors = ["#007AFF", "#FF3B30", "#34C759", "#FF9500", "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00"]
        let colorIndex = (teamNumber - 1) % colors.count
        
        viewModel.addTeam(to: quiz, name: "Team \(teamNumber)", color: colors[colorIndex])
    }
    
    private var roundsEditView: some View {
        VStack(spacing: 0) {
            // Header mit Add Button
            HStack {
                Text("Runden verwalten")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    addNewRound()
                } label: {
                    Label("Runde hinzufügen", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            if quiz.safeRounds.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "list.number")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    Text("Keine Runden")
                        .font(.title2)
                        .bold()
                    
                    Text("Füge Runden hinzu, um Punkte zu vergeben")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button {
                        addNewRound()
                    } label: {
                        Label("Erste Runde hinzufügen", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(quiz.sortedRounds) { round in
                        EditableRoundRow(round: round, quiz: quiz, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let round = quiz.sortedRounds[index]
                            viewModel.deleteRound(round, from: quiz)
                        }
                    }
                }
            }
        }
    }
    
    private func addNewRound() {
        let roundNumber = quiz.safeRounds.count + 1
        viewModel.addRound(to: quiz, name: "Runde \(roundNumber)", maxPoints: 10)
    }
    
    private func saveChanges() {
        quiz.name = quizName.trimmingCharacters(in: .whitespacesAndNewlines)
        quiz.venue = venueName.trimmingCharacters(in: .whitespacesAndNewlines)
        quiz.date = quizDate
    }
    
    private func deleteQuiz() {
        viewModel.deleteQuiz(quiz)
        dismiss()
    }
}

// MARK: - Editable Team Row
struct EditableTeamRow: View {
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var contactPerson: String = ""
    @State private var email: String = ""
    @State private var isConfirmed: Bool = false
    @State private var showingColorPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showingImagePicker = false
    
    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Hauptinhalt
            HStack(spacing: 16) {
                // Team-Icon (Bild oder Farbe)
                TeamIconView(team: team, size: 40)
                .help(isEditing ? "Bild oder Farbe ändern" : "Team-Icon")
                .onTapGesture {
                    if isEditing {
                        showingColorPicker.toggle()
                    }
                }
                .popover(isPresented: $showingColorPicker) {
                    VStack(spacing: 20) {
                        Text("Team-Icon wählen")
                            .font(.headline)
                        
                        // Bildauswahl
                        Button {
                            showingImagePicker = true
                            showingColorPicker = false
                        } label: {
                            Label("Bild auswählen", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        
                        // Bild entfernen, wenn vorhanden
                        if team.imageData != nil {
                            Button {
                                team.imageData = nil
                                showingColorPicker = false
                            } label: {
                                Label("Bild entfernen", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Divider()
                        
                        // Farbauswahl
                        Text("Farbe wählen")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 12), count: 6), spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        if team.color == colorHex {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 3)
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                                .font(.title3)
                                                .bold()
                                        }
                                    }
                                    .shadow(color: Color(hex: colorHex)?.opacity(0.4) ?? .clear, radius: 2)
                                    .onTapGesture {
                                        team.color = colorHex
                                        team.imageData = nil // Bild entfernen wenn Farbe gewählt wird
                                        showingColorPicker = false
                                    }
                            }
                        }
                    }
                    .padding(20)
                }
                
                // Team-Informationen
                VStack(alignment: .leading, spacing: 8) {
                    if isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            // Team Name
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Team-Name")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .bold()
                                TextField("Team Name", text: $editedName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Divider()
                            
                            // Team Details
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Kontaktinformationen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .bold()
                                
                                TextField("Kontaktperson", text: $contactPerson)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("E-Mail", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                
                                Toggle("Bestätigt", isOn: $isConfirmed)
                                    .toggleStyle(.checkbox)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            // Team Name
                            Text(team.name)
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.primary)
                            
                            // Details
                            if !team.contactPerson.isEmpty || !team.email.isEmpty || team.isConfirmed {
                                VStack(alignment: .leading, spacing: 6) {
                                    if !team.contactPerson.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "person.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .frame(width: 16)
                                            Text(team.contactPerson)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    if !team.email.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "envelope.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .frame(width: 16)
                                            Text(team.email)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    if team.isConfirmed {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                                .font(.caption)
                                            Text("Bestätigt")
                                                .font(.subheadline)
                                                .foregroundStyle(.green)
                                                .bold()
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons - Größer und besser sichtbar
                HStack(spacing: 12) {
                    // Bearbeiten/Speichern Button - Größer und prominenter
                    Button {
                        if isEditing {
                            saveChanges()
                        } else {
                            editedName = team.name
                            contactPerson = team.contactPerson
                            email = team.email
                            isConfirmed = team.isConfirmed
                            isEditing = true
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                            Text(isEditing ? "Speichern" : "Bearbeiten")
                        }
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(isEditing ? Color.green : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    .help(isEditing ? "Speichern" : "Bearbeiten")
                    
                    // Löschen Button
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .help("Team löschen")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, isEditing ? 20 : 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: team.color)?.opacity(0.4) ?? .blue.opacity(0.4),
                            Color(hex: team.color)?.opacity(0.2) ?? .blue.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
        }
        .alert("Team löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                viewModel.deleteTeam(team, from: quiz)
            }
        } message: {
            Text("Möchtest du '\(team.name)' wirklich löschen?")
        }
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
    }
    
    private func saveChanges() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            viewModel.updateTeamName(team, newName: trimmedName)
        }
        viewModel.updateTeamDetails(team, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed)
        isEditing = false
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
}

// MARK: - Editable Round Row
struct EditableRoundRow: View {
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    
    var statusColor: Color {
        if round.isCompleted {
            return .green
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return .orange
        } else {
            return .gray
        }
    }
    
    var statusText: String {
        if round.isCompleted {
            return "Abgeschlossen"
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return "Aktiv"
        } else {
            return "Vorbereitung"
        }
    }
    
    var statusIcon: String {
        if round.isCompleted {
            return "checkmark.circle.fill"
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return "circle.fill"
        } else {
            return "hourglass.circle"
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Runden-Nummer Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [statusColor, statusColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .shadow(color: statusColor.opacity(0.4), radius: 6, x: 0, y: 2)
                
                Text("R\(getRoundNumber())")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            // Runden-Info
            VStack(alignment: .leading, spacing: 6) {
                Text(round.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    // Status
                    HStack(spacing: 4) {
                        Image(systemName: statusIcon)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(statusColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
                    
                    // Punkte
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(round.maxPoints) Pkt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Status Badge (nur wenn aktiv oder abgeschlossen)
            if round.isCompleted || (quiz.isActive && quiz.currentRound?.id == round.id) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(statusColor)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            // Bearbeiten-Button
            Button {
                showingEditSheet = true
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .help("Runde bearbeiten")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            statusColor.opacity(0.4),
                            statusColor.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRoundSheet(round: round, quiz: quiz, viewModel: viewModel)
        }
    }
    
    private func getRoundNumber() -> Int {
        guard let index = quiz.sortedRounds.firstIndex(where: { $0.id == round.id }) else {
            return 0
        }
        return index + 1
    }
}
