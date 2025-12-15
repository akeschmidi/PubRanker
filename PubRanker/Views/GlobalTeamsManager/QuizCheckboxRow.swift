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
            HStack(spacing: AppSpacing.xs) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                        .stroke(isSelected ? Color.appPrimary : Color.appTextTertiary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.clear)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.body)
                            .bold()
                            .foregroundStyle(Color.appPrimary)
                    }
                }

                // Quiz Info
                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(quiz.name)
                        .font(.body)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)

                    HStack(spacing: AppSpacing.xs) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: AppSpacing.xxs) {
                        Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                            .font(.subheadline)
                        Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }

                Spacer()
            }
            .padding(AppSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .fill(isSelected ? Color.appPrimary.opacity(0.05) : Color.appBackgroundSecondary)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(isSelected ? Color.appPrimary.opacity(0.3) : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}









