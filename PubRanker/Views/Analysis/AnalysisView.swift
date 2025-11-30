//
//  AnalysisView.swift
//  PubRanker
//
//  Created on 31.10.2025
//

import SwiftUI
import SwiftData
import AppKit
import Charts

struct AnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Quiz> { $0.isActive || $0.isCompleted }, sort: \Quiz.date, order: .reverse)
    private var analyzableQuizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @State private var selectedQuiz: Quiz?
    @State private var showingExportDialog = false
    @State private var exportedFileURL: URL?
    @State private var quizToDelete: Quiz?
    @State private var showingDeleteConfirmation = false
    @State private var selectedTab: AnalysisTab = .quizAnalysis

    var completedQuizzes: [Quiz] {
        analyzableQuizzes.filter { $0.isCompleted }
    }

    var activeQuizzes: [Quiz] {
        analyzableQuizzes.filter { $0.isActive && !$0.isCompleted }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab Selector
            Picker("Ansicht", selection: $selectedTab) {
                ForEach(AnalysisTab.allCases, id: \.self) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Content based on selected tab
            switch selectedTab {
            case .quizAnalysis:
                quizAnalysisView
            case .teamStatistics:
                TeamStatisticsView()
            case .overallStatistics:
                OverallStatisticsView()
            }
        }
        .onAppear {
            viewModel.setContext(modelContext)
            if selectedQuiz == nil {
                if !activeQuizzes.isEmpty {
                    selectedQuiz = activeQuizzes.first
                } else if !completedQuizzes.isEmpty {
                    selectedQuiz = completedQuizzes.first
                }
            }
        }
        .onChange(of: analyzableQuizzes) { oldValue, newValue in
            // Wenn das aktuell ausgewählte Quiz gelöscht wurde
            if let selected = selectedQuiz, !newValue.contains(where: { $0.id == selected.id }) {
                if !activeQuizzes.isEmpty {
                    selectedQuiz = activeQuizzes.first
                } else if !completedQuizzes.isEmpty {
                    selectedQuiz = completedQuizzes.first
                } else {
                    selectedQuiz = nil
                }
            }
        }
    }

    private var quizAnalysisView: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if let quiz = selectedQuiz {
                analysisDetailView(for: quiz)
            } else {
                emptyState
            }
        }
        .navigationSplitViewStyle(.balanced)
    }
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Label("Quiz Auswerten", systemImage: "chart.bar.fill")
                    .font(.title2)
                    .bold()
                Text("Ergebnisse analysieren")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Quiz List
            List(selection: $selectedQuiz) {
                if analyzableQuizzes.isEmpty {
                    ContentUnavailableView(
                        "Keine Quiz vorhanden",
                        systemImage: "chart.bar",
                        description: Text("Starte oder beende ein Quiz, um es hier zu sehen")
                    )
                } else {
                    if !activeQuizzes.isEmpty {
                        Section("Aktive Quiz (\(activeQuizzes.count))") {
                            ForEach(activeQuizzes) { quiz in
                                ActiveQuizRowAnalysis(quiz: quiz)
                                    .tag(quiz)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            quizToDelete = quiz
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label(NSLocalizedString("navigation.delete", comment: "Delete"), systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            quizToDelete = quiz
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label(NSLocalizedString("navigation.delete", comment: "Delete"), systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                    
                    if !completedQuizzes.isEmpty {
                        Section("Abgeschlossene Quiz (\(completedQuizzes.count))") {
                            ForEach(completedQuizzes) { quiz in
                                CompletedQuizRow(quiz: quiz)
                                    .tag(quiz)
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            quizToDelete = quiz
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label(NSLocalizedString("navigation.delete", comment: "Delete"), systemImage: "trash")
                                        }
                                    }
                                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                        Button(role: .destructive) {
                                            quizToDelete = quiz
                                            showingDeleteConfirmation = true
                                        } label: {
                                            Label(NSLocalizedString("navigation.delete", comment: "Delete"), systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .alert(NSLocalizedString("export.success.title", comment: "Export success title"), isPresented: $showingExportDialog) {
            if let fileURL = exportedFileURL {
                Button(NSLocalizedString("export.showInFinder", comment: "Show in Finder")) {
                    NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
                }
                Button(NSLocalizedString("export.share", comment: "Share")) {
                    let picker = NSSharingServicePicker(items: [fileURL])
                    if let view = NSApp.keyWindow?.contentView {
                        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
                    }
                }
            }
            Button("OK") {}
        } message: {
            if let fileURL = exportedFileURL {
                Text(String(format: NSLocalizedString("export.success.message", comment: "Export success message"), fileURL.lastPathComponent))
            }
        }
        .alert(
            NSLocalizedString("quiz.delete.confirm", comment: "Delete quiz confirmation"),
            isPresented: $showingDeleteConfirmation,
            presenting: quizToDelete
        ) { quiz in
            Button(NSLocalizedString("navigation.cancel", comment: "Cancel"), role: .cancel) {
                quizToDelete = nil
            }
            Button(NSLocalizedString("navigation.delete", comment: "Delete"), role: .destructive) {
                deleteQuiz(quiz)
            }
        } message: { quiz in
            Text(String(format: NSLocalizedString("quiz.delete.message", comment: "Delete quiz message"), quiz.name))
        }
    }
    
    private func deleteQuiz(_ quiz: Quiz) {
        // Wenn das zu löschende Quiz aktuell ausgewählt ist, deselektiere es
        if selectedQuiz?.id == quiz.id {
            selectedQuiz = nil
        }
        
        // Lösche das Quiz aus dem ModelContext
        modelContext.delete(quiz)
        
        // Setze den State zurück
        quizToDelete = nil
    }
    
    private func analysisDetailView(for quiz: Quiz) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Quiz Result Header
                resultHeader(quiz)
                
                // Export Section
                exportSection(quiz)
                
                Divider()
                
                // Winner Podium
                if quiz.safeTeams.count >= 3 {
                    winnerPodium(quiz)
                }
                
                Divider()
                
                // Full Results
                fullResultsSection(quiz)
                
                Divider()
                
                // Statistics
                statisticsSection(quiz)

                Divider()

                // Charts Section
                QuizChartsView(quiz: quiz)

                Divider()

                // Round-by-Round Breakdown
                roundBreakdown(quiz)
            }
            .padding(.vertical)
        }
    }
    
    private func resultHeader(_ quiz: Quiz) -> some View {
        VStack(spacing: 16) {
            // Trophy/Chart Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: quiz.isCompleted ? [.yellow, .orange] : [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .shadow(color: (quiz.isCompleted ? Color.orange : Color.blue).opacity(0.4), radius: 10)
                
                Image(systemName: quiz.isCompleted ? "trophy.fill" : "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }
            
            // Quiz Info
            VStack(spacing: 8) {
                Text(quiz.name)
                    .font(.title)
                    .bold()
                
                HStack(spacing: 16) {
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                    }
                    Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                
                if quiz.isCompleted {
                    Label("Abgeschlossen", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green)
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(.green)
                            .frame(width: 8, height: 8)
                        Label("Live - läuft gerade", systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.green)
                    .clipShape(Capsule())
                }
                
                if !quiz.isCompleted {
                    Text("Zwischenstand nach \(quiz.completedRoundsCount) von \(quiz.safeRounds.count) Runden")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
    
    private func exportSection(_ quiz: Quiz) -> some View {
        VStack(spacing: 12) {
            Text("Ergebnisse exportieren")
                .font(.headline)
            
            HStack(spacing: 16) {
                Button {
                    exportQuiz(quiz: quiz, format: .json)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "doc.text.fill")
                            .font(.largeTitle)
                        Text("JSON")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                
                Button {
                    exportQuiz(quiz: quiz, format: .csv)
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "tablecells.fill")
                            .font(.largeTitle)
                        Text("CSV")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
    
    private func winnerPodium(_ quiz: Quiz) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text(quiz.isCompleted ? "Siegertreppchen" : "Aktuelle Führung")
                    .font(.title2)
                    .bold()
                
                if !quiz.isCompleted {
                    Text("(Zwischenstand)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            HStack(alignment: .bottom, spacing: 20) {
                // 2nd Place
                if quiz.sortedTeamsByScore.count > 1 {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[1],
                        place: 2,
                        height: 120,
                        color: .gray,
                        quiz: quiz
                    )
                }

                // 1st Place (Winner)
                if !quiz.sortedTeamsByScore.isEmpty {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[0],
                        place: 1,
                        height: 160,
                        color: .yellow,
                        quiz: quiz
                    )
                }

                // 3rd Place
                if quiz.sortedTeamsByScore.count > 2 {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[2],
                        place: 3,
                        height: 100,
                        color: Color(red: 0.8, green: 0.5, blue: 0.2),
                        quiz: quiz
                    )
                }
            }
        }
        .padding()
    }
    
    private func podiumPlace(team: Team, place: Int, height: CGFloat, color: Color, quiz: Quiz) -> some View {
        VStack(spacing: 12) {
            // Medal
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .shadow(color: color.opacity(0.5), radius: 8)

                Text("\(place)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
            }

            // Team Info
            VStack(spacing: 4) {
                Text(team.name)
                    .font(.headline)
                    .multilineTextAlignment(.center)

                Text("\(team.getTotalScore(for: quiz)) Punkte")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Podium Base
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.3))
                .frame(width: 100, height: height)
                .overlay {
                    Text("#\(place)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(color.opacity(0.5))
                }
        }
    }
    
    private func fullResultsSection(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "list.number")
                    .font(.title2)
                    .foregroundStyle(.blue)
                Text("Rangliste")
                    .font(.title2)
                    .bold()
            }
            .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(Array(quiz.sortedTeamsByScore.enumerated()), id: \.element.id) { index, team in
                    modernResultCard(team: team, rank: index + 1, quiz: quiz)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func modernResultCard(team: Team, rank: Int, quiz: Quiz) -> some View {
        HStack(spacing: 0) {
            // Rang Badge
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [rankColor(rank), rankColor(rank).opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: rankColor(rank).opacity(0.4), radius: 6)
                    
                    VStack(spacing: 2) {
                        if rank == 1 {
                            Image(systemName: "crown.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                        } else {
                            Text("\(rank)")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.white)
                        }
                    }
                } else {
                    Circle()
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .frame(width: 50, height: 50)
                    
                    Text("\(rank)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.trailing, 16)
            
            // Team Info
            HStack(spacing: 12) {
                // Team Icon (Bild oder Farbe)
                TeamIconView(team: team, size: 32)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.headline)
                    
                    // Fortschrittsbalken relativ zur höchsten Punktzahl
                    if quiz.safeTeams.count > 1, let maxScore = quiz.sortedTeamsByScore.first?.getTotalScore(for: quiz), maxScore > 0 {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Hintergrund
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)

                                // Fortschritt
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: team.color) ?? .blue)
                                    .frame(width: geometry.size.width * CGFloat(team.getTotalScore(for: quiz)) / CGFloat(maxScore), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                
                Spacer()
                
                // Punkte Display
                VStack(spacing: 4) {
                    Text("\(team.getTotalScore(for: quiz))")
                        .font(.system(size: 32, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(rank <= 3 ? rankColor(rank) : .primary)

                    Text("Punkte")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, 12)
            }
            .padding(.vertical, 12)
            .padding(.trailing, 16)
        }
        .padding(.leading, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(rank <= 3 ? rankColor(rank).opacity(0.08) : Color(nsColor: .controlBackgroundColor).opacity(0.5))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(rank <= 3 ? rankColor(rank).opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 2)
        }
    }
    
    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .secondary
        }
    }
    
    private func statisticsSection(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Statistiken")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                statCard(
                    title: "Teilnehmer",
                    value: "\(quiz.safeTeams.count)",
                    icon: "person.3.fill",
                    color: .blue
                )
                
                statCard(
                    title: "Runden",
                    value: "\(quiz.safeRounds.count)",
                    icon: "list.number",
                    color: .green
                )
                
                statCard(
                    title: "Höchste Punktzahl",
                    value: "\(quiz.sortedTeamsByScore.first?.getTotalScore(for: quiz) ?? 0)",
                    icon: "star.fill",
                    color: .yellow
                )
                
                statCard(
                    title: "Durchschnitt",
                    value: String(format: "%.1f", averageScore(quiz)),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
                
                statCard(
                    title: "Gesamt Punkte",
                    value: "\(totalPoints(quiz))",
                    icon: "sum",
                    color: .purple
                )
                
                statCard(
                    title: "Max. möglich",
                    value: "\(maxPossiblePoints(quiz))",
                    icon: "trophy.fill",
                    color: .cyan
                )
            }
            .padding(.horizontal)
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func roundBreakdown(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Runden-Analyse")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                ForEach(quiz.sortedRounds) { round in
                    roundAnalysisCard(round: round, quiz: quiz)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func roundAnalysisCard(round: Round, quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(round.name)
                    .font(.headline)
                
                Spacer()
                
                Text("Max: \(round.maxPoints)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Top scorer in this round
            if let topScorer = quiz.safeTeams.max(by: { 
                ($0.getScore(for: round) ?? 0) < ($1.getScore(for: round) ?? 0) 
            }) {
                HStack {
                    Label(topScorer.name, systemImage: "star.fill")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                    
                    Spacer()
                    
                    Text("\(topScorer.getScore(for: round) ?? 0) Punkte")
                        .font(.subheadline)
                        .bold()
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // Average for this round
            let avgScore = quiz.safeTeams.reduce(0.0) { total, team in
                total + Double(team.getScore(for: round) ?? 0)
            } / Double(quiz.safeTeams.count)
            
            HStack {
                Label("Durchschnitt", systemImage: "chart.bar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(String(format: "%.1f Punkte", avgScore))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func exportQuiz(quiz: Quiz, format: ExportFormat) {
        if let fileURL = viewModel.saveQuizExport(quiz: quiz, format: format) {
            exportedFileURL = fileURL
            showingExportDialog = true
        }
    }


    // Helper Functions
    private func averageScore(_ quiz: Quiz) -> Double {
        guard !quiz.safeTeams.isEmpty else { return 0 }
        let total = quiz.safeTeams.reduce(0) { $0 + $1.getTotalScore(for: quiz) }
        return Double(total) / Double(quiz.safeTeams.count)
    }

    private func totalPoints(_ quiz: Quiz) -> Int {
        quiz.safeTeams.reduce(0) { $0 + $1.getTotalScore(for: quiz) }
    }
    
    private func maxPossiblePoints(_ quiz: Quiz) -> Int {
        quiz.safeRounds.reduce(0) { $0 + $1.maxPoints }
    }
    
    private var emptyState: some View {
        ContentUnavailableView(
            "Keine abgeschlossenen Quiz",
            systemImage: "chart.bar",
            description: Text("Beende ein Quiz, um die Ergebnisse hier zu analysieren")
        )
    }
}
//
//  TeamStatisticsView.swift
//  PubRanker
//
//  Created on 24.11.2025
//

import SwiftUI
import SwiftData

// MARK: - Team Statistics Aggregation
struct TeamStats: Identifiable, Hashable {
    let id: UUID
    let teamName: String
    let teamColor: String
    let teamImageData: Data?
    let participationCount: Int
    let winsCount: Int
    let secondPlaceCount: Int
    let thirdPlaceCount: Int
    let totalPoints: Int
    let averagePoints: Double
    let averageRank: Double
    let bestRank: Int
    let worstRank: Int
    let quizHistory: [QuizPerformance]

    struct QuizPerformance: Hashable {
        let quizName: String
        let quizDate: Date
        let rank: Int
        let points: Int
        let totalTeams: Int
    }

    var winRate: Double {
        guard participationCount > 0 else { return 0 }
        return Double(winsCount) / Double(participationCount) * 100
    }

    var podiumRate: Double {
        guard participationCount > 0 else { return 0 }
        let podiumCount = winsCount + secondPlaceCount + thirdPlaceCount
        return Double(podiumCount) / Double(participationCount) * 100
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: TeamStats, rhs: TeamStats) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Team Statistics View
struct TeamStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allTeams: [Team]
    @Query(filter: #Predicate<Quiz> { $0.isCompleted }, sort: \Quiz.date, order: .reverse)
    private var completedQuizzes: [Quiz]

    @State private var selectedTeam: TeamStats?
    @State private var sortOption: StatsSortOption = .mostWins
    @State private var searchText = ""
    @State private var cachedTeamStatistics: [TeamStats] = []

    private var filteredAndSortedStats: [TeamStats] {
        var stats = cachedTeamStatistics

        if !searchText.isEmpty {
            stats = stats.filter { $0.teamName.localizedCaseInsensitiveContains(searchText) }
        }

        return sortStats(stats)
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if let stats = selectedTeam {
                detailView(for: stats)
            } else {
                emptyState
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            updateTeamStatistics()
        }
        .onChange(of: completedQuizzes) { oldValue, newValue in
            updateTeamStatistics()
        }
    }

    // MARK: - Sidebar
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Label("Team-Statistiken", systemImage: "chart.bar.doc.horizontal.fill")
                    .font(.title2)
                    .bold()
                Text("Übersicht über alle Quiz")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))

            Divider()

            // Search
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Team suchen...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
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
            Menu {
                ForEach(StatsSortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        HStack {
                            Image(systemName: option.icon)
                            Text(option.rawValue)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text("Sortierung:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(sortOption.rawValue)
                        .font(.caption)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .padding(.horizontal)

            Divider()

            // Team List
            List(selection: $selectedTeam) {
                if filteredAndSortedStats.isEmpty {
                    ContentUnavailableView(
                        "Keine Statistiken",
                        systemImage: "chart.bar",
                        description: Text("Beende Quiz, um Team-Statistiken zu sehen")
                    )
                } else {
                    Section("Teams (\(filteredAndSortedStats.count))") {
                        ForEach(filteredAndSortedStats) { stats in
                            TeamStatsRow(stats: stats)
                                .tag(stats)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
    }

    // MARK: - Detail View
    private func detailView(for stats: TeamStats) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Team Header
                teamHeader(stats)

                Divider()

                // Key Statistics
                keyStatistics(stats)

                Divider()

                // Performance Overview
                performanceOverview(stats)

                Divider()

                // Team Statistics Charts
                TeamChartsView(stats: stats)

                Divider()

                // Quiz History
                quizHistory(stats)
            }
            .padding(.vertical)
        }
    }

    private func teamHeader(_ stats: TeamStats) -> some View {
        VStack(spacing: 16) {
            // Team Icon/Trophy
            HStack(spacing: 20) {
                if let imageData = stats.teamImageData, let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(hex: stats.teamColor) ?? .blue, lineWidth: 4)
                        }
                        .shadow(color: (Color(hex: stats.teamColor) ?? .blue).opacity(0.4), radius: 10)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: stats.teamColor) ?? .blue, (Color(hex: stats.teamColor) ?? .blue).opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .shadow(color: (Color(hex: stats.teamColor) ?? .blue).opacity(0.4), radius: 10)

                        if stats.winsCount > 0 {
                            Image(systemName: "trophy.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                        } else {
                            Image(systemName: "star.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(.white)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(stats.teamName)
                        .font(.system(size: 32, weight: .bold))

                    HStack(spacing: 16) {
                        Label("\(stats.participationCount) Quiz", systemImage: "list.number")
                            .font(.subheadline)

                        if stats.winsCount > 0 {
                            Label("\(stats.winsCount) Siege", systemImage: "trophy.fill")
                                .font(.subheadline)
                                .foregroundStyle(.yellow)
                        }
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
        }
        .padding()
    }

    private func keyStatistics(_ stats: TeamStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Kernstatistiken")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                statsCard(
                    title: "Teilnahmen",
                    value: "\(stats.participationCount)",
                    icon: "number.circle.fill",
                    color: .blue
                )

                statsCard(
                    title: "Siege",
                    value: "\(stats.winsCount)",
                    icon: "trophy.fill",
                    color: .yellow
                )

                statsCard(
                    title: "Siegrate",
                    value: String(format: "%.1f%%", stats.winRate),
                    icon: "percent",
                    color: .green
                )

                statsCard(
                    title: "Ø Platzierung",
                    value: String(format: "%.1f", stats.averageRank),
                    icon: "list.number",
                    color: .orange
                )

                statsCard(
                    title: "Ø Punkte",
                    value: String(format: "%.1f", stats.averagePoints),
                    icon: "star.fill",
                    color: .purple
                )

                statsCard(
                    title: "Gesamtpunkte",
                    value: "\(stats.totalPoints)",
                    icon: "sum",
                    color: .cyan
                )
            }
            .padding(.horizontal)
        }
    }

    private func performanceOverview(_ stats: TeamStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Leistungsübersicht")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            VStack(spacing: 16) {
                // Podium Statistics
                HStack(spacing: 20) {
                    podiumBadge(place: 1, count: stats.winsCount, color: .yellow, total: stats.participationCount)
                    podiumBadge(place: 2, count: stats.secondPlaceCount, color: .gray, total: stats.participationCount)
                    podiumBadge(place: 3, count: stats.thirdPlaceCount, color: Color(red: 0.8, green: 0.5, blue: 0.2), total: stats.participationCount)
                }
                .frame(maxWidth: .infinity)

                // Podium Rate
                VStack(spacing: 8) {
                    HStack {
                        Text("Podiumsrate")
                            .font(.headline)
                        Spacer()
                        Text(String(format: "%.1f%%", stats.podiumRate))
                            .font(.title2)
                            .bold()
                            .monospacedDigit()
                    }

                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 12)

                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [.yellow, .orange, .red],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * (stats.podiumRate / 100), height: 12)
                        }
                    }
                    .frame(height: 12)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Best & Worst Performance
                HStack(spacing: 16) {
                    VStack(spacing: 8) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(.green)
                        Text("Beste Platzierung")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(stats.bestRank).")
                            .font(.title2)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(spacing: 8) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        Text("Schlechteste Platzierung")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(stats.worstRank).")
                            .font(.title2)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
    }

    private func quizHistory(_ stats: TeamStats) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Quiz-Historie")
                    .font(.title2)
                    .bold()
                Text("(\(stats.quizHistory.count))")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            LazyVStack(spacing: 12) {
                ForEach(Array(stats.quizHistory.enumerated()), id: \.element.quizName) { index, performance in
                    quizHistoryCard(performance: performance)
                }
            }
            .padding(.horizontal)
        }
    }

    private func quizHistoryCard(performance: TeamStats.QuizPerformance) -> some View {
        HStack(spacing: 16) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor(performance.rank))
                    .frame(width: 50, height: 50)

                Text("\(performance.rank)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
            }

            // Quiz Info
            VStack(alignment: .leading, spacing: 6) {
                Text(performance.quizName)
                    .font(.headline)

                HStack(spacing: 12) {
                    Label(performance.quizDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)

                    Label("\(performance.totalTeams) Teams", systemImage: "person.3")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Points
            VStack(spacing: 4) {
                Text("\(performance.points)")
                    .font(.title2)
                    .bold()
                    .monospacedDigit()

                Text("Punkte")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(rankColor(performance.rank).opacity(0.3), lineWidth: 2)
        }
    }

    private func statsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func podiumBadge(place: Int, count: Int, color: Color, total: Int) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .shadow(color: color.opacity(0.5), radius: 8)

                Text("\(place)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
            }

            Text("\(count)×")
                .font(.title2)
                .bold()
                .monospacedDigit()

            if total > 0 {
                Text(String(format: "%.0f%%", Double(count) / Double(total) * 100))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Keine Team-Statistiken",
            systemImage: "chart.bar",
            description: Text("Beende Quiz, um Team-Statistiken zu sehen")
        )
    }

    // MARK: - Update Functions
    private func updateTeamStatistics() {
        cachedTeamStatistics = calculateTeamStatistics()

        // Aktualisiere die Auswahl wenn nötig
        if selectedTeam == nil && !filteredAndSortedStats.isEmpty {
            selectedTeam = filteredAndSortedStats.first
        } else if let selected = selectedTeam {
            // Finde das aktualisierte TeamStats für das aktuell ausgewählte Team
            if let updatedStats = cachedTeamStatistics.first(where: { $0.id == selected.id }) {
                selectedTeam = updatedStats
            }
        }
    }

    // MARK: - Statistics Calculation
    private func calculateTeamStatistics() -> [TeamStats] {
        var statsDict: [String: TeamStatsBuilder] = [:]

        for quiz in completedQuizzes {
            let rankedTeams = quiz.sortedTeamsByScore

            for (index, team) in rankedTeams.enumerated() {
                let rank = index + 1
                let teamKey = team.name

                if statsDict[teamKey] == nil {
                    statsDict[teamKey] = TeamStatsBuilder(
                        teamId: team.id,
                        teamName: team.name,
                        teamColor: team.color,
                        teamImageData: team.imageData
                    )
                }

                statsDict[teamKey]?.addPerformance(
                    quizName: quiz.name,
                    quizDate: quiz.date,
                    rank: rank,
                    points: team.getTotalScore(for: quiz),
                    totalTeams: rankedTeams.count
                )
            }
        }

        return statsDict.values.map { $0.build() }.sorted {
            if $0.winsCount != $1.winsCount {
                return $0.winsCount > $1.winsCount
            }
            return $0.teamName.localizedCompare($1.teamName) == .orderedAscending
        }
    }

    private func sortStats(_ stats: [TeamStats]) -> [TeamStats] {
        switch sortOption {
        case .mostWins:
            return stats.sorted {
                if $0.winsCount != $1.winsCount {
                    return $0.winsCount > $1.winsCount
                }
                return $0.teamName.localizedCompare($1.teamName) == .orderedAscending
            }
        case .mostParticipations:
            return stats.sorted {
                if $0.participationCount != $1.participationCount {
                    return $0.participationCount > $1.participationCount
                }
                return $0.teamName.localizedCompare($1.teamName) == .orderedAscending
            }
        case .bestAverage:
            return stats.sorted {
                if $0.averageRank != $1.averageRank {
                    return $0.averageRank < $1.averageRank
                }
                return $0.teamName.localizedCompare($1.teamName) == .orderedAscending
            }
        case .mostPoints:
            return stats.sorted {
                if $0.totalPoints != $1.totalPoints {
                    return $0.totalPoints > $1.totalPoints
                }
                return $0.teamName.localizedCompare($1.teamName) == .orderedAscending
            }
        case .nameAZ:
            return stats.sorted { $0.teamName.localizedCompare($1.teamName) == .orderedAscending }
        }
    }
}

// MARK: - Team Stats Builder
private class TeamStatsBuilder {
    let teamId: UUID
    let teamName: String
    let teamColor: String
    let teamImageData: Data?
    var performances: [TeamStats.QuizPerformance] = []

    init(teamId: UUID, teamName: String, teamColor: String, teamImageData: Data?) {
        self.teamId = teamId
        self.teamName = teamName
        self.teamColor = teamColor
        self.teamImageData = teamImageData
    }

    func addPerformance(quizName: String, quizDate: Date, rank: Int, points: Int, totalTeams: Int) {
        performances.append(TeamStats.QuizPerformance(
            quizName: quizName,
            quizDate: quizDate,
            rank: rank,
            points: points,
            totalTeams: totalTeams
        ))
    }

    func build() -> TeamStats {
        let participationCount = performances.count
        let winsCount = performances.filter { $0.rank == 1 }.count
        let secondPlaceCount = performances.filter { $0.rank == 2 }.count
        let thirdPlaceCount = performances.filter { $0.rank == 3 }.count
        let totalPoints = performances.reduce(0) { $0 + $1.points }
        let averagePoints = participationCount > 0 ? Double(totalPoints) / Double(participationCount) : 0
        let averageRank = participationCount > 0 ? Double(performances.reduce(0) { $0 + $1.rank }) / Double(participationCount) : 0
        let bestRank = performances.map { $0.rank }.min() ?? 0
        let worstRank = performances.map { $0.rank }.max() ?? 0

        return TeamStats(
            id: teamId,
            teamName: teamName,
            teamColor: teamColor,
            teamImageData: teamImageData,
            participationCount: participationCount,
            winsCount: winsCount,
            secondPlaceCount: secondPlaceCount,
            thirdPlaceCount: thirdPlaceCount,
            totalPoints: totalPoints,
            averagePoints: averagePoints,
            averageRank: averageRank,
            bestRank: bestRank,
            worstRank: worstRank,
            quizHistory: performances.sorted { $0.quizDate > $1.quizDate }
        )
    }
}

// MARK: - Team Stats Row
struct TeamStatsRow: View {
    let stats: TeamStats

    var body: some View {
        HStack(spacing: 12) {
            // Team Icon
            if let imageData = stats.teamImageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: stats.teamColor) ?? .blue)
                    .frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(stats.teamName)
                    .font(.body)
                    .bold()

                HStack(spacing: 12) {
                    if stats.winsCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "trophy.fill")
                                .font(.caption)
                            Text("\(stats.winsCount)")
                                .font(.caption)
                                .monospacedDigit()
                        }
                        .foregroundStyle(.yellow)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "list.number")
                            .font(.caption)
                        Text("\(stats.participationCount)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Stats Sort Option
enum StatsSortOption: String, CaseIterable {
    case mostWins = "Meiste Siege"
    case mostParticipations = "Meiste Teilnahmen"
    case bestAverage = "Beste Ø Platzierung"
    case mostPoints = "Meiste Punkte"
    case nameAZ = "Name (A-Z)"

    var icon: String {
        switch self {
        case .mostWins: return "trophy.fill"
        case .mostParticipations: return "list.number"
        case .bestAverage: return "star.fill"
        case .mostPoints: return "sum"
        case .nameAZ: return "textformat.abc"
        }
    }
}

// MARK: - Overall Statistics View
struct OverallStatisticsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Quiz> { $0.isCompleted }, sort: \Quiz.date, order: .reverse)
    private var completedQuizzes: [Quiz]
    @Query private var allTeams: [Team]

    private var totalUniqueTeams: Int {
        Set(completedQuizzes.flatMap { $0.safeTeams.map { $0.id } }).count
    }

    private var totalMaxPossiblePoints: Int {
        completedQuizzes.reduce(0) { sum, quiz in
            sum + quiz.safeRounds.reduce(0) { $0 + $1.maxPoints }
        }
    }

    private var totalMaxAchievedPoints: Int {
        completedQuizzes.reduce(0) { sum, quiz in
            sum + (quiz.sortedTeamsByScore.first?.getTotalScore(for: quiz) ?? 0)
        }
    }

    private var averageTeamsPerQuiz: Double {
        guard !completedQuizzes.isEmpty else { return 0 }
        let total = completedQuizzes.reduce(0) { $0 + $1.safeTeams.count }
        return Double(total) / Double(completedQuizzes.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)

                    Text("Gesamt-Übersicht")
                        .font(.title)
                        .bold()

                    Text("Statistiken über alle abgeschlossenen Quiz")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()

                Divider()

                // Key Statistics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    statCard(
                        title: "Abgeschlossene Quiz",
                        value: "\(completedQuizzes.count)",
                        icon: "checkmark.circle.fill",
                        color: .green
                    )

                    statCard(
                        title: "Unique Teams",
                        value: "\(totalUniqueTeams)",
                        icon: "person.3.fill",
                        color: .blue
                    )

                    statCard(
                        title: "Ø Teams pro Quiz",
                        value: String(format: "%.1f", averageTeamsPerQuiz),
                        icon: "chart.bar.fill",
                        color: .orange
                    )
                }
                .padding(.horizontal)

                Divider()

                // Team Performance Level
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(.purple)
                        Text("Niveau der Teams")
                            .font(.title2)
                            .bold()
                    }
                    .padding(.horizontal)

                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Maximale Punktzahl")
                                    .font(.headline)
                                Text("\(totalMaxPossiblePoints) Punkte")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.blue)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Erreichte Punktzahl")
                                    .font(.headline)
                                Text("\(totalMaxAchievedPoints) Punkte")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundStyle(.green)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                        // Performance Percentage
                        if totalMaxPossiblePoints > 0 {
                            let percentage = Double(totalMaxAchievedPoints) / Double(totalMaxPossiblePoints) * 100

                            VStack(spacing: 8) {
                                HStack {
                                    Text("Gesamt-Niveau")
                                        .font(.headline)
                                    Spacer()
                                    Text(String(format: "%.1f%%", percentage))
                                        .font(.title)
                                        .bold()
                                        .foregroundStyle(.purple)
                                }

                                GeometryReader { geometry in
                                    ZStack(alignment: .leading) {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(height: 16)

                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(
                                                LinearGradient(
                                                    colors: [.blue, .purple, .pink],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: geometry.size.width * (percentage / 100), height: 16)
                                    }
                                }
                                .frame(height: 16)
                            }
                            .padding()
                            .background(Color.purple.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal)
                }

                Divider()

                // Quiz List
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(.cyan)
                        Text("Quiz-Auflistung")
                            .font(.title2)
                            .bold()
                        Text("(\(completedQuizzes.count))")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)

                    LazyVStack(spacing: 12) {
                        ForEach(completedQuizzes) { quiz in
                            quizCard(quiz: quiz)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func quizCard(quiz: Quiz) -> some View {
        HStack(spacing: 16) {
            // Quiz Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)

                Image(systemName: "trophy.fill")
                    .foregroundStyle(.white)
                    .font(.title3)
            }

            // Quiz Info
            VStack(alignment: .leading, spacing: 6) {
                Text(quiz.name)
                    .font(.headline)

                HStack(spacing: 12) {
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                            .font(.caption)
                    }
                    Label(quiz.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                }
                .foregroundStyle(.secondary)
            }

            Spacer()

            // Stats
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                    Text("\(quiz.safeTeams.count)")
                        .font(.caption)
                        .bold()
                }
                .foregroundStyle(.blue)

                HStack(spacing: 4) {
                    Image(systemName: "list.number")
                        .font(.caption)
                    Text("\(quiz.safeRounds.count)")
                        .font(.caption)
                        .bold()
                }
                .foregroundStyle(.green)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.cyan.opacity(0.3), lineWidth: 2)
        }
    }
}
