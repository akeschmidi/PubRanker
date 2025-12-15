//
//  ScoreEntryView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct ScoreEntryView: View {
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var teamScores: [UUID: String] = [:]
    @State private var showSuccessMessage = false
    @State private var savedRoundName = ""
    
    var sortedTeams: [Team] {
        quiz.safeTeams.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text(round.name)
                        .font(.title)
                        .bold()

                    if let maxPoints = round.maxPoints {
                        Text(String(format: NSLocalizedString("score.enter.max", comment: "Enter points max"), maxPoints))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(L10n.Round.noMaxPointsSet)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 20)
                
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        NSLocalizedString("execution.noTeams", comment: "No teams"),
                        systemImage: "person.3.slash",
                        description: Text(NSLocalizedString("execution.noTeams.description", comment: "No teams description"))
                    )
                } else {
                    // Teams Liste
                    VStack(spacing: 16) {
                        ForEach(sortedTeams) { team in
                            teamScoreRow(for: team)
                        }
                    }
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical)
                    
                    // Action Buttons
                    HStack(spacing: AppSpacing.sm) {
                        Button {
                            clearAllScores()
                        } label: {
                            Label(L10n.Execution.reset, systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .secondaryGradientButton(size: .large)
                        
                        Button {
                            saveAllScores()
                        } label: {
                            Label(L10n.Navigation.save, systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryGradientButton(size: .large)
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)
                    
                    // Next Round Button
                    if let nextRound = getNextRound() {
                        Button {
                            saveAllScores()
                            viewModel.completeRound(round)
                        } label: {
                            VStack(spacing: AppSpacing.xxs) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text(NSLocalizedString("score.nextRound", comment: "Continue to next round"))
                                        .font(.headline)
                                }
                                Text(String(format: NSLocalizedString("score.nextRound.name", comment: "Next round name"), nextRound.name))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.md)
                        }
                        .primaryGradientButton(size: .large)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.top, AppSpacing.xxs)
                    } else if !round.isCompleted {
                        Button {
                            saveAllScores()
                            viewModel.completeRound(round)
                        } label: {
                            HStack {
                                Image(systemName: "flag.checkered")
                                Text(NSLocalizedString("score.completeRound", comment: "Complete round"))
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(AppSpacing.md)
                        }
                        .accentGradientButton(size: .large)
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.top, AppSpacing.xxs)
                    }
                    
                    if round.isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.appSuccess)
                            Text(NSLocalizedString("score.roundCompleted", comment: "Round completed"))
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(Color.appSuccess.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                        .padding(.horizontal, AppSpacing.screenPadding)
                        .padding(.top, AppSpacing.xxs)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .alert(NSLocalizedString("score.saved.title", comment: "Points saved"), isPresented: $showSuccessMessage) {
            Button(L10n.Alert.ok) {}
        } message: {
            Text(String(format: NSLocalizedString("score.saved.message", comment: "Points saved message"), savedRoundName))
        }
        .onAppear {
            loadCurrentScores()
        }
        .onChange(of: round.id) { _, _ in
            // Reset und lade Scores neu wenn Runde wechselt
            loadCurrentScores()
        }
    }
    
    private func teamScoreRow(for team: Team) -> some View {
        HStack(spacing: 16) {
            // Team Info
            HStack(spacing: 12) {
                TeamIconView(team: team, size: 16)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.headline)
                    
                    if let currentScore = team.getScore(for: round) {
                        Text("Aktuell: \(currentScore) Punkte")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Score Input
            HStack(spacing: 8) {
                // Minus Button
                Button {
                    decrementScore(for: team)
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appAccent)
                }
                .buttonStyle(.plain)
                .disabled(getScoreValue(for: team) <= 0)
                
                // Text Field
                TextField("0", text: Binding(
                    get: { teamScores[team.id] ?? "0" },
                    set: { newValue in
                        // Only allow numbers
                        let filtered = newValue.filter { $0.isNumber }
                        if let value = Int(filtered) {
                            // Check maxPoints only if set
                            if let maxPts = round.maxPoints, value > maxPts {
                                return
                            }
                            teamScores[team.id] = filtered
                        } else if filtered.isEmpty {
                            teamScores[team.id] = "0"
                        }
                    }
                ))
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .multilineTextAlignment(.center)
                .font(.title3.bold())

                // Plus Button
                Button {
                    incrementScore(for: team)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appSuccess)
                }
                .buttonStyle(.plain)
                .disabled({
                    if let maxPts = round.maxPoints {
                        return getScoreValue(for: team) >= maxPts
                    } else {
                        return false
                    }
                }())

                if let maxPts = round.maxPoints {
                    Text("/ \(maxPts)")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                } else {
                    Text(L10n.Round.unlimited)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
    }
    
    private func getScoreValue(for team: Team) -> Int {
        Int(teamScores[team.id] ?? "0") ?? 0
    }
    
    private func incrementScore(for team: Team) {
        let current = getScoreValue(for: team)
        if let maxPts = round.maxPoints {
            if current < maxPts {
                teamScores[team.id] = "\(current + 1)"
            }
        } else {
            teamScores[team.id] = "\(current + 1)"
        }
    }
    
    private func decrementScore(for team: Team) {
        let current = getScoreValue(for: team)
        if current > 0 {
            teamScores[team.id] = "\(current - 1)"
        }
    }
    
    private func loadCurrentScores() {
        for team in quiz.safeTeams {
            if let score = team.getScore(for: round) {
                teamScores[team.id] = "\(score)"
            } else {
                teamScores[team.id] = "0"
            }
        }
    }
    
    private func clearAllScores() {
        for team in quiz.safeTeams {
            teamScores[team.id] = "0"
        }
    }
    
    private func saveAllScores() {
        // Speichere den Runden-Namen BEVOR die Runde abgeschlossen wird
        savedRoundName = round.name
        
        for team in quiz.safeTeams {
            let score = getScoreValue(for: team)
            viewModel.updateScore(for: team, in: round, points: score)
        }
        showSuccessMessage = true
    }
    
    private func getNextRound() -> Round? {
        let sortedRounds = quiz.sortedRounds
        guard let currentIndex = sortedRounds.firstIndex(where: { $0.id == round.id }) else {
            return nil
        }
        let nextIndex = currentIndex + 1
        return nextIndex < sortedRounds.count ? sortedRounds[nextIndex] : nil
    }
}

