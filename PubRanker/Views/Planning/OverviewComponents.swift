//
//  OverviewComponents.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

// MARK: - Quick Stats Grid
struct QuickStatsGrid: View {
    let quiz: Quiz
    
    var body: some View {
        HStack(spacing: 12) {
            CompactStatCard(
                title: "Teams",
                value: "\(quiz.safeTeams.count)",
                icon: "person.3.fill",
                color: .blue,
                isComplete: !quiz.safeTeams.isEmpty
            )
            
            CompactStatCard(
                title: "Runden",
                value: "\(quiz.safeRounds.count)",
                icon: "list.number",
                color: .green,
                isComplete: !quiz.safeRounds.isEmpty
            )
            
            CompactStatCard(
                title: "Max. Punkte",
                value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })",
                icon: "star.fill",
                color: .orange,
                isComplete: !quiz.safeRounds.isEmpty
            )
        }
    }
}

// MARK: - Compact Stat Card
struct CompactStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isComplete: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .bold()
                    .monospacedDigit()
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title3)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Status Cards Section
struct StatusCardsSection: View {
    let quiz: Quiz
    
    var body: some View {
        HStack(spacing: 12) {
            StatusCard(
                title: quiz.safeTeams.isEmpty ? "Teams fehlen" : "Teams bereit",
                icon: quiz.safeTeams.isEmpty ? "person.3.slash.fill" : "person.3.fill",
                color: quiz.safeTeams.isEmpty ? .orange : .green
            )
            
            StatusCard(
                title: quiz.safeRounds.isEmpty ? "Runden fehlen" : "Runden bereit",
                icon: quiz.safeRounds.isEmpty ? "list.number" : "checkmark.circle.fill",
                color: quiz.safeRounds.isEmpty ? .orange : .green
            )
            
            StatusCard(
                title: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? "Bereit zum Start" : "Nicht bereit",
                icon: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                color: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? .green : .gray
            )
        }
    }
}

// MARK: - Status Card
struct StatusCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title3)
            
            Text(title)
                .font(.body)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .foregroundStyle(color)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(color.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Compact Team Overview
struct CompactTeamOverview: View {
    let quiz: Quiz
    let onManage: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Teams (\(quiz.safeTeams.count))", systemImage: "person.3.fill")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button {
                    onManage()
                } label: {
                    Text("Verwalten")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 10)], spacing: 10) {
                ForEach(quiz.safeTeams) { team in
                    CompactTeamCard(team: team)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Compact Team Card
struct CompactTeamCard: View {
    let team: Team
    
    var body: some View {
        HStack(spacing: 10) {
            TeamIconView(team: team, size: 40)
            
            Text(team.name)
                .font(.body)
                .lineLimit(1)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: team.color)?.opacity(0.3) ?? .clear, lineWidth: 1)
        }
    }
}

// MARK: - Compact Rounds Overview
struct CompactRoundsOverview: View {
    let quiz: Quiz
    let onManage: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Runden (\(quiz.safeRounds.count))", systemImage: "list.number")
                    .font(.title3)
                    .bold()
                
                Spacer()
                
                Button {
                    onManage()
                } label: {
                    Text("Verwalten")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                ForEach(Array(quiz.sortedRounds.enumerated()), id: \.element.id) { index, round in
                    CompactRoundCard(round: round, index: index)
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Compact Round Card
struct CompactRoundCard: View {
    let round: Round
    let index: Int
    
    var body: some View {
        VStack(spacing: 6) {
            Text("R\(index + 1)")
                .font(.body)
                .bold()
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(.blue)
                .clipShape(Circle())
            
            Text(round.name)
                .font(.body)
                .lineLimit(2)
                .multilineTextAlignment(.center)
            
            Text("\(round.maxPoints) Pkt")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

