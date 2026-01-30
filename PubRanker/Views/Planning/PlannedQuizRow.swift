//
//  PlannedQuizRow.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct PlannedQuizRow: View {
    let quiz: Quiz
    let isSelected: Bool

    init(quiz: Quiz, isSelected: Bool = false, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.quiz = quiz
        self.isSelected = isSelected
    }

    private var confirmedTeamsCount: Int {
        quiz.safeTeams.filter { $0.isConfirmed(for: quiz) }.count
    }

    var body: some View {
        HStack(spacing: 0) {
            // Selection Indicator
            if isSelected {
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.appPrimary)
                    .frame(width: 4)
                    .padding(.vertical, AppSpacing.xxs)
            }

            // Quiz Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(quiz.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(2)

                HStack(spacing: AppSpacing.xs) {
                    if !quiz.venue.isEmpty {
                        Label(quiz.venue, systemImage: "mappin.circle")
                            .font(.caption)
                    }
                    Text(quiz.date, style: .date)
                        .font(.caption)
                }
                .foregroundStyle(Color.appTextSecondary)

                HStack(spacing: AppSpacing.xxs) {
                    Label("\(confirmedTeamsCount)/\(quiz.safeTeams.count)", systemImage: "person.3")
                        .font(.caption2)
                        .foregroundStyle(confirmedTeamsCount == quiz.safeTeams.count && quiz.safeTeams.count > 0 ? Color.appSuccess : Color.appTextSecondary)
                    Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.vertical, AppSpacing.xs)
            .padding(.horizontal, AppSpacing.sm)

            Spacer()
        }
        .background(
            Group {
                if isSelected {
                    LinearGradient(
                        colors: [
                            Color.appPrimary.opacity(0.15),
                            Color.appPrimary.opacity(0.08)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                } else {
                    Color.clear
                }
            }
        )
        .cornerRadius(AppCornerRadius.sm)
        .overlay {
            if isSelected {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 2, leading: 8, bottom: 2, trailing: 8))
    }
}

