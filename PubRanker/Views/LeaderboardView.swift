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
    
    var body: some View {
        Group {
            if quiz.teams.isEmpty {
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
            } else if quiz.rounds.isEmpty {
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
                        // Podium View for Top 3
                        if quiz.teams.count >= 3 {
                            PodiumView(teams: Array(quiz.sortedTeamsByScore.prefix(3)))
                                .padding(.bottom, 20)
                        }
                        
                        // All Teams List
                        LazyVStack(spacing: 8) {
                            ForEach(Array(quiz.sortedTeamsByScore.enumerated()), id: \.element.id) { index, team in
                                LeaderboardRowView(
                                    team: team,
                                    rank: index + 1,
                                    quiz: quiz,
                                    isTopThree: index < 3
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
    let teams: [Team]
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 20) {
            // 2nd Place
            if teams.count > 1 {
                PodiumPlace(team: teams[1], rank: 2, height: 120)
            }
            
            // 1st Place
            if teams.count > 0 {
                PodiumPlace(team: teams[0], rank: 1, height: 150)
            }
            
            // 3rd Place
            if teams.count > 2 {
                PodiumPlace(team: teams[2], rank: 3, height: 100)
            }
        }
        .padding(.vertical, 20)
    }
}

struct PodiumPlace: View {
    let team: Team
    let rank: Int
    let height: CGFloat
    
    var body: some View {
        VStack(spacing: 8) {
            Text(rankEmoji)
                .font(.system(size: 40))
            
            Text("\(team.totalScore)")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(rankColor)
            
            Text(team.name)
                .font(.caption)
                .bold()
                .multilineTextAlignment(.center)
                .lineLimit(2)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(rankColor.opacity(0.2))
                .frame(width: 100, height: height)
                .overlay(
                    Text("\(rank).")
                        .font(.system(size: 36, weight: .bold))
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
                
                Text("\(rank)")
                    .font(isTopThree ? .title : .title3)
                    .bold()
                    .foregroundStyle(isTopThree ? .white : .primary)
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
                    
                    Text("\(team.getScore(for: round)) / \(round.maxPoints)")
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
