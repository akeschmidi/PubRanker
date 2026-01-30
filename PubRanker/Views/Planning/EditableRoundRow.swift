//
//  EditableRoundRow.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct EditableRoundRow: View {
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingEditSheet = false
    @State private var showingDeleteConfirmation = false
    
    var statusColor: Color {
        if round.isCompleted {
            return Color.appSuccess
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return Color.appAccent
        } else {
            return Color.appTextSecondary
        }
    }
    
    var statusText: String {
        if round.isCompleted {
            return "Abgeschlossen"
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return "Aktiv"
        } else {
            return "Vorbereitung"
        }
    }
    
    var statusIcon: String {
        if round.isCompleted {
            return "checkmark.circle.fill"
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return "circle.fill"
        } else {
            return "hourglass.circle"
        }
    }
    
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            // Runden-Nummer Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [statusColor, statusColor.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: AppSpacing.xxxl, height: AppSpacing.xxxl)
                    .shadow(AppShadow.md)

                Text("R\(getRoundNumber())")
                    .font(.system(size: AppSpacing.sm, weight: .bold))
                    .foregroundStyle(.white)
                    .monospacedDigit()
            }
            
            // Runden-Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(round.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                HStack(spacing: AppSpacing.xs) {
                    // Status
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: statusIcon)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(statusColor)
                    }
                    .padding(.horizontal, AppSpacing.xxs)
                    .padding(.vertical, AppSpacing.xxxs)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
                    
                    // Punkte
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appAccent)
                        Text("\(round.maxPoints ?? 0) Pkt")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                }
            }
            
            Spacer()
            
            // Status Badge (nur wenn aktiv oder abgeschlossen)
            if round.isCompleted || (quiz.isActive && quiz.currentRound?.id == round.id) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(statusColor)
                    .symbolEffect(.pulse, options: .repeating)
            }
            
            // Bearbeiten-Button
            Button {
                showingEditSheet = true
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "pencil")
                        .font(.body)
                    Text("Bearbeiten")
                        .font(.body)
                }
            }
            .primaryGlassButton()
            .helpText("Runde bearbeiten")
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .appCard(style: .glass, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(
                    LinearGradient(
                        colors: [
                            statusColor.opacity(0.4),
                            statusColor.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: AppSpacing.xxxs
                )
        }
        .sheet(isPresented: $showingEditSheet) {
            EditRoundSheet(round: round, quiz: quiz, viewModel: viewModel)
        }
    }
    
    private func getRoundNumber() -> Int {
        guard let index = quiz.sortedRounds.firstIndex(where: { $0.id == round.id }) else {
            return 0
        }
        return index + 1
    }
}





