//
//  QuizCheckboxRow.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct QuizCheckboxRow: View {
    let quiz: Quiz
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.body)
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }

                // Quiz Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.body)
                        .bold()
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                            .font(.subheadline)
                        Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}





