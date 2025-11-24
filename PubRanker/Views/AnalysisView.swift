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
    @State private var quizToDelete: Quiz?
    @State private var showingDeleteConfirmation = false
    
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
                    if quiz.safeTeams.count > 1, let maxScore = quiz.sortedTeamsByScore.first?.totalScore, maxScore > 0 {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {   
                                // Hintergrund
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 6)
                                
                                // Fortschritt
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color(hex: team.color) ?? .blue)
                                    .frame(width: geometry.size.width * CGFloat(team.totalScore) / CGFloat(maxScore), height: 6)
                            }
                        }
                        .frame(height: 6)
                    }
                }
                
                Spacer()
                
                // Punkte Display
                VStack(spacing: 4) {
                    Text("\(team.totalScore)")
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
