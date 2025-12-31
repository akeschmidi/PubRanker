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
    let onEdit: (() -> Void)?
    let onDelete: (() -> Void)?
    
    init(quiz: Quiz, onEdit: (() -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        self.quiz = quiz
        self.onEdit = onEdit
        self.onDelete = onDelete
    }

    private var confirmedTeamsCount: Int {
        quiz.safeTeams.filter { $0.isConfirmed(for: quiz) }.count
    }

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            // Quiz Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(quiz.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)

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
        .padding(.vertical, AppSpacing.xxxs)
        .padding(.horizontal, AppSpacing.xxxs)
    }
}

