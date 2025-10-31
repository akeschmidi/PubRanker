//
//  AnalysisView.swift
//  PubRanker
//
//  Created on 31.10.2025
//

import SwiftUI
import SwiftData
import AppKit

struct AnalysisView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Quiz> { $0.isActive || $0.isCompleted }, sort: \Quiz.date, order: .reverse) 
    private var analyzableQuizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @State private var selectedQuiz: Quiz?
    @State private var showingExportDialog = false
    @State private var exportedFileURL: URL?
    
    var completedQuizzes: [Quiz] {
        analyzableQuizzes.filter { $0.isCompleted }
    }
    
    var activeQuizzes: [Quiz] {
        analyzableQuizzes.filter { $0.isActive && !$0.isCompleted }
    }
    
    var body: some View {
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
                            }
                        }
                    }
                    
                    if !completedQuizzes.isEmpty {
                        Section("Abgeschlossene Quiz (\(completedQuizzes.count))") {
                            ForEach(completedQuizzes) { quiz in
                                CompletedQuizRow(quiz: quiz)
                                    .tag(quiz)
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
                        color: .gray
                    )
                }
                
                // 1st Place (Winner)
                if !quiz.sortedTeamsByScore.isEmpty {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[0],
                        place: 1,
                        height: 160,
                        color: .yellow
                    )
                }
                
                // 3rd Place
                if quiz.sortedTeamsByScore.count > 2 {
                    podiumPlace(
                        team: quiz.sortedTeamsByScore[2],
                        place: 3,
                        height: 100,
                        color: Color(red: 0.8, green: 0.5, blue: 0.2)
                    )
                }
            }
        }
        .padding()
    }
    
    private func podiumPlace(team: Team, place: Int, height: CGFloat, color: Color) -> some View {
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
                
                Text("\(team.totalScore) Punkte")
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
            Text("Vollständige Ergebnisse")
                .font(.title2)
                .bold()
                .padding(.horizontal)
            
            LazyVStack(spacing: 8) {
                ForEach(Array(quiz.sortedTeamsByScore.enumerated()), id: \.element.id) { index, team in
                    resultRow(team: team, rank: index + 1)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func resultRow(team: Team, rank: Int) -> some View {
        HStack {
            // Rank
            Text("#\(rank)")
                .font(.title3)
                .bold()
                .frame(width: 50)
                .foregroundStyle(rank <= 3 ? rankColor(rank) : .secondary)
            
            // Team Color
            Circle()
                .fill(Color(hex: team.color) ?? .blue)
                .frame(width: 12, height: 12)
            
            // Team Name
            Text(team.name)
                .font(.headline)
            
            Spacer()
            
            // Total Score
            Text("\(team.totalScore)")
                .font(.title2)
                .bold()
                .foregroundStyle(rank <= 3 ? rankColor(rank) : .primary)
            
            Text("Punkte")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(rank <= 3 ? rankColor(rank).opacity(0.1) : Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
                    value: "\(quiz.sortedTeamsByScore.first?.totalScore ?? 0)",
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
        let total = quiz.safeTeams.reduce(0) { $0 + $1.totalScore }
        return Double(total) / Double(quiz.safeTeams.count)
    }
    
    private func totalPoints(_ quiz: Quiz) -> Int {
        quiz.safeTeams.reduce(0) { $0 + $1.totalScore }
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

struct ActiveQuizRowAnalysis: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                
                Text(quiz.name)
                    .font(.headline)
                
                Text("LIVE")
                    .font(.caption2)
                    .bold()
                    .foregroundStyle(.green)
            }
            
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
                Label("\(quiz.completedRoundsCount)/\(quiz.safeRounds.count)", systemImage: "list.number")
                    .font(.caption2)
                if let leader = quiz.sortedTeamsByScore.first {
                    Label(leader.name, systemImage: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
            .foregroundStyle(.secondary)
            
            ProgressView(value: quiz.progress)
                .tint(.green)
        }
        .padding(.vertical, 4)
    }
}

struct CompletedQuizRow: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                
                Text(quiz.name)
                    .font(.headline)
            }
            
            HStack(spacing: 12) {
                if !quiz.venue.isEmpty {
                    Label(quiz.venue, systemImage: "mappin.circle")
                        .font(.caption)
                }
                Text(quiz.date, style: .date)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            
            if let winner = quiz.sortedTeamsByScore.first {
                HStack(spacing: 8) {
                    Label("Sieger:", systemImage: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(winner.name)
                        .font(.caption2)
                        .bold()
                    Text("(\(winner.totalScore))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
