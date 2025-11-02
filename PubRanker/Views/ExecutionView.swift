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
    @State private var selectedTab: ExecutionTab = .overview
    
    enum ExecutionTab: String, CaseIterable, Identifiable {
        case overview = "Übersicht"
        case scoring = "Punkte eingeben"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .overview: return "chart.bar.fill"
            case .scoring: return "pencil.circle.fill"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if let quiz = selectedQuiz {
                executionDetailView(for: quiz)
            } else {
                emptyState
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            viewModel.setContext(modelContext)
            if selectedQuiz == nil && !activeQuizzes.isEmpty {
                selectedQuiz = activeQuizzes.first
            }
        }
        .onChange(of: selectedWorkflow) { oldValue, newValue in
            // Wenn von Planung zur Durchführung gewechselt wird
            if oldValue == .planning && newValue == .execution {
                // Wechsle direkt zum "Punkte eingeben" Tab
                selectedTab = .scoring
                // Wähle das neueste aktive Quiz
                if !activeQuizzes.isEmpty {
                    selectedQuiz = activeQuizzes.first
                }
            }
        }
        .onChange(of: activeQuizzes) { oldValue, newValue in
            // Wenn das aktuell ausgewählte Quiz gelöscht wurde
            if let selected = selectedQuiz, !newValue.contains(where: { $0.id == selected.id }) {
                selectedQuiz = newValue.first
            }
        }
    }
    
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
                Text("Quiz durchführen")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Active Quiz List
            List(selection: $selectedQuiz) {
                if activeQuizzes.isEmpty {
                    ContentUnavailableView(
                        "Keine aktiven Quiz",
                        systemImage: "play.circle",
                        description: Text("Starte ein Quiz in der Planungsphase")
                    )
                } else {
                    Section("Aktive Quiz (\(activeQuizzes.count))") {
                        ForEach(activeQuizzes) { quiz in
                            ActiveQuizRow(quiz: quiz)
                                .tag(quiz)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    private func executionDetailView(for quiz: Quiz) -> some View {
        VStack(spacing: 0) {
            // Live Header
            liveQuizHeader(quiz)
            
            Divider()
            
            // Tab Picker
            Picker("Ansicht", selection: $selectedTab) {
                ForEach(ExecutionTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // Tab Content
            Group {
                switch selectedTab {
                case .overview:
                    liveOverview(quiz)
                case .scoring:
                    if let currentRound = quiz.currentRound {
                        ScoreEntryView(round: currentRound, quiz: quiz, viewModel: viewModel)
                    } else {
                        ContentUnavailableView(
                            "Keine aktive Runde",
                            systemImage: "list.number",
                            description: Text("Alle Runden sind abgeschlossen oder es gibt noch keine Runden.")
                        )
                    }
                }
            }
        }
    }
    
    private func liveQuizHeader(_ quiz: Quiz) -> some View {
        VStack(spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                // Live Indicator
                HStack(spacing: 8) {
                    Circle()
                        .fill(.red)
                        .frame(width: 12, height: 12)
                    Text("LIVE")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.red.opacity(0.1))
                .clipShape(Capsule())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.title2)
                        .bold()
                    
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Current Round Info
                if let currentRound = quiz.currentRound {
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Aktuelle Runde")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(currentRound.name)
                            .font(.headline)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Complete Button
                Button {
                    viewModel.completeQuiz(quiz)
                    // Wechsle zur Auswertungsphase
                    selectedWorkflow = .analysis
                } label: {
                    Label("Beenden", systemImage: "flag.checkered")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .keyboardShortcut("e", modifiers: .command)
                .help(NSLocalizedString("status.complete", comment: "Complete quiz") + " (⌘E)")
            }
            
            // Progress Bar
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
    
    private func liveOverview(_ quiz: Quiz) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Stats
                HStack(spacing: 16) {
                    overviewStatCard(
                        title: "Teams",
                        value: "\(quiz.safeTeams.count)",
                        icon: "person.3.fill",
                        color: .blue
                    )
                    overviewStatCard(
                        title: "Runden",
                        value: "\(quiz.safeRounds.count)",
                        icon: "list.number",
                        color: .green
                    )
                    overviewStatCard(
                        title: "Abgeschlossen",
                        value: "\(quiz.completedRoundsCount)",
                        icon: "checkmark.circle.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)
                
                Divider()
                
                // Rounds Overview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Runden-Übersicht")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(quiz.sortedRounds) { round in
                            RoundStatusCard(round: round, quiz: quiz, viewModel: viewModel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }
    
    private func overviewStatCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 36, weight: .bold))
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "Kein aktives Quiz",
            systemImage: "play.circle",
            description: Text("Starte ein Quiz in der Planungsphase")
        )
    }
}

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

struct RoundStatusCard: View {
    let round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    var body: some View {
        HStack {
            // Round Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(round.name)
                        .font(.headline)
                    
                    if round.isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    } else {
                        Image(systemName: "circle")
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text("Max. \(round.maxPoints) Punkte")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Status/Action
            if round.isCompleted {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Abgeschlossen")
                        .font(.caption)
                        .foregroundStyle(.green)
                    
                    let totalPoints = quiz.safeTeams.reduce(0) { total, team in
                        total + (team.getScore(for: round) ?? 0)
                    }
                    Text("\(totalPoints) Punkte vergeben")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            } else if quiz.currentRound?.id == round.id {
                Label("Aktiv", systemImage: "play.circle.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .clipShape(Capsule())
            } else {
                Text("Ausstehend")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
