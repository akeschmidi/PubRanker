//
//  TeamCard.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct TeamCard: View {
    @Bindable var team: Team
    @Bindable var viewModel: QuizViewModel
    let onDelete: () -> Void

    @State private var showingEditSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Header mit Team-Info und Kontaktdaten
            HStack(alignment: .top, spacing: AppSpacing.md) {
                // Linke Seite: Icon + Team-Name
                HStack(spacing: AppSpacing.sm) {
                    TeamIconView(team: team, size: 50)
                        .shadow(color: (Color(hex: team.color) ?? Color.appPrimary).opacity(0.3), radius: 4, y: 2)

                    VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                        Text(team.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let quizzes = team.quizzes, !quizzes.isEmpty {
                            HStack(spacing: AppSpacing.xxxs) {
                                Image(systemName: "link.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color(hex: team.color) ?? Color.appPrimary)
                                Text("\(quizzes.count) Quiz")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }
                }

                Spacer(minLength: AppSpacing.xs)

                // Rechte Seite: Kontaktdaten kompakt
                VStack(alignment: .trailing, spacing: AppSpacing.xxs) {
                    if !team.contactPerson.isEmpty {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                            Text(team.contactPerson)
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }

                    if !team.email.isEmpty {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "envelope.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                            Text(team.email)
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .lineLimit(1)
                        }
                    }

                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                        Text(team.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding(AppSpacing.md)
            .background(
                LinearGradient(
                    colors: [
                        (Color(hex: team.color) ?? Color.appPrimary).opacity(0.12),
                        (Color(hex: team.color) ?? Color.appPrimary).opacity(0.06)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            Divider()

            // Status-Bereich
            HStack(spacing: AppSpacing.md) {
                // Bestätigungsstatus
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: team.isConfirmed ? "checkmark.circle.fill" : "circle")
                        .font(.body)
                        .foregroundStyle(team.isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                    Text(team.isConfirmed ? "Bestätigt" : "Nicht bestätigt")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(team.isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                }

                Spacer()

                // Quiz-Zuordnung
                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "link.circle.fill")
                            .font(.body)
                            .foregroundStyle(Color.appSecondary)
                        if quizzes.count == 1 {
                            Text(quizzes[0].name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appSecondary)
                                .lineLimit(1)
                        } else {
                            Text("\(quizzes.count) Quizzes")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appSecondary)
                        }
                    }
                } else {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "circle.dotted")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                        Text("Nicht zugeordnet")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)

            Divider()

            HStack(spacing: AppSpacing.xs) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .primaryGlassButton(size: .small)

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Löschen", systemImage: "trash")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .destructiveGlassButton(size: .small)
            }
            .padding(AppSpacing.sm)
            .background(Color.appBackgroundSecondary.opacity(0.5))
        }
        .appCard(style: .glass, cornerRadius: AppCornerRadius.md)
        .sheet(isPresented: $showingEditSheet) {
            GlobalEditTeamSheet(team: team, viewModel: viewModel)
        }
    }
}


