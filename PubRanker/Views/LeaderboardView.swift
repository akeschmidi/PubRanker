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
        return quiz.getTeamRankings()
    }
    
    var body: some View {
        Group {
            if quiz.safeTeams.isEmpty {
                VStack(spacing: AppSpacing.sectionSpacing) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.appSecondary)

                    VStack(spacing: AppSpacing.xxs) {
                        Text(NSLocalizedString("empty.noTeams", comment: "No teams"))
                            .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)

                        Text(NSLocalizedString("empty.noTeams.leaderboard", comment: "Add teams to see leaderboard"))
                            .font(Font.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }

                    Text(NSLocalizedString("empty.noTeams.leaderboard.action", comment: "Switch to teams tab"))
                        .font(Font.system(size: 13, weight: .regular))
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if quiz.safeRounds.isEmpty {
                VStack(spacing: AppSpacing.sectionSpacing) {
                    Image(systemName: "number.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.appPrimary)

                    VStack(spacing: AppSpacing.xxs) {
                        Text(NSLocalizedString("empty.noRounds", comment: "No rounds"))
                            .font(Font.system(size: 20, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)

                        Text(NSLocalizedString("empty.noRounds.message", comment: "Create rounds for quiz"))
                            .font(Font.system(size: 14, weight: .regular))
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }
                    
                    Text(NSLocalizedString("empty.noRounds.leaderboard.action", comment: "Switch to rounds tab"))
                        .font(.callout)
                        .foregroundStyle(Color.appTextSecondary)
                        .padding(.horizontal, AppSpacing.screenPadding)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 0) {
                        // Podium View for Top 3 ranks (may include more than 3 teams if tied)
                        let rankedTeams = calculateRanks()
                        let topRanks = rankedTeams.filter { $0.rank <= 3 }
                        if topRanks.count >= 3 {
                            PodiumView(rankedTeams: topRanks, quiz: quiz)
                                .padding(.bottom, AppSpacing.md)
                                .transition(.scale.combined(with: .opacity))
                        }

                        // All Teams List
                        LazyVStack(spacing: AppSpacing.xxs) {
                            ForEach(calculateRanks(), id: \.team.id) { item in
                                LeaderboardRowView(
                                    team: item.team,
                                    rank: item.rank,
                                    quiz: quiz,
                                    isTopThree: item.rank <= 3
                                )
                                .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: calculateRanks().map { $0.rank })
                    }
                    .padding(AppSpacing.sectionSpacing)
                }
            }
        }
    }
}

struct PodiumView: View {
    let rankedTeams: [(team: Team, rank: Int)]
    let quiz: Quiz

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
                        CompactRankRow(teams: rank1Teams, rank: 1, quiz: quiz)
                    }
                    if !rank2Teams.isEmpty {
                        CompactRankRow(teams: rank2Teams, rank: 2, quiz: quiz)
                    }
                    if !rank3Teams.isEmpty {
                        CompactRankRow(teams: rank3Teams, rank: 3, quiz: quiz)
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
                            PodiumPlace(team: item.team, rank: 2, height: 120, isShared: rank2Teams.count > 1, quiz: quiz)
                        }
                    }
                }
                
                // 1st Place
                if !rank1Teams.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(rank1Teams, id: \.team.id) { item in
                            PodiumPlace(team: item.team, rank: 1, height: 150, isShared: rank1Teams.count > 1, quiz: quiz)
                        }
                    }
                }
                
                // 3rd Place
                if !rank3Teams.isEmpty {
                    VStack(spacing: 8) {
                        ForEach(rank3Teams, id: \.team.id) { item in
                            PodiumPlace(team: item.team, rank: 3, height: 100, isShared: rank3Teams.count > 1, quiz: quiz)
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
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            HStack {
                Text(rankEmoji)
                    .font(.title)
                Text(String(format: NSLocalizedString("leaderboard.rank.position", comment: "Rank position"), rank))
                    .font(.headline)
                    .foregroundStyle(rankColor)
                if teams.count > 1 {
                    Text(NSLocalizedString("leaderboard.rank.tied", comment: "Tied rank"))
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                Spacer()
            }
            
            // Teams
            HStack(spacing: AppSpacing.xxs) {
                ForEach(teams, id: \.team.id) { item in
                    Text(item.team.name)
                        .font(.caption)
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)
                        .padding(.horizontal, AppSpacing.xxs)
                        .padding(.vertical, AppSpacing.xxxs)
                        .background(rankColor.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(AppSpacing.xs)
        .background(rankColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
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
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appPrimary
        default: return Color.appPrimary
        }
    }
}

struct PodiumPlace: View {
    let team: Team
    let rank: Int
    let height: CGFloat
    let isShared: Bool
    let quiz: Quiz

    var body: some View {
        VStack(spacing: 8) {
            Text(rankEmoji)
                .font(.system(size: isShared ? 32 : 40))

            Text("\(team.getTotalScore(for: quiz))")
                .font(.system(size: isShared ? 22 : 28, weight: .bold))
                .foregroundStyle(rankColor)
                .monospacedDigit()
            
            Text(team.name)
                .font(.caption)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(rankColor.opacity(0.2))
                .frame(width: isShared ? 80 : 100, height: isShared ? height * 0.8 : height)
                .overlay(
                    Text("\(rank).")
                        .font(.system(size: isShared ? 28 : 36, weight: .bold))
                        .foregroundStyle(rankColor)
                        .monospacedDigit()
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
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appPrimary
        default: return Color.appPrimary
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
        let rankings = quiz.getTeamRankings()
        let teamsWithSameRank = rankings.filter { $0.rank == rank }
        return teamsWithSameRank.count > 1
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Rank Badge
            ZStack {
                if isTopThree {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 4, y: 2)
                } else {
                    Circle()
                        .strokeBorder(Color.appTextTertiary.opacity(0.3), lineWidth: 2)
                        .background(Circle().fill(Color.appBackgroundSecondary))
                        .frame(width: 50, height: 50)
                }
                
                VStack(spacing: 0) {
                    if isSharedRank {
                        Text("=")
                            .font(.caption2)
                            .foregroundStyle(isTopThree ? .white.opacity(0.7) : Color.appTextSecondary)
                    }
                    Text("\(rank)")
                        .font(isTopThree ? .title : .title3)
                        .bold()
                        .foregroundStyle(isTopThree ? .white : Color.appTextPrimary)
                }
            }
            .frame(width: 60)
            
            // Team Info
            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(team.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                HStack(spacing: AppSpacing.xxs) {
                    ForEach(team.roundScores.prefix(6), id: \.roundId) { score in
                        VStack(spacing: AppSpacing.xxxs) {
                            Text("\(score.points)")
                                .font(.caption)
                                .bold()
                                .foregroundStyle(Color.appTextPrimary)
                                .monospacedDigit()
                                .contentTransition(.numericText())
                            Text(L10n.CommonUI.roundNumber(quiz.sortedRounds.firstIndex(where: { $0.id == score.roundId }).map { $0 + 1 } ?? 0))
                                .font(.system(size: 9))
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                        }
                        .frame(width: 32)
                        .padding(.vertical, AppSpacing.xxxs)
                        .background(Color.appTextTertiary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xs))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: score.points)
                    }
                    
                    if team.roundScores.count > 6 {
                        Text("+\(team.roundScores.count - 6)")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                }
            }
            
            Spacer()
            
            // Total Score
            VStack(alignment: .trailing, spacing: AppSpacing.xxxs) {
                Text("\(team.getTotalScore(for: quiz))")
                    .font(Font.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(isTopThree ? rankColor : Color.appTextPrimary)
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: team.getTotalScore(for: quiz))

                Text(NSLocalizedString("common.points", comment: "Points"))
                    .font(Font.system(size: 11, weight: .regular))
                    .foregroundStyle(Color.appTextSecondary)
                    .textCase(.uppercase)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .appCard(style: isTopThree ? .elevated : .default, cornerRadius: AppCornerRadius.lg)
        .overlay {
            if isTopThree {
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .strokeBorder(rankColor.opacity(0.3), lineWidth: 2)
            }
        }
    }
    
    private var rankColor: Color {
        switch rank {
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appPrimary
        default: return Color.appPrimary
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
                            Text("\(score) / \(round.maxPoints ?? 0)")
                        } else {
                            Text("– / \(round.maxPoints ?? 0)")
                        }
                    }
                    .font(.body)
                    .bold()
                }
                .padding(.vertical, 4)
            }
            
            Divider()
            
            HStack {
                Text(L10n.CommonUI.totalScore)
                    .font(.headline)
                
                Spacer()
                
                    Text("\(team.getTotalScore(for: quiz))")
                    .font(.title)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
            }
        }
        .padding()
    }
}
