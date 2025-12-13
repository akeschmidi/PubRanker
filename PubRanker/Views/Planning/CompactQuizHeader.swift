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
                Button {
                    onEdit()
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "pencil")
                            .font(.body)
                        Text("Bearbeiten")
                            .font(.body)
                            .bold()
                    }
                }
                .primaryGradientButton()
                .help("Quiz bearbeiten")
                
                Button {
                    onDelete()
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "trash")
                            .font(.body)
                        Text("Löschen")
                            .font(.body)
                            .bold()
                    }
                }
                .accentGradientButton()
                .help("Quiz löschen")
                
                if !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                    Button {
                        onStart()
                    } label: {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "play.circle.fill")
                                .font(.body)
                            Text("Starten")
                                .font(.body)
                                .bold()
                        }
                    }
                    .successGradientButton()
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Quiz starten (⌘S)")
                }
            }
        }
        .padding(AppSpacing.md)
    }
}





