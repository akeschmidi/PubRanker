//
//  TeamSetupWizard.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import SwiftData

struct TeamSetupWizard: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var mode: TeamSetupMode = .createNew
    @State private var numberOfTeams: Int = 4
    @State private var teamNames: [String] = []
    @State private var selectedTeams: Set<UUID> = []
    @State private var showingAddTeamSheet = false
    @State private var showingGlobalTeamPicker = false
    @FocusState private var focusedField: Int?
    
    enum TeamSetupMode {
        case createNew
        case selectExisting
    }
    
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
    
    var availableGlobalTeams: [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
        .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
    
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
                    // Mode Selection
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        Text("Methode")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        
                        Picker("Methode", selection: $mode) {
                            Label("Neue Teams erstellen", systemImage: "plus.circle.fill")
                                .tag(TeamSetupMode.createNew)
                            Label("Aus vorhandenen Teams auswählen", systemImage: "checkmark.circle.fill")
                                .tag(TeamSetupMode.selectExisting)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Divider()
                    
                    if mode == .createNew {
                        createNewTeamsView
                    } else {
                        selectExistingTeamsView
                    }
                }
                .padding(.horizontal, 40)
            }
            
            // Action Buttons
            HStack(spacing: AppSpacing.sm) {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.escape)
                .secondaryGradientButton(size: .large)
                
                Button {
                    if mode == .createNew {
                        createTeams()
                        dismiss()
                    } else {
                        // Im selectExisting-Modus werden Teams über die Sheets hinzugefügt
                        dismiss()
                    }
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "checkmark.circle.fill")
                        if mode == .createNew {
                            Text("\(numberOfTeams) Teams erstellen")
                                .monospacedDigit()
                        } else {
                            Text("Fertig")
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .primaryGradientButton(size: .large)
            }
            .padding(.horizontal, AppSpacing.xxl)
            .padding(.vertical, AppSpacing.sectionSpacing)
        }
        .frame(width: 650, height: 750)
        .background(Color.appBackground)
        .sheet(isPresented: $showingAddTeamSheet) {
            AddTeamSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingGlobalTeamPicker) {
            GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams, modelContext: modelContext)
        }
        .onAppear {
            updateTeamNames()
            focusedField = 0
        }
    }
    
    // MARK: - Create New Teams View
    private var createNewTeamsView: some View {
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
                        HStack(spacing: AppSpacing.xxs) {
                            ForEach(presetCounts, id: \.self) { count in
                                Button("\(count)") {
                                    numberOfTeams = count
                                    updateTeamNames()
                                }
                                .secondaryGradientButton()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    // Team Names
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(Color.appSecondary)
                            Text("Team-Namen")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            
                            Spacer()
                            
                            Button {
                                generateRandomNames()
                            } label: {
                                Label("Zufällige Namen", systemImage: "shuffle")
                                    .font(.caption)
                            }
                            .secondaryGradientButton()
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
                                .background(Color.appBackgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
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
    }
    
    // MARK: - Select Existing Teams View
    private var selectExistingTeamsView: some View {
        VStack(spacing: AppSpacing.sectionSpacing) {
            if availableGlobalTeams.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    Image(systemName: "person.3.slash.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Text("Keine verfügbaren Teams")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    
                    Text("Erstellen Sie zuerst Teams im Teams-Manager")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, AppSpacing.xxl)
            } else {
                VStack(spacing: AppSpacing.xs) {
                    Text("Teams hinzufügen")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: AppSpacing.xs) {
                        Button {
                            showingAddTeamSheet = true
                        } label: {
                            Label("Team hinzufügen", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryGradientButton(size: .large)
                        
                        Button {
                            showingGlobalTeamPicker = true
                        } label: {
                            Label("Aus vorhandenen wählen (\(availableGlobalTeams.count))", systemImage: "square.stack.3d.up.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .secondaryGradientButton(size: .large)
                    }
                }
                .padding(.vertical, AppSpacing.md)
            }
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
        let availableNames = randomTeamNames.shuffled()
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
    
    private func addSelectedTeams() {
        for teamId in selectedTeams {
            if let team = allTeams.first(where: { $0.id == teamId }) {
                viewModel.addExistingTeam(team, to: quiz)
            }
        }
    }
}

// MARK: - Team Wizard Selection Row
struct TeamWizardSelectionRow: View {
    let team: Team
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppSpacing.sm) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                        .fill(isSelected ? Color.appPrimary : Color.clear)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                                .strokeBorder(
                                    isSelected ? Color.appPrimary : Color.appTextTertiary,
                                    lineWidth: 2
                                )
                        )
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                
                // Team Icon
                TeamIconView(team: team, size: 32)
                
                // Team Name
                Text(team.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                
                Spacer()
                
                // Team Color Indicator
                Circle()
                    .fill(Color(hex: team.color) ?? Color.appPrimary)
                    .frame(width: 16, height: 16)
            }
            .padding(AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(isSelected ? Color.appPrimary.opacity(0.1) : Color.appBackgroundSecondary)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .strokeBorder(
                        isSelected ? Color.appPrimary.opacity(0.3) : Color.appTextTertiary.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}
