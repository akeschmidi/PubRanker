//
//  TeamSetupWizard.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct TeamSetupWizard: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var numberOfTeams: Int = 4
    @State private var teamNames: [String] = []
    @FocusState private var focusedField: Int?
    
    let presetCounts = [4, 6, 8, 10]
    
    let randomTeamNames = [
        "Die Überflieger",
        "Quiz-Meister",
        "Schlauberger",
        "Denkfabrik",
        "Brain Squad",
        "Wissens-Wölfe",
        "Quiz-Kings",
        "Einstein's Erben",
        "Trivia Titans",
        "Rätsel-Ritter"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green, Color.green.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .green.opacity(0.3), radius: 10)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Teams erstellen")
                        .font(.title)
                        .bold()
                    
                    Text("Erstellen Sie mehrere Teams auf einmal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Number of Teams
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Anzahl der Teams")
                                .font(.headline)
                        }
                        
                        HStack {
                            Button {
                                if numberOfTeams > 2 {
                                    numberOfTeams -= 1
                                    updateTeamNames()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(numberOfTeams)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)
                            
                            Button {
                                if numberOfTeams < 20 {
                                    numberOfTeams += 1
                                    updateTeamNames()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Quick buttons
                        HStack(spacing: 8) {
                            ForEach(presetCounts, id: \.self) { count in
                                Button("\(count)") {
                                    numberOfTeams = count
                                    updateTeamNames()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    // Team Names
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.purple)
                            Text("Team-Namen")
                                .font(.headline)
                            
                            Spacer()
                            
                            Button {
                                generateRandomNames()
                            } label: {
                                Label("Zufällige Namen", systemImage: "shuffle")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                            .controlSize(.small)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(0..<numberOfTeams, id: \.self) { index in
                                HStack(spacing: 12) {
                                    // Color Circle
                                    Circle()
                                        .fill(getTeamColor(for: index))
                                        .frame(width: 24, height: 24)
                                        .shadow(color: getTeamColor(for: index).opacity(0.3), radius: 3)
                                    
                                    // Team Number
                                    Text("T\(index + 1)")
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(.secondary)
                                        .frame(width: 30)
                                    
                                    // Text Field
                                    TextField("Team \(index + 1)", text: Binding(
                                        get: { teamNames.indices.contains(index) ? teamNames[index] : "" },
                                        set: { newValue in
                                            while teamNames.count <= index {
                                                teamNames.append("")
                                            }
                                            teamNames[index] = newValue
                                        }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: index)
                                    .onSubmit {
                                        if index < numberOfTeams - 1 {
                                            focusedField = index + 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vorschau")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<min(numberOfTeams, 3), id: \.self) { index in
                                HStack {
                                    Circle()
                                        .fill(getTeamColor(for: index))
                                        .frame(width: 16, height: 16)
                                    
                                    Text(getTeamName(for: index))
                                        .font(.subheadline)
                                        .bold()
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            if numberOfTeams > 3 {
                                Text("... und \(numberOfTeams - 3) weitere Teams")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button {
                    createTeams()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("\(numberOfTeams) Teams erstellen")
                    }
                    .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .frame(width: 650, height: 750)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            updateTeamNames()
            focusedField = 0
        }
    }
    
    private func updateTeamNames() {
        while teamNames.count < numberOfTeams {
            teamNames.append("")
        }
    }
    
    private func getTeamName(for index: Int) -> String {
        if teamNames.indices.contains(index) && !teamNames[index].isEmpty {
            return teamNames[index]
        }
        return "Team \(index + 1)"
    }
    
    private func getTeamColor(for index: Int) -> Color {
        let colors: [Color] = [
            .blue, .red, .green, .orange, .purple, .pink,
            .cyan, .yellow, .mint, .indigo, .brown, .teal
        ]
        return colors[index % colors.count]
    }
    
    private func getTeamColorHex(for index: Int) -> String {
        let colors = [
            "#007AFF", "#FF3B30", "#34C759", "#FF9500", "#AF52DE", "#FF2D55",
            "#32ADE6", "#FFCC00", "#00C7BE", "#5856D6", "#A2845E", "#30B0C7"
        ]
        return colors[index % colors.count]
    }
    
    private func generateRandomNames() {
        var availableNames = randomTeamNames.shuffled()
        for index in 0..<numberOfTeams {
            if index < availableNames.count {
                while teamNames.count <= index {
                    teamNames.append("")
                }
                teamNames[index] = availableNames[index]
            }
        }
    }
    
    private func createTeams() {
        for index in 0..<numberOfTeams {
            let name = getTeamName(for: index)
            let color = getTeamColorHex(for: index)
            viewModel.addTeam(to: quiz, name: name, color: color)
        }
    }
}
