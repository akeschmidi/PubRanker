//
//  TeamManagementView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import SwiftData

struct TeamManagementView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]

    @State private var showingAddTeamSheet = false
    @State private var showingTeamWizard = false
    @State private var showingGlobalTeamPicker = false

    var sortedTeams: [Team] {
        quiz.safeTeams.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    var availableGlobalTeams: [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
        .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if quiz.safeTeams.isEmpty {
                VStack(spacing: AppSpacing.sectionSpacing) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.appTextSecondary)
                    
                    VStack(spacing: AppSpacing.xxs) {
                        Text(NSLocalizedString("empty.noTeams", comment: "No teams"))
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                        
                        Text(NSLocalizedString("empty.noTeams.management", comment: "Add teams to start quiz"))
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    
                    HStack(spacing: AppSpacing.xs) {
                        Button {
                            showingTeamWizard = true
                        } label: {
                            Label(NSLocalizedString("team.new.multiple", comment: "Multiple teams"), systemImage: "person.3.fill")
                                .font(.headline)
                        }
                        .primaryGradientButton(size: .large)
                        
                        Button {
                            showingAddTeamSheet = true
                        } label: {
                            Label(NSLocalizedString("team.new.single", comment: "Single team"), systemImage: "plus.circle")
                                .font(.headline)
                        }
                        .secondaryGradientButton(size: .large)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(AppSpacing.screenPadding)
            } else {
                List {
                    ForEach(sortedTeams) { team in
                        TeamRowView(team: team, quiz: quiz, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTeam(sortedTeams[index], from: quiz)
                        }
                    }
                }
            }
            
            // Action Buttons am unteren Rand
            if !quiz.safeTeams.isEmpty {
                Divider()
                
                HStack(spacing: AppSpacing.xs) {
                    Button {
                        showingAddTeamSheet = true
                    } label: {
                        Label("Team hinzufügen", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryGradientButton(size: .large)
                    
                    if !availableGlobalTeams.isEmpty {
                        Button {
                            showingGlobalTeamPicker = true
                        } label: {
                            Label("Aus vorhandenen wählen (\(availableGlobalTeams.count))", systemImage: "square.stack.3d.up.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .secondaryGradientButton(size: .large)
                    }
                }
                .padding(AppSpacing.md)
                .background(Color.appBackgroundSecondary)
            }
        }
        .sheet(isPresented: $showingAddTeamSheet) {
            AddTeamSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingTeamWizard) {
            TeamWizardSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingGlobalTeamPicker) {
            GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams, modelContext: modelContext)
        }
    }
}

struct TeamRowView: View {
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingDeleteConfirmation = false
    @State private var showingEditSheet = false

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            // Team Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(team.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                if !team.contactPerson.isEmpty {
                    Text(team.contactPerson)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            Spacer()

            // Status
            HStack(spacing: AppSpacing.xs) {
                if team.isConfirmed(for: quiz) {
                    Label("Bestätigt", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appSuccess)
                }
            }

            // Action Buttons
            HStack(spacing: AppSpacing.xxs) {
                // Bearbeiten Button
                Button {
                    showingEditSheet = true
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "pencil")
                            .font(.body)
                        Text(L10n.CommonUI.edit)
                            .font(.body)
                    }
                }
                .primaryGradientButton()
                .help(NSLocalizedString("team.edit.help", comment: "Edit team help"))
                
                // Delete Button
                Button {
                    showingDeleteConfirmation = true
                } label: {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "trash")
                            .font(.body)
                        Text(L10n.CommonUI.remove)
                            .font(.body)
                    }
                }
                .accentGradientButton()
                .help(NSLocalizedString("team.remove.help", comment: "Remove team help"))
            }
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xs)
        .appCard(style: .default, cornerRadius: AppCornerRadius.sm)
        .sheet(isPresented: $showingEditSheet) {
            EditTeamSheet(team: team, quiz: quiz, viewModel: viewModel)
        }
        .alert(NSLocalizedString("team.remove.confirm", comment: "Remove team confirm"), isPresented: $showingDeleteConfirmation) {
            Button(L10n.Navigation.cancel, role: .cancel) {}
            Button(L10n.CommonUI.remove, role: .destructive) {
                viewModel.deleteTeam(team, from: quiz)
            }
        } message: {
            Text(String(format: NSLocalizedString("team.remove.message", comment: "Remove team message"), team.name))
        }
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
                Section(L10n.CommonUI.teamDetails) {
                    TextField(L10n.CommonUI.teamName, text: $teamName)
                    
                    VStack(alignment: .leading) {
                        Text(L10n.CommonUI.color)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: AppSpacing.xs) {
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
            .navigationTitle(L10n.CommonUI.addTeam)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Navigation.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.CommonUI.add) {
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

// MARK: - Edit Team Sheet
struct EditTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var teamName = ""
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section(L10n.CommonUI.teamDetails) {
                    TextField(L10n.CommonUI.teamName, text: $teamName)
                }
                
                Section(L10n.CommonUI.contactInfo) {
                    TextField(NSLocalizedString("common.contactPerson", comment: "Contact person"), text: $contactPerson)
                    TextField(NSLocalizedString("common.email", comment: "Email"), text: $email)
                }
                
                Section {
                    Toggle(L10n.CommonUI.confirmed, isOn: $isConfirmed)
                }
            }
            .navigationTitle(L10n.CommonUI.editTeam)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Navigation.cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(L10n.Navigation.save) {
                        let trimmedName = teamName.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedName.isEmpty {
                            viewModel.updateTeamName(team, newName: trimmedName)
                        }
                        viewModel.updateTeamDetails(team, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, forQuiz: quiz)
                        dismiss()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
        .onAppear {
            teamName = team.name
            contactPerson = team.contactPerson
            email = team.email
            isConfirmed = team.isConfirmed(for: quiz)
        }
    }
}

// MARK: - Team Wizard Sheet
struct TeamWizardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var numberOfTeams: Int = 4
    @State private var teamNames: [String] = []
    @State private var showingAddTeamSheet = false
    @State private var showingGlobalTeamPicker = false
    @FocusState private var focusedField: Int?
    
    var availableGlobalTeams: [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
        .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }
    
    let presetCounts = [4, 6, 8, 10]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: AppSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.gradientSuccess)
                        .frame(width: 80, height: 80)
                        .shadow(AppShadow.success)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }

                VStack(spacing: AppSpacing.xxs) {
                    Text(L10n.CommonUI.teamSetup)
                        .font(.title)
                        .bold()

                    Text(L10n.CommonUI.teamSetupDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.xl)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Number of Teams
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .foregroundStyle(.blue)
                            Text(L10n.CommonUI.numberOfTeams)
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
                            Text(L10n.CommonUI.teamNames)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(0..<numberOfTeams, id: \.self) { index in
                                HStack(spacing: 12) {
                                    // Color Circle
                                    Circle()
                                        .fill(getTeamColor(for: index))
                                        .frame(width: 24, height: 24)
                                        .shadow(radius: 3, y: 1)
                                    
                                    // Team Number
                                    Text(L10n.CommonUI.teamNumber(index + 1))
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
                        Text(L10n.CommonUI.preview)
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
                .padding(.horizontal, 40)
            }
            
            // Action Buttons
            VStack(spacing: AppSpacing.sm) {
                // Buttons für vorhandene Teams
                HStack(spacing: AppSpacing.xs) {
                    Button {
                        showingAddTeamSheet = true
                    } label: {
                        Label(L10n.CommonUI.addTeam, systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryGradientButton(size: .large)
                    
                    if !availableGlobalTeams.isEmpty {
                        Button {
                            showingGlobalTeamPicker = true
                        } label: {
                            Label(String(format: NSLocalizedString("team.selectFromExisting", comment: "Select from existing"), availableGlobalTeams.count), systemImage: "square.stack.3d.up.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .secondaryGradientButton(size: .large)
                    }
                }
                
                Divider()
                
                // Wizard Action Buttons
                HStack(spacing: AppSpacing.sm) {
                    Button {
                        dismiss()
                    } label: {
                        Text(L10n.Navigation.cancel)
                            .frame(maxWidth: .infinity)
                    }
                    .keyboardShortcut(.escape)
                    .secondaryGradientButton(size: .large)
                    
                    Button {
                        createTeams()
                        dismiss()
                    } label: {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("\(numberOfTeams) Teams erstellen")
                                .monospacedDigit()
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .keyboardShortcut(.return, modifiers: .command)
                    .primaryGradientButton(size: .large)
                }
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



