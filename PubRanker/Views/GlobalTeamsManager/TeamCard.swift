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
            HStack(spacing: AppSpacing.xs) {
                TeamIconView(team: team, size: 40)

                Text(team.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                Spacer()
            }
            .padding(AppSpacing.sm)
            .background(
                LinearGradient(
                    colors: [
                        (Color(hex: team.color) ?? Color.appPrimary).opacity(0.1),
                        (Color(hex: team.color) ?? Color.appPrimary).opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            Divider()

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                if !team.contactPerson.isEmpty {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 20)
                        Text(team.contactPerson)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                if !team.email.isEmpty {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 20)
                        Text(team.email)
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .lineLimit(1)
                    }
                }

                // Bestätigungsstatus
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: team.isConfirmed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(team.isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                        .frame(width: 20)
                    Text(team.isConfirmed ? "Bestätigt" : "Nicht bestätigt")
                        .font(.subheadline)
                        .foregroundStyle(team.isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                }

                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "link.circle.fill")
                            .foregroundStyle(Color.appSecondary)
                            .frame(width: 20)
                        if quizzes.count == 1 {
                            Text("Zugeordnet zu: \(quizzes[0].name)")
                                .font(.body)
                                .foregroundStyle(Color.appSecondary)
                        } else {
                            Text("Zugeordnet zu \(quizzes.count) Quizzes")
                                .font(.body)
                                .foregroundStyle(Color.appSecondary)
                        }
                    }
                    .padding(.top, AppSpacing.xxxs)
                } else {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "circle.dotted")
                            .foregroundStyle(Color.appTextSecondary)
                            .frame(width: 20)
                            .font(.body)
                        Text("Nicht zugeordnet")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .padding(.top, AppSpacing.xxxs)
                }

                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.appTextSecondary)
                        .frame(width: 20)
                        .font(.body)
                    Text("Erstellt: \(team.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(AppSpacing.sm)

            Divider()

            HStack(spacing: AppSpacing.xxs) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .font(.body)
                }
                .primaryGradientButton(size: .small)

                Spacer()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                }
                .accentGradientButton(size: .small)
            }
            .padding(AppSpacing.xs)
            .background(Color.appBackgroundSecondary.opacity(0.5))
        }
        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
        .sheet(isPresented: $showingEditSheet) {
            GlobalEditTeamSheet(team: team, viewModel: viewModel)
        }
    }
}


