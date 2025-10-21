//
//  ScoreEntryView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct ScoreEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var teamScores: [UUID: Int] = [:]
    @State private var currentTeamIndex = 0
    
    var sortedTeams: [Team] {
        quiz.safeTeams.sorted { $0.name < $1.name }
    }
    
    var currentTeam: Team? {
        guard currentTeamIndex < sortedTeams.count else { return nil }
        return sortedTeams[currentTeamIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if quiz.safeTeams.isEmpty {
                ContentUnavailableView(
                    "Keine Teams",
                    systemImage: "person.3.slash",
                    description: Text("Fügen Sie Teams hinzu, um Punkte zu vergeben.")
                )
            } else if let team = currentTeam {
                // Header
                VStack(spacing: 12) {
                    Text(round.name)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    
                    Text("Team \(currentTeamIndex + 1) von \(sortedTeams.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    ProgressView(value: Double(currentTeamIndex), total: Double(sortedTeams.count))
                        .frame(width: 200)
                }
                .padding(.top, 30)
                
                Spacer()
                
                // Team Display
                VStack(spacing: 20) {
                    HStack {
                        Circle()
                            .fill(Color(hex: team.color) ?? .blue)
                            .frame(width: 20, height: 20)
                        
                        Text(team.name)
                            .font(.system(size: 36, weight: .bold))
                    }
                    
                    // Score Display
                    VStack(spacing: 8) {
                        Text("\(teamScores[team.id] ?? team.getScore(for: round))")
                            .font(.system(size: 120, weight: .bold))
                            .monospacedDigit()
                            .foregroundStyle(.blue)
                        
                        Text("von \(round.maxPoints) Punkten")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 20)
                    
                    // Number Pad
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                        ForEach(0...round.maxPoints, id: \.self) { points in
                            Button {
                                teamScores[team.id] = points
                            } label: {
                                Text("\(points)")
                                    .font(.system(size: 24, weight: .semibold))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 60)
                                    .background(
                                        (teamScores[team.id] ?? team.getScore(for: round)) == points
                                            ? Color.accentColor
                                            : Color(nsColor: .controlBackgroundColor)
                                    )
                                    .foregroundStyle(
                                        (teamScores[team.id] ?? team.getScore(for: round)) == points
                                            ? .white
                                            : .primary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                (teamScores[team.id] ?? team.getScore(for: round)) == points
                                                    ? Color.accentColor
                                                    : Color.secondary.opacity(0.2),
                                                lineWidth: 2
                                            )
                                    }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 40)
                }
                
                Spacer()
                
                // Navigation Buttons
                HStack(spacing: 20) {
                    Button {
                        if currentTeamIndex > 0 {
                            currentTeamIndex -= 1
                        }
                    } label: {
                        Label("Zurück", systemImage: "chevron.left")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(currentTeamIndex == 0)
                    
                    if currentTeamIndex < sortedTeams.count - 1 {
                        Button {
                            currentTeamIndex += 1
                        } label: {
                            Label("Nächstes Team", systemImage: "chevron.right")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.return)
                    } else {
                        Button {
                            saveScores()
                            dismiss()
                        } label: {
                            Label("Fertig", systemImage: "checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.return)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
        }
        .frame(width: 700, height: 650)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
        }
        .onAppear {
            // Initialize scores with current values
            for team in quiz.safeTeams {
                teamScores[team.id] = team.getScore(for: round)
            }
        }
    }
    
    private func saveScores() {
        for team in quiz.safeTeams {
            if let score = teamScores[team.id] {
                viewModel.updateScore(for: team, in: round, points: score)
            }
        }
    }
}

