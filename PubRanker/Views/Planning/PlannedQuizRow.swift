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
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?

    init(quiz: Quiz, isSelected: Bool = false, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.quiz = quiz
        self.isSelected = isSelected
        self.onEdit = onEdit
        self.onDelete = onDelete
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

            HStack(spacing: AppSpacing.xs) {
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
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: AppSpacing.xxs) {
                if let onEdit = onEdit {
                    Button {
                        onEdit()
                    } label: {
                        Image(systemName: "pencil")
                            .font(.body)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: max(AppSpacing.lg, AppSpacing.touchTarget), height: max(AppSpacing.lg, AppSpacing.touchTarget))
                            .background(
                                Circle()
                                    .fill(Color.appPrimary)
                            )
                            .shadow(AppShadow.sm)
                    }
                    .buttonStyle(.plain)
                    .helpText("Quiz bearbeiten")
                }

                if let onDelete = onDelete {
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .font(.body)
                            .bold()
                            .foregroundStyle(.white)
                            .frame(width: max(AppSpacing.lg, AppSpacing.touchTarget), height: max(AppSpacing.lg, AppSpacing.touchTarget))
                            .background(
                                Circle()
                                    .fill(Color.appAccent)
                            )
                            .shadow(AppShadow.sm)
                    }
                    .buttonStyle(.plain)
                    .helpText("Quiz löschen")
                }
            }
            }
            .padding(.vertical, AppSpacing.xs)
            .padding(.horizontal, AppSpacing.sm)
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

