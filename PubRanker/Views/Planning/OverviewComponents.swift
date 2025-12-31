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
        HStack(spacing: AppSpacing.xs) {
            CompactStatCard(
                title: "Teams",
                value: "\(quiz.safeTeams.count)",
                icon: "person.3.fill",
                color: Color.appPrimary,
                isComplete: !quiz.safeTeams.isEmpty
            )
            
            CompactStatCard(
                title: "Runden",
                value: "\(quiz.safeRounds.count)",
                icon: "list.number",
                color: Color.appSuccess,
                isComplete: !quiz.safeRounds.isEmpty
            )
            
            CompactStatCard(
                title: "Max. Punkte",
                value: "\(quiz.safeRounds.reduce(0) { $0 + ($1.maxPoints ?? 0) })",
                icon: "star.fill",
                color: Color.appAccent,
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
        VStack(spacing: AppSpacing.xxs) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(AppShadow.sm)

                Image(systemName: icon)
                    .font(.body)
                    .foregroundStyle(color)
            }
            .overlay(alignment: .topTrailing) {
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appSuccess)
                        .font(.caption)
                        .offset(x: 4, y: -4)
                }
            }

            Text(value)
                .font(.system(size: 20, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(color)

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.sm)
        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(color.opacity(0.2), lineWidth: AppSpacing.xxxs)
        }
    }
}

// MARK: - Status Cards Section
struct StatusCardsSection: View {
    let quiz: Quiz
    
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            StatusCard(
                title: quiz.safeTeams.isEmpty ? "Teams fehlen" : "Teams bereit",
                icon: quiz.safeTeams.isEmpty ? "person.slash.fill" : "person.3.fill",
                color: quiz.safeTeams.isEmpty ? Color.appAccent : Color.appSuccess
            )
            
            StatusCard(
                title: quiz.safeRounds.isEmpty ? "Runden fehlen" : "Runden bereit",
                icon: quiz.safeRounds.isEmpty ? "list.number" : "checkmark.circle.fill",
                color: quiz.safeRounds.isEmpty ? Color.appAccent : Color.appSuccess
            )
            
            StatusCard(
                title: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? "Bereit zum Start" : "Nicht bereit",
                icon: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? "checkmark.circle.fill" : "exclamationmark.circle.fill",
                color: (!quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty) ? Color.appSuccess : Color.appTextSecondary
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
        VStack(spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .font(.title2)
            
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(color)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.sm)
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .stroke(color.opacity(0.3), lineWidth: AppSpacing.xxxs)
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
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Label("Teams (\(quiz.safeTeams.count))", systemImage: "person.3.fill")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                Spacer()

                Button {
                    onManage()
                } label: {
                    Text("Verwalten")
                        .font(.body)
                }
                .secondaryGradientButton()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: AppSpacing.xs)], spacing: AppSpacing.xs) {
                ForEach(sortedTeams) { team in
                    CompactTeamCard(team: team, quiz: quiz)
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .default)
    }
}

// MARK: - Compact Team Card
struct CompactTeamCard: View {
    let team: Team
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            HStack(spacing: AppSpacing.xs) {
                TeamIconView(team: team, size: 44)

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(team.name)
                        .font(.body)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)

                    if !team.contactPerson.isEmpty {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                            Text(team.contactPerson)
                                .font(.caption)
                        }
                        .foregroundStyle(Color.appTextSecondary)
                        .lineLimit(1)
                    }
                }

                Spacer()

                // Status Indicator
                VStack(spacing: AppSpacing.xxxs) {
                    if team.isConfirmed(for: quiz) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.appSuccess)
                            .font(.title3)
                    }

                    if !team.email.isEmpty {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(Color.appPrimary)
                            .font(.caption)
                    }
                }
            }
        }
        .padding(AppSpacing.xs)
        .background(
            LinearGradient(
                colors: [
                    (Color(hex: team.color) ?? Color.appPrimary).opacity(0.08),
                    (Color(hex: team.color) ?? Color.appPrimary).opacity(0.03)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .stroke(Color(hex: team.color)?.opacity(0.4) ?? Color.clear, lineWidth: AppSpacing.xxxs)
        }
    }
}

// MARK: - Compact Rounds Overview
struct CompactRoundsOverview: View {
    let quiz: Quiz
    let onManage: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Label("Runden (\(quiz.safeRounds.count))", systemImage: "list.number")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                Spacer()
                
                Button {
                    onManage()
                } label: {
                    Text("Verwalten")
                        .font(.body)
                }
                .secondaryGradientButton()
            }
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: AppSpacing.xs)], spacing: AppSpacing.xs) {
                ForEach(Array(quiz.sortedRounds.enumerated()), id: \.element.id) { index, round in
                    CompactRoundCard(round: round, index: index)
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .default)
    }
}

// MARK: - Compact Round Card
struct CompactRoundCard: View {
    let round: Round
    let index: Int
    
    var body: some View {
        VStack(spacing: AppSpacing.xxxs) {
            Text("R\(index + 1)")
                .font(.body)
                .bold()
                .foregroundStyle(.white)
                .frame(width: 36, height: 36)
                .background(Color.appPrimary)
                .clipShape(Circle())
                .shadow(AppShadow.sm)

            Text(round.name)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)

            if let maxPoints = round.maxPoints {
                Text("\(maxPoints) Pkt")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
            } else {
                Text(L10n.Round.noMaxPointsShort)
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.xs)
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
    }
}

