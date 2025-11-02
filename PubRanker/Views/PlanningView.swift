//
//  PlanningView.swift
//  PubRanker
//
//  Created on 31.10.2025
//

import SwiftUI
import SwiftData

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
            VStack(alignment: .leading, spacing: 8) {
                Label("Quiz Planen", systemImage: "calendar.badge.plus")
                    .font(.title2)
                    .bold()
                Text("Bereite deine Quiz vor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewQuizSheet = true
                } label: {
                    Label("Neues Quiz", systemImage: "plus.circle.fill")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
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
        ScrollView {
            VStack(spacing: 24) {
                // Quiz Info Header
                quizInfoCard(quiz)
                
                // Quick Stats
                quickStatsRow(quiz)
                
                Divider()
                
                // Setup Sections
                VStack(spacing: 16) {
                    setupSection(
                        title: "Teams hinzufügen",
                        icon: "person.3.fill",
                        color: .blue,
                        count: quiz.safeTeams.count,
                        isComplete: !quiz.safeTeams.isEmpty
                    ) {
                        TeamManagementView(quiz: quiz, viewModel: viewModel)
                    }
                    
                    setupSection(
                        title: "Runden definieren",
                        icon: "list.number",
                        color: .green,
                        count: quiz.safeRounds.count,
                        isComplete: !quiz.safeRounds.isEmpty
                    ) {
                        RoundManagementView(quiz: quiz, viewModel: viewModel)
                    }
                    
                    // Team-Übersicht
                    if !quiz.safeTeams.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Label("Team-Übersicht", systemImage: "person.3.fill")
                                    .font(.headline)
                                    .foregroundStyle(.blue)
                                
                                Spacer()
                                
                                Text("\(quiz.safeTeams.count)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(.blue)
                                    .clipShape(Capsule())
                            }
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(quiz.safeTeams) { team in
                                        teamOverviewCard(team: team, quiz: quiz)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        .padding()
                        .background(Color(nsColor: .controlBackgroundColor).opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private func quizInfoCard(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.title)
                        .bold()
                    
                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Action Buttons rechts
                HStack(spacing: 12) {
                    // Delete Button
                    Button {
                        quizToDelete = quiz
                        showingDeleteConfirmation = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.circle.fill")
                                .font(.title2)
                            Text("Löschen")
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.red.opacity(0.1))
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .help("Quiz löschen")
                    
                    // Edit Button
                    Button {
                        showingEditQuizSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.title2)
                            Text("Bearbeiten")
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.1))
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.blue, lineWidth: 2)
                        }
                    }
                    .buttonStyle(.plain)
                    .help("Quiz bearbeiten")
                    
                    // Start Quiz Button
                    if !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                        Button {
                            viewModel.startQuiz(quiz)
                            // Wechsle zur Durchführungsphase
                            selectedWorkflow = .execution
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Quiz starten")
                                    .font(.headline)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .green.opacity(0.3), radius: 6)
                        }
                        .buttonStyle(.plain)
                        .keyboardShortcut("s", modifiers: .command)
                        .help("Quiz starten (⌘S)")
                    }
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func quickStatsRow(_ quiz: Quiz) -> some View {
        HStack(spacing: 16) {
            statCard(title: "Teams", value: "\(quiz.safeTeams.count)", icon: "person.3.fill", color: .blue)
            statCard(title: "Runden", value: "\(quiz.safeRounds.count)", icon: "list.number", color: .green)
            statCard(title: "Max. Punkte", value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })", icon: "star.fill", color: .orange)
        }
        .padding(.horizontal)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func teamOverviewCard(team: Team, quiz: Quiz) -> some View {
        VStack(spacing: 8) {
            // Farb-Badge mit Rang
            ZStack {
                Circle()
                    .fill(Color(hex: team.color) ?? .blue)
                    .frame(width: 50, height: 50)
                    .shadow(color: Color(hex: team.color)?.opacity(0.4) ?? .clear, radius: 4)
                
                VStack(spacing: 2) {
                    Text("#\(viewModel.getTeamRank(for: team, in: quiz))")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(.white)
                    
                    Image(systemName: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(.white)
                }
            }
            
            // Team-Name
            Text(team.name)
                .font(.subheadline)
                .bold()
                .lineLimit(1)
            
            // Punkte
            VStack(spacing: 2) {
                Text("\(team.totalScore)")
                    .font(.title2)
                    .bold()
                    .monospacedDigit()
                
                Text("Punkte")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .frame(width: 120)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: team.color)?.opacity(0.4) ?? .clear, lineWidth: 2)
        }
    }
    
    private func setupSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        count: Int,
        isComplete: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                
                Spacer()
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                
                Text("\(count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            content()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                        .font(.title)
                        .bold()
                    
                    Text("Plane und organisiere dein Pub Quiz ganz einfach")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Großer CTA Button
                Button {
                    showingNewQuizSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Neues Quiz erstellen")
                                .font(.headline)
                            Text("Starte mit der Planung")
                                .font(.caption)
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
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var quizName: String = ""
    @State private var venueName: String = ""
    @State private var quizDate: Date = Date()
    @State private var showingDeleteConfirmation = false
    @State private var selectedTab: EditTab = .details
    
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
        VStack(spacing: 0) {
            // Header mit Add Button
            HStack {
                Text("Teams verwalten")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    addNewTeam()
                } label: {
                    Label("Team hinzufügen", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
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
                        Label("Erstes Team hinzufügen", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
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
    @State private var showingColorPicker = false
    @State private var showingDeleteConfirmation = false
    
    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            // Hauptinhalt
            HStack(spacing: 12) {
                // Farb-Button
                Button {
                    showingColorPicker.toggle()
                } label: {
                    Circle()
                        .fill(Color(hex: team.color) ?? .blue)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Circle()
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        }
                        .shadow(color: Color(hex: team.color)?.opacity(0.3) ?? .clear, radius: 4)
                }
                .buttonStyle(.plain)
                .help("Farbe ändern")
                .popover(isPresented: $showingColorPicker) {
                    VStack(spacing: 16) {
                        Text("Farbe wählen")
                            .font(.headline)
                        
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
                                        showingColorPicker = false
                                    }
                            }
                        }
                    }
                    .padding(20)
                }
                
                // Team-Name bearbeiten
                VStack(alignment: .leading, spacing: 4) {
                    if isEditing {
                        TextField("Team Name", text: $editedName)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                saveChanges()
                            }
                    } else {
                        Text(team.name)
                            .font(.headline)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Bearbeiten/Speichern Button
                    Button {
                        if isEditing {
                            saveChanges()
                        } else {
                            editedName = team.name
                            isEditing = true
                        }
                    } label: {
                        Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isEditing ? .green : .blue)
                    }
                    .buttonStyle(.plain)
                    .help(isEditing ? "Speichern" : "Namen bearbeiten")
                    
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: team.color)?.opacity(0.3) ?? .clear, lineWidth: 2)
        }
        .alert("Team löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                viewModel.deleteTeam(team, from: quiz)
            }
        } message: {
            Text("Möchtest du '\(team.name)' wirklich löschen?")
        }
    }
    
    private func saveChanges() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            viewModel.updateTeamName(team, newName: trimmedName)
        }
        isEditing = false
    }
}

// MARK: - Editable Round Row
struct EditableRoundRow: View {
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var isEditingName = false
    @State private var isEditingPoints = false
    @State private var editedName: String = ""
    @State private var editedPoints: String = ""
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
        HStack(spacing: 0) {
            // Hauptinhalt
            HStack(spacing: 12) {
                // Runden-Nummer Badge
                VStack(spacing: 4) {
                    Text("R\(getRoundNumber())")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(statusColor)
                        .clipShape(Circle())
                        .shadow(color: statusColor.opacity(0.4), radius: 4)
                    
                    if round.isCompleted || quiz.currentRound?.id == round.id {
                        Image(systemName: statusIcon)
                            .font(.caption2)
                            .foregroundStyle(statusColor)
                            .symbolEffect(.pulse)
                    }
                }
                
                // Runden-Info
                VStack(alignment: .leading, spacing: 4) {
                    if isEditingName {
                        TextField("Runden Name", text: $editedName)
                            .textFieldStyle(.roundedBorder)
                            .onSubmit {
                                saveNameChanges()
                            }
                    } else {
                        Text(round.name)
                            .font(.headline)
                    }
                    
                    // Status und Punkte Info
                    HStack(spacing: 8) {
                        Label(statusText, systemImage: statusIcon)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                        
                        Text("•")
                            .foregroundStyle(.secondary)
                        
                        Label("Max. \(round.maxPoints) Punkte", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Punkte-Bearbeitung Card (direkt anklickbar)
                Button {
                    if !isEditingPoints {
                        editedPoints = "\(round.maxPoints)"
                        isEditingPoints = true
                    }
                } label: {
                    VStack(spacing: 4) {
                        if isEditingPoints {
                            TextField("Punkte", text: $editedPoints)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 60)
                                .multilineTextAlignment(.center)
                                .onSubmit {
                                    savePointsChanges()
                                }
                        } else {
                            HStack(spacing: 4) {
                                Text("\(round.maxPoints)")
                                    .font(.system(size: 28, weight: .bold))
                                    .monospacedDigit()
                                Image(systemName: "pencil.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Text("Punkte")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .textCase(.uppercase)
                    }
                    .frame(width: 100)
                    .padding(.vertical, 8)
                    .background(isEditingPoints ? Color.orange.opacity(0.2) : Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        if !isEditingPoints {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                        }
                    }
                }
                .buttonStyle(.plain)
                .help("Punkte bearbeiten")
                
                // Action Buttons
                HStack(spacing: 8) {
                    // Speichern Button (nur sichtbar wenn Punkte bearbeitet werden)
                    if isEditingPoints {
                        Button {
                            savePointsChanges()
                        } label: {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                        }
                        .buttonStyle(.plain)
                        .help("Punkte speichern")
                    }
                    
                    // Name bearbeiten Button
                    Button {
                        if isEditingName {
                            saveNameChanges()
                        } else {
                            editedName = round.name
                            isEditingName = true
                        }
                    } label: {
                        Image(systemName: isEditingName ? "checkmark.circle.fill" : "pencil.circle.fill")
                            .font(.title2)
                            .foregroundStyle(isEditingName ? .green : .blue)
                    }
                    .buttonStyle(.plain)
                    .help(isEditingName ? "Speichern" : "Namen bearbeiten")
                    
                    // Löschen Button
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        Image(systemName: "trash.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    .buttonStyle(.plain)
                    .help("Runde löschen")
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(statusColor.opacity(0.3), lineWidth: 2)
        }
        .alert("Runde löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {}
            Button("Löschen", role: .destructive) {
                viewModel.deleteRound(round, from: quiz)
            }
        } message: {
            Text("Möchtest du '\(round.name)' wirklich löschen?")
        }
    }
    
    private func getRoundNumber() -> Int {
        guard let index = quiz.sortedRounds.firstIndex(where: { $0.id == round.id }) else {
            return 0
        }
        return index + 1
    }
    
    private func saveNameChanges() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            viewModel.updateRoundName(round, newName: trimmedName)
        }
        isEditingName = false
    }
    
    private func savePointsChanges() {
        if let points = Int(editedPoints), points > 0 {
            viewModel.updateRoundMaxPoints(round, maxPoints: points)
        }
        isEditingPoints = false
    }
}
