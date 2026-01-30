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
    var onTeamsTap: (() -> Void)? = nil
    var onRoundsTap: (() -> Void)? = nil

    @State private var totalMaxPoints: Int = 0

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            CompactStatCard(
                title: "Teams",
                value: "\(quiz.safeTeams.count)",
                icon: "person.3.fill",
                color: Color.appPrimary,
                isComplete: !quiz.safeTeams.isEmpty,
                onTap: onTeamsTap
            )

            CompactStatCard(
                title: "Runden",
                value: "\(quiz.safeRounds.count)",
                icon: "list.number",
                color: Color.appSuccess,
                isComplete: !quiz.safeRounds.isEmpty,
                onTap: onRoundsTap
            )

            CompactStatCard(
                title: "Max. Punkte",
                value: "\(totalMaxPoints)",
                icon: "star.fill",
                color: Color.appAccent,
                isComplete: !quiz.safeRounds.isEmpty
            )
        }
        .onAppear {
            updateTotalMaxPoints()
        }
        .onChange(of: quiz.safeRounds.count) { _, _ in
            updateTotalMaxPoints()
        }
    }

    private func updateTotalMaxPoints() {
        totalMaxPoints = quiz.safeRounds.reduce(0) { $0 + ($1.maxPoints ?? 0) }
    }
}

// MARK: - Compact Stat Card
struct CompactStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let isComplete: Bool
    var onTap: (() -> Void)? = nil

    var body: some View {
        Group {
            if let onTap = onTap {
                Button(action: onTap) {
                    cardContent
                }
                .buttonStyle(.plain)
            } else {
                cardContent
            }
        }
    }

    private var cardContent: some View {
        VStack(spacing: AppSpacing.xs) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 54, height: 54)
                    .shadow(color: color.opacity(0.3), radius: 6, y: 3)

                Image(systemName: icon)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(color)
            }
            .overlay(alignment: .topTrailing) {
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.appSuccess)
                        .font(.body)
                        .background(
                            Circle()
                                .fill(Color.appBackground)
                                .frame(width: 14, height: 14)
                        )
                        .offset(x: 6, y: -6)
                }
            }

            Text(value)
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(color)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.md)
        .padding(.horizontal, AppSpacing.sm)
        .background(
            LinearGradient(
                colors: [color.opacity(0.08), color.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .appCard(style: .glass, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(color.opacity(0.3), lineWidth: 1.5)
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
        .appCard(style: .glass, cornerRadius: AppCornerRadius.sm)
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

    @State private var sortedTeams: [Team] = []

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
                .secondaryGlassButton()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280), spacing: AppSpacing.xs)], spacing: AppSpacing.xs) {
                ForEach(sortedTeams) { team in
                    CompactTeamCard(team: team, quiz: quiz)
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .glass)
        .onAppear {
            updateSortedTeams()
        }
        .onChange(of: quiz.safeTeams.count) { _, _ in
            updateSortedTeams()
        }
    }

    private func updateSortedTeams() {
        sortedTeams = quiz.safeTeams.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
}

// MARK: - Compact Team Card
struct CompactTeamCard: View {
    @Bindable var team: Team
    let quiz: Quiz

    @State private var isConfirmed: Bool = false

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Team Icon
            TeamIconView(team: team, size: 52)
                .shadow(color: (Color(hex: team.color) ?? Color.appPrimary).opacity(0.3), radius: 4, y: 2)

            // Team Info - nimmt verfügbaren Platz
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(team.name)
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)

                if !team.contactPerson.isEmpty {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "person.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                        Text(team.contactPerson)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .lineLimit(1)
                }

                if !team.email.isEmpty {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "envelope.fill")
                            .font(.caption2)
                            .foregroundStyle(Color.appPrimary)
                        Text(team.email)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(AppSpacing.sm)
        .background(
            LinearGradient(
                colors: [
                    (Color(hex: team.color) ?? Color.appPrimary).opacity(0.12),
                    (Color(hex: team.color) ?? Color.appPrimary).opacity(0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .appCard(style: .glass, cornerRadius: AppCornerRadius.sm)
        // Rahmen zuerst (hinter dem Badge)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .stroke((Color(hex: team.color) ?? Color.appPrimary).opacity(isConfirmed ? 0.8 : 0.5), lineWidth: isConfirmed ? 2 : 1.5)
        }
        // Badge oben rechts (über dem Rahmen)
        .overlay(alignment: .topTrailing) {
            // Bestätigt Badge - anklickbar
            Button {
                isConfirmed.toggle()
                team.setConfirmed(for: quiz, isConfirmed: isConfirmed)
                try? team.modelContext?.save()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .shadow(color: isConfirmed ? Color.appSuccess.opacity(0.4) : Color.gray.opacity(0.3), radius: 3, y: 1)

                    Image(systemName: isConfirmed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isConfirmed ? Color.appSuccess : Color.appTextTertiary)
                        .font(.system(size: 22))
                }
            }
            .buttonStyle(.plain)
            .offset(x: 6, y: -6)
        }
        .onAppear {
            isConfirmed = team.isConfirmed(for: quiz)
        }
    }
}

// MARK: - Compact Rounds Overview
struct CompactRoundsOverview: View {
    let quiz: Quiz
    let onManage: () -> Void
    var onRoundTap: ((Round) -> Void)? = nil

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
                .secondaryGlassButton()
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: AppSpacing.xs)], spacing: AppSpacing.xs) {
                ForEach(quiz.sortedRounds.indices, id: \.self) { index in
                    let round = quiz.sortedRounds[index]
                    CompactRoundCard(round: round, index: index) {
                        onRoundTap?(round)
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .glass)
    }
}

// MARK: - Compact Round Card
struct CompactRoundCard: View {
    let round: Round
    let index: Int
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
        VStack(spacing: AppSpacing.xs) {
            // Round Badge oder Bild
            if let imageData = round.imageData {
                // Runden-Bild anzeigen
                #if os(macOS)
                if let nsImage = NSImage(data: imageData) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(Color.appPrimary.opacity(0.4), lineWidth: 2)
                        )
                        .shadow(color: Color.appPrimary.opacity(0.3), radius: 4, y: 2)
                }
                #else
                if let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                .stroke(Color.appPrimary.opacity(0.4), lineWidth: 2)
                        )
                        .shadow(color: Color.appPrimary.opacity(0.3), radius: 4, y: 2)
                }
                #endif
            } else {
                // Fallback: Runden-Nummer Badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.9), Color.appPrimary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)
                        .shadow(color: Color.appPrimary.opacity(0.4), radius: 6, y: 3)

                    Text("R\(index + 1)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
            }

            // Round Name
            Text(round.name)
                .font(.body)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.9)

            // Max Points
            if let maxPoints = round.maxPoints {
                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(Color.appAccent)
                    Text("\(maxPoints)")
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.appAccent)
                        .monospacedDigit()
                    Text("Pkt")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            } else {
                Text(L10n.Round.noMaxPointsShort)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 128) // Fix height for uniform round card sizing
        .padding(.vertical, AppSpacing.sm)
        .padding(.horizontal, AppSpacing.xs)
        .background(
            LinearGradient(
                colors: [Color.appPrimary.opacity(0.08), Color.appPrimary.opacity(0.03)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .appCard(style: .glass, cornerRadius: AppCornerRadius.sm)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1.5)
        }
        }
        .buttonStyle(.plain)
    }
}

