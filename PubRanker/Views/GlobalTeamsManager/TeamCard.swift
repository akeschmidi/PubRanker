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
            HStack(spacing: 12) {
                TeamIconView(team: team, size: 40)

                Text(team.name)
                    .font(.body)
                    .bold()
                    .lineLimit(1)

                Spacer()
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        (Color(hex: team.color) ?? .blue).opacity(0.1),
                        (Color(hex: team.color) ?? .blue).opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                if !team.contactPerson.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(team.contactPerson)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !team.email.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(team.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                // Bestätigungsstatus
                HStack(spacing: 8) {
                    Image(systemName: team.isConfirmed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(team.isConfirmed ? .green : .secondary)
                        .frame(width: 20)
                    Text(team.isConfirmed ? "Bestätigt" : "Nicht bestätigt")
                        .font(.subheadline)
                        .foregroundStyle(team.isConfirmed ? .green : .secondary)
                }

                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "link.circle.fill")
                            .foregroundStyle(.purple)
                            .frame(width: 20)
                        if quizzes.count == 1 {
                            Text("Zugeordnet zu: \(quizzes[0].name)")
                                .font(.body)
                                .foregroundStyle(.purple)
                        } else {
                            Text("Zugeordnet zu \(quizzes.count) Quizzes")
                                .font(.body)
                                .foregroundStyle(.purple)
                        }
                    }
                    .padding(.top, 4)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.dotted")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                            .font(.body)
                        Text("Nicht zugeordnet")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                        .font(.body)
                    Text("Erstellt: \(team.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            Divider()

            HStack(spacing: 8) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)

                Spacer()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingEditSheet) {
            GlobalEditTeamSheet(team: team, viewModel: viewModel)
        }
    }
}


