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
            .confirmationDialog(L10n.Execution.Cancel.title, isPresented: $showingCancelConfirmation) {
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
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // Empty group to override default sidebar toggle
            }
        }
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
        Button(L10n.Execution.Cancel.returnToPlanning, role: .destructive) {
            if let quiz = selectedQuiz {
                viewModel.cancelQuiz(quiz)
                selectedWorkflow = .planning
            }
        }
        Button(L10n.Navigation.cancel, role: .cancel) { }
    }
    
    private var cancelConfirmationMessage: some View {
        Text(L10n.Execution.Cancel.message)
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
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                HStack {
                    Label(L10n.Execution.liveQuiz, systemImage: "play.circle.fill")
                        .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)

                    if !activeQuizzes.isEmpty {
                        Circle()
                            .fill(Color.appSuccess)
                            .frame(width: 12, height: 12)
                            .overlay {
                                Circle()
                                    .fill(Color.appSuccess)
                                    .frame(width: 12, height: 12)
                                    .opacity(0.5)
                                    .scaleEffect(1.5)
                                    .animation(.easeInOut(duration: 1).repeatForever(), value: true)
                            }
                    }
                }
                Text(L10n.Execution.enterScores)
                    .font(Font.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            
            Divider()
            
            // Active Quiz List
            if activeQuizzes.isEmpty {
                ContentUnavailableView(
                    L10n.Execution.noActiveQuizzes,
                    systemImage: "play.circle",
                    description: Text(L10n.Execution.noActiveQuizzesDescription())
                )
            } else {
                List(selection: $selectedQuiz) {
                    Section(L10n.Execution.activeQuizzesSection(activeQuizzes.count)) {
                        ForEach(activeQuizzes) { quiz in
                            ActiveQuizRow(quiz: quiz)
                                .tag(quiz)
                        }
                    }
                }
                .listStyle(.sidebar)
            }
        }
        .navigationTitle("")
    }

    // MARK: - Main Scoring View
    
    private func mainScoringView(for quiz: Quiz) -> some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Main Content - Punkteeingabe
                VStack(spacing: 0) {
                    // Top Header
                    scoringHeader(quiz)
                    
                    Divider()
                    
                    // Content
                    if let round = selectedRound {
                        VStack(spacing: 0) {
                            scoringContent(quiz: quiz, round: round)
                            
                            Divider()
                            
                            // Action Buttons - Fixed at bottom
                            actionButtons(quiz: quiz, round: round)
                                .padding(AppSpacing.md)
                        }
                    } else {
                        ContentUnavailableView(
                            L10n.Execution.noRoundSelected,
                            systemImage: "list.number",
                            description: Text(L10n.Execution.noRoundDescription())
                        )
                    }
                }
                
                // Right Sidebar - Live Rangliste (nur anzeigen wenn genug Platz)
                if geometry.size.width > 1200 {
                    Divider()
                    
                    liveLeaderboard(quiz)
                        .frame(width: 320)
                }
            }
        }
    }
    
    // MARK: - Scoring Header
    
    private func scoringHeader(_ quiz: Quiz) -> some View {
        VStack(spacing: AppSpacing.xs) {
            // Top Row - Quiz Info & Live Indicator
            HStack(alignment: .center, spacing: AppSpacing.sm) {
                // Live Indicator
                HStack(spacing: AppSpacing.xxs) {
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 10, height: 10)
                    Text(L10n.Execution.live)
                        .font(Font.system(size: 11, weight: .regular))
                        .bold()
                        .foregroundStyle(Color.appAccent)
                }
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxxs)
                .background(Color.appAccent.opacity(0.1))
                .clipShape(Capsule())

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(quiz.name)
                        .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)

                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                            .font(Font.system(size: 11, weight: .regular))
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Current Round Badge
                if let displayRound = selectedRound ?? quiz.currentRound {
                    VStack(alignment: .trailing, spacing: AppSpacing.xxxs) {
                        Text(displayRound.isCompleted ? L10n.Execution.roundCompleted : L10n.Execution.roundCurrent)
                            .font(Font.system(size: 10, weight: .regular))
                            .foregroundStyle(Color.appTextSecondary)
                        Text(displayRound.name)
                            .font(Font.system(size: 15, weight: .medium))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxxs)
                    .background(displayRound.isCompleted ? Color.appAccent.opacity(0.15) : Color.appPrimary.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                }
            }
            
            // Action Buttons Row - Wraps on smaller screens
            HStack(spacing: AppSpacing.xxs) {
                // Edit Rounds Button
                Button {
                    showingEditRoundsSheet = true
                } label: {
                    Label(L10n.Execution.roundsEdit, systemImage: "pencil.circle")
                }
                .secondaryGradientButton()
                .help(L10n.Execution.roundsEditHelp)
                
                // Presentation Mode Button
                Button {
                    presentationManager.togglePresentation(for: quiz)
                } label: {
                    Label(
                        presentationManager.isPresenting ? L10n.Execution.presentationEnd : L10n.Execution.presentationStart,
                        systemImage: presentationManager.isPresenting ? "rectangle.fill.on.rectangle.fill" : "rectangle.on.rectangle"
                    )
                }
                .primaryGradientButton()
                .keyboardShortcut("p", modifiers: .command)
                .help(L10n.Execution.presentationHelp)
                
                // Cancel Quiz Button
                Button {
                    showingCancelConfirmation = true
                } label: {
                    Label(L10n.Navigation.cancel, systemImage: "xmark.circle")
                }
                .accentGradientButton()
                .help(L10n.Execution.cancelHelp)
                
                // Complete Button
                Button {
                    viewModel.completeQuiz(quiz)
                    selectedWorkflow = .analysis
                } label: {
                    Label(L10n.Execution.complete, systemImage: "flag.checkered")
                }
                .accentGradientButton()
                .keyboardShortcut("e", modifiers: .command)
                .help(L10n.Execution.completeHelp)
                
                Spacer()
            }
            
            // Progress & Round Navigation
            VStack(spacing: AppSpacing.xxs) {
                // Progress
                if !quiz.safeRounds.isEmpty {
                    VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                        HStack {
                            Text(L10n.Execution.progress)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            Spacer()
                            Text(L10n.Execution.roundsProgress(quiz.completedRoundsCount, quiz.safeRounds.count))
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        ProgressView(value: quiz.progress)
                            .tint(Color.appSuccess)
                    }
                }
                
                // Round Navigation
                if let currentRound = selectedRound ?? quiz.currentRound {
                    roundNavigation(quiz: quiz, currentRound: currentRound)
                }
            }
        }
        .padding(AppSpacing.md)
    }
    
    // MARK: - Round Navigation
    
    private func roundNavigation(quiz: Quiz, currentRound: Round) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            // Previous Round
            if let previousRound = getPreviousRound(quiz: quiz, currentRound: currentRound) {
                Button {
                    navigateToRound(previousRound)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .secondaryGradientButton()
                .help(L10n.Execution.roundPrevious(previousRound.name))
            } else {
                Button {
                } label: {
                    Image(systemName: "chevron.left")
                }
                .secondaryGradientButton()
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
                                    .foregroundStyle(Color.appSuccess)
                            }
                        }
                    }
                }
            } label: {
                HStack(spacing: AppSpacing.xxxs) {
                    Text((selectedRound ?? currentRound).name)
                        .font(.subheadline)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxxs)
            }
            .secondaryGradientButton()
            
            // Next Round
            if let nextRound = getNextRound(quiz: quiz, currentRound: currentRound) {
                Button {
                    navigateToRound(nextRound)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .secondaryGradientButton()
                .help(L10n.Execution.roundNext(nextRound.name))
            } else {
                Button {
                } label: {
                    Image(systemName: "chevron.right")
                }
                .secondaryGradientButton()
                .disabled(true)
            }
        }
    }
    
    // MARK: - Scoring Content
    
    private func scoringContent(quiz: Quiz, round: Round) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                
                // Teams Scoring Grid
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        L10n.Execution.noTeams,
                        systemImage: "person.3.slash",
                        description: Text(L10n.Execution.noTeamsDescription())
                    )
                    .frame(maxHeight: 400)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: AppSpacing.xs),
                        GridItem(.flexible(), spacing: AppSpacing.xs),
                        GridItem(.flexible(), spacing: AppSpacing.xs)
                    ], spacing: AppSpacing.xs) {
                        ForEach(quiz.safeTeams.sorted(by: naturalSort)) { team in
                            teamScoreCard(team: team, round: round, quiz: quiz)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.bottom, AppSpacing.screenPadding)
        }
    }
        
    // MARK: - Team Score Card

    private func teamScoreCard(team: Team, round: Round, quiz: Quiz) -> some View {
        let rank = viewModel.getTeamRank(for: team, in: quiz)
        let currentScore = getScoreValue(for: team)
        let teamColor = Color(hex: team.color) ?? Color.appPrimary
        let isTopThree = rank <= 3

        return VStack(spacing: AppSpacing.sm) {
            // Team Header
            HStack(spacing: AppSpacing.sm) {
                // Rank Badge
                if isTopThree {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: rank == 1 ? [Color.appSecondary, Color.appSecondary.opacity(0.8)] :
                                            rank == 2 ? [Color.appTextSecondary, Color.appTextSecondary.opacity(0.8)] :
                                            [Color.appPrimary, Color.appPrimary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 32, height: 32)
                            .shadow(AppShadow.sm)
                        
                        Image(systemName: "medal.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                } else {
                    Text("\(rank)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(width: 32, height: 32)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .fill(Color.appBackgroundSecondary)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(Color.appTextTertiary.opacity(0.3), lineWidth: 1)
                        }
                }

                // Team Name & Color
                HStack(spacing: AppSpacing.xs) {
                    Circle()
                        .fill(teamColor)
                        .frame(width: 16, height: 16)
                        .shadow(color: teamColor.opacity(0.4), radius: 2, y: 1)
                    
                    Text(team.name)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.top, AppSpacing.md)

            Divider()
                .padding(.horizontal, AppSpacing.md)

            // Score Input
            VStack(spacing: AppSpacing.xs) {
                // Current Score Display - Feste Höhe um Layout-Shift zu vermeiden
                HStack {
                    if let savedScore = team.getScore(for: round), savedScore > 0 {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.appSuccess)
                            Text(L10n.Execution.scoreSaved(savedScore))
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                        }
                    } else {
                        // Platzhalter für konsistente Höhe
                        Text(" ")
                            .font(.caption)
                            .opacity(0)
                    }
                    Spacer()
                }
                .frame(height: 16)
                .padding(.horizontal, AppSpacing.md)

                // Input Controls
                HStack(spacing: AppSpacing.sm) {
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
                            .font(.title3)
                            .foregroundStyle(currentScore > 0 ? Color.appAccent : Color.appTextTertiary)
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
                                if let maxPts = round.maxPoints {
                                    let maxDigits = String(maxPts).count
                                    let limited = String(filtered.prefix(maxDigits))
                                    teamScores[team.id] = limited
                                } else {
                                    teamScores[team.id] = filtered
                                }
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
                                            let clampedValue: Int
                                            if let maxPts = round.maxPoints {
                                                clampedValue = min(value, maxPts)
                                            } else {
                                                clampedValue = value
                                            }
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
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .frame(width: 70)
                    .background(
                        RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                            .fill(Color.appBackgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .stroke(focusedTeamId == team.id ? teamColor : Color.clear, lineWidth: 2)
                            )
                    )
                    .onChange(of: focusedTeamId) { oldValue, newValue in
                        // When field loses focus, save and clamp value
                        if oldValue == team.id && newValue != team.id {
                            saveTask?.cancel()
                            let currentValue = Int(teamScores[team.id] ?? "0") ?? 0
                            let clampedValue: Int
                            if let maxPts = round.maxPoints {
                                clampedValue = min(max(currentValue, 0), maxPts)
                            } else {
                                clampedValue = max(currentValue, 0)
                            }
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
                        let clampedValue: Int
                        if let maxPts = round.maxPoints {
                            clampedValue = min(max(currentValue, 0), maxPts)
                        } else {
                            clampedValue = max(currentValue, 0)
                        }
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
                            .font(.title3)
                            .foregroundStyle({
                                if let maxPts = round.maxPoints {
                                    return currentScore < maxPts ? Color.appSuccess : Color.appTextTertiary
                                } else {
                                    return Color.appSuccess
                                }
                            }())
                    }
                    .buttonStyle(.plain)
                    .disabled({
                        if let maxPts = round.maxPoints {
                            return currentScore >= maxPts
                        } else {
                            return false
                        }
                    }())
                }

                // Max Points Indicator
                if let maxPts = round.maxPoints {
                    Text("/ \(maxPts)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                } else {
                    Text(L10n.Round.unlimited)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.bottom, AppSpacing.md)
        }
        .appCard(style: isTopThree ? .elevated : .default, cornerRadius: AppCornerRadius.md)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(isTopThree ? teamColor.opacity(0.3) : Color.appTextTertiary.opacity(0.15), lineWidth: 1.5)
        )
    }
    
    // MARK: - Action Buttons
    
    private func actionButtons(quiz: Quiz, round: Round) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            // Titel
            Text(L10n.Execution.actions)
                .font(.headline)
                .foregroundStyle(Color.appTextSecondary)
            
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Button {
                        clearAllScores()
                    } label: {
                        Label(L10n.Execution.reset, systemImage: "arrow.counterclockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .secondaryGradientButton(size: .large)
                    
                    Button {
                        saveAllScores(quiz: quiz, round: round)
                    } label: {
                        Label(L10n.Execution.saveAll, systemImage: "checkmark.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryGradientButton(size: .large)
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
                            Text(L10n.Execution.roundCompleteAndContinue)
                            Text("→ \(nextRound.name)")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .successGradientButton(size: .large)
                } else if !round.isCompleted {
                    Button {
                        saveAllScores(quiz: quiz, round: round)
                        viewModel.completeRound(round)
                    } label: {
                        HStack {
                            Image(systemName: "flag.checkered")
                            Text(L10n.Execution.roundCompleteLast)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .accentGradientButton(size: .large)
                }
            }
        }
    }
    
    // MARK: - Live Leaderboard
    
    private func liveLeaderboard(_ quiz: Quiz) -> some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Label(L10n.Execution.leaderboardLive, systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
            }
            .padding(AppSpacing.md)
            
            Divider()
            
            // Teams List
            ScrollView {
                LazyVStack(spacing: AppSpacing.xxs) {
                    ForEach(quiz.getTeamRankings(), id: \.team.id) { ranking in
                        leaderboardRow(team: ranking.team, rank: ranking.rank, quiz: quiz)
                            .id("\(ranking.team.id)-\(ranking.team.getTotalScore(for: quiz))") // Force update when score changes
                    }
                }
                .padding(AppSpacing.md)
            }
            // Remove animation to improve performance - updates will still happen but without animation lag
        }
        .background(Color.appBackground)
    }
    
    private func leaderboardRow(team: Team, rank: Int, quiz: Quiz) -> some View {
        let teamColor = Color(hex: team.color) ?? Color.appPrimary
        let isTopThree = rank <= 3

        return HStack(spacing: AppSpacing.xs) {
            // Rank
            if isTopThree {
                Image(systemName: rank == 1 ? "medal.fill" : rank == 2 ? "medal.fill" : "medal.fill")
                    .foregroundStyle(rank == 1 ? Color.appSecondary : rank == 2 ? Color.appTextSecondary : Color.appPrimary)
                    .font(.title3)
                    .frame(width: 32)
            } else {
                Text("\(rank)")
                    .font(.headline)
                    .foregroundStyle(Color.appTextSecondary)
                    .frame(width: 32)
            }

            // Team Color & Name
            HStack(spacing: AppSpacing.xxs) {
                Circle()
                    .fill(teamColor)
                    .frame(width: 10, height: 10)
                Text(team.name)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
            }

            Spacer()

            // Score - Simple text without transition for better performance
            Text("\(team.getTotalScore(for: quiz))")
                .font(.headline)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .monospacedDigit()
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xs)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(isTopThree ? teamColor.opacity(0.1) : Color.appBackgroundSecondary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .stroke(isTopThree ? teamColor.opacity(0.2) : Color.clear, lineWidth: 1)
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
    
    private func incrementScore(for team: Team, maxPoints: Int?) {
        let current = getScoreValue(for: team)
        if let maxPts = maxPoints {
            if current < maxPts {
                teamScores[team.id] = "\(current + 1)"
            }
        } else {
            teamScores[team.id] = "\(current + 1)"
        }
    }

    private func decrementScore(for team: Team, maxPoints: Int?) {
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
            L10n.Execution.noActiveQuizzes,
            systemImage: "play.circle",
            description: Text(L10n.Execution.noActiveQuizzesDescription())
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
                Section(L10n.Execution.EditRounds.title) {
                    ForEach(quiz.sortedRounds) { round in
                        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                            HStack {
                                Text(round.name)
                                    .font(.headline)
                                
                                Spacer()
                                
                                if round.isCompleted {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.appSuccess)
                                        .font(.caption)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color.appTextSecondary)
                                        .font(.caption)
                                }
                            }
                            
                            if let maxPoints = round.maxPoints {
                                Text(L10n.Execution.EditRounds.maxPointsDisplay(maxPoints))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            } else {
                                Text(L10n.Round.noMaxPoints)
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                        .padding(.vertical, AppSpacing.xxxs)
                        .tag(round)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle(L10n.Execution.EditRounds.rounds)
        } detail: {
            if let round = selectedRound {
                RoundEditDetailContent(round: round, quiz: quiz, viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    L10n.Execution.EditRounds.selectRound,
                    systemImage: "list.number",
                    description: Text(L10n.Execution.EditRounds.selectRoundDescription())
                )
            }
        }
        .navigationTitle(L10n.Execution.EditRounds.editScores)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(L10n.Execution.EditRounds.done) {
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
            VStack(spacing: AppSpacing.xs) {
                HStack {
                    if editingRoundSettings {
                        // Editing Mode
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            TextField(L10n.Execution.EditRounds.roundNamePlaceholder, text: $tempRoundName)
                                .textFieldStyle(.roundedBorder)
                                .font(.title2)
                            
                            HStack(spacing: AppSpacing.xxs) {
                                Text(L10n.Execution.EditRounds.maxPointsLabel)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextPrimary)
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
                                Text(L10n.Execution.EditRounds.maxPointsPerTeam)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    } else {
                        // Display Mode
                        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                            Text(round.name)
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.appTextPrimary)

                            if let maxPoints = round.maxPoints {
                                Text(L10n.Execution.EditRounds.maxPointsDisplay(maxPoints))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            } else {
                                Text(L10n.Round.noMaxPoints)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Edit/Save Buttons
                    if editingRoundSettings {
                        HStack(spacing: AppSpacing.xxs) {
                            Button(L10n.Navigation.cancel) {
                                cancelRoundEditing()
                            }
                            .secondaryGradientButton()
                            
                            Button(L10n.Navigation.save) {
                                saveRoundSettings()
                            }
                            .primaryGradientButton()
                        }
                    } else {
                        HStack(spacing: AppSpacing.xs) {
                            Button {
                                startRoundEditing()
                            } label: {
                                Label(L10n.Execution.EditRounds.editSettings, systemImage: "slider.horizontal.3")
                            }
                            .secondaryGradientButton()
                            .help(L10n.Execution.EditRounds.editSettingsHelp)
                            
                            if round.isCompleted {
                                HStack(spacing: AppSpacing.xxxs) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.appSuccess)
                                    Text(L10n.Execution.EditRounds.completed)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appSuccess)
                                }
                                .padding(.horizontal, AppSpacing.xs)
                                .padding(.vertical, AppSpacing.xxxs)
                                .background(Color.appSuccess.opacity(0.1))
                                .clipShape(Capsule())
                            }
                        }
                    }
                }
                
                if hasChanges {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(Color.appAccent)
                        Text(L10n.Execution.EditRounds.unsavedChanges)
                            .font(.subheadline)
                            .foregroundStyle(Color.appAccent)
                        Spacer()
                        Button(L10n.Navigation.save) {
                            saveAllScores()
                        }
                        .primaryGradientButton(size: .small)
                    }
                    .padding(AppSpacing.md)
                    .background(Color.appAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
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
                                .foregroundStyle(Color.appAccent)
                            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                                Text(L10n.Execution.EditRounds.warningMaxPoints)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appAccent)
                                Text(L10n.Execution.EditRounds.warningAffectedTeams(teamsWithTooManyPoints.joined(separator: ", ")))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                Text(L10n.Execution.EditRounds.warningLimit(newMaxPoints))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            Spacer()
                        }
                        .padding(AppSpacing.md)
                        .background(Color.appAccent.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }
                }
            }
            .padding(AppSpacing.md)
            
            Divider()
            
            // Teams Grid
            ScrollView {
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        L10n.Execution.noTeams,
                        systemImage: "person.3.slash",
                        description: Text(L10n.Execution.noTeamsDescription())
                    )
                    .frame(maxHeight: 400)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: AppSpacing.sectionSpacing),
                        GridItem(.flexible(), spacing: AppSpacing.sectionSpacing)
                    ], spacing: AppSpacing.sectionSpacing) {
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
                    .padding(AppSpacing.sectionSpacing)
                }
            }
            
            // Action Buttons
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.xs) {
                    Button(L10n.Execution.reset) {
                        loadCurrentScores()
                        hasChanges = false
                    }
                    .secondaryGradientButton()
                    .disabled(!hasChanges)
                    
                    Button(L10n.Execution.saveAll) {
                        saveAllScores()
                    }
                    .primaryGradientButton()
                    .disabled(!hasChanges)
                }
                
                if !round.isCompleted {
                    Button(L10n.Execution.EditRounds.roundComplete) {
                        saveAllScores()
                        viewModel.completeRound(round)
                    }
                    .successGradientButton()
                } else {
                    Button(L10n.Execution.EditRounds.roundReopen) {
                        round.isCompleted = false
                        viewModel.saveContext()
                    }
                    .accentGradientButton()
                }
            }
            .padding(AppSpacing.md)
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
        tempMaxPoints = "\(round.maxPoints ?? 0)"
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
    let maxPoints: Int?
    
    private var teamColor: Color {
        Color(hex: team.color) ?? Color.appPrimary
    }
    
    private var scoreValue: Int {
        Int(currentScore) ?? 0
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            // Team Header
            HStack {
                Circle()
                    .fill(teamColor)
                    .frame(width: 16, height: 16)
                
                Text(team.name)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Score Input
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    // Decrement
                    Button {
                        if scoreValue > 0 {
                            currentScore = "\(scoreValue - 1)"
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title)
                            .foregroundStyle(scoreValue > 0 ? Color.appAccent : Color.appTextTertiary)
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
                            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                .fill(Color.appBackgroundSecondary)
                                .overlay(
                                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                        .stroke(teamColor, lineWidth: 3)
                                )
                        )
                        .onChange(of: currentScore) { _, newValue in
                            // Filter nur Zahlen
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                currentScore = filtered
                            }
                            // Begrenze auf maxPoints (wenn gesetzt)
                            if let maxPts = maxPoints, let value = Int(filtered), value > maxPts {
                                currentScore = "\(maxPts)"
                            }
                        }
                    
                    // Increment
                    Button {
                        if let maxPts = maxPoints {
                            if scoreValue < maxPts {
                                currentScore = "\(scoreValue + 1)"
                            }
                        } else {
                            currentScore = "\(scoreValue + 1)"
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundStyle({
                                if let maxPts = maxPoints {
                                    return scoreValue < maxPts ? Color.appSuccess : Color.appTextTertiary
                                } else {
                                    return Color.appSuccess
                                }
                            }())
                    }
                    .buttonStyle(.plain)
                    .disabled({
                        if let maxPts = maxPoints {
                            return scoreValue >= maxPts
                        } else {
                            return false
                        }
                    }())
                    .frame(width: 44, height: 44)
                }
                
                // Max Points Indicator
                if let maxPts = maxPoints {
                    Text("/ \(maxPts)")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .bold()
                        .monospacedDigit()
                } else {
                    Text(L10n.Round.unlimited)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                        .bold()
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .default, cornerRadius: AppCornerRadius.lg)
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .stroke(teamColor.opacity(0.3), lineWidth: 2)
        )
    }
}

// MARK: - Active Quiz Row

struct ActiveQuizRow: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
            HStack {
                Circle()
                    .fill(Color.appSuccess)
                    .frame(width: 8, height: 8)
                
                Text(quiz.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            
            if let currentRound = quiz.currentRound {
                HStack(spacing: AppSpacing.xxs) {
                    Label(currentRound.name, systemImage: "play.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appSuccess)
                }
            }
            
            ProgressView(value: quiz.progress)
                .tint(Color.appSuccess)
                .frame(height: 4)
            
            HStack(spacing: AppSpacing.xxs) {
                Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                    .font(.caption2)
                Label("\(quiz.completedRoundsCount)/\(quiz.safeRounds.count)", systemImage: "list.number")
                    .font(.caption2)
            }
            .foregroundStyle(Color.appTextSecondary)
        }
        .padding(.vertical, AppSpacing.xxxs)
    }
}
