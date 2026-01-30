//
//  CompactQuizHeader.swift
//  PubRanker
//
//  Created on 23.11.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI
import SwiftData

struct CompactQuizHeader: View {
    let quiz: Quiz
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil
    var onStart: (() -> Void)? = nil
    var onEmail: (() -> Void)? = nil

    /// Zeigt die Action-Buttons an (Standard: false für Sidebar-Buttons)
    var showActionButtons: Bool = false
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    /// Anzahl der Teams mit E-Mail-Adresse
    private var teamsWithEmailCount: Int {
        quiz.safeTeams.filter { !$0.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }.count
    }
    
    var body: some View {
        #if os(iOS)
        // iPad: Minimale Abstände
        HStack(alignment: .center, spacing: AppSpacing.xxs) {
            // Quiz Info - kompakt
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "calendar.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appPrimary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.name)
                        .font(.headline)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(1)

                    HStack(spacing: AppSpacing.xxs) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.caption)
                                .lineLimit(1)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.caption)
                    }
                    .foregroundStyle(Color.appTextSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Action Buttons (optional)
            if showActionButtons {
                actionButtons
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.top, 0)
        .padding(.bottom, AppSpacing.xxs)
        .background(Color.adaptiveCardBackground)
        #else
        // macOS: Original Layout
        VStack(spacing: AppSpacing.sm) {
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "calendar.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appPrimary)

                    VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                        Text(quiz.name)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)

                        HStack(spacing: AppSpacing.xs) {
                            if !quiz.venue.isEmpty {
                                Label(quiz.venue, systemImage: "mappin.circle")
                                    .font(.subheadline)
                                    .lineLimit(1)
                            }
                            Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // Action Buttons (optional)
                if showActionButtons {
                    actionButtons
                }
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.xs)
        .background(Color.adaptiveCardBackground)
        #endif
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var actionButtons: some View {
        #if os(iOS)
        // iPad: Compact icon-only buttons
        HStack(spacing: AppSpacing.xxs) {
            // E-Mail Button
            if let onEmail = onEmail, teamsWithEmailCount > 0 {
                Button {
                    onEmail()
                } label: {
                    Image(systemName: "envelope.fill")
                        .font(.body)
                        .frame(width: AppSpacing.touchTarget, height: AppSpacing.touchTarget)
                }
                .buttonStyle(.plain)
                .background(
                    Circle()
                        .fill(Color.appSecondary)
                )
                .foregroundStyle(.white)
            }

            if let onEdit = onEdit {
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .frame(width: AppSpacing.touchTarget, height: AppSpacing.touchTarget)
                }
                .buttonStyle(.plain)
                .background(
                    Circle()
                        .fill(Color.appPrimary)
                )
                .foregroundStyle(.white)
            }

            if let onDelete = onDelete {
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.body)
                        .frame(width: AppSpacing.touchTarget, height: AppSpacing.touchTarget)
                }
                .buttonStyle(.plain)
                .background(
                    Circle()
                        .fill(Color.appAccent)
                )
                .foregroundStyle(.white)
            }

            if let onStart = onStart, !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                Button {
                    onStart()
                } label: {
                    Image(systemName: "play.fill")
                        .font(.body)
                        .frame(width: AppSpacing.touchTarget, height: AppSpacing.touchTarget)
                }
                .buttonStyle(.plain)
                .background(
                    Circle()
                        .fill(Color.appSuccess)
                )
                .foregroundStyle(.white)
            }
        }
        #else
        // macOS: Full labels with keyboard shortcuts - Liquid Glass Design
        HStack(spacing: AppSpacing.xxs) {
            // E-Mail Button - Glass Design
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
                .secondaryGlassButton()
                .keyboardShortcut("e", modifiers: .command)
                .helpText(String(format: NSLocalizedString("email.send.quiz.help", comment: ""), teamsWithEmailCount))
            }
            
            if let onEdit = onEdit {
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
                .primaryGlassButton()
                .helpText(NSLocalizedString("quiz.edit.help", comment: "Edit quiz"))
            }

            if let onDelete = onDelete {
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
                .destructiveGlassButton()
                .helpText(NSLocalizedString("quiz.delete.help", comment: "Delete quiz"))
            }

            if let onStart = onStart, !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                Button {
                    onStart()
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "play.fill")
                            .font(.body)
                        Text(NSLocalizedString("common.start", comment: "Start"))
                            .font(.body)
                            .bold()
                    }
                }
                .successGlassButton()
                .keyboardShortcut("s", modifiers: .command)
                .helpText(NSLocalizedString("quiz.start.help", comment: "Start quiz"))
            }
        }
        #endif
    }
}
