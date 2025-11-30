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
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(color)

                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isComplete {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.title2)
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [
                    color.opacity(0.05),
                    color.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(color.opacity(0.2), lineWidth: 1)
        }
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

    private var sortedTeams: [Team] {
        quiz.safeTeams.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

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

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: 12)], spacing: 12) {
                ForEach(sortedTeams) { team in
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
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                TeamIconView(team: team, size: 44)

                VStack(alignment: .leading, spacing: 4) {
                    Text(team.name)
                        .font(.body)
                        .bold()
                        .lineLimit(1)

                    if !team.contactPerson.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                            Text(team.contactPerson)
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    }
                }

                Spacer()

                // Status Indicator
                VStack(spacing: 4) {
                    if team.isConfirmed {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                            .font(.title3)
                    }

                    if !team.email.isEmpty {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.blue)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(12)
        .background(
            LinearGradient(
                colors: [
                    (Color(hex: team.color) ?? .blue).opacity(0.08),
                    (Color(hex: team.color) ?? .blue).opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: team.color)?.opacity(0.4) ?? .clear, lineWidth: 1.5)
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

