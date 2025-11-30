//
//  ExecutionView.swift
//  PubRanker
//
//  Created on 31.10.2025
//

import SwiftUI
import SwiftData

struct ExecutionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Quiz> { $0.isActive && !$0.isCompleted }, sort: \Quiz.date, order: .reverse)
    private var activeQuizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @State private var selectedQuiz: Quiz?
    @State private var selectedRound: Round?
    @Bindable private var presentationManager = PresentationManager.shared
    @State private var teamScores: [UUID: String] = [:]
    @State private var saveTask: Task<Void, Never>?
    @FocusState private var focusedTeamId: UUID?
    @State private var showingEditRoundsSheet = false
    @State private var showingCancelConfirmation = false
    
    var body: some View {
        mainView
            .onAppear {
                setupInitialState()
            }
            .onChange(of: selectedWorkflow) { oldValue, newValue in
                handleWorkflowChange(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: activeQuizzes) { oldValue, newValue in
                handleActiveQuizzesChange(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: selectedQuiz?.id) { _, _ in
                handleSelectedQuizChange()
            }
            .sheet(isPresented: $showingEditRoundsSheet, onDismiss: {
                // UI aktualisieren wenn Sheet geschlossen wird
                refreshUI()
            }) {
                editRoundsSheet
                    .frame(minWidth: 900, minHeight: 700)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .confirmationDialog("Quiz abbrechen", isPresented: $showingCancelConfirmation) {
                cancelConfirmationButtons
            } message: {
                cancelConfirmationMessage
            }
    }
    
    private var mainView: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if let quiz = selectedQuiz {
                mainScoringView(for: quiz)
            } else {
                emptyState
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    @ViewBuilder
    private var editRoundsSheet: some View {
        if let quiz = selectedQuiz {
            NavigationView {
                EditRoundsSheetContent(quiz: quiz, viewModel: viewModel)
            }
        }
    }
    
    @ViewBuilder
    private var cancelConfirmationButtons: some View {
        Button("Zur Planung zurückkehren", role: .destructive) {
            if let quiz = selectedQuiz {
                viewModel.cancelQuiz(quiz)
                selectedWorkflow = .planning
            }
        }
        Button("Abbrechen", role: .cancel) { }
    }
    
    private var cancelConfirmationMessage: some View {
        Text("Das Quiz wird gestoppt und alle Runden werden als nicht abgeschlossen markiert. Die eingegebenen Punkte bleiben erhalten.")
    }
    
    private func setupInitialState() {
        viewModel.setContext(modelContext)
        if selectedQuiz == nil && !activeQuizzes.isEmpty {
            selectedQuiz = activeQuizzes.first
            if let quiz = selectedQuiz {
                selectedRound = quiz.currentRound
            }
            loadCurrentScores()
        }
    }
    
    private func handleWorkflowChange(oldValue: ContentView.WorkflowPhase, newValue: ContentView.WorkflowPhase) {
        if oldValue == .planning && newValue == .execution {
            if !activeQuizzes.isEmpty {
                selectedQuiz = activeQuizzes.first
                if let quiz = selectedQuiz {
                    selectedRound = quiz.currentRound
                }
                loadCurrentScores()
            }
        }
    }
    
    private func handleActiveQuizzesChange(oldValue: [Quiz], newValue: [Quiz]) {
        if let selected = selectedQuiz, !newValue.contains(where: { $0.id == selected.id }) {
            selectedQuiz = newValue.first
            if let quiz = selectedQuiz {
                selectedRound = quiz.currentRound
            }
            loadCurrentScores()
        }
    }
    
    private func handleSelectedQuizChange() {
        if let quiz = selectedQuiz {
            selectedRound = quiz.currentRound
        }
        loadCurrentScores()
    }
    
    private func refreshUI() {
        // Lade aktuelle Scores neu
        loadCurrentScores()
        
        // Aktualisiere Presentation Window falls aktiv
        if presentationManager.isPresenting, let quiz = selectedQuiz {
            presentationManager.updateQuiz(quiz)
        }
        
        // Trigger UI refresh durch temporäre State-Änderung
        Task { @MainActor in
            // Kurze Verzögerung um sicherzustellen dass alle Änderungen verarbeitet wurden
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunden
            
            // Lade Scores erneut um sicherzustellen dass alles aktuell ist
            loadCurrentScores()
        }
    }
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Live Quiz", systemImage: "play.circle.fill")
                        .font(.title2)
                        .bold()
                    
                    if !activeQuizzes.isEmpty {
                        Circle()
                            .fill(.green)
                            .frame(width: 12, height: 12)
                            .overlay {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 12, height: 12)
                                    .opacity(0.5)
                                    .scaleEffect(1.5)
                                    .animation(.easeInOut(duration: 1).repeatForever(), value: true)
                            }
                    }
                }
                Text("Punkte eingeben")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Active Quiz List
            if activeQuizzes.isEmpty {
                ContentUnavailableView(
                    "Keine aktiven Quiz",
                    systemImage: "play.circle",
                    description: Text("Starte ein Quiz in der Planungsphase")
                )
            } else {
                List(selection: $selectedQuiz) {
                    Section("Aktive Quiz (\(activeQuizzes.count))") {
                        ForEach(activeQuizzes) { quiz in
                            ActiveQuizRow(quiz: quiz)
                                .tag(quiz)
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
    }
    
    // MARK: - Main Scoring View
    
    private func mainScoringView(for quiz: Quiz) -> some View {
        HStack(spacing: 0) {
            // Main Content - Punkteeingabe
            VStack(spacing: 0) {
                // Top Header
                scoringHeader(quiz)
                
                Divider()
                
                // Content
                if let round = selectedRound {
                    scoringContent(quiz: quiz, round: round)
                } else {
                    ContentUnavailableView(
                        "Keine Runde ausgewählt",
                        systemImage: "list.number",
                        description: Text("Wähle eine Runde aus, um Punkte einzugeben.")
                    )
                }
            }
            
            Divider()
            
            // Right Sidebar - Live Rangliste
            liveLeaderboard(quiz)
                .frame(width: 320)
        }
    }
    
    // MARK: - Scoring Header
    
    private func scoringHeader(_ quiz: Quiz) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                // Live Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 10, height: 10)
                    Text("LIVE")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.red.opacity(0.1))
                .clipShape(Capsule())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.name)
                        .font(.title2)
                        .bold()
                    
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Current Round Badge
                if let displayRound = selectedRound ?? quiz.currentRound {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(displayRound.isCompleted ? "Abgeschlossene Runde" : "Aktuelle Runde")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text(displayRound.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(displayRound.isCompleted ? Color.orange.opacity(0.15) : Color.blue.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Edit Rounds Button
                Button {
                    showingEditRoundsSheet = true
                } label: {
                    Label("Runden bearbeiten", systemImage: "pencil.circle")
                }
                .buttonStyle(.bordered)
                .help("Punkte bereits abgeschlossener Runden bearbeiten")
                
                // Presentation Mode Button
                Button {
                    presentationManager.togglePresentation(for: quiz)
                } label: {
                    Label(
                        presentationManager.isPresenting ? "Präsentation beenden" : "Präsentation starten",
                        systemImage: presentationManager.isPresenting ? "rectangle.fill.on.rectangle.fill" : "rectangle.on.rectangle"
                    )
                }
                .buttonStyle(.bordered)
                .keyboardShortcut("p", modifiers: .command)
                .help("Presentation Mode (⌘P)")
                
                // Cancel Quiz Button
                Button {
                    showingCancelConfirmation = true
                } label: {
                    Label("Abbrechen", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
                .tint(.orange)
                .help("Quiz abbrechen und zurück zur Planung")
                
                // Complete Button
                Button {
                    viewModel.completeQuiz(quiz)
                    selectedWorkflow = .analysis
                } label: {
                    Label("Beenden", systemImage: "flag.checkered")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut("e", modifiers: .command)
                .help("Quiz beenden (⌘E)")
            }
            
            // Progress & Round Navigation
            HStack(spacing: 16) {
                // Progress
                if !quiz.safeRounds.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Fortschritt")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(quiz.completedRoundsCount)/\(quiz.safeRounds.count) Runden")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: quiz.progress)
                            .tint(.green)
                    }
                }
                
                // Round Navigation
                if let currentRound = selectedRound ?? quiz.currentRound {
                    roundNavigation(quiz: quiz, currentRound: currentRound)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .windowBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    // MARK: - Round Navigation
    
    private func roundNavigation(quiz: Quiz, currentRound: Round) -> some View {
        HStack(spacing: 8) {
            // Previous Round
            if let previousRound = getPreviousRound(quiz: quiz, currentRound: currentRound) {
                Button {
                    navigateToRound(previousRound)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.bordered)
                .help("Vorherige Runde: \(previousRound.name)")
            } else {
                Button {
                } label: {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.bordered)
                .disabled(true)
            }
            
            // Round Picker
            Menu {
                ForEach(quiz.sortedRounds) { round in
                    Button {
                        navigateToRound(round)
                    } label: {
                        HStack {
                            Text(round.name)
                            if round.id == currentRound.id {
                                Image(systemName: "checkmark")
                            }
                            if round.isCompleted {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Text((selectedRound ?? currentRound).name)
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
            }
            .buttonStyle(.bordered)
            
            // Next Round
            if let nextRound = getNextRound(quiz: quiz, currentRound: currentRound) {
                Button {
                    navigateToRound(nextRound)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.bordered)
                .help("Nächste Runde: \(nextRound.name)")
            } else {
                Button {
                } label: {
                    Image(systemName: "chevron.right")
                }
                .buttonStyle(.bordered)
                .disabled(true)
            }
        }
    }
    
    // MARK: - Scoring Content
    
    private func scoringContent(quiz: Quiz, round: Round) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Round Info Card
                roundInfoCard(round: round)
                    .padding(.horizontal)
                    .padding(.top)
                
                // Teams Scoring Grid
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams vorhanden",
                        systemImage: "person.3.slash",
                        description: Text("Füge Teams hinzu, um Punkte zu vergeben")
                    )
                    .frame(maxHeight: 400)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(quiz.safeTeams.sorted(by: naturalSort)) { team in
                            teamScoreCard(team: team, round: round, quiz: quiz)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Action Buttons
                actionButtons(quiz: quiz, round: round)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
        }
    }
    
    // MARK: - Round Info Card
    
    private func roundInfoCard(round: Round) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(round.name)
                    .font(.title)
                    .bold()
                Text("Max. \(round.maxPoints) Punkte pro Team")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if round.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Abgeschlossen")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
            } else {
                HStack(spacing: 6) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 8, height: 8)
                    Text("Aktiv")
                        .font(.subheadline)
                        .foregroundStyle(.blue)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.blue.opacity(0.1))
                .clipShape(Capsule())
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }
    
    // MARK: - Team Score Card
    
    private func teamScoreCard(team: Team, round: Round, quiz: Quiz) -> some View {
        let rank = viewModel.getTeamRank(for: team, in: quiz)
        let currentScore = getScoreValue(for: team)
        let teamColor = Color(hex: team.color) ?? .blue
        
        return VStack(spacing: 12) {
            // Team Header
            HStack {
                // Rank Badge
                if rank <= 3 {
                    Image(systemName: rank == 1 ? "medal.fill" : rank == 2 ? "medal.fill" : "medal.fill")
                        .foregroundStyle(rank == 1 ? .yellow : rank == 2 ? .gray : .brown)
                        .font(.title3)
                } else {
                    Text("\(rank)")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .frame(width: 24, height: 24)
                        .background(Color.secondary.opacity(0.2))
                        .clipShape(Circle())
                }
                
                // Team Name & Color
                HStack(spacing: 8) {
                    Circle()
                        .fill(teamColor)
                        .frame(width: 12, height: 12)
                    Text(team.name)
                        .font(.headline)
                        .lineLimit(1)
                }
                
                Spacer()
                
                // Total Score
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(team.getTotalScore(for: quiz))")
                        .font(.title3)
                        .bold()
                    Text("Gesamt")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Divider()
            
            // Score Input
            VStack(spacing: 8) {
                // Current Score Display
                if let savedScore = team.getScore(for: round), savedScore > 0 {
                    Text("Gespeichert: \(savedScore)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                // Input Controls
                HStack(spacing: 12) {
                    // Decrement
                    Button {
                        decrementScore(for: team, maxPoints: round.maxPoints)
                        // Save immediately for button clicks
                        let newValue = getScoreValue(for: team)
                        if newValue != team.getScore(for: round) {
                            saveScore(for: team, in: round, points: newValue)
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(currentScore > 0 ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(currentScore <= 0)
                    
                    // Text Field
                    TextField("0", text: Binding(
                        get: { 
                            let value = teamScores[team.id] ?? "0"
                            return value.isEmpty ? "0" : value
                        },
                        set: { newValue in
                            // Allow user to type freely - only filter numbers
                            let filtered = newValue.filter { $0.isNumber }
                            
                            // Update display value - allow empty during typing
                            if !filtered.isEmpty {
                                // Limit to maxPoints digits to prevent overflow
                                let maxDigits = String(round.maxPoints).count
                                let limited = String(filtered.prefix(maxDigits))
                                teamScores[team.id] = limited
                            } else {
                                // Allow empty field during editing
                                teamScores[team.id] = ""
                            }
                            
                            // Debounced auto-save - cancel previous task and start new one
                            saveTask?.cancel()
                            if let value = Int(filtered), value >= 0, focusedTeamId == team.id {
                                saveTask = Task {
                                    try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second delay
                                    if !Task.isCancelled && focusedTeamId == team.id {
                                        await MainActor.run {
                                            let clampedValue = min(value, round.maxPoints)
                                            // Only save if value actually changed
                                            if clampedValue != team.getScore(for: round) {
                                                teamScores[team.id] = "\(clampedValue)"
                                                saveScore(for: team, in: round, points: clampedValue)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    ))
                    .focused($focusedTeamId, equals: team.id)
                    .textFieldStyle(.plain)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(width: 100)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(nsColor: .controlBackgroundColor))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(focusedTeamId == team.id ? teamColor : Color.clear, lineWidth: 3)
                            )
                    )
                    .onChange(of: focusedTeamId) { oldValue, newValue in
                        // When field loses focus, save and clamp value
                        if oldValue == team.id && newValue != team.id {
                            saveTask?.cancel()
                            let currentValue = Int(teamScores[team.id] ?? "0") ?? 0
                            let clampedValue = min(max(currentValue, 0), round.maxPoints)
                            teamScores[team.id] = "\(clampedValue)"
                            // Only save if value changed
                            if clampedValue != team.getScore(for: round) {
                                saveScore(for: team, in: round, points: clampedValue)
                            }
                        }
                    }
                    .onSubmit {
                        // Save and clamp when user presses Enter
                        saveTask?.cancel()
                        let currentValue = Int(teamScores[team.id] ?? "0") ?? 0
                        let clampedValue = min(max(currentValue, 0), round.maxPoints)
                        teamScores[team.id] = "\(clampedValue)"
                        // Only save if value changed
                        if clampedValue != team.getScore(for: round) {
                            saveScore(for: team, in: round, points: clampedValue)
                        }
                    }
                    
                    // Increment
                    Button {
                        incrementScore(for: team, maxPoints: round.maxPoints)
                        // Save immediately for button clicks
                        let newValue = getScoreValue(for: team)
                        if newValue != team.getScore(for: round) {
                            saveScore(for: team, in: round, points: newValue)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(currentScore < round.maxPoints ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(currentScore >= round.maxPoints)
                }
                
                // Max Points Indicator
                Text("/ \(round.maxPoints)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(rank <= 3 ? teamColor.opacity(0.3) : Color.clear, lineWidth: 2)
        )
    }
    
    // MARK: - Action Buttons
    
    private func actionButtons(quiz: Quiz, round: Round) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                Button {
                    clearAllScores()
                } label: {
                    Label("Zurücksetzen", systemImage: "arrow.counterclockwise")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button {
                    saveAllScores(quiz: quiz, round: round)
                } label: {
                    Label("Alle speichern", systemImage: "checkmark.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.return, modifiers: .command)
            }
            
            // Complete Round Button
            if let nextRound = getNextRound(quiz: quiz, currentRound: round) {
                Button {
                    saveAllScores(quiz: quiz, round: round)
                    viewModel.completeRound(round)
                    // Navigate to next round
                    selectedRound = nextRound
                    loadCurrentScores()
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Runde abschließen & weiter")
                        Text("→ \(nextRound.name)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .controlSize(.large)
            } else if !round.isCompleted {
                Button {
                    saveAllScores(quiz: quiz, round: round)
                    viewModel.completeRound(round)
                } label: {
                    HStack {
                        Image(systemName: "flag.checkered")
                        Text("Letzte Runde abschließen")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                .controlSize(.large)
            }
        }
    }
    
    // MARK: - Live Leaderboard
    
    private func liveLeaderboard(_ quiz: Quiz) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label("Live Rangliste", systemImage: "chart.bar.fill")
                    .font(.headline)
                Spacer()
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Teams List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(quiz.getTeamRankings(), id: \.team.id) { ranking in
                        leaderboardRow(team: ranking.team, rank: ranking.rank, quiz: quiz)
                            .id("\(ranking.team.id)-\(ranking.team.getTotalScore(for: quiz))") // Force update when score changes
                    }
                }
                .padding()
            }
            // Remove animation to improve performance - updates will still happen but without animation lag
        }
        .background(Color(nsColor: .windowBackgroundColor))
    }
    
    private func leaderboardRow(team: Team, rank: Int, quiz: Quiz) -> some View {
        let teamColor = Color(hex: team.color) ?? .blue
        
        return HStack(spacing: 12) {
            // Rank
            if rank <= 3 {
                Image(systemName: rank == 1 ? "medal.fill" : rank == 2 ? "medal.fill" : "medal.fill")
                    .foregroundStyle(rank == 1 ? .yellow : rank == 2 ? .gray : .brown)
                    .font(.title3)
                    .frame(width: 32)
            } else {
                Text("\(rank)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .frame(width: 32)
            }
            
            // Team Color & Name
            HStack(spacing: 8) {
                Circle()
                    .fill(teamColor)
                    .frame(width: 10, height: 10)
                Text(team.name)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Score - Simple text without transition for better performance
            Text("\(team.getTotalScore(for: quiz))")
                .font(.headline)
                .bold()
                .monospacedDigit()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(rank <= 3 ? teamColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(rank <= 3 ? teamColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    /// Natural sort function that handles numbers correctly (Team 1, Team 2, Team 10 instead of Team 1, Team 10, Team 2)
    private func naturalSort(_ team1: Team, _ team2: Team) -> Bool {
        let name1 = team1.name
        let name2 = team2.name
        
        // Extract numbers from strings and compare
        let numbers1 = extractNumbers(from: name1)
        let numbers2 = extractNumbers(from: name2)
        
        // Compare non-numeric prefixes first
        let prefix1 = name1.components(separatedBy: CharacterSet.decimalDigits).first ?? ""
        let prefix2 = name2.components(separatedBy: CharacterSet.decimalDigits).first ?? ""
        
        if prefix1 != prefix2 {
            return prefix1.localizedCompare(prefix2) == .orderedAscending
        }
        
        // If prefixes are the same, compare numbers
        if let num1 = numbers1.first, let num2 = numbers2.first {
            if num1 != num2 {
                return num1 < num2
            }
        }
        
        // Fallback to standard comparison
        return name1.localizedStandardCompare(name2) == .orderedAscending
    }
    
    /// Extract all numbers from a string
    private func extractNumbers(from string: String) -> [Int] {
        let regex = try? NSRegularExpression(pattern: "\\d+", options: [])
        let nsString = string as NSString
        let results = regex?.matches(in: string, options: [], range: NSRange(location: 0, length: nsString.length))
        return results?.compactMap { result in
            Int(nsString.substring(with: result.range))
        } ?? []
    }
    
    private func getScoreValue(for team: Team) -> Int {
        Int(teamScores[team.id] ?? "0") ?? 0
    }
    
    private func incrementScore(for team: Team, maxPoints: Int) {
        let current = getScoreValue(for: team)
        if current < maxPoints {
            teamScores[team.id] = "\(current + 1)"
        }
    }
    
    private func decrementScore(for team: Team, maxPoints: Int) {
        let current = getScoreValue(for: team)
        if current > 0 {
            teamScores[team.id] = "\(current - 1)"
        }
    }
    
    private func saveScore(for team: Team, in round: Round, points: Int? = nil) {
        let score = points ?? getScoreValue(for: team)
        viewModel.updateScore(for: team, in: round, points: score)
        
        // Update presentation window if active
        if presentationManager.isPresenting, let quiz = selectedQuiz {
            presentationManager.updateQuiz(quiz)
        }
    }
    
    private func saveAllScores(quiz: Quiz, round: Round) {
        for team in quiz.safeTeams {
            let score = getScoreValue(for: team)
            viewModel.updateScore(for: team, in: round, points: score)
        }
    }
    
    private func clearAllScores() {
        for team in selectedQuiz?.safeTeams ?? [] {
            teamScores[team.id] = "0"
        }
    }
    
    private func loadCurrentScores() {
        guard let quiz = selectedQuiz else { return }
        
        // Initialize selectedRound if not set
        if selectedRound == nil {
            selectedRound = quiz.currentRound
        }
        
        guard let round = selectedRound else { return }
        
        teamScores.removeAll()
        for team in quiz.safeTeams {
            if let score = team.getScore(for: round) {
                teamScores[team.id] = "\(score)"
            } else {
                teamScores[team.id] = "0"
            }
        }
    }
    
    private func getNextRound(quiz: Quiz, currentRound: Round) -> Round? {
        let sortedRounds = quiz.sortedRounds
        guard let currentIndex = sortedRounds.firstIndex(where: { $0.id == currentRound.id }) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        return nextIndex < sortedRounds.count ? sortedRounds[nextIndex] : nil
    }
    
    private func getPreviousRound(quiz: Quiz, currentRound: Round) -> Round? {
        let sortedRounds = quiz.sortedRounds
        guard let currentIndex = sortedRounds.firstIndex(where: { $0.id == currentRound.id }) else {
            return nil
        }
        let previousIndex = currentIndex - 1
        return previousIndex >= 0 ? sortedRounds[previousIndex] : nil
    }
    
    private func navigateToRound(_ round: Round) {
        guard let quiz = selectedQuiz else { return }
        
        // Save current scores before switching
        if let currentRound = selectedRound {
            saveAllScores(quiz: quiz, round: currentRound)
        }
        
        // Set the selected round
        selectedRound = round
        
        // Load scores for new round
        teamScores.removeAll()
        for team in quiz.safeTeams {
            if let score = team.getScore(for: round) {
                teamScores[team.id] = "\(score)"
            } else {
                teamScores[team.id] = "0"
            }
        }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "Kein aktives Quiz",
            systemImage: "play.circle",
            description: Text("Starte ein Quiz in der Planungsphase")
        )
    }
}

// MARK: - Edit Rounds Sheet Content

struct EditRoundsSheetContent: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRound: Round?
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            // Sidebar - Runden Liste
            List(selection: $selectedRound) {
                Section("Runden bearbeiten") {
                    ForEach(quiz.sortedRounds) { round in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(round.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                if round.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                        .font(.caption)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                        .font(.caption)
                                }
                            }
                            
                            Text("Max. \(round.maxPoints) Punkte")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                        .tag(round)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Runden")
        } detail: {
            if let round = selectedRound {
                RoundEditDetailContent(round: round, quiz: quiz, viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    "Runde auswählen",
                    systemImage: "list.number",
                    description: Text("Wähle eine Runde aus, um die Punkte zu bearbeiten")
                )
            }
        }
        .navigationTitle("Punkte bearbeiten")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Fertig") {
                    // Speichere alle ungespeicherten Änderungen vor dem Schließen
                    saveAllPendingChanges()
                    dismiss()
                }
            }
        }
        .onAppear {
            if selectedRound == nil && !quiz.safeRounds.isEmpty {
                selectedRound = quiz.sortedRounds.first
            }
        }
    }
    
    private func saveAllPendingChanges() {
        // Speichere alle ungespeicherten Änderungen in allen Runden
        // Dies ist ein Sicherheitsnetz falls der Benutzer vergessen hat zu speichern
        viewModel.saveContext()
    }
}

struct RoundEditDetailContent: View {
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var teamScores: [UUID: String] = [:]
    @State private var hasChanges = false
    @State private var editingRoundSettings = false
    @State private var tempRoundName = ""
    @State private var tempMaxPoints = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    if editingRoundSettings {
                        // Editing Mode
                        VStack(alignment: .leading, spacing: 8) {
                            TextField("Rundenname", text: $tempRoundName)
                                .textFieldStyle(.roundedBorder)
                                .font(.title2)
                            
                            HStack(spacing: 8) {
                                Text("Max. Punkte:")
                                    .font(.subheadline)
                                TextField("10", text: $tempMaxPoints)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                    .onChange(of: tempMaxPoints) { _, newValue in
                                        // Nur Zahlen erlauben
                                        let filtered = newValue.filter { $0.isNumber }
                                        if filtered != newValue {
                                            tempMaxPoints = filtered
                                        }
                                    }
                                Text("pro Team")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } else {
                        // Display Mode
                        VStack(alignment: .leading, spacing: 4) {
                            Text(round.name)
                                .font(.title2)
                                .bold()
                            
                            Text("Max. \(round.maxPoints) Punkte pro Team")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    // Edit/Save Buttons
                    if editingRoundSettings {
                        HStack(spacing: 8) {
                            Button("Abbrechen") {
                                cancelRoundEditing()
                            }
                            .buttonStyle(.bordered)
                            
                            Button("Speichern") {
                                saveRoundSettings()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    } else {
                        HStack(spacing: 12) {
                            Button {
                                startRoundEditing()
                            } label: {
                                Label("Punkte bearbeiten", systemImage: "slider.horizontal.3")
                            }
                            .buttonStyle(.bordered)
                            .help("Maximale Punkte und Rundenname bearbeiten")
                            
                            if round.isCompleted {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.green)
                                    Text("Abgeschlossen")
                                        .font(.subheadline)
                                        .foregroundStyle(.green)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                if hasChanges {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Du hast ungespeicherte Änderungen")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                        Spacer()
                        Button("Speichern") {
                            saveAllScores()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Warnung bei Max-Punkte Änderung
                if editingRoundSettings, let newMaxPoints = Int(tempMaxPoints), newMaxPoints > 0 {
                    let teamsWithTooManyPoints = quiz.safeTeams.compactMap { team -> String? in
                        if let score = team.getScore(for: round), score > newMaxPoints {
                            return team.name
                        }
                        return nil
                    }
                    
                    if !teamsWithTooManyPoints.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.red)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Achtung: Einige Teams haben mehr Punkte als das neue Maximum")
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                Text("Betroffene Teams: \(teamsWithTooManyPoints.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("Diese werden automatisch auf \(newMaxPoints) Punkte begrenzt.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Teams Grid
            ScrollView {
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams vorhanden",
                        systemImage: "person.3.slash",
                        description: Text("Füge Teams hinzu, um Punkte zu vergeben")
                    )
                    .frame(maxHeight: 400)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 24),
                        GridItem(.flexible(), spacing: 24)
                    ], spacing: 24) {
                        ForEach(quiz.safeTeams.sorted(by: { $0.name < $1.name })) { team in
                            TeamEditCardContent(
                                team: team,
                                round: round,
                                currentScore: Binding(
                                    get: { teamScores[team.id] ?? "0" },
                                    set: { newValue in
                                        teamScores[team.id] = newValue
                                        hasChanges = true
                                    }
                                ),
                                maxPoints: round.maxPoints
                            )
                        }
                    }
                    .padding(24)
                }
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Zurücksetzen") {
                        loadCurrentScores()
                        hasChanges = false
                    }
                    .buttonStyle(.bordered)
                    .disabled(!hasChanges)
                    
                    Button("Alle speichern") {
                        saveAllScores()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!hasChanges)
                }
                
                if !round.isCompleted {
                    Button("Runde als abgeschlossen markieren") {
                        saveAllScores()
                        viewModel.completeRound(round)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                } else {
                    Button("Runde wieder öffnen") {
                        round.isCompleted = false
                        viewModel.saveContext()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .onAppear {
            loadCurrentScores()
        }
        .onChange(of: round.id) { _, _ in
            loadCurrentScores()
            hasChanges = false
            editingRoundSettings = false
        }
    }
    
    private func loadCurrentScores() {
        teamScores.removeAll()
        for team in quiz.safeTeams {
            if let score = team.getScore(for: round) {
                teamScores[team.id] = "\(score)"
            } else {
                teamScores[team.id] = "0"
            }
        }
    }
    
    private func saveAllScores() {
        for team in quiz.safeTeams {
            let scoreText = teamScores[team.id] ?? "0"
            let score = Int(scoreText) ?? 0
            viewModel.updateScore(for: team, in: round, points: score)
        }
        hasChanges = false
    }
    
    private func startRoundEditing() {
        tempRoundName = round.name
        tempMaxPoints = "\(round.maxPoints)"
        editingRoundSettings = true
    }
    
    private func cancelRoundEditing() {
        editingRoundSettings = false
        tempRoundName = ""
        tempMaxPoints = ""
    }
    
    private func saveRoundSettings() {
        var needsReload = false
        
        // Update round name
        if !tempRoundName.isEmpty && tempRoundName != round.name {
            round.name = tempRoundName
        }
        
        // Update max points
        if let newMaxPoints = Int(tempMaxPoints), newMaxPoints > 0 && newMaxPoints != round.maxPoints {
            round.maxPoints = newMaxPoints
            needsReload = true
            
            // Warnung wenn Teams mehr Punkte haben als das neue Maximum
            let teamsWithTooManyPoints = quiz.safeTeams.compactMap { team -> (Team, Int)? in
                if let score = team.getScore(for: round), score > newMaxPoints {
                    return (team, score)
                }
                return nil
            }
            
            if !teamsWithTooManyPoints.isEmpty {
                // Automatisch auf neue Maximalpunktzahl begrenzen
                for (team, _) in teamsWithTooManyPoints {
                    viewModel.updateScore(for: team, in: round, points: newMaxPoints)
                }
            }
        }
        
        viewModel.saveContext()
        editingRoundSettings = false
        
        if needsReload {
            loadCurrentScores()
        }
    }
}

struct TeamEditCardContent: View {
    let team: Team
    let round: Round
    @Binding var currentScore: String
    let maxPoints: Int
    
    private var teamColor: Color {
        Color(hex: team.color) ?? .blue
    }
    
    private var scoreValue: Int {
        Int(currentScore) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Team Header
            HStack {
                Circle()
                    .fill(teamColor)
                    .frame(width: 16, height: 16)
                
                Text(team.name)
                    .font(.title2)
                    .bold()
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Score Input
            VStack(spacing: 12) {
                HStack(spacing: 16) {
                    // Decrement
                    Button {
                        if scoreValue > 0 {
                            currentScore = "\(scoreValue - 1)"
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(scoreValue > 0 ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(scoreValue <= 0)
                    .frame(width: 44, height: 44)
                    
                    // Text Field
                    TextField("0", text: $currentScore)
                        .textFieldStyle(.plain)
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(width: 120, height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(teamColor, lineWidth: 3)
                                )
                        )
                        .onChange(of: currentScore) { _, newValue in
                            // Filter nur Zahlen
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                currentScore = filtered
                            }
                            // Begrenze auf maxPoints
                            if let value = Int(filtered), value > maxPoints {
                                currentScore = "\(maxPoints)"
                            }
                        }
                    
                    // Increment
                    Button {
                        if scoreValue < maxPoints {
                            currentScore = "\(scoreValue + 1)"
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle(scoreValue < maxPoints ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(scoreValue >= maxPoints)
                    .frame(width: 44, height: 44)
                }
                
                // Max Points Indicator
                Text("/ \(maxPoints)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(teamColor.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Active Quiz Row

struct ActiveQuizRow: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text(quiz.name)
                    .font(.headline)
            }
            
            if let currentRound = quiz.currentRound {
                HStack(spacing: 8) {
                    Label(currentRound.name, systemImage: "play.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                }
            }
            
            ProgressView(value: quiz.progress)
                .tint(.green)
                .frame(height: 4)
            
            HStack(spacing: 8) {
                Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                    .font(.caption2)
                Label("\(quiz.completedRoundsCount)/\(quiz.safeRounds.count)", systemImage: "list.number")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
