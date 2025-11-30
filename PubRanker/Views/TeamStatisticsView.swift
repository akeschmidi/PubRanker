//
//  TeamStatisticsView.swift
//  PubRanker
//
//  Created on 24.11.2025
//

import SwiftUI
import SwiftData

// MARK: - Team Statistics Aggregation
struct TeamStats: Identifiable {
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

    struct QuizPerformance {
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

    private var teamStatistics: [TeamStats] {
        calculateTeamStatistics()
    }

    private var filteredAndSortedStats: [TeamStats] {
        var stats = teamStatistics

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
            if selectedTeam == nil && !filteredAndSortedStats.isEmpty {
                selectedTeam = filteredAndSortedStats.first
            }
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

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "Keine Team-Statistiken",
            systemImage: "chart.bar",
            description: Text("Beende Quiz, um Team-Statistiken zu sehen")
        )
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
                    points: team.totalScore,
                    totalTeams: rankedTeams.count
                )
            }
        }

        return statsDict.values.map { $0.build() }.sorted { $0.winsCount > $1.winsCount }
    }

    private func sortStats(_ stats: [TeamStats]) -> [TeamStats] {
        switch sortOption {
        case .mostWins:
            return stats.sorted { $0.winsCount > $1.winsCount }
        case .mostParticipations:
            return stats.sorted { $0.participationCount > $1.participationCount }
        case .bestAverage:
            return stats.sorted { $0.averageRank < $1.averageRank }
        case .mostPoints:
            return stats.sorted { $0.totalPoints > $1.totalPoints }
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
