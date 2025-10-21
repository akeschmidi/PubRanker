//
//  RoundManagementView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct RoundManagementView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingAddRoundSheet = false
    @State private var showingRoundWizard = false
    @State private var selectedRound: Round?
    @State private var editingCell: String?
    
    var body: some View {
        mainContent
            .toolbar {
                toolbarContent
            }
            .sheet(isPresented: $showingAddRoundSheet) {
                QuickRoundSheet(quiz: quiz, viewModel: viewModel)
            }
            .sheet(isPresented: $showingRoundWizard) {
                RoundWizardSheet(quiz: quiz, viewModel: viewModel)
            }
    }
    
    // MARK: - Computed Properties
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Active Round Status Banner
            if quiz.isActive, let currentRound = quiz.currentRound {
                CurrentRoundBanner(quiz: quiz, currentRound: currentRound, viewModel: viewModel)
            }
            
            contentArea
        }
    }
    
    private var contentArea: some View {
        Group {
            if quiz.safeRounds.isEmpty || quiz.safeTeams.isEmpty {
                    VStack(spacing: 20) {
                        if quiz.safeTeams.isEmpty {
                            emptyTeamsView
                        } else {
                            emptyRoundsView
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView([.horizontal, .vertical]) {
                        VStack(alignment: .leading, spacing: 0) {
                            // Header Row
                            HStack(spacing: 0) {
                            // Team Column Header
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Team")
                                    .font(.title3)
                                    .bold()
                                Text("\(quiz.safeTeams.count) Teams")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .frame(width: 220, alignment: .leading)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .controlBackgroundColor).opacity(0.8)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Round Column Headers
                            ForEach(Array(quiz.sortedRounds.enumerated()), id: \.element.id) { index, round in
                                VStack(spacing: 6) {
                                    HStack(spacing: 6) {
                                        Text("R\(index + 1)")
                                            .font(.caption)
                                            .bold()
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(getRoundStatusColor(for: round))
                                            .clipShape(Capsule())
                                        
                                        if round.isCompleted {
                                            Image(systemName: "checkmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.green)
                                        } else if quiz.currentRound?.id == round.id {
                                            Image(systemName: "circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.orange)
                                        }
                                    }
                                    
                                    // Score completion indicator
                                    RoundCompletionIndicator(quiz: quiz, round: round)
                                    
                                    Text(round.name)
                                        .font(.system(size: 16, weight: .bold))
                                        .lineLimit(2)
                                        .multilineTextAlignment(.center)
                                    
                                    Text(String(format: NSLocalizedString("common.points.max", comment: "Max points"), round.maxPoints))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color.secondary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .frame(width: 140)
                                .padding(.vertical, 12)
                                .background(
                                    LinearGradient(
                                        colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .controlBackgroundColor).opacity(0.8)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .overlay {
                                    Rectangle()
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                }
                            }
                            
                            // Total Column Header
                            VStack(spacing: 4) {
                                Image(systemName: "trophy.fill")
                                    .font(.title3)
                                    .foregroundStyle(.yellow)
                                Text("Gesamt")
                                    .font(.title3)
                                    .bold()
                            }
                            .frame(width: 120)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: [Color.yellow.opacity(0.15), Color.orange.opacity(0.1)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                        }
                        
                        Divider()
                        
                        // Team Rows
                        ForEach(Array(quiz.safeTeams.enumerated()), id: \.element.id) { index, team in
                            HStack(spacing: 0) {
                                // Team Name
                                HStack(spacing: 12) {
                                    Circle()
                                        .fill(Color(hex: team.color) ?? .blue)
                                        .frame(width: 16, height: 16)
                                        .shadow(color: Color(hex: team.color)?.opacity(0.3) ?? .clear, radius: 3)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(team.name)
                                            .font(.system(size: 17, weight: .semibold))
                                        Text("Rang: \(viewModel.getTeamRank(for: team, in: quiz))")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .frame(width: 220, alignment: .leading)
                                .padding(.vertical, 16)
                                .padding(.horizontal, 12)
                                .background(
                                    index % 2 == 0
                                        ? Color(nsColor: .controlBackgroundColor).opacity(0.3)
                                        : Color.clear
                                )
                                
                                // Score Cells
                                ForEach(quiz.sortedRounds) { round in
                                    ScoreCell(
                                        team: team,
                                        round: round,
                                        viewModel: viewModel,
                                        isEditing: editingCell == "\(team.id)-\(round.id)",
                                        onTap: {
                                            editingCell = "\(team.id)-\(round.id)"
                                        },
                                        onDismiss: {
                                            editingCell = nil
                                        }
                                    )
                                    .frame(width: 140)
                                    .background(
                                        index % 2 == 0
                                            ? Color(nsColor: .controlBackgroundColor).opacity(0.3)
                                            : Color.clear
                                    )
                                }
                                
                                // Total Score
                                VStack(spacing: 4) {
                                    Text("\(team.totalScore)")
                                        .font(.system(size: 32, weight: .bold))
                                        .monospacedDigit()
                                        .foregroundStyle(.primary)
                                    
                                    Text(NSLocalizedString("common.points", comment: "Points"))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .textCase(.uppercase)
                                }
                                .frame(width: 120)
                                .padding(.vertical, 12)
                                .background(
                                    index % 2 == 0
                                        ? Color.yellow.opacity(0.08)
                                        : Color.yellow.opacity(0.05)
                                )
                            }
                            .overlay {
                                Rectangle()
                                    .stroke(Color.secondary.opacity(0.15), lineWidth: 1)
                            }
                        }
                    }
                    .padding()
                }
            }
        } // schließt Group
    } // schließt contentArea
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .automatic) {
            Menu {
                Button {
                    showingRoundWizard = true
                } label: {
                    Label(NSLocalizedString("round.new.multiple.create", comment: "Create multiple rounds"), systemImage: "rectangle.stack.fill")
                }
                
                Button {
                    showingAddRoundSheet = true
                } label: {
                    Label(NSLocalizedString("round.new.single.add", comment: "Add single round"), systemImage: "plus.circle")
                }
            } label: {
                Label(NSLocalizedString("round.add", comment: "Add round"), systemImage: "plus.circle.fill")
            }
            .help(NSLocalizedString("round.add.multiple", comment: "Add rounds"))
        }
        
        if let currentRound = quiz.currentRound {
            ToolbarItem(placement: .automatic) {
                Button {
                    viewModel.completeRound(currentRound)
                } label: {
                    Label(NSLocalizedString("round.complete", comment: "Complete round"), systemImage: "checkmark.circle")
                }
                .keyboardShortcut("k", modifiers: .command)
                .help(NSLocalizedString("round.complete.help", comment: "Complete current round"))
            }
        }
    }
    
    // Helper to get round status color
    private func getRoundStatusColor(for round: Round) -> Color {
        if round.isCompleted {
            return .green
        } else if quiz.currentRound?.id == round.id {
            return .orange
        } else {
            return .gray
        }
    }
    
    private var emptyTeamsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("empty.noTeams", comment: "No teams"))
                    .font(.title2)
                    .bold()
                
                Text(NSLocalizedString("empty.noTeams.beforeRounds", comment: "Add teams before rounds"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
    
    private var emptyRoundsView: some View {
        VStack(spacing: 24) {
            Image(systemName: "list.number.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            VStack(spacing: 8) {
                Text(NSLocalizedString("empty.noRounds", comment: "No rounds"))
                    .font(.title2)
                    .bold()
                
                Text(NSLocalizedString("empty.noRounds.management", comment: "Add rounds to assign points"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                Button {
                    showingRoundWizard = true
                } label: {
                    Label(NSLocalizedString("round.new.multiple", comment: "Multiple rounds"), systemImage: "rectangle.stack.fill")
                        .font(.headline)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button {
                    showingAddRoundSheet = true
                } label: {
                    Label(NSLocalizedString("round.new.single", comment: "Single round"), systemImage: "plus.circle")
                        .font(.headline)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding()
    }
} // schließt RoundManagementView

// MARK: - Current Round Banner
struct CurrentRoundBanner: View {
    let quiz: Quiz
    let currentRound: Round
    @Bindable var viewModel: QuizViewModel
    
    var completedTeamsCount: Int {
        quiz.safeTeams.filter { $0.hasScore(for: currentRound) }.count
    }
    
    var totalTeams: Int {
        quiz.safeTeams.count
    }
    
    var progress: Double {
        guard totalTeams > 0 else { return 0 }
        return Double(completedTeamsCount) / Double(totalTeams)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Left side - Current Round Info
                HStack(spacing: 12) {
                    Image(systemName: "circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .symbolEffect(.pulse)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AKTUELLE RUNDE")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .bold()
                        
                        Text(currentRound.name)
                            .font(.title2)
                            .bold()
                    }
                }
                
                Spacer()
                
                // Center - Progress
                VStack(spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(.secondary)
                        Text("\(completedTeamsCount) von \(totalTeams) Teams")
                            .font(.subheadline)
                            .bold()
                    }
                    
                    ProgressView(value: progress)
                        .frame(width: 200)
                        .tint(progress == 1.0 ? .green : .orange)
                }
                
                Spacer()
                
                // Right side - Actions
                HStack(spacing: 12) {
                    if progress == 1.0 {
                        Button {
                            viewModel.completeRound(currentRound)
                        } label: {
                            Label(NSLocalizedString("round.complete", comment: "Complete round"), systemImage: "checkmark.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .controlSize(.large)
                    } else {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(String(format: NSLocalizedString("common.missing", comment: "Missing count"), totalTeams - completedTeamsCount))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(String(format: NSLocalizedString("common.points.maxLabel", comment: "Max points label"), currentRound.maxPoints))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.15), Color.orange.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.orange)
                .frame(height: 3)
        }
    }
}

// MARK: - Round Completion Indicator
struct RoundCompletionIndicator: View {
    let quiz: Quiz
    let round: Round
    
    var teamsWithScores: Int {
        quiz.safeTeams.filter { $0.hasScore(for: round) }.count
    }
    
    var totalTeams: Int {
        quiz.safeTeams.count
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<min(totalTeams, 5), id: \.self) { index in
                Circle()
                    .fill(index < teamsWithScores ? Color.green : Color.secondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
            
            if totalTeams > 5 {
                Text("+\(totalTeams - 5)")
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.secondary.opacity(0.05))
        .clipShape(Capsule())
    }
}

// MARK: - Score Cell Component
struct ScoreCell: View {
    let team: Team
    let round: Round
    @Bindable var viewModel: QuizViewModel
    let isEditing: Bool
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    @State private var saveTimer: Timer?
    
    var currentScore: Int? {
        team.getScore(for: round)
    }
    
    var hasScore: Bool {
        team.hasScore(for: round)
    }
    
    var body: some View {
        ZStack {
            if isEditing {
                VStack(spacing: 8) {
                    // TextField für direkte Eingabe
                    TextField("", text: $inputText)
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 32, weight: .bold))
                        .focused($isFocused)
                        .onSubmit {
                            saveScore()
                        }
                        .onChange(of: inputText) { oldValue, newValue in
                            scheduleAutoSave()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.accentColor.opacity(0.15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor, lineWidth: 3)
                        }
                    
                    // Schnell-Buttons für häufige Werte
                    HStack(spacing: 6) {
                        ForEach([0, round.maxPoints / 2, round.maxPoints], id: \.self) { points in
                            Button {
                                inputText = "\(points)"
                                saveScore()
                            } label: {
                                Text("\(points)")
                                    .font(.caption)
                                    .bold()
                                    .foregroundStyle(.white)
                                    .frame(minWidth: 30)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color.accentColor)
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8)
            } else {
                // Display Mode
                Button(action: onTap) {
                    VStack(spacing: 6) {
                        // Score Display
                        if let score = currentScore {
                            Text("\(score)")
                                .font(.system(size: 36, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(score == 0 ? .secondary : .primary)
                        } else {
                            Text("–")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                        
                        // Info Label
                        HStack(spacing: 2) {
                            if let score = currentScore, score > 0 {
                                Text("\(score)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("/")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            Text(String(format: NSLocalizedString("score.points", comment: "Points"), round.maxPoints))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if let score = currentScore {
                                if score == round.maxPoints {
                                    Color.green.opacity(0.15)
                                } else if score > 0 {
                                    Color.accentColor.opacity(0.08)
                                } else {
                                    Color.clear
                                }
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                (currentScore ?? 0) > 0
                                    ? Color.accentColor.opacity(0.4)
                                    : Color.secondary.opacity(0.2),
                                lineWidth: (currentScore ?? 0) > 0 ? 2 : 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .help(currentScore != nil ? String(format: NSLocalizedString("score.clickToEdit", comment: "Click to edit"), currentScore!) : NSLocalizedString("score.clickToAdd", comment: "Click to add"))
            }
        }
        .onChange(of: isEditing) { oldValue, newValue in
            if newValue {
                // Initialisiere Feld: wenn Score vorhanden zeige ihn, sonst leer
                if let score = currentScore {
                    inputText = "\(score)"
                } else {
                    inputText = ""
                }
                isFocused = true
            } else {
                // Auto-save beim Verlassen
                saveTimer?.invalidate()
                saveScore()
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if !newValue && isEditing {
                // Fokus verloren - speichern und schließen
                saveScore()
            }
        }
    }
    
    private func scheduleAutoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            // Auto-Save bei jeder Änderung (leer = Score entfernen, "0" = 0 Punkte)
            saveScore()
        }
    }
    
    private func saveScore() {
        saveTimer?.invalidate()
        
        // Leeres Feld = Score entfernen (nicht bewertet)
        if inputText.isEmpty {
            viewModel.clearScore(for: team, in: round)
            onDismiss()
            return
        }
        
        // Validiere eingegebene Zahl (inkl. 0)
        if let score = Int(inputText), score >= 0, score <= round.maxPoints {
            viewModel.updateScore(for: team, in: round, points: score)
            onDismiss()
        }
        // Ungültige Eingabe = ignorieren und Dialog offen lassen
    }
}

// MARK: - Quick Round Sheet
struct QuickRoundSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var roundName = ""
    @State private var maxPoints = 10
    @FocusState private var focusedField: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "list.number.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("Neue Runde erstellen")
                    .font(.title2)
                    .bold()
                
                Text("Runde \(quiz.safeRounds.count + 1)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 20)
            
            // Form
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("round.name", comment: "Round name"))
                        .font(.headline)
                    
                    TextField(NSLocalizedString("round.name.placeholder", comment: "Round name placeholder"), text: $roundName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .focused($focusedField)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("round.maxPoints.label", comment: "Maximum points"))
                        .font(.headline)
                    
                    HStack {
                        Button {
                            if maxPoints > 1 {
                                maxPoints -= 1
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.title)
                        }
                        .buttonStyle(.plain)
                        
                        Text("\(maxPoints)")
                            .font(.system(size: 48, weight: .bold))
                            .monospacedDigit()
                            .frame(minWidth: 100)
                        
                        Button {
                            if maxPoints < 100 {
                                maxPoints += 1
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Quick Presets
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("common.quickSelect", comment: "Quick select"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach([5, 10, 15, 20], id: \.self) { points in
                            Button(String(format: NSLocalizedString("common.points.count", comment: "Points count"), points)) {
                                maxPoints = points
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 12) {
                Button("Abbrechen") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button("Runde erstellen") {
                    viewModel.addRound(to: quiz, name: roundName, maxPoints: maxPoints)
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(roundName.isEmpty)
            }
            .padding(.bottom, 20)
        }
        .frame(width: 500, height: 550)
        .onAppear {
            focusedField = true
        }
    }
}

// MARK: - Round Wizard Sheet
struct RoundWizardSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var numberOfRounds: Int = 6
    @State private var maxPointsPerRound: Int = 10
    @State private var useCustomNames: Bool = false
    @State private var useCustomPoints: Bool = false
    @State private var roundNames: [String] = []
    @State private var roundPoints: [Int] = []
    
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
                        Text(NSLocalizedString("common.quickSelect", comment: "Quick select"))
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
                                        Text(String(format: NSLocalizedString("round.count.label", comment: "Rounds count"), preset.1))
                                            .font(.caption)
                                        Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), preset.2))
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
                                    updateRoundPoints()
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
                                    updateRoundPoints()
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
                            ForEach([4, 5, 6, 8, 10], id: \.self) { count in
                                Button("\(count)") {
                                    numberOfRounds = count
                                    updateRoundNames()
                                    updateRoundPoints()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Max Points (nur wenn nicht individuell)
                    if !useCustomPoints {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .foregroundStyle(.yellow)
                                Text(NSLocalizedString("common.points.perRound", comment: "Max points per round"))
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
                                
                                TextField("", value: $maxPointsPerRound, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .multilineTextAlignment(.center)
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
                    }
                    
                    Divider()
                    
                    // Custom Points Toggle
                    Toggle(isOn: $useCustomPoints) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(.yellow)
                            Text(NSLocalizedString("common.points.custom", comment: "Custom points per round"))
                                .font(.headline)
                        }
                    }
                    .onChange(of: useCustomPoints) { oldValue, newValue in
                        if newValue {
                            updateRoundPoints()
                        }
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
                    
                    // Custom Names and/or Points List
                    if useCustomNames || useCustomPoints {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(useCustomNames && useCustomPoints ? NSLocalizedString("round.names.custom", comment: "Round names and points") : useCustomNames ? NSLocalizedString("round.names.only", comment: "Round names only") : NSLocalizedString("common.points.perRound", comment: "Max points"))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            ForEach(0..<numberOfRounds, id: \.self) { index in
                                HStack(spacing: 12) {
                                    Text("R\(index + 1)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 30)
                                    
                                    if useCustomNames {
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
                                    
                                    if useCustomPoints {
                                        HStack {
                                            TextField(NSLocalizedString("common.points", comment: "Points"), value: Binding(
                                                get: { roundPoints.indices.contains(index) ? roundPoints[index] : maxPointsPerRound },
                                                set: { newValue in
                                                    while roundPoints.count <= index {
                                                        roundPoints.append(maxPointsPerRound)
                                                    }
                                                    roundPoints[index] = newValue
                                                }
                                            ), format: .number)
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 80)
                                            .multilineTextAlignment(.trailing)
                                            
                                            Text(NSLocalizedString("score.pointsUnit", comment: "Points unit"))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
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
                            ForEach(0..<min(numberOfRounds, 3), id: \.self) { index in
                                HStack {
                                    Text("Runde \(index + 1):")
                                        .font(.subheadline)
                                    Text(getRoundName(for: index))
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), getRoundPoints(for: index)))
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
            updateRoundPoints()
        }
    }
    
    private func updateRoundNames() {
        if useCustomNames {
            while roundNames.count < numberOfRounds {
                roundNames.append("Runde \(roundNames.count + 1)")
            }
        }
    }
    
    private func updateRoundPoints() {
        if useCustomPoints {
            while roundPoints.count < numberOfRounds {
                roundPoints.append(maxPointsPerRound)
            }
        }
    }
    
    private func getRoundName(for index: Int) -> String {
        if useCustomNames && roundNames.indices.contains(index) && !roundNames[index].isEmpty {
            return roundNames[index]
        }
        return "Runde \(index + 1)"
    }
    
    private func getRoundPoints(for index: Int) -> Int {
        if useCustomPoints && roundPoints.indices.contains(index) {
            return roundPoints[index]
        }
        return maxPointsPerRound
    }
    
    private func createRounds() {
        for index in 0..<numberOfRounds {
            let name = getRoundName(for: index)
            let points = getRoundPoints(for: index)
            viewModel.addRound(to: quiz, name: name, maxPoints: points)
        }
    }
}
