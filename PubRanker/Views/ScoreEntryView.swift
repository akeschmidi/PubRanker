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
                    
                    Text("Punkte eingeben (max. \(round.maxPoints) pro Team)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 20)
                
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams vorhanden",
                        systemImage: "person.3.slash",
                        description: Text("Füge Teams hinzu, um Punkte zu vergeben")
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
                    HStack(spacing: 16) {
                        Button {
                            clearAllScores()
                        } label: {
                            Label("Zurücksetzen", systemImage: "arrow.counterclockwise")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        
                        Button {
                            saveAllScores()
                        } label: {
                            Label("Speichern", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .keyboardShortcut(.return, modifiers: .command)
                    }
                    .padding(.horizontal)
                    
                    // Next Round Button
                    if let nextRound = getNextRound() {
                        Button {
                            saveAllScores()
                            viewModel.completeRound(round)
                        } label: {
                            VStack(spacing: 8) {
                                HStack {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Weiter zur nächsten Runde")
                                        .font(.headline)
                                }
                                Text("→ \(nextRound.name)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.large)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    } else if !round.isCompleted {
                        Button {
                            saveAllScores()
                            viewModel.completeRound(round)
                        } label: {
                            HStack {
                                Image(systemName: "flag.checkered")
                                Text("Runde abschließen")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                        .controlSize(.large)
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    
                    if round.isCompleted {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Diese Runde ist abgeschlossen")
                                .font(.subheadline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .alert("Punkte gespeichert! ✅", isPresented: $showSuccessMessage) {
            Button("OK") {}
        } message: {
            Text("Die Punkte für \(savedRoundName) wurden erfolgreich gespeichert.")
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
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .disabled(getScoreValue(for: team) <= 0)
                
                // Text Field
                TextField("0", text: Binding(
                    get: { teamScores[team.id] ?? "0" },
                    set: { newValue in
                        // Only allow numbers
                        let filtered = newValue.filter { $0.isNumber }
                        if let value = Int(filtered), value <= round.maxPoints {
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
                        .foregroundStyle(.green)
                }
                .buttonStyle(.plain)
                .disabled(getScoreValue(for: team) >= round.maxPoints)
                
                Text("/ \(round.maxPoints)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func getScoreValue(for team: Team) -> Int {
        Int(teamScores[team.id] ?? "0") ?? 0
    }
    
    private func incrementScore(for team: Team) {
        let current = getScoreValue(for: team)
        if current < round.maxPoints {
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

