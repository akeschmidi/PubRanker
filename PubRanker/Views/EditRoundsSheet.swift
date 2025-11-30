//
//  EditRoundsSheet.swift
//  PubRanker
//
//  Sheet zum nachträglichen Bearbeiten von Rundenpunkten
//

import SwiftUI

struct EditRoundsSheet: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRound: Round?
    
    var body: some View {
        NavigationSplitView {
            // Sidebar - Runden Liste
            List(selection: $selectedRound) {
                Section("Runden bearbeiten") {
                    ForEach(quiz.sortedRounds) { round in
                        RoundRowView(round: round)
                            .tag(round)
                    }
                }
            }
            .listStyle(.sidebar)
            .navigationTitle("Runden")
        } detail: {
            if let round = selectedRound {
                RoundEditDetailView(round: round, quiz: quiz, viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    "Runde auswählen",
                    systemImage: "list.number",
                    description: Text("Wähle eine Runde aus, um die Punkte zu bearbeiten")
                )
            }
        }
        .navigationTitle("Punkte bearbeiten")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Fertig") {
                    dismiss()
                }
            }
        }
        .onAppear {
            if selectedRound == nil && !quiz.safeRounds.isEmpty {
                selectedRound = quiz.sortedRounds.first
            }
        }
    }
}

struct RoundRowView: View {
    let round: Round
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(round.name)
                    .font(.headline)
                
                Spacer()
                
                if round.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            
            Text("Max. \(round.maxPoints) Punkte")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}

struct RoundEditDetailView: View {
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var teamScores: [UUID: String] = [:]
    @State private var hasChanges = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(round.name)
                            .font(.title2)
                            .bold()
                        
                        Text("Max. \(round.maxPoints) Punkte pro Team")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if round.isCompleted {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Abgeschlossen")
                                .font(.subheadline)
                                .foregroundStyle(.green)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.1))
                        .clipShape(Capsule())
                    }
                }
                
                if hasChanges {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text("Du hast ungespeicherte Änderungen")
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                        Spacer()
                        Button("Speichern") {
                            saveAllScores()
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Teams Grid
            ScrollView {
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams vorhanden",
                        systemImage: "person.3.slash",
                        description: Text("Füge Teams hinzu, um Punkte zu vergeben")
                    )
                    .frame(maxHeight: 400)
                } else {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 16) {
                        ForEach(quiz.safeTeams.sorted(by: { $0.name < $1.name })) { team in
                            TeamEditCard(
                                team: team,
                                round: round,
                                currentScore: Binding(
                                    get: { teamScores[team.id] ?? "0" },
                                    set: { newValue in
                                        teamScores[team.id] = newValue
                                        hasChanges = true
                                    }
                                ),
                                maxPoints: round.maxPoints
                            )
                        }
                    }
                    .padding()
                }
            }
            
            // Action Buttons
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Zurücksetzen") {
                        loadCurrentScores()
                        hasChanges = false
                    }
                    .buttonStyle(.bordered)
                    .disabled(!hasChanges)
                    
                    Button("Alle speichern") {
                        saveAllScores()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!hasChanges)
                }
                
                if !round.isCompleted {
                    Button("Runde als abgeschlossen markieren") {
                        saveAllScores()
                        viewModel.completeRound(round)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                } else {
                    Button("Runde wieder öffnen") {
                        round.isCompleted = false
                        viewModel.saveContext()
                    }
                    .buttonStyle(.bordered)
                    .tint(.orange)
                }
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .onAppear {
            loadCurrentScores()
        }
        .onChange(of: round.id) { _, _ in
            loadCurrentScores()
            hasChanges = false
        }
    }
    
    private func loadCurrentScores() {
        teamScores.removeAll()
        for team in quiz.safeTeams {
            if let score = team.getScore(for: round) {
                teamScores[team.id] = "\(score)"
            } else {
                teamScores[team.id] = "0"
            }
        }
    }
    
    private func saveAllScores() {
        for team in quiz.safeTeams {
            let scoreText = teamScores[team.id] ?? "0"
            let score = Int(scoreText) ?? 0
            viewModel.updateScore(for: team, in: round, points: score)
        }
        hasChanges = false
    }
}

struct TeamEditCard: View {
    let team: Team
    let round: Round
    @Binding var currentScore: String
    let maxPoints: Int
    
    private var teamColor: Color {
        Color(hex: team.color) ?? .blue
    }
    
    private var scoreValue: Int {
        Int(currentScore) ?? 0
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Team Header
            HStack {
                Circle()
                    .fill(teamColor)
                    .frame(width: 12, height: 12)
                
                Text(team.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
            }
            
            // Score Input
            VStack(spacing: 8) {
                HStack(spacing: 12) {
                    // Decrement
                    Button {
                        if scoreValue > 0 {
                            currentScore = "\(scoreValue - 1)"
                        }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(scoreValue > 0 ? .red : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(scoreValue <= 0)
                    
                    // Text Field
                    TextField("0", text: $currentScore)
                        .textFieldStyle(.plain)
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .frame(width: 80)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(nsColor: .controlBackgroundColor))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(teamColor, lineWidth: 2)
                                )
                        )
                        .onChange(of: currentScore) { _, newValue in
                            // Filter nur Zahlen
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                currentScore = filtered
                            }
                            // Begrenze auf maxPoints
                            if let value = Int(filtered), value > maxPoints {
                                currentScore = "\(maxPoints)"
                            }
                        }
                    
                    // Increment
                    Button {
                        if scoreValue < maxPoints {
                            currentScore = "\(scoreValue + 1)"
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(scoreValue < maxPoints ? .green : .gray)
                    }
                    .buttonStyle(.plain)
                    .disabled(scoreValue >= maxPoints)
                }
                
                // Max Points Indicator
                Text("/ \(maxPoints)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .windowBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(teamColor.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    let quiz = Quiz(name: "Test Quiz", venue: "Test Venue")
    let viewModel = QuizViewModel()
    return EditRoundsSheet(quiz: quiz, viewModel: viewModel)
}


