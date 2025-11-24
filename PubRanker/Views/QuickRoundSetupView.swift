//
//  QuickRoundSetupView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct QuickRoundSetupView: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var numberOfRounds: Int = 6
    @State private var maxPointsPerRound: Int = 10
    @State private var useCustomNames: Bool = false
    @State private var roundNames: [String] = []
    
    let presetFormats = [
        ("Klassisch", 6, 10),
        ("Kurz", 4, 10),
        ("Lang", 8, 10),
        ("Schnell", 5, 5)
    ]
    
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.orange, Color.orange.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .orange.opacity(0.3), radius: 10)
                    
                    Image(systemName: "list.number")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Runden-Setup")
                        .font(.title)
                        .bold()
                    
                    Text("Erstellen Sie mehrere Runden auf einmal")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Preset Formats
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Schnellauswahl")
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(presetFormats, id: \.0) { preset in
                                Button {
                                    numberOfRounds = preset.1
                                    maxPointsPerRound = preset.2
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(preset.0)
                                            .font(.headline)
                                        Text("\(preset.1) Runden")
                                            .font(.caption)
                                        Text("\(preset.2) Punkte")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        numberOfRounds == preset.1 && maxPointsPerRound == preset.2
                                            ? Color.accentColor.opacity(0.2)
                                            : Color(nsColor: .controlBackgroundColor)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                numberOfRounds == preset.1 && maxPointsPerRound == preset.2
                                                    ? Color.accentColor
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Number of Rounds
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .foregroundStyle(.blue)
                            Text("Anzahl der Runden")
                                .font(.headline)
                        }
                        
                        HStack {
                            Button {
                                if numberOfRounds > 1 {
                                    numberOfRounds -= 1
                                    updateRoundNames()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(numberOfRounds)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)
                            
                            Button {
                                if numberOfRounds < 20 {
                                    numberOfRounds += 1
                                    updateRoundNames()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Max Points
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(.yellow)
                            Text("Max. Punkte pro Runde")
                                .font(.headline)
                        }
                        
                        HStack {
                            Button {
                                if maxPointsPerRound > 1 {
                                    maxPointsPerRound -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(maxPointsPerRound)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)
                            
                            Button {
                                if maxPointsPerRound < 100 {
                                    maxPointsPerRound += 1
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
                            ForEach([5, 10, 15, 20], id: \.self) { points in
                                Button("\(points)") {
                                    maxPointsPerRound = points
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    // Custom Names Toggle
                    Toggle(isOn: $useCustomNames) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.purple)
                            Text("Benutzerdefinierte Namen")
                                .font(.headline)
                        }
                    }
                    .onChange(of: useCustomNames) { oldValue, newValue in
                        if newValue {
                            updateRoundNames()
                        }
                    }
                    
                    // Custom Names List
                    if useCustomNames {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Runden-Namen")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(0..<numberOfRounds, id: \.self) { index in
                                HStack {
                                    Text("R\(index + 1)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 30)
                                    
                                    TextField("Runde \(index + 1)", text: Binding(
                                        get: { roundNames.indices.contains(index) ? roundNames[index] : "" },
                                        set: { newValue in
                                            while roundNames.count <= index {
                                                roundNames.append("")
                                            }
                                            roundNames[index] = newValue
                                        }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                }
                            }
                        }
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vorschau")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<min(numberOfRounds, 3), id: \.self) { index in
                                HStack {
                                    Text("Runde \(index + 1):")
                                        .font(.subheadline)
                                    Text(getRoundName(for: index))
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text("\(maxPointsPerRound) Punkte")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            if numberOfRounds > 3 {
                                Text("... und \(numberOfRounds - 3) weitere")
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
                    createRounds()
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("\(numberOfRounds) Runden erstellen")
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
        .frame(width: 650, height: 800)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            updateRoundNames()
        }
    }
    
    private func updateRoundNames() {
        if useCustomNames {
            while roundNames.count < numberOfRounds {
                roundNames.append("Runde \(roundNames.count + 1)")
            }
        }
    }
    
    private func getRoundName(for index: Int) -> String {
        if useCustomNames && roundNames.indices.contains(index) && !roundNames[index].isEmpty {
            return roundNames[index]
        }
        return "Runde \(index + 1)"
    }
    
    private func createRounds() {
        for index in 0..<numberOfRounds {
            let name = getRoundName(for: index)
            viewModel.addRound(to: quiz, name: name, maxPoints: maxPointsPerRound)
        }
    }
}
