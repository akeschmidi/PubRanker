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
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.vertical, AppSpacing.xs)

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
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // Empty group to override default sidebar toggle
            }
        }
    }

    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Label(L10n.Analysis.title, systemImage: "chart.bar.fill")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                Text(L10n.Analysis.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(Color.appBackgroundSecondary)

            Divider()

            // Quiz List
            List(selection: $selectedQuiz) {
                if analyzableQuizzes.isEmpty {
                    ContentUnavailableView(
                        L10n.Analysis.noQuizzes,
                        systemImage: "chart.bar",
                        description: Text(L10n.Analysis.noQuizzesDescription())
                    )
                } else {
                    if !activeQuizzes.isEmpty {
                        Section(L10n.Analysis.activeQuizzesSection(activeQuizzes.count)) {
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
                        Section(L10n.Analysis.completedQuizzesSection(completedQuizzes.count)) {
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
        .navigationTitle("")
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
            Button(L10n.Alert.ok) {}
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
            VStack(spacing: AppSpacing.sectionSpacing) {
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
            .padding(.vertical, AppSpacing.screenPadding)
        }
    }

    private func resultHeader(_ quiz: Quiz) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Trophy/Chart Icon
            ZStack {
                Circle()
                    .fill(quiz.isCompleted ? Color.appSecondary : Color.appPrimary)
                    .frame(width: 80, height: 80)
                    .shadow(radius: 4, y: 2)

                Image(systemName: quiz.isCompleted ? "trophy.fill" : "chart.bar.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.white)
            }

            // Quiz Info
            VStack(spacing: AppSpacing.xxs) {
                Text(quiz.name)
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: AppSpacing.sm) {
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                    }
                    Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                }
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)

                if quiz.isCompleted {
                    Label(NSLocalizedString("status.completed", comment: "Completed"), systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, AppSpacing.xxxs)
                        .background(Color.appSuccess)
                        .clipShape(Capsule())
                } else {
                    HStack(spacing: AppSpacing.xxs) {
                        Circle()
                            .fill(Color.appSuccess)
                            .frame(width: 8, height: 8)
                        Label(NSLocalizedString("analysis.liveRunning", comment: "Live - running"), systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxxs)
                    .background(Color.appSuccess)
                    .clipShape(Capsule())
                }

                if !quiz.isCompleted {
                    Text(L10n.Analysis.interimAfterRounds(quiz.completedRoundsCount, quiz.safeRounds.count))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                }
            }
        }
        .padding(AppSpacing.md)
    }

    private func exportSection(_ quiz: Quiz) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Text(L10n.Analysis.exportResults)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)

            HStack(spacing: AppSpacing.sm) {
                Button {
                    exportQuiz(quiz: quiz, format: .json)
                } label: {
                    VStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "doc.text.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.appPrimary)
                        Text("JSON")
                            .font(.caption)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                }
                .buttonStyle(.plain)
                .appCard(style: .default, cornerRadius: AppCornerRadius.sm)

                Button {
                    exportQuiz(quiz: quiz, format: .csv)
                } label: {
                    VStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "tablecells.fill")
                            .font(.largeTitle)
                            .foregroundStyle(Color.appSuccess)
                        Text("CSV")
                            .font(.caption)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                }
                .buttonStyle(.plain)
                .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
            }
        }
        .padding(.horizontal, AppSpacing.screenPadding)
    }

    private func winnerPodium(_ quiz: Quiz) -> some View {
        VStack(spacing: AppSpacing.sm) {
            HStack {
                Text(quiz.isCompleted ? NSLocalizedString("analysis.winnerPodium", comment: "Winner Podium") : NSLocalizedString("analysis.currentLeadership", comment: "Current Leadership"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                if !quiz.isCompleted {
                    Text(NSLocalizedString("analysis.interim", comment: "Interim"))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            HStack(alignment: .bottom, spacing: AppSpacing.md) {
                // 2nd Place
                if quiz.sortedTeamsByScore.count > 1 {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[1],
                        place: 2,
                        height: 120,
                        color: Color.appTextSecondary,
                        quiz: quiz
                    )
                }

                // 1st Place (Winner)
                if !quiz.sortedTeamsByScore.isEmpty {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[0],
                        place: 1,
                        height: 160,
                        color: Color.appSecondary,
                        quiz: quiz
                    )
                }

                // 3rd Place
                if quiz.sortedTeamsByScore.count > 2 {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[2],
                        place: 3,
                        height: 100,
                        color: Color.appPrimary,
                        quiz: quiz
                    )
                }
            }
        }
        .padding(AppSpacing.md)
    }

    private func podiumPlace(team: Team, place: Int, height: CGFloat, color: Color, quiz: Quiz) -> some View {
        VStack(spacing: AppSpacing.xs) {
            // Medal
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 3, y: 1)

                Text("\(place)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            // Team Info
            VStack(spacing: AppSpacing.xxxs) {
                Text(team.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .multilineTextAlignment(.center)

                Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), team.getTotalScore(for: quiz)))
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
            }

            // Podium Base
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(color.opacity(0.3))
                .frame(width: 100, height: height)
                .overlay {
                    Text("#\(place)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(color.opacity(0.5))
                        .monospacedDigit()
                }
        }
    }

    private func fullResultsSection(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Image(systemName: "list.number")
                    .font(.title2)
                    .foregroundStyle(Color.appPrimary)
                Text(L10n.Analysis.leaderboard)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            LazyVStack(spacing: AppSpacing.xs) {
                ForEach(Array(quiz.sortedTeamsByScore.enumerated()), id: \.element.id) { index, team in
                    modernResultCard(team: team, rank: index + 1, quiz: quiz)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func modernResultCard(team: Team, rank: Int, quiz: Quiz) -> some View {
        let isTopThree = rank <= 3

        return HStack(spacing: 0) {
            // Rang Badge
            ZStack {
                if isTopThree {
                    Circle()
                        .fill(rankColor(rank))
                        .frame(width: 60, height: 60)
                        .shadow(radius: 3, y: 1)

                    VStack(spacing: AppSpacing.xxxs) {
                        if rank == 1 {
                            Image(systemName: "crown.fill")
                                .font(.title3)
                                .foregroundStyle(.white)
                        } else {
                            Text("\(rank)")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(.white)
                                .monospacedDigit()
                        }
                    }
                } else {
                    Circle()
                        .fill(Color.appBackgroundSecondary)
                        .frame(width: 50, height: 50)

                    Text("\(rank)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                }
            }
            .padding(.trailing, AppSpacing.sm)

            // Team Info
            HStack(spacing: AppSpacing.xs) {
                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(team.name)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    // Fortschrittsbalken relativ zur höchsten Punktzahl
                    if quiz.safeTeams.count > 1, let maxScore = quiz.sortedTeamsByScore.first?.getTotalScore(for: quiz), maxScore > 0 {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Hintergrund
                                RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                    .fill(Color.appTextTertiary.opacity(0.2))
                                    .frame(height: 6)

                                // Fortschritt - einheitliche Farbe basierend auf Rank
                                RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                    .fill(isTopThree ? rankColor(rank) : Color.appPrimary)
                                    .frame(width: geometry.size.width * CGFloat(team.getTotalScore(for: quiz)) / CGFloat(maxScore), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }

                Spacer()

                // Punkte Display
                VStack(spacing: AppSpacing.xxxs) {
                    Text("\(team.getTotalScore(for: quiz))")
                        .font(.system(size: 32, weight: .bold))
                        .monospacedDigit()
                        .foregroundStyle(rank <= 3 ? rankColor(rank) : Color.appTextPrimary)

                    Text(L10n.Analysis.points)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                        .textCase(.uppercase)
                }
                .padding(.horizontal, AppSpacing.xs)
            }
            .padding(.vertical, AppSpacing.xs)
            .padding(.trailing, AppSpacing.sm)
        }
        .padding(.leading, AppSpacing.sm)
        .appCard(style: isTopThree ? .elevated : .default, cornerRadius: AppCornerRadius.lg)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .stroke(isTopThree ? rankColor(rank).opacity(0.3) : Color.appTextTertiary.opacity(0.2), lineWidth: 2)
        }
    }

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appPrimary
        default: return Color.appTextSecondary
        }
    }

    private func statisticsSection(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(L10n.Analysis.statistics)
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                statCard(
                    title: NSLocalizedString("stats.participants", comment: "Participants"),
                    value: "\(quiz.safeTeams.count)",
                    icon: "person.3.fill",
                    color: Color.appPrimary
                )

                statCard(
                    title: NSLocalizedString("quiz.rounds", comment: "Rounds"),
                    value: "\(quiz.safeRounds.count)",
                    icon: "list.number",
                    color: Color.appSuccess
                )

                statCard(
                    title: NSLocalizedString("stats.highestScore", comment: "Highest Score"),
                    value: "\(quiz.sortedTeamsByScore.first?.getTotalScore(for: quiz) ?? 0)",
                    icon: "star.fill",
                    color: Color.appSecondary
                )

                statCard(
                    title: NSLocalizedString("stats.average", comment: "Average"),
                    value: String(format: "%.1f", averageScore(quiz)),
                    icon: "chart.line.uptrend.xyaxis",
                    color: Color.appAccent
                )

                statCard(
                    title: NSLocalizedString("analysis.totalPoints", comment: "Total Points"),
                    value: "\(totalPoints(quiz))",
                    icon: "sum",
                    color: Color.appSecondary
                )

                statCard(
                    title: NSLocalizedString("analysis.maxScore", comment: "Max Score"),
                    value: "\(maxPossiblePoints(quiz))",
                    icon: "trophy.fill",
                    color: Color.appPrimary
                )
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
                .foregroundStyle(color)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
    }

    private func roundBreakdown(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(L10n.Analysis.roundBreakdown)
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

            LazyVStack(spacing: AppSpacing.xs) {
                ForEach(quiz.sortedRounds) { round in
                    roundAnalysisCard(round: round, quiz: quiz)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func roundAnalysisCard(round: Round, quiz: Quiz) -> some View {
        AppCard(style: .default) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                HStack {
                    Text(round.name)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    Spacer()

                    Text(L10n.Analysis.maxPoints(round.maxPoints))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                }

                // Top scorer in this round
                if let topScorer = quiz.safeTeams.max(by: {
                    ($0.getScore(for: round) ?? 0) < ($1.getScore(for: round) ?? 0)
                }) {
                    HStack {
                        Label(topScorer.name, systemImage: "star.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.appAccent)

                        Spacer()

                        Text(String(format: NSLocalizedString("common.points.count", comment: "Points"), topScorer.getScore(for: round) ?? 0))
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(Color.appAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xs))
                }

                // Average for this round
                let avgScore = quiz.safeTeams.reduce(0.0) { total, team in
                    total + Double(team.getScore(for: round) ?? 0)
                } / Double(quiz.safeTeams.count)

                HStack {
                    Label(NSLocalizedString("analysis.average", comment: "Average"), systemImage: "chart.bar")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)

                    Spacer()

                    Text(String(format: "%.1f %@", avgScore, NSLocalizedString("common.points", comment: "Points")))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                }
            }
        }
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
            NSLocalizedString("analysis.noCompletedQuizzes", comment: "No completed quizzes"),
            systemImage: "chart.bar",
            description: Text(L10n.Analysis.noTeamStatsDescription())
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
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                // Empty group to override default sidebar toggle
            }
        }
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
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Label(NSLocalizedString("team.statistics", comment: "Team Statistics"), systemImage: "chart.bar.doc.horizontal.fill")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                Text(NSLocalizedString("analysis.allQuizzes", comment: "Overview of all quizzes"))
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.md)
            .background(Color.appBackgroundSecondary)

            Divider()

            // Search
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.appTextSecondary)
                TextField(NSLocalizedString("common.search", comment: "Search"), text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.appBackgroundSecondary)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(Color.appTextTertiary.opacity(0.2), lineWidth: 1)
                    }
            )
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.xs)

            Divider()

            // Sort Menu
            Menu {
                ForEach(StatsSortOption.allCases, id: \.self) { option in
                    Button {
                        sortOption = option
                    } label: {
                        HStack {
                            Image(systemName: option.icon)
                            Text(option.localizedName)
                            if sortOption == option {
                                Image(systemName: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                HStack {
                    Text(L10n.Analysis.sorting)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    Text(sortOption.localizedName)
                        .font(.caption)
                        .foregroundStyle(Color.appTextPrimary)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(.horizontal, AppSpacing.xs)
                .padding(.vertical, AppSpacing.xxs)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, AppSpacing.md)

            Divider()

            // Team List
            List(selection: $selectedTeam) {
                if filteredAndSortedStats.isEmpty {
                    ContentUnavailableView(
                        NSLocalizedString("analysis.noStatistics", comment: "No statistics"),
                        systemImage: "chart.bar",
                        description: Text(L10n.Analysis.noTeamStatsDescription())
                    )
                } else {
                    Section(L10n.Analysis.teamsSection(filteredAndSortedStats.count)) {
                        ForEach(filteredAndSortedStats) { stats in
                            TeamStatsRow(stats: stats)
                                .tag(stats)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .navigationTitle("")
    }

    // MARK: - Detail View
    private func detailView(for stats: TeamStats) -> some View {
        ScrollView {
            VStack(spacing: AppSpacing.sectionSpacing) {
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
            .padding(.vertical, AppSpacing.screenPadding)
        }
    }

    private func teamHeader(_ stats: TeamStats) -> some View {
        VStack(spacing: AppSpacing.sm) {
            // Team Icon/Trophy
            HStack(spacing: AppSpacing.md) {
                if let imageData = stats.teamImageData, let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(Color(hex: stats.teamColor) ?? Color.appPrimary, lineWidth: 4)
                        }
                        .shadow(AppShadow.lg)
                } else {
                    ZStack {
                        Circle()
                            .fill(Color(hex: stats.teamColor) ?? Color.appPrimary)
                            .frame(width: 100, height: 100)
                            .shadow(radius: 4, y: 2)

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

                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(stats.teamName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: AppSpacing.sm) {
                        Label(String(format: "%d %@", stats.participationCount, NSLocalizedString("quiz.title", comment: "Quiz")), systemImage: "list.number")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)

                        if stats.winsCount > 0 {
                            Label(String(format: "%d %@", stats.winsCount, NSLocalizedString("analysis.wins", comment: "Wins")), systemImage: "trophy.fill")
                                .font(.subheadline)
                                .foregroundStyle(Color.appSecondary)
                        }
                    }
                }

                Spacer()
            }
        }
        .padding(AppSpacing.md)
    }

    private func keyStatistics(_ stats: TeamStats) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(L10n.Analysis.coreStats)
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                statsCard(
                    title: NSLocalizedString("analysis.participation", comment: "Participation"),
                    value: "\(stats.participationCount)",
                    icon: "number.circle.fill",
                    color: Color.appPrimary
                )

                statsCard(
                    title: NSLocalizedString("analysis.wins", comment: "Wins"),
                    value: "\(stats.winsCount)",
                    icon: "trophy.fill",
                    color: Color.appSecondary
                )

                statsCard(
                    title: NSLocalizedString("analysis.winRate", comment: "Win rate"),
                    value: String(format: "%.1f%%", stats.winRate),
                    icon: "percent",
                    color: Color.appSuccess
                )

                statsCard(
                    title: NSLocalizedString("analysis.averageRank", comment: "Average rank"),
                    value: String(format: "%.1f", stats.averageRank),
                    icon: "list.number",
                    color: Color.appAccent
                )

                statsCard(
                    title: NSLocalizedString("analysis.averagePoints", comment: "Average points"),
                    value: String(format: "%.1f", stats.averagePoints),
                    icon: "star.fill",
                    color: Color.appPrimary
                )

                statsCard(
                    title: NSLocalizedString("analysis.totalPoints", comment: "Total points"),
                    value: "\(stats.totalPoints)",
                    icon: "sum",
                    color: Color.appSecondary
                )
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func performanceOverview(_ stats: TeamStats) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text(L10n.Analysis.performance)
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

            VStack(spacing: AppSpacing.sm) {
                // Podium Statistics
                HStack(spacing: AppSpacing.md) {
                    podiumBadge(place: 1, count: stats.winsCount, color: Color.appSecondary, total: stats.participationCount)
                    podiumBadge(place: 2, count: stats.secondPlaceCount, color: Color.appTextSecondary, total: stats.participationCount)
                    podiumBadge(place: 3, count: stats.thirdPlaceCount, color: Color.appPrimary, total: stats.participationCount)
                }
                .frame(maxWidth: .infinity)

                // Podium Rate
                AppCard(style: .default) {
                    VStack(spacing: AppSpacing.xxs) {
                        HStack {
                            Text(L10n.Analysis.podiumRate)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                            Text(String(format: "%.1f%%", stats.podiumRate))
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.appTextPrimary)
                                .monospacedDigit()
                        }

                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                    .fill(Color.appTextTertiary.opacity(0.2))
                                    .frame(height: 12)

                                RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                    .fill(Color.appSecondary)
                                    .frame(width: geometry.size.width * (stats.podiumRate / 100), height: 12)
                            }
                        }
                        .frame(height: 12)
                    }
                }

                // Best & Worst Performance
                HStack(spacing: AppSpacing.sm) {
                    AppCard(style: .default) {
                        VStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "arrow.up.circle.fill")
                                .font(.title)
                                .foregroundStyle(Color.appSuccess)
                            Text(L10n.Analysis.bestRank)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            Text("\(stats.bestRank).")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    AppCard(style: .default) {
                        VStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "arrow.down.circle.fill")
                                .font(.title)
                                .foregroundStyle(Color.appPrimary)
                            Text(L10n.Analysis.worstRank)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            Text("\(stats.worstRank).")
                                .font(.title2)
                                .bold()
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func quizHistory(_ stats: TeamStats) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            HStack {
                Text(L10n.Analysis.quizHistory)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                Text("(\(stats.quizHistory.count))")
                    .font(.title2)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            LazyVStack(spacing: AppSpacing.xs) {
                ForEach(Array(stats.quizHistory.enumerated()), id: \.element.quizName) { index, performance in
                    quizHistoryCard(performance: performance)
                }
            }
            .padding(.horizontal, AppSpacing.screenPadding)
        }
    }

    private func quizHistoryCard(performance: TeamStats.QuizPerformance) -> some View {
        HStack(spacing: AppSpacing.sm) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(rankColor(performance.rank))
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2, y: 1)

                Text("\(performance.rank)")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            // Quiz Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(performance.quizName)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: AppSpacing.xs) {
                    Label(performance.quizDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)

                    Label("\(performance.totalTeams) Teams", systemImage: "person.3")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()

            // Points
            VStack(spacing: AppSpacing.xxxs) {
                Text("\(performance.points)")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                    .monospacedDigit()

                Text(L10n.Analysis.points)
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .textCase(.uppercase)
            }
        }
        .padding(AppSpacing.sm)
        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(rankColor(performance.rank).opacity(0.3), lineWidth: 2)
        }
    }

    private func statsCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
                .foregroundStyle(color)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
    }

    private func podiumBadge(place: Int, count: Int, color: Color, total: Int) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            ZStack {
                Circle()
                    .fill(color)
                    .frame(width: 60, height: 60)
                    .shadow(radius: 3, y: 1)

                Text("\(place)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }

            Text("\(count)×")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .monospacedDigit()

            if total > 0 {
                Text(String(format: "%.0f%%", Double(count) / Double(total) * 100))
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.sm)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
    }

    private var emptyState: some View {
        ContentUnavailableView(
            NSLocalizedString("analysis.noStatistics", comment: "No statistics"),
            systemImage: "chart.bar",
            description: Text(L10n.Analysis.noTeamStatsDescription())
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

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appPrimary
        default: return Color.appTextSecondary
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
        HStack(spacing: AppSpacing.xs) {
            // Team Icon
            if let imageData = stats.teamImageData, let nsImage = NSImage(data: imageData) {
                Image(nsImage: nsImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 36, height: 36)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(hex: stats.teamColor) ?? Color.appPrimary)
                    .frame(width: 36, height: 36)
            }

            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(stats.teamName)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: AppSpacing.xs) {
                    if stats.winsCount > 0 {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "trophy.fill")
                                .font(.caption)
                            Text("\(stats.winsCount)")
                                .font(.caption)
                                .monospacedDigit()
                        }
                        .foregroundStyle(Color.appSecondary)
                    }

                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "list.number")
                            .font(.caption)
                        Text("\(stats.participationCount)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()
        }
        .padding(.vertical, AppSpacing.xxxs)
    }
}

// MARK: - Stats Sort Option
enum StatsSortOption: CaseIterable {
    case mostWins
    case mostParticipations
    case bestAverage
    case mostPoints
    case nameAZ

    var localizedName: String {
        switch self {
        case .mostWins: return NSLocalizedString("sort.mostWins", comment: "Most Wins")
        case .mostParticipations: return NSLocalizedString("sort.mostParticipations", comment: "Most Participations")
        case .bestAverage: return NSLocalizedString("sort.bestAverage", comment: "Best Average")
        case .mostPoints: return NSLocalizedString("sort.mostPoints", comment: "Most Points")
        case .nameAZ: return NSLocalizedString("sort.nameAZ", comment: "Name A-Z")
        }
    }

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
            VStack(spacing: AppSpacing.sectionSpacing) {
                // Header
                VStack(spacing: AppSpacing.sm) {
                    Image(systemName: "chart.pie.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.appPrimary)

                    Text(NSLocalizedString("analysis.overview", comment: "Overall Overview"))
                        .font(.title)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)

                    Text(NSLocalizedString("analysis.overview.description", comment: "Statistics for all completed quizzes"))
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .padding(AppSpacing.md)

                Divider()

                // Key Statistics Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.sm) {
                    statCard(
                        title: NSLocalizedString("analysis.completedQuizzes", comment: "Completed quizzes"),
                        value: "\(completedQuizzes.count)",
                        icon: "checkmark.circle.fill",
                        color: Color.appSuccess
                    )

                    statCard(
                        title: NSLocalizedString("analysis.uniqueTeams", comment: "Unique teams"),
                        value: "\(totalUniqueTeams)",
                        icon: "person.3.fill",
                        color: Color.appPrimary
                    )

                    statCard(
                        title: NSLocalizedString("analysis.averageTeamsPerQuiz", comment: "Average teams per quiz"),
                        value: String(format: "%.1f", averageTeamsPerQuiz),
                        icon: "chart.bar.fill",
                        color: Color.appAccent
                    )
                }
                .padding(.horizontal, AppSpacing.screenPadding)

                Divider()

                // Team Performance Level
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "target")
                            .foregroundStyle(Color.appSecondary)
                        Text(L10n.Analysis.teamLevel)
                            .font(.title2)
                            .foregroundStyle(Color.appTextPrimary)
                            .bold()
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    VStack(spacing: AppSpacing.sm) {
                        AppCard(style: .default) {
                            HStack {
                                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                    Text(L10n.Analysis.maxScore)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), totalMaxPossiblePoints))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(Color.appPrimary)
                                        .monospacedDigit()
                                }
                                Spacer()
                            }
                        }

                        AppCard(style: .default) {
                            HStack {
                                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                                    Text(L10n.Analysis.achievedScore)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                    Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), totalMaxAchievedPoints))
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundStyle(Color.appSuccess)
                                        .monospacedDigit()
                                }
                                Spacer()
                            }
                        }

                        // Performance Percentage
                        if totalMaxPossiblePoints > 0 {
                            let percentage = Double(totalMaxAchievedPoints) / Double(totalMaxPossiblePoints) * 100

                            AppCard(style: .default) {
                                VStack(spacing: AppSpacing.xxs) {
                                    HStack {
                                        Text(L10n.Analysis.totalLevel)
                                            .font(.headline)
                                            .foregroundStyle(Color.appTextPrimary)
                                        Spacer()
                                        Text(String(format: "%.1f%%", percentage))
                                            .font(.title)
                                            .bold()
                                            .foregroundStyle(Color.appSecondary)
                                            .monospacedDigit()
                                    }

                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                                .fill(Color.appTextTertiary.opacity(0.2))
                                                .frame(height: 16)

                                            RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                                .fill(Color.appSecondary)
                                                .frame(width: geometry.size.width * (percentage / 100), height: 16)
                                        }
                                    }
                                    .frame(height: 16)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }

                Divider()

                // Quiz List
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundStyle(Color.appAccent)
                        Text(L10n.Analysis.quizListing)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                        Text("(\(completedQuizzes.count))")
                            .font(.title2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    LazyVStack(spacing: AppSpacing.xs) {
                        ForEach(completedQuizzes) { quiz in
                            quizCard(quiz: quiz)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                }
            }
            .padding(.vertical, AppSpacing.screenPadding)
        }
    }

    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
                .foregroundStyle(color)
                .monospacedDigit()
            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
    }

    private func quizCard(quiz: Quiz) -> some View {
        HStack(spacing: AppSpacing.sm) {
            // Quiz Icon
            ZStack {
                Circle()
                    .fill(Color.appAccent)
                    .frame(width: 50, height: 50)
                    .shadow(radius: 2, y: 1)

                Image(systemName: "trophy.fill")
                    .foregroundStyle(.white)
                    .font(.title3)
            }

            // Quiz Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(quiz.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: AppSpacing.xs) {
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    Label(quiz.date.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()

            // Stats
            VStack(spacing: AppSpacing.xxs) {
                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: "person.3.fill")
                        .font(.caption)
                    Text("\(quiz.safeTeams.count)")
                        .font(.caption)
                        .bold()
                        .monospacedDigit()
                }
                .foregroundStyle(Color.appPrimary)

                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: "list.number")
                        .font(.caption)
                    Text("\(quiz.safeRounds.count)")
                        .font(.caption)
                        .bold()
                        .monospacedDigit()
                }
                .foregroundStyle(Color.appSuccess)
            }
        }
        .padding(AppSpacing.sm)
        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(Color.appAccent.opacity(0.3), lineWidth: 2)
        }
    }
}
