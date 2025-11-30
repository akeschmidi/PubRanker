//
//  EditQuizSheet.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct EditQuizSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    
    @State private var quizName: String = ""
    @State private var venueName: String = ""
    @State private var quizDate: Date = Date()
    @State private var showingDeleteConfirmation = false
    @State private var selectedTab: EditTab = .details
    @State private var showingGlobalTeamPicker = false
    
    enum EditTab: String, CaseIterable, Identifiable {
        case details = "Details"
        case teams = "Teams"
        case rounds = "Runden"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .details: return "info.circle.fill"
            case .teams: return "person.3.fill"
            case .rounds: return "list.number"
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Tab Picker
                Picker("Bereich", selection: $selectedTab) {
                    ForEach(EditTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Tab Content
                Group {
                    switch selectedTab {
                    case .details:
                        detailsView
                    case .teams:
                        teamsEditView
                    case .rounds:
                        roundsEditView
                    }
                }
            }
            .navigationTitle("Quiz bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        saveChanges()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Löschen", systemImage: "trash")
                    }
                }
            }
            .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    deleteQuiz()
                }
            } message: {
                Text("Möchtest du '\(quiz.name)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
            .sheet(isPresented: $showingGlobalTeamPicker) {
                GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams(for: quiz), modelContext: modelContext)
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .onAppear {
            quizName = quiz.name
            venueName = quiz.venue
            quizDate = quiz.date
        }
    }
    
    private var detailsView: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quiz-Details Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        Text("Quiz-Details")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Quiz-Name
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Quiz-Name", systemImage: "textformat")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("Name eingeben", text: $quizName)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                    }
                    
                    // Veranstaltungsort
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Veranstaltungsort", systemImage: "mappin.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        TextField("Ort eingeben", text: $venueName)
                            .textFieldStyle(.roundedBorder)
                            .font(.body)
                    }
                    
                    // Datum & Uhrzeit
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Datum & Uhrzeit", systemImage: "calendar")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        DatePicker("", 
                                  selection: $quizDate,
                                  displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .datePickerStyle(.compact)
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                }
                
                // Statistiken Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                        Text("Statistiken")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    // Stats Grid
                    HStack(spacing: 12) {
                        statBox(
                            title: "Teams",
                            value: "\(quiz.safeTeams.count)",
                            icon: "person.3.fill",
                            color: .blue
                        )
                        
                        statBox(
                            title: "Runden",
                            value: "\(quiz.safeRounds.count)",
                            icon: "list.number",
                            color: .green
                        )
                        
                        statBox(
                            title: "Max. Punkte",
                            value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })",
                            icon: "star.fill",
                            color: .orange
                        )
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.green.opacity(0.3), lineWidth: 2)
                }
                
                // Status Card
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    HStack {
                        Image(systemName: "flag.fill")
                            .font(.title2)
                            .foregroundStyle(.purple)
                        Text("Status")
                            .font(.headline)
                        Spacer()
                    }
                    
                    Divider()
                    
                    HStack(spacing: 20) {
                        statusIndicator(
                            title: quiz.isActive ? "Aktiv" : "Geplant",
                            icon: quiz.isActive ? "play.circle.fill" : "calendar",
                            color: quiz.isActive ? .green : .gray
                        )
                        
                        statusIndicator(
                            title: quiz.isCompleted ? "Abgeschlossen" : "Vorbereitung",
                            icon: quiz.isCompleted ? "checkmark.circle.fill" : "hourglass.circle",
                            color: quiz.isCompleted ? .blue : .orange
                        )
                    }
                }
                .padding(20)
                .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.3), lineWidth: 2)
                }
            }
            .padding(20)
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .monospacedDigit()
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func statusIndicator(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text("Status")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(12)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var teamsEditView: some View {
        let availableTeams = availableGlobalTeams(for: quiz)
        
        return VStack(spacing: 0) {
            // Header mit Add Button
            HStack {
                Text("Teams verwalten")
                    .font(.headline)
                
                Spacer()
                
                Menu {
                    Button {
                        addNewTeam()
                    } label: {
                        Label("Neues Team erstellen", systemImage: "plus.circle")
                    }
                    
                    if !availableTeams.isEmpty {
                        Divider()
                        
                        Button {
                            showingGlobalTeamPicker = true
                        } label: {
                            Label("Aus vorhandenen wählen (\(availableTeams.count))", systemImage: "square.stack.3d.up.fill")
                        }
                    }
                } label: {
                    Label("Team hinzufügen", systemImage: "plus.circle.fill")
                }
                .buttonStyle(.borderedProminent)
                .menuStyle(.button)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            if quiz.safeTeams.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("Keine Teams")
                        .font(.title2)
                        .bold()

                    Text("Füge Teams hinzu, um mit dem Quiz zu starten")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    VStack(spacing: 12) {
                        Button {
                            addNewTeam()
                        } label: {
                            Label("Neues Team hinzufügen", systemImage: "plus.circle.fill")
                                .font(.headline)
                                .frame(maxWidth: 400)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)

                        Button {
                            if !availableTeams.isEmpty {
                                showingGlobalTeamPicker = true
                            }
                        } label: {
                            Label(availableTeams.isEmpty ? "Keine vorhandenen Teams verfügbar" : "Aus vorhandenen wählen (\(availableTeams.count))", systemImage: "square.stack.3d.up.fill")
                                .font(.headline)
                                .frame(maxWidth: 400)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.large)
                        .disabled(availableTeams.isEmpty)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(quiz.safeTeams) { team in
                        EditableTeamRow(team: team, quiz: quiz, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            viewModel.deleteTeam(quiz.safeTeams[index], from: quiz)
                        }
                    }
                }
            }
        }
    }
    
    private func availableGlobalTeams(for quiz: Quiz) -> [Team] {
        return allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }
    
    private func addNewTeam() {
        let teamNumber = quiz.safeTeams.count + 1
        let colors = ["#007AFF", "#FF3B30", "#34C759", "#FF9500", "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00"]
        let colorIndex = (teamNumber - 1) % colors.count
        
        viewModel.addTeam(to: quiz, name: "Team \(teamNumber)", color: colors[colorIndex])
    }
    
    private var roundsEditView: some View {
        VStack(spacing: 0) {
            if quiz.safeRounds.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "list.number")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)

                    Text("Keine Runden")
                        .font(.title2)
                        .bold()

                    Text("Füge Runden hinzu, um Punkte zu vergeben")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)

                    Button {
                        addNewRound()
                    } label: {
                        Label("Erste Runde hinzufügen", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(quiz.sortedRounds) { round in
                        EditableRoundRow(round: round, quiz: quiz, viewModel: viewModel)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let round = quiz.sortedRounds[index]
                            viewModel.deleteRound(round, from: quiz)
                        }
                    }
                }

                // Action Button am unteren Rand
                Divider()

                HStack {
                    Button {
                        addNewRound()
                    } label: {
                        Label("Runde hinzufügen", systemImage: "plus.circle.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
            }
        }
    }
    
    private func addNewRound() {
        let roundNumber = quiz.safeRounds.count + 1
        viewModel.addRound(to: quiz, name: "Runde \(roundNumber)", maxPoints: 10)
    }
    
    private func saveChanges() {
        quiz.name = quizName.trimmingCharacters(in: .whitespacesAndNewlines)
        quiz.venue = venueName.trimmingCharacters(in: .whitespacesAndNewlines)
        quiz.date = quizDate
    }
    
    private func deleteQuiz() {
        viewModel.deleteQuiz(quiz)
        dismiss()
    }
}

// MARK: - Global Team Picker Sheet
struct GlobalTeamPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    let availableTeams: [Team]
    let modelContext: ModelContext

    @State private var searchText = ""
    @State private var selectedTeams: Set<UUID> = []

    var filteredTeams: [Team] {
        let teams: [Team]
        if searchText.isEmpty {
            teams = availableTeams
        } else {
            teams = availableTeams.filter { team in
                team.name.localizedCaseInsensitiveContains(searchText) ||
                team.contactPerson.localizedCaseInsensitiveContains(searchText)
            }
        }
        return teams.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if availableTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine verfügbaren Teams",
                        systemImage: "person.3.slash",
                        description: Text("Alle Teams sind bereits anderen Quizzes zugeordnet")
                    )
                } else {
                    List(filteredTeams, selection: $selectedTeams) { team in
                        HStack(spacing: 12) {
                            TeamIconView(team: team, size: 32)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(team.name)
                                    .font(.body)

                                if !team.contactPerson.isEmpty {
                                    HStack(spacing: 6) {
                                        Image(systemName: "person.fill")
                                            .font(.subheadline)
                                        Text(team.contactPerson)
                                            .font(.subheadline)
                                    }
                                    .foregroundStyle(.secondary)
                                }

                                if team.isConfirmed {
                                    HStack(spacing: 4) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.green)
                                            .font(.body)
                                        Text("Bestätigt")
                                            .font(.subheadline)
                                            .foregroundStyle(.green)
                                    }
                                }
                            }

                            Spacer()

                            if selectedTeams.contains(team.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, 4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTeams.contains(team.id) {
                                selectedTeams.remove(team.id)
                            } else {
                                selectedTeams.insert(team.id)
                            }
                        }
                    }
                    .searchable(text: $searchText, prompt: "Teams durchsuchen...")
                }
            }
            .navigationTitle("Teams hinzufügen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Hinzufügen (\(selectedTeams.count))") {
                        addSelectedTeams()
                        dismiss()
                    }
                    .disabled(selectedTeams.isEmpty)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 500)
    }

    private func addSelectedTeams() {
        for teamId in selectedTeams {
            if let team = availableTeams.first(where: { $0.id == teamId }) {
                // Add quiz to team's quizzes
                if team.quizzes == nil {
                    team.quizzes = []
                }
                if !team.quizzes!.contains(where: { $0.id == quiz.id }) {
                    team.quizzes!.append(quiz)
                }

                // Add team to quiz's teams
                if quiz.teams == nil {
                    quiz.teams = []
                }
                if !quiz.teams!.contains(where: { $0.id == team.id }) {
                    quiz.teams!.append(team)
                }
            }
        }
        try? modelContext.save()
    }
}

