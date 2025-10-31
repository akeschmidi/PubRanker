//
//  TeamManagementView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct TeamManagementView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingAddTeamSheet = false
    @State private var showingTeamWizard = false
    
    var body: some View {
        VStack {
            if quiz.safeTeams.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        Text(NSLocalizedString("empty.noTeams", comment: "No teams"))
                            .font(.title2)
                            .bold()
                        
                        Text(NSLocalizedString("empty.noTeams.management", comment: "Add teams to start quiz"))
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: 12) {
                        Button {
                            showingTeamWizard = true
                        } label: {
                            Label(NSLocalizedString("team.new.multiple", comment: "Multiple teams"), systemImage: "person.3.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        
                        Button {
                            showingAddTeamSheet = true
                        } label: {
                            Label(NSLocalizedString("team.new.single", comment: "Single team"), systemImage: "plus.circle")
                                .font(.headline)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                List {
                    ForEach(quiz.safeTeams) { team in
                        TeamRowView(team: team, quiz: quiz, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTeam(quiz.safeTeams[index], from: quiz)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingTeamWizard = true
                    } label: {
                        Label(NSLocalizedString("team.new.multiple.create", comment: "Create multiple teams"), systemImage: "person.3.fill")
                    }
                    
                    Button {
                        showingAddTeamSheet = true
                    } label: {
                        Label(NSLocalizedString("team.new.single.add", comment: "Add single team"), systemImage: "plus.circle")
                    }
                } label: {
                    Label(NSLocalizedString("team.add", comment: "Add team"), systemImage: "plus")
                }
                .help(NSLocalizedString("team.add.multiple", comment: "Add teams"))
            }
        }
        .sheet(isPresented: $showingAddTeamSheet) {
            AddTeamSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingTeamWizard) {
            TeamWizardSheet(quiz: quiz, viewModel: viewModel)
        }
    }
}

struct TeamRowView: View {
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var isEditing = false
    @State private var editedName: String = ""
    
    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: team.color) ?? .blue)
                .frame(width: 12, height: 12)
            
            if isEditing {
                TextField("Team Name", text: $editedName, onCommit: {
                    saveChanges()
                })
                .textFieldStyle(.roundedBorder)
            } else {
                Text(team.name)
                    .font(.body)
            }
            
            Spacer()
            
            Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), team.totalScore))
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Button {
                if isEditing {
                    saveChanges()
                } else {
                    editedName = team.name
                    isEditing = true
                }
            } label: {
                Image(systemName: isEditing ? "checkmark" : "pencil")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    
    private func saveChanges() {
        if !editedName.isEmpty {
            viewModel.updateTeamName(team, newName: editedName)
        }
        isEditing = false
    }
}

struct AddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    
    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Team Details") {
                    TextField("Team Name", text: $teamName)
                    
                    VStack(alignment: .leading) {
                        Text("Farbe")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        if selectedColor == colorHex {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 3)
                                        }
                                    }
                                    .onTapGesture {
                                        selectedColor = colorHex
                                    }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Team hinzufügen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen") {
                        viewModel.addTeam(to: quiz, name: teamName, color: selectedColor)
                        dismiss()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
}

// MARK: - Team Wizard Sheet
struct TeamWizardSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var numberOfTeams: Int = 4
    @State private var teamNames: [String] = []
    @FocusState private var focusedField: Int?
    
    let presetCounts = [4, 6, 8, 10]
    
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
    
    private func createTeams() {
        for index in 0..<numberOfTeams {
            let name = getTeamName(for: index)
            let color = getTeamColorHex(for: index)
            viewModel.addTeam(to: quiz, name: name, color: color)
        }
    }
}
