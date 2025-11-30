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
            return .green
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return .orange
        } else {
            return .gray
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
        HStack(spacing: 16) {
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
                    .frame(width: 48, height: 48)
                    .shadow(color: statusColor.opacity(0.4), radius: 6, x: 0, y: 2)
                
                Text("R\(getRoundNumber())")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            // Runden-Info
            VStack(alignment: .leading, spacing: 6) {
                Text(round.name)
                    .font(.title3)
                    .bold()
                    .foregroundStyle(.primary)
                
                HStack(spacing: 12) {
                    // Status
                    HStack(spacing: 4) {
                        Image(systemName: statusIcon)
                            .font(.caption)
                            .foregroundStyle(statusColor)
                        Text(statusText)
                            .font(.subheadline)
                            .foregroundStyle(statusColor)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.15))
                    .clipShape(Capsule())
                    
                    // Punkte
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                        Text("\(round.maxPoints) Pkt")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
                Image(systemName: "pencil.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            .buttonStyle(.plain)
            .help("Runde bearbeiten")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            statusColor.opacity(0.4),
                            statusColor.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
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





