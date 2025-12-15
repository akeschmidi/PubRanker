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
    
    @State private var showingMaxTeamsEditor = false
    @State private var tempMaxTeams: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header mit Team-Status
            TeamManagementHeader(
                quiz: quiz,
                onEditMaxTeams: {
                    tempMaxTeams = quiz.maxTeams.map { String($0) } ?? ""
                    showingMaxTeamsEditor = true
                }
            )
            
            Divider()
            
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
            
            // Action Buttons am unteren Rand - IMMER anzeigen
            Divider()
            
            HStack(spacing: AppSpacing.xs) {
                Button {
                    showingGlobalTeamPicker = true
                } label: {
                    if availableGlobalTeams.isEmpty {
                        Label(NSLocalizedString("team.noExistingTeams", comment: "No existing teams"), systemImage: "square.stack.3d.up.fill")
                            .frame(maxWidth: .infinity)
                    } else {
                        Label(String(format: NSLocalizedString("team.selectFromExisting", comment: "Select from existing"), availableGlobalTeams.count), systemImage: "square.stack.3d.up.fill")
                            .frame(maxWidth: .infinity)
                    }
                }
                .secondaryGradientButton(size: .large)
                .disabled(availableGlobalTeams.isEmpty)
                .opacity(availableGlobalTeams.isEmpty ? 0.5 : 1.0)
            }
            .padding(AppSpacing.md)
            .background(Color.appBackgroundSecondary)
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
        .sheet(isPresented: $showingMaxTeamsEditor) {
            MaxTeamsEditorSheet(quiz: quiz, tempMaxTeams: $tempMaxTeams)
        }
    }
}

// MARK: - Team Management Header
struct TeamManagementHeader: View {
    let quiz: Quiz
    let onEditMaxTeams: () -> Void
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            // Linke Seite: Team-Status
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: "person.3.fill")
                    .font(.title3)
                    .foregroundStyle(Color.appPrimary)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: AppSpacing.xxxs) {
                        Text("\(quiz.confirmedTeamsCount)")
                            .font(.headline)
                            .foregroundStyle(Color.appSuccess)
                        
                        Text(NSLocalizedString("teams.confirmed", comment: "confirmed teams"))
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                        
                        Text("/")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextTertiary)
                        
                        if let maxTeams = quiz.maxTeams {
                            Text("\(maxTeams)")
                                .font(.headline)
                                .foregroundStyle(Color.appPrimary)
                            
                            Text(NSLocalizedString("teams.defined", comment: "defined teams"))
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                        } else {
                            Text("\(quiz.safeTeams.count)")
                                .font(.headline)
                                .foregroundStyle(Color.appPrimary)
                            
                            Text(NSLocalizedString("teams.assigned", comment: "assigned teams"))
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Rechte Seite: Max Teams bearbeiten
            Button {
                onEditMaxTeams()
            } label: {
                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.body)
                    Text(NSLocalizedString("teams.setMax", comment: "Set max teams"))
                        .font(.body)
                }
            }
            .secondaryGradientButton()
        }
        .padding(.horizontal, AppSpacing.screenPadding)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.appBackgroundSecondary)
    }
}

// MARK: - Max Teams Editor Sheet
struct MaxTeamsEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var quiz: Quiz
    @Binding var tempMaxTeams: String
    
    @State private var maxTeams: Int = 10
    @State private var hasLimit: Bool = false
    
    let presetCounts = [6, 8, 10, 12, 16, 20]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: AppSpacing.xs) {
                ZStack {
                    Circle()
                        .fill(Color.gradientPrimary)
                        .frame(width: 60, height: 60)
                        .shadow(AppShadow.primary)
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(.white)
                }
                
                Text(NSLocalizedString("teams.maxTeams.title", comment: "Team limit"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                Text(NSLocalizedString("teams.maxTeams.description", comment: "Define team limit"))
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.top, AppSpacing.lg)
            .padding(.bottom, AppSpacing.md)
            
            // Content
            ScrollView {
                VStack(spacing: AppSpacing.sm) {
                    // Toggle für Limit
                    Toggle(isOn: $hasLimit) {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: hasLimit ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(hasLimit ? Color.appSuccess : Color.appTextTertiary)
                            Text(NSLocalizedString("teams.maxTeams.enable", comment: "Enable team limit"))
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    .toggleStyle(.switch)
                    .padding(AppSpacing.md)
                    .appCard(style: .default, cornerRadius: AppCornerRadius.md)
                    
                    if hasLimit {
                        // Stepper Card
                        VStack(spacing: AppSpacing.md) {
                            HStack(spacing: AppSpacing.lg) {
                                Button {
                                    if maxTeams > 2 { maxTeams -= 1 }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.appPrimary)
                                }
                                .buttonStyle(.plain)
                                
                                Text("\(maxTeams)")
                                    .font(.system(size: 64, weight: .bold))
                                    .monospacedDigit()
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(minWidth: 80)
                                
                                Button {
                                    if maxTeams < 50 { maxTeams += 1 }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(Color.appPrimary)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Quick Presets mit Outline-Buttons
                            VStack(spacing: AppSpacing.xxs) {
                                Text(NSLocalizedString("common.quickSelect", comment: "Quick select"))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                
                                HStack(spacing: AppSpacing.xs) {
                                    ForEach(presetCounts, id: \.self) { count in
                                        Button {
                                            maxTeams = count
                                        } label: {
                                            Text("\(count)")
                                                .font(.headline)
                                                .monospacedDigit()
                                                .foregroundStyle(maxTeams == count ? .white : Color.appPrimary)
                                                .frame(width: 44, height: 36)
                                                .background(
                                                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                                        .fill(maxTeams == count ? Color.appPrimary : Color.appPrimary.opacity(0.1))
                                                )
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                                        .stroke(Color.appPrimary.opacity(0.3), lineWidth: 1)
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }
                        .padding(AppSpacing.md)
                        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
                        
                        // Status Card
                        VStack(spacing: AppSpacing.xs) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appSuccess)
                                Text(NSLocalizedString("teams.confirmed", comment: "Confirmed"))
                                    .foregroundStyle(Color.appTextSecondary)
                                Spacer()
                                Text("\(quiz.confirmedTeamsCount) / \(maxTeams)")
                                    .font(.headline)
                                    .monospacedDigit()
                                    .foregroundStyle(quiz.confirmedTeamsCount >= maxTeams ? Color.appSuccess : Color.appTextPrimary)
                            }
                            
                            Divider()
                            
                            HStack {
                                Image(systemName: "person.3.fill")
                                    .foregroundStyle(Color.appPrimary)
                                Text(NSLocalizedString("teams.assigned", comment: "Assigned"))
                                    .foregroundStyle(Color.appTextSecondary)
                                Spacer()
                                Text("\(quiz.safeTeams.count) / \(maxTeams)")
                                    .font(.headline)
                                    .monospacedDigit()
                                    .foregroundStyle(quiz.safeTeams.count >= maxTeams ? Color.appAccent : Color.appTextPrimary)
                            }
                        }
                        .padding(AppSpacing.md)
                        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
                        
                    } else {
                        // Unbegrenzt Card
                        VStack(spacing: AppSpacing.sm) {
                            Image(systemName: "infinity")
                                .font(.system(size: 50))
                                .foregroundStyle(Color.appTextTertiary)
                            
                            Text(NSLocalizedString("teams.maxTeams.unlimited", comment: "Unlimited"))
                                .font(.title3)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, AppSpacing.xxl)
                        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
                    }
                }
                .padding(.horizontal, AppSpacing.lg)
            }
            
            // Action Buttons
            HStack(spacing: AppSpacing.sm) {
                Button {
                    dismiss()
                } label: {
                    Text(L10n.Navigation.cancel)
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button {
                    quiz.maxTeams = hasLimit ? maxTeams : nil
                    dismiss()
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(L10n.Navigation.save)
                    }
                    .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .primaryGradientButton(size: .large)
            }
            .padding(AppSpacing.lg)
            .background(Color.appBackgroundSecondary)
        }
        .frame(width: 600, height: 800)
        .background(Color.appBackground)
        .onAppear {
            if let existingMax = quiz.maxTeams {
                maxTeams = existingMax
                hasLimit = true
            } else {
                hasLimit = false
                maxTeams = max(quiz.safeTeams.count, 10)
            }
        }
    }
}

struct TeamRowView: View {
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingDeleteConfirmation = false
    @State private var isConfirmed: Bool = false

    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            // Team Icon
            TeamIconView(team: team, size: 36)
            
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
                
                if !team.email.isEmpty {
                    Text(team.email)
                        .font(.caption2)
                        .foregroundStyle(Color.appPrimary)
                }
            }

            Spacer()

            // Bestätigung Toggle
            Toggle(isOn: $isConfirmed) {
                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: isConfirmed ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isConfirmed ? Color.appSuccess : Color.appTextTertiary)
                    Text(NSLocalizedString("team.confirmed", comment: "Confirmed"))
                        .font(.caption)
                        .foregroundStyle(isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                }
            }
            .toggleStyle(.button)
            .buttonStyle(.plain)
            .help(NSLocalizedString("team.confirmed.toggle.help", comment: "Toggle participation confirmation"))
            .onChange(of: isConfirmed) { _, newValue in
                team.setConfirmed(for: quiz, isConfirmed: newValue)
            }

            // Entfernen Button
            Button {
                showingDeleteConfirmation = true
            } label: {
                Image(systemName: "trash")
                    .font(.body)
                    .foregroundStyle(Color.appTextTertiary)
            }
            .buttonStyle(.plain)
            .help(NSLocalizedString("team.remove.help", comment: "Remove team help"))
        }
        .padding(.horizontal, AppSpacing.xs)
        .padding(.vertical, AppSpacing.xs)
        .appCard(style: isConfirmed ? .elevated : .default, cornerRadius: AppCornerRadius.sm)
        .overlay {
            if isConfirmed {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(Color.appSuccess.opacity(0.5), lineWidth: 2)
            }
        }
        .alert(NSLocalizedString("team.remove.confirm", comment: "Remove team confirm"), isPresented: $showingDeleteConfirmation) {
            Button(L10n.Navigation.cancel, role: .cancel) {}
            Button(L10n.CommonUI.remove, role: .destructive) {
                viewModel.deleteTeam(team, from: quiz)
            }
        } message: {
            Text(String(format: NSLocalizedString("team.remove.message", comment: "Remove team message"), team.name))
        }
        .onAppear {
            isConfirmed = team.isConfirmed(for: quiz)
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



