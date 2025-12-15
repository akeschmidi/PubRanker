//
//  CompactQuizHeader.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct CompactQuizHeader: View {
    let quiz: Quiz
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onStart: () -> Void
    var onEmail: (() -> Void)? = nil
    
    /// Anzahl der Teams mit E-Mail-Adresse
    private var teamsWithEmailCount: Int {
        quiz.safeTeams.filter { !$0.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Quiz Info
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "calendar.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.appPrimary)
                
                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(quiz.name)
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                    
                    HStack(spacing: AppSpacing.xs) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.body)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.body)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
            }
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: AppSpacing.xxs) {
                // E-Mail Button
                if let onEmail = onEmail, teamsWithEmailCount > 0 {
                    Button {
                        onEmail()
                    } label: {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "envelope.fill")
                                .font(.body)
                            Text(NSLocalizedString("email.send", comment: "Send email"))
                                .font(.body)
                                .bold()
                        }
                    }
                    .secondaryGradientButton()
                    .keyboardShortcut("e", modifiers: .command)
                    .help(String(format: NSLocalizedString("email.send.quiz.help", comment: ""), teamsWithEmailCount))
                }
                
                Button {
                    onEdit()
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "pencil")
                            .font(.body)
                        Text(NSLocalizedString("navigation.edit", comment: "Edit"))
                            .font(.body)
                            .bold()
                    }
                }
                .primaryGradientButton()
                .help(NSLocalizedString("quiz.edit.help", comment: "Edit quiz"))
                
                Button {
                    onDelete()
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "trash")
                            .font(.body)
                        Text(NSLocalizedString("navigation.delete", comment: "Delete"))
                            .font(.body)
                            .bold()
                    }
                }
                .accentGradientButton()
                .help(NSLocalizedString("quiz.delete.help", comment: "Delete quiz"))
                
                if !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                    Button {
                        onStart()
                    } label: {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "play.circle.fill")
                                .font(.body)
                            Text(NSLocalizedString("common.start", comment: "Start"))
                                .font(.body)
                                .bold()
                        }
                    }
                    .successGradientButton()
                    .keyboardShortcut("s", modifiers: .command)
                    .help(NSLocalizedString("quiz.start.help", comment: "Start quiz"))
                }
            }
        }
        .padding(AppSpacing.md)
    }
}





