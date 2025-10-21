//
//  LeaderboardView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct LeaderboardView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    // Calculate ranks with tied teams getting the same rank (Dense Ranking)
    // Example: Team A=100pts (Rank 1), Team B=100pts (Rank 1), Team C=95pts (Rank 2)
    private func calculateRanks() -> [(team: Team, rank: Int)] {
        let sortedTeams = quiz.sortedTeamsByScore
        var result: [(team: Team, rank: Int)] = []
        var currentRank = 1
        var previousScore: Int?
        
        for team in sortedTeams {
            if let prevScore = previousScore, team.totalScore != prevScore {
                // Different score - increment rank by 1 (Dense Ranking)
                currentRank += 1
            }
            result.append((team: team, rank: currentRank))
            previousScore = team.totalScore
        }
        
        return result
    }
    
    var body: some View {
        Group {
            if quiz.safeTeams.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.yellow)
                    
                    VStack(spacing: 8) {
                        Text("Keine Teams")
                            .font(.title2)
                            .bold()
                        
                        Text("Fügen Sie Teams hinzu, um die Rangliste zu sehen.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Text("Wechseln Sie zum Teams-Tab, um Teams hinzuzufügen.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if quiz.safeRounds.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "list.number.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Keine Runden")
                            .font(.title2)
                            .bold()
                        
                        Text("Erstellen Sie Runden, um Punkte zu vergeben und die Rangliste zu sehen.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    Text("Wechseln Sie zum Runden-Tab, um Runden hinzuzufügen.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Podium View for Top 3 ranks (may include more than 3 teams if tied)
                        let rankedTeams = calculateRanks()
                        let topRanks = rankedTeams.filter { $0.rank <= 3 }
                        if topRanks.count >= 3 {
                            PodiumView(rankedTeams: topRanks)
                                .padding(.bottom, 20)
                        }
                        
                        // All Teams List
                        LazyVStack(spacing: 8) {
                            ForEach(calculateRanks(), id: \.team.id) { item in
                                LeaderboardRowView(
                                    team: item.team,
                                    rank: item.rank,
                                    quiz: quiz,
                                    isTopThree: item.rank <= 3
                                )
                            }
                        }
                    }
                    .padding(24)
                }
            }
        }
    }
}

struct PodiumView: View {
    let rankedTeams: [(team: Team, rank: Int)]
    
    var body: some View {
        // Group teams by rank
        let rank1Teams = rankedTeams.filter { $0.rank == 1 }
        let rank2Teams = rankedTeams.filter { $0.rank == 2 }
        let rank3Teams = rankedTeams.filter { $0.rank == 3 }
        
        // Wenn zu viele Teams für Podium, zeige kompakte Version
        let totalTeams = rank1Teams.count + rank2Teams.count + rank3Teams.count
        
        if totalTeams > 5 {
            // Kompakte Podium-Ansicht
            VStack(spacing: 16) {
                Text("🏆 Top 3 Ränge")
                    .font(.title2)
                    .bold()
                
                VStack(spacing: 12) {
                    if !rank1Teams.isEmpty {
                        CompactRankRow(teams: rank1Teams, rank: 1)
                    }
                    if !rank2Teams.isEmpty {
                        CompactRankRow(teams: rank2Teams, rank: 2)
                    }
                    if !rank3Teams.isEmpty {
                        CompactRankRow(teams: rank3Teams, rank: 3)
                    }
                }
            }
            .padding(.vertical, 20)
        } else {
            // Standard Podium
            HStack(alignment: .bottom, spacing: 20) {
                // 2nd Place
                if !rank2Teams.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(rank2Teams, id: \.team.id) { item in
                            PodiumPlace(team: item.team, rank: 2, height: 120, isShared: rank2Teams.count > 1)
                        }
                    }
                }
                
                // 1st Place
                if !rank1Teams.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(rank1Teams, id: \.team.id) { item in
                            PodiumPlace(team: item.team, rank: 1, height: 150, isShared: rank1Teams.count > 1)
                        }
                    }
                }
                
                // 3rd Place
                if !rank3Teams.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(rank3Teams, id: \.team.id) { item in
                            PodiumPlace(team: item.team, rank: 3, height: 100, isShared: rank3Teams.count > 1)
                        }
                    }
                }
            }
            .padding(.vertical, 20)
        }
    }
}

// Kompakte Zeile für Ränge mit vielen Teams
struct CompactRankRow: View {
    let teams: [(team: Team, rank: Int)]
    let rank: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(rankEmoji)
                    .font(.title)
                Text("Platz \(rank)")
                    .font(.headline)
                    .foregroundStyle(rankColor)
                if teams.count > 1 {
                    Text("(geteilt)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Text("\(teams.first?.team.totalScore ?? 0) Punkte")
                    .font(.headline)
                    .foregroundStyle(rankColor)
            }
            
            // Teams
            HStack(spacing: 8) {
                ForEach(teams, id: \.team.id) { item in
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(hex: item.team.color) ?? .blue)
                            .frame(width: 8, height: 8)
                        Text(item.team.name)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(rankColor.opacity(0.15))
                    .clipShape(Capsule())
                }
            }
        }
        .padding(12)
        .background(rankColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(rankColor.opacity(0.3), lineWidth: 2)
        )
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
}

struct PodiumPlace: View {
    let team: Team
    let rank: Int
    let height: CGFloat
    let isShared: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(rankEmoji)
                .font(.system(size: isShared ? 32 : 40))
            
            Text("\(team.totalScore)")
                .font(.system(size: isShared ? 22 : 28, weight: .bold))
                .foregroundStyle(rankColor)
            
            Text(team.name)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(rankColor.opacity(0.2))
                .frame(width: isShared ? 80 : 100, height: isShared ? height * 0.8 : height)
                .overlay(
                    Text("\(rank).")
                        .font(.system(size: isShared ? 28 : 36, weight: .bold))
                        .foregroundStyle(rankColor)
                )
        }
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "\u{1F947}" // 🥇
        case 2: return "\u{1F948}" // 🥈
        case 3: return "\u{1F949}" // 🥉
        default: return ""
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
}

struct LeaderboardRowView: View {
    let team: Team
    let rank: Int
    let quiz: Quiz
    let isTopThree: Bool
    
    // Check if this team shares the rank with others
    private var isSharedRank: Bool {
        let rankedTeams = quiz.sortedTeamsByScore.filter { $0.totalScore == team.totalScore }
        return rankedTeams.count > 1
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Rank Badge
            ZStack {
                if isTopThree {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 60, height: 60)
                        .shadow(color: rankColor.opacity(0.4), radius: 8)
                } else {
                    Circle()
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 2)
                        .background(Circle().fill(Color(nsColor: .controlBackgroundColor)))
                        .frame(width: 50, height: 50)
                }
                
                VStack(spacing: 0) {
                    if isSharedRank {
                        Text("=")
                            .font(.caption2)
                            .foregroundStyle(isTopThree ? .white.opacity(0.7) : .secondary)
                    }
                    Text("\(rank)")
                        .font(isTopThree ? .title : .title3)
                        .bold()
                        .foregroundStyle(isTopThree ? .white : .primary)
                }
            }
            .frame(width: 60)
            
            // Team Info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Circle()
                        .fill(Color(hex: team.color) ?? .blue)
                        .frame(width: 12, height: 12)
                    
                    Text(team.name)
                        .font(.title3)
                        .bold()
                }
                
                HStack(spacing: 8) {
                    ForEach(team.roundScores.prefix(6), id: \.roundId) { score in
                        VStack(spacing: 2) {
                            Text("\(score.points)")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(.primary)
                            Text("R\(quiz.sortedRounds.firstIndex(where: { $0.id == score.roundId }).map { $0 + 1 } ?? 0)")
                                .font(.system(size: 9))
                                .foregroundStyle(.secondary)
                        }
                        .frame(width: 32)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                    
                    if team.roundScores.count > 6 {
                        Text("+\(team.roundScores.count - 6)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Total Score
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(team.totalScore)")
                    .font(.system(size: 42, weight: .bold))
                    .foregroundStyle(isTopThree ? rankColor : .primary)
                    .monospacedDigit()
                
                Text("Punkte")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(isTopThree ? rankColor.opacity(0.1) : Color(nsColor: .controlBackgroundColor))
                .shadow(color: isTopThree ? rankColor.opacity(0.2) : .black.opacity(0.05), radius: isTopThree ? 8 : 3, y: 2)
        }
        .overlay {
            if isTopThree {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(rankColor.opacity(0.3), lineWidth: 2)
            }
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
}

struct TeamScoreDetailsView: View {
    let team: Team
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(team.name)
                .font(.title2)
                .bold()
            
            Divider()
            
            ForEach(quiz.sortedRounds, id: \.id) { round in
                HStack {
                    Text(round.name)
                        .font(.body)
                    
                    Spacer()
                    
                    Group {
                        if let score = team.getScore(for: round) {
                            Text("\(score) / \(round.maxPoints)")
                        } else {
                            Text("– / \(round.maxPoints)")
                        }
                    }
                    .font(.body)
                    .bold()
                }
                .padding(.vertical, 4)
            }
            
            Divider()
            
            HStack {
                Text("Gesamtpunktzahl")
                    .font(.headline)
                
                Spacer()
                
                Text("\(team.totalScore)")
                    .font(.title)
                    .bold()
                    .foregroundStyle(.blue)
            }
        }
        .padding()
    }
}
