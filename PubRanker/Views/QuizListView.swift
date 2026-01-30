//
//  QuizListView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import SwiftData

struct QuizListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quiz.date, order: .reverse) private var quizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @State private var showingNewQuizSheet = false
    @State private var selection: Quiz?
    @State private var quizToDelete: Quiz?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            quizList
            .navigationTitle("PubRanker 🎯")
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewQuizSheet = true
                    } label: {
                        Label("Neues Quiz", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    .helpText("Neues Quiz erstellen (⌘N)")
                }
                
                if let selectedQuiz = selection {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            quizToDelete = selectedQuiz
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                        .helpText("Ausgewähltes Quiz löschen")
                    }
                }
            }
            .onChange(of: selection) { oldValue, newValue in
                viewModel.selectedQuiz = newValue
            }
            .sheet(isPresented: $showingNewQuizSheet) {
                NewQuizSheet(viewModel: viewModel)
            }
            .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation, presenting: quizToDelete) { quiz in
                Button("Abbrechen", role: .cancel) {
                    quizToDelete = nil
                }
                Button("Löschen", role: .destructive) {
                    deleteQuiz(quiz)
                }
            } message: { quiz in
                Text(String(format: NSLocalizedString("common.delete.confirm", comment: "Delete confirmation"), quiz.name))
            }
        } detail: {
            if let selectedQuiz = selection {
                QuizDetailView(quiz: selectedQuiz, viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    NSLocalizedString("quiz.select.none", comment: "No quiz selected"),
                    systemImage: "list.bullet.clipboard",
                    description: Text(NSLocalizedString("quiz.select.prompt", comment: "Select quiz prompt"))
                )
                .frame(minWidth: 600, minHeight: 400)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            viewModel.setContext(modelContext)
            // Select first active quiz if none selected
            if selection == nil && !activeQuizzes.isEmpty {
                selection = activeQuizzes.first
            }
        }
        #if os(macOS)
        .frame(minWidth: 900, minHeight: 600)
        #else
        .frame(minWidth: 320, minHeight: 480)
        #endif
    }
    
    private func deleteQuiz(_ quiz: Quiz) {
        // Deselect if currently selected
        if selection?.id == quiz.id {
            selection = nil
        }
        viewModel.deleteQuiz(quiz)
        quizToDelete = nil
    }
    
    private var activeQuizzes: [Quiz] {
        quizzes.filter { $0.isActive && !$0.isCompleted }
    }
    
    private var completedQuizzes: [Quiz] {
        quizzes.filter { $0.isCompleted }
    }
    
    private var plannedQuizzes: [Quiz] {
        quizzes.filter { !$0.isActive && !$0.isCompleted }
    }
    
    private var quizList: some View {
        List(selection: $selection) {
            if !activeQuizzes.isEmpty {
                quizSection(title: "Aktive Quiz", quizzes: activeQuizzes)
            }
            
            if !completedQuizzes.isEmpty {
                quizSection(title: "Abgeschlossene Quiz", quizzes: completedQuizzes)
            }
            
            if !plannedQuizzes.isEmpty {
                quizSection(title: "Geplante Quiz", quizzes: plannedQuizzes)
            }
        }
    }
    
    private func quizSection(title: String, quizzes: [Quiz]) -> some View {
        Section(title) {
            ForEach(quizzes) { quiz in
                QuizRowView(quiz: quiz)
                    .tag(quiz)
                    .contextMenu {
                        deleteButton(for: quiz)
                    }
            }
            .onDelete { indexSet in
                handleDelete(at: indexSet, in: quizzes)
            }
        }
    }
    
    private func deleteButton(for quiz: Quiz) -> some View {
        Button(role: .destructive) {
            quizToDelete = quiz
            showingDeleteConfirmation = true
        } label: {
            Label("Löschen", systemImage: "trash")
        }
    }
    
    private func handleDelete(at indexSet: IndexSet, in quizzes: [Quiz]) {
        for index in indexSet {
            quizToDelete = quizzes[index]
            showingDeleteConfirmation = true
        }
    }
}

struct QuizRowView: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
            HStack {
                Text(quiz.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                
                Spacer()
                
                if quiz.isActive {
                    Label("Live", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appSuccess)
                } else if quiz.isCompleted {
                    Label("Beendet", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appPrimary)
                }
            }
            
            HStack {
                if !quiz.venue.isEmpty {
                    Label(quiz.venue, systemImage: "mappin.circle")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                Spacer()
                
                Text(quiz.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }
            
            HStack {
                Label(String(format: NSLocalizedString("quiz.teams.count", comment: "Teams count"), quiz.safeTeams.count), systemImage: "person.3")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
                
                Label(String(format: NSLocalizedString("round.count", comment: "Rounds count"), quiz.safeRounds.count), systemImage: "list.number")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
                
                if quiz.safeRounds.count > 0 {
                    ProgressView(value: quiz.progress)
                        .tint(Color.appPrimary)
                        .frame(width: 60)
                }
            }
        }
        .padding(.vertical, AppSpacing.xxxs)
    }
}

struct NewQuizSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var viewModel: QuizViewModel

    // Wizard State
    @State private var currentStep: WizardStep = .details
    @State private var createdQuiz: Quiz?

    // Step 1: Quiz Details
    @State private var quizName = ""
    @State private var venue = ""
    @State private var date = Date()
    @FocusState private var focusedField: Field?

    // Step 2: Teams - use existing sheets
    @State private var showingTeamWizard = false
    @State private var showingAddTeam = false
    @State private var showingGlobalTeamPicker = false
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]

    // Step 3: Rounds - use existing sheets
    @State private var showingRoundWizard = false
    @State private var showingAddRound = false

    enum WizardStep: Int, CaseIterable {
        case details = 1
        case teams = 2
        case rounds = 3

        var title: String {
            switch self {
            case .details: return "Quiz-Details"
            case .teams: return "Teams hinzufügen"
            case .rounds: return "Runden definieren"
            }
        }

        var icon: String {
            switch self {
            case .details: return "sparkles"
            case .teams: return "person.3.fill"
            case .rounds: return "list.number"
            }
        }
    }

    enum Field {
        case name, venue
    }

    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            progressHeader

            // Content for current step
            switch currentStep {
            case .details:
                detailsStepView
            case .teams:
                teamsStepView
            case .rounds:
                roundsStepView
            }

            Divider()

            // Navigation Buttons
            navigationButtons
        }
        .frame(width: 900, height: 800)
        .background(Color.appBackground)
        .onAppear {
            focusedField = .name
            // Wizard-Modus aktivieren
            viewModel.isWizardMode = true
            // Sicherstellen, dass der Context gesetzt ist
            viewModel.setContext(modelContext)
        }
        .onDisappear {
            // Wenn der Wizard abgebrochen wird, Wizard-Modus beenden
            if currentStep != .rounds || createdQuiz == nil {
                viewModel.isWizardMode = false
                viewModel.temporaryQuiz = nil
            }
        }
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        VStack(spacing: 16) {
            // Step Indicators
            HStack(spacing: 12) {
                ForEach(WizardStep.allCases, id: \.self) { step in
                    HStack(spacing: 8) {
                        // Step Circle
                        ZStack {
                            Circle()
                                .fill(stepColor(for: step))
                                .frame(width: 40, height: 40)

                            if step.rawValue < currentStep.rawValue {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            } else {
                                Text("\(step.rawValue)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(.white)
                            }
                        }

                        // Step Title
                        Text(step.title)
                            .font(.system(size: 14, weight: currentStep == step ? .bold : .regular))
                            .foregroundStyle(currentStep == step ? Color.appTextPrimary : Color.appTextSecondary)

                        // Connector Line
                        if step != .rounds {
                            Rectangle()
                                .fill(step.rawValue < currentStep.rawValue ? Color.appPrimary : Color.appTextTertiary.opacity(0.3))
                                .frame(height: 2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.xxl)
            .padding(.top, AppSpacing.sectionSpacing)
            .padding(.bottom, AppSpacing.sm)
        }
        .background(Color.appBackgroundSecondary)
    }

    private func stepColor(for step: WizardStep) -> Color {
        if step.rawValue < currentStep.rawValue {
            return Color.appSuccess
        } else if step == currentStep {
            return Color.appPrimary
        } else {
            return Color.appTextTertiary.opacity(0.3)
        }
    }

    // MARK: - Step 1: Details

    private var detailsStepView: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.3), radius: 10)

                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                .padding(.top, 20)

                VStack(spacing: 8) {
                    Text("Neues Quiz erstellen")
                        .font(.title)
                        .bold()

                    Text("Starte mit den Grundinformationen")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Form
                VStack(spacing: 24) {
                    // Quiz Name
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "text.quote")
                                .foregroundStyle(Color.appPrimary)
                            Text("Quiz-Name")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }

                        TextField("z.B. Pub Quiz April 2024", text: $quizName)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                            .focused($focusedField, equals: .name)
                    }

                    // Venue
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(Color.appAccent)
                            Text("Ort")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }

                        TextField("z.B. Murphy's Pub", text: $venue)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                            .focused($focusedField, equals: .venue)
                    }

                    // Date & Time - Modern Cards
                    HStack(spacing: 20) {
                        // Datum Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.green, .green.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                        .shadow(color: .green.opacity(0.3), radius: 8)

                                    Image(systemName: "calendar")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Datum")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text(date.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.primary)
                                }
                            }

                            DatePicker("", selection: $date, displayedComponents: [.date])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .fill(Color.appBackgroundSecondary)
                                .shadow(AppShadow.md)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .stroke(Color.appSuccess.opacity(0.2), lineWidth: 1)
                        }

                        // Uhrzeit Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .orange.opacity(0.7)],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 44, height: 44)
                                        .shadow(color: .orange.opacity(0.3), radius: 8)

                                    Image(systemName: "clock")
                                        .font(.system(size: 20))
                                        .foregroundStyle(.white)
                                }

                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Uhrzeit")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)

                                    Text(date.formatted(date: .omitted, time: .shortened))
                                        .font(.system(size: 17, weight: .semibold))
                                        .foregroundStyle(.primary)
                                }
                            }

                            DatePicker("", selection: $date, displayedComponents: [.hourAndMinute])
                                .datePickerStyle(.compact)
                                .labelsHidden()
                        }
                        .padding(20)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .fill(Color.appBackgroundSecondary)
                                .shadow(AppShadow.md)
                        )
                        .overlay {
                            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                                .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            .padding(.bottom, 20)
        }
    }

    // MARK: - Step 2: Teams

    private var teamsStepView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 8) {
                Text("Teams hinzufügen")
                    .font(.title)
                    .bold()

                Text("Füge die teilnehmenden Teams hinzu")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 32)
            .padding(.bottom, 24)

            // Content
            if let quiz = createdQuiz {
                if quiz.safeTeams.isEmpty {
                    // Empty state with action buttons
                    VStack(spacing: 24) {
                        VStack(spacing: 8) {
                            Text("Noch keine Teams hinzugefügt")
                                .font(.title2)
                                .bold()

                            Text("Füge Teams einzeln hinzu oder erstelle mehrere auf einmal")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        VStack(spacing: AppSpacing.sm) {
                            HStack(spacing: 12) {
                                Button {
                                    showingTeamWizard = true
                                } label: {
                                    Label("Mehrere Teams", systemImage: "person.3.fill")
                                        .font(.headline)
                                }
                                .primaryGlassButton(size: .large)

                                Button {
                                    showingAddTeam = true
                                } label: {
                                    Label("Einzelnes Team", systemImage: "plus.circle")
                                        .font(.headline)
                                }
                                .secondaryGlassButton(size: .large)
                            }
                            
                            if let quiz = createdQuiz, !availableGlobalTeams(for: quiz).isEmpty {
                                Button {
                                    showingGlobalTeamPicker = true
                                } label: {
                                    Label("Aus vorhandenen wählen (\(availableGlobalTeams(for: quiz).count))", systemImage: "square.stack.3d.up.fill")
                                        .font(.headline)
                                }
                                .secondaryGlassButton(size: .large)
                            }
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else {
                    // Teams list
                    VStack(spacing: 16) {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(quiz.safeTeams) { team in
                                    HStack {
                                        TeamIconView(team: team, size: 12)

                                        Text(team.name)
                                            .font(.body)

                                        Spacer()

                                        Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), team.totalScore))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding()
                                    .background(Color.appBackgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                                }
                            }
                            .padding(.horizontal, 40)
                        }

                        // Add more buttons
                        VStack(spacing: AppSpacing.sm) {
                            HStack(spacing: 12) {
                                Button {
                                    showingTeamWizard = true
                                } label: {
                                    Label("Mehrere Teams", systemImage: "person.3.fill")
                                }
                                .primaryGlassButton()

                                Button {
                                    showingAddTeam = true
                                } label: {
                                    Label("Einzelnes Team", systemImage: "plus.circle")
                                }
                                .secondaryGlassButton()
                            }
                            
                            if !availableGlobalTeams(for: quiz).isEmpty {
                                Button {
                                    showingGlobalTeamPicker = true
                                } label: {
                                    Label("Aus vorhandenen wählen (\(availableGlobalTeams(for: quiz).count))", systemImage: "square.stack.3d.up.fill")
                                }
                                .secondaryGlassButton()
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 16)
                    }
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showingTeamWizard) {
            if let quiz = createdQuiz {
                TeamWizardSheet(quiz: quiz, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingAddTeam) {
            if let quiz = createdQuiz {
                AddTeamSheet(quiz: quiz, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingGlobalTeamPicker) {
            if let quiz = createdQuiz {
                GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams(for: quiz), modelContext: modelContext)
            }
        }
    }
    
    private func availableGlobalTeams(for quiz: Quiz) -> [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
        .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    // MARK: - Step 3: Rounds

    private var roundsStepView: some View {
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

                    Image(systemName: "list.number")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }

                VStack(spacing: 8) {
                    Text("Runden definieren")
                        .font(.title)
                        .bold()

                    Text("Erstelle die Runden für dein Quiz")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 32)
            .padding(.bottom, 24)

            // Content
            if let quiz = createdQuiz {
                if quiz.safeRounds.isEmpty {
                    // Empty state with action buttons
                    VStack(spacing: 24) {
                        Image(systemName: "number.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.green)

                        VStack(spacing: 8) {
                            Text("Noch keine Runden hinzugefügt")
                                .font(.title2)
                                .bold()

                            Text("Füge Runden einzeln hinzu oder erstelle mehrere auf einmal")
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }

                        HStack(spacing: 12) {
                            Button {
                                showingRoundWizard = true
                            } label: {
                                Label("Mehrere Runden", systemImage: "rectangle.stack.fill")
                                    .font(.headline)
                            }
                            .primaryGlassButton(size: .large)

                            Button {
                                showingAddRound = true
                            } label: {
                                Label("Einzelne Runde", systemImage: "plus.circle")
                                    .font(.headline)
                            }
                            .secondaryGlassButton(size: .large)
                        }
                    }
                    .frame(maxHeight: .infinity)
                    .padding()
                } else {
                    // Rounds list
                    VStack(spacing: 16) {
                        ScrollView {
                            VStack(spacing: 8) {
                                ForEach(Array(quiz.sortedRounds.enumerated()), id: \.element.id) { index, round in
                                    HStack {
                                        Text("R\(index + 1)")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .frame(width: 40, height: 40)
                                            .background(Color.green)
                                            .clipShape(Circle())

                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(round.name)
                                                .font(.body)
                                                .bold()

                                            Text("\(round.maxPoints ?? 0) Punkte")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()
                                    }
                                    .padding()
                                    .background(Color.appBackgroundSecondary)
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                                }
                            }
                            .padding(.horizontal, 40)
                        }

                        // Add more buttons
                        HStack(spacing: 12) {
                            Button {
                                showingRoundWizard = true
                            } label: {
                                Label("Mehrere Runden", systemImage: "rectangle.stack.fill")
                            }
                            .primaryGlassButton()

                            Button {
                                showingAddRound = true
                            } label: {
                                Label("Einzelne Runde", systemImage: "plus.circle")
                            }
                            .secondaryGlassButton()
                        }
                        .padding(.horizontal, 40)
                        .padding(.bottom, 16)
                    }
                }
            }

            Spacer()
        }
        .sheet(isPresented: $showingRoundWizard) {
            if let quiz = createdQuiz {
                RoundWizardSheet(quiz: quiz, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingAddRound) {
            if let quiz = createdQuiz {
                QuickRoundSheet(quiz: quiz, viewModel: viewModel)
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 16) {
            // Back/Cancel Button
            Button {
                if currentStep == .details {
                    // Wizard-Modus beenden beim Abbrechen
                    viewModel.isWizardMode = false
                    viewModel.temporaryQuiz = nil
                    dismiss()
                } else {
                    withAnimation {
                        currentStep = WizardStep(rawValue: currentStep.rawValue - 1) ?? .details
                    }
                }
            } label: {
                HStack {
                    Image(systemName: currentStep == .details ? "xmark" : "chevron.left")
                    Text(currentStep == .details ? "Abbrechen" : "Zurück")
                }
                .frame(maxWidth: .infinity)
            }
            .keyboardShortcut(.escape)
            .secondaryGlassButton(size: .large)

            // Next/Create Button
            Button {
                if currentStep == .rounds {
                    // Final speichern und Wizard-Modus beenden
                    if let quiz = createdQuiz {
                        viewModel.saveQuizFinal(quiz)
                        viewModel.isWizardMode = false
                        viewModel.temporaryQuiz = nil
                    }
                    dismiss()
                } else if currentStep == .details {
                    // Temporäres Quiz erstellen (ohne Speichern)
                    viewModel.isWizardMode = true
                    let tempQuiz = viewModel.createTemporaryQuiz(name: quizName, venue: venue, date: date)
                    viewModel.temporaryQuiz = tempQuiz
                    createdQuiz = tempQuiz
                    withAnimation {
                        currentStep = .teams
                    }
                } else {
                    // Move to next step
                    withAnimation {
                        currentStep = WizardStep(rawValue: currentStep.rawValue + 1) ?? .teams
                    }
                }
            } label: {
                HStack {
                    Text(currentStep == .rounds ? "Fertig" : "Weiter")
                    Image(systemName: currentStep == .rounds ? "checkmark.circle.fill" : "chevron.right")
                }
                .frame(maxWidth: .infinity)
            }
            .keyboardShortcut(.return, modifiers: .command)
            .primaryGlassButton(size: .large)
            .disabled(!canProceed)
        }
        .padding(.horizontal, AppSpacing.xxl)
        .padding(.vertical, AppSpacing.sectionSpacing)
    }

    // MARK: - Helper Methods

    private var canProceed: Bool {
        switch currentStep {
        case .details:
            return !quizName.isEmpty
        case .teams:
            return true // Teams sind optional
        case .rounds:
            return true // Runden sind optional
        }
    }
}
