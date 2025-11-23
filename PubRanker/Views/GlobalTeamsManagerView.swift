//
//  GlobalTeamsManagerView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct GlobalTeamsManagerView: View {
    @Bindable var viewModel: QuizViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]

    @State private var showingAddTeamSheet = false
    @State private var searchText = ""
    @State private var selectedTeam: Team?
    @State private var showingDeleteAlert = false

    var filteredTeams: [Team] {
        if searchText.isEmpty {
            return allTeams
        }
        return allTeams.filter { team in
            team.name.localizedCaseInsensitiveContains(searchText) ||
            team.contactPerson.localizedCaseInsensitiveContains(searchText) ||
            team.email.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()

            if allTeams.isEmpty {
                emptyStateView
            } else {
                VStack(spacing: 0) {
                    searchAndStatsBar
                    Divider()

                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
                        ], spacing: 20) {
                            ForEach(filteredTeams) { team in
                                TeamCard(team: team, viewModel: viewModel, onDelete: {
                                    selectedTeam = team
                                    showingDeleteAlert = true
                                })
                            }
                        }
                        .padding(24)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddTeamSheet) {
            GlobalAddTeamSheet(viewModel: viewModel, modelContext: modelContext)
        }
        .alert("Team löschen", isPresented: $showingDeleteAlert) {
            Button("Abbrechen", role: .cancel) {
                selectedTeam = nil
            }
            Button("Löschen", role: .destructive) {
                if let team = selectedTeam {
                    deleteTeam(team)
                }
            }
        } message: {
            if let team = selectedTeam {
                Text("Möchten Sie das Team '\(team.name)' wirklich löschen?")
            }
        }
    }

    private var headerView: some View {
        HStack(spacing: 20) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.2), .cyan.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: "person.3.fill")
                        .font(.title2)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Team-Manager")
                        .font(.title2)
                        .bold()
                    Text("Teams verwalten und organisieren")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button {
                showingAddTeamSheet = true
            } label: {
                Label("Neues Team", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .windowBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var searchAndStatsBar: some View {
        HStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Teams durchsuchen...", text: $searchText)
                    .textFieldStyle(.plain)

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(10)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .frame(maxWidth: 400)

            Spacer()

            HStack(spacing: 24) {
                StatBadge(
                    icon: "person.3.fill",
                    label: "Gesamt",
                    value: "\(allTeams.count)",
                    color: .blue
                )

                StatBadge(
                    icon: "checkmark.circle.fill",
                    label: "Bestätigt",
                    value: "\(allTeams.filter { $0.isConfirmed }.count)",
                    color: .green
                )

                StatBadge(
                    icon: "link.circle.fill",
                    label: "Zugeordnet",
                    value: "\(allTeams.filter { !($0.quizzes?.isEmpty ?? true) }.count)",
                    color: .purple
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color(nsColor: .windowBackgroundColor))
    }

    private var emptyStateView: some View {
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .cyan.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 12) {
                    Text("Keine Teams vorhanden")
                        .font(.title)
                        .bold()

                    Text("Erstellen Sie Ihr erstes Team, um es später einfach zu Quizzes hinzuzufügen")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 450)
                }
            }

            Button {
                showingAddTeamSheet = true
            } label: {
                Label("Erstes Team erstellen", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func deleteTeam(_ team: Team) {
        modelContext.delete(team)
        try? modelContext.save()
        selectedTeam = nil
    }
}

// MARK: - Team Card
struct TeamCard: View {
    @Bindable var team: Team
    @Bindable var viewModel: QuizViewModel
    let onDelete: () -> Void

    @State private var showingEditSheet = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: team.color) ?? .blue)
                    .frame(width: 20, height: 20)
                    .shadow(color: (Color(hex: team.color) ?? .blue).opacity(0.3), radius: 3)

                Text(team.name)
                    .font(.headline)
                    .lineLimit(1)

                Spacer()

                if team.isConfirmed {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                        .help("Bestätigt")
                }
            }
            .padding(16)
            .background(
                LinearGradient(
                    colors: [
                        (Color(hex: team.color) ?? .blue).opacity(0.1),
                        (Color(hex: team.color) ?? .blue).opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )

            Divider()

            VStack(alignment: .leading, spacing: 12) {
                if !team.contactPerson.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "person.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(team.contactPerson)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                if !team.email.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "envelope.fill")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text(team.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }

                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: 8) {
                        Image(systemName: "link.circle.fill")
                            .foregroundStyle(.purple)
                            .frame(width: 20)
                        if quizzes.count == 1 {
                            Text("Zugeordnet zu: \(quizzes[0].name)")
                                .font(.caption)
                                .foregroundStyle(.purple)
                                .bold()
                        } else {
                            Text("Zugeordnet zu \(quizzes.count) Quizzes")
                                .font(.caption)
                                .foregroundStyle(.purple)
                                .bold()
                        }
                    }
                    .padding(.top, 4)
                } else {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.dotted")
                            .foregroundStyle(.secondary)
                            .frame(width: 20)
                        Text("Nicht zugeordnet")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 4)
                }

                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)
                    Text("Erstellt: \(team.createdAt.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            Divider()

            HStack(spacing: 8) {
                Button {
                    showingEditSheet = true
                } label: {
                    Label("Bearbeiten", systemImage: "pencil")
                        .font(.caption)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Spacer()

                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Image(systemName: "trash")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.red)
            }
            .padding(12)
            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingEditSheet) {
            GlobalEditTeamSheet(team: team, viewModel: viewModel)
        }
    }
}

// MARK: - Stat Badge
struct StatBadge: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(color)

            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(.headline)
                    .monospacedDigit()
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Global Add Team Sheet
struct GlobalAddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: QuizViewModel
    let modelContext: ModelContext

    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false

    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Team-Informationen") {
                    TextField("Team-Name", text: $teamName)
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 12) {
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

                Section("Kontaktinformationen") {
                    TextField("Kontaktperson (optional)", text: $contactPerson)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)

                    TextField("E-Mail (optional)", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                }

                Section("Status") {
                    Toggle("Team ist bestätigt", isOn: $isConfirmed)
                        .help("Team hat die Teilnahme bestätigt")
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Neues Team erstellen")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Erstellen") {
                        createTeam()
                        dismiss()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .frame(minWidth: 500, minHeight: 450)
    }

    private func createTeam() {
        let team = Team(name: teamName, color: selectedColor)
        team.contactPerson = contactPerson
        team.email = email
        team.isConfirmed = isConfirmed

        modelContext.insert(team)
        try? modelContext.save()
    }
}

// MARK: - Global Edit Team Sheet
struct GlobalEditTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var team: Team
    @Bindable var viewModel: QuizViewModel
    @Query(filter: #Predicate<Quiz> { !$0.isActive && !$0.isCompleted }, sort: \Quiz.date, order: .reverse)
    private var plannedQuizzes: [Quiz]

    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false
    @State private var selectedQuizIds: Set<UUID> = []

    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section("Team-Informationen") {
                    TextField("Team-Name", text: $teamName)
                        .textFieldStyle(.roundedBorder)

                    VStack(alignment: .leading, spacing: 12) {
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

                Section("Kontaktinformationen") {
                    TextField("Kontaktperson (optional)", text: $contactPerson)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)

                    TextField("E-Mail (optional)", text: $email)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.emailAddress)
                }

                Section("Status") {
                    Toggle("Team ist bestätigt", isOn: $isConfirmed)
                        .help("Team hat die Teilnahme bestätigt")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Quiz-Zuordnung")
                                .font(.headline)
                            Spacer()
                            Text("\(selectedQuizIds.count) ausgewählt")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if plannedQuizzes.isEmpty {
                            HStack {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .foregroundStyle(.secondary)
                                Text("Keine geplanten Quizzes verfügbar")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        } else {
                            VStack(spacing: 8) {
                                ForEach(plannedQuizzes) { quiz in
                                    QuizCheckboxRow(
                                        quiz: quiz,
                                        isSelected: selectedQuizIds.contains(quiz.id)
                                    ) {
                                        toggleQuiz(quiz)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Team bearbeiten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Speichern") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(teamName.isEmpty)
                }
            }
        }
        .frame(minWidth: 550, minHeight: 600)
        .onAppear {
            teamName = team.name
            selectedColor = team.color
            contactPerson = team.contactPerson
            email = team.email
            isConfirmed = team.isConfirmed
            selectedQuizIds = Set(team.quizzes?.map { $0.id } ?? [])
        }
    }

    private func saveChanges() {
        team.name = teamName
        team.color = selectedColor
        team.contactPerson = contactPerson
        team.email = email
        team.isConfirmed = isConfirmed

        // Update quiz assignments
        let currentQuizIds = Set(team.quizzes?.map { $0.id } ?? [])

        // Remove from quizzes that are no longer selected
        for quizId in currentQuizIds {
            if !selectedQuizIds.contains(quizId), let quiz = team.quizzes?.first(where: { $0.id == quizId }) {
                if let index = quiz.teams?.firstIndex(where: { $0.id == team.id }) {
                    quiz.teams?.remove(at: index)
                }
                if let teamIndex = team.quizzes?.firstIndex(where: { $0.id == quizId }) {
                    team.quizzes?.remove(at: teamIndex)
                }
            }
        }

        // Add to newly selected quizzes
        for quizId in selectedQuizIds {
            if !currentQuizIds.contains(quizId), let quiz = plannedQuizzes.first(where: { $0.id == quizId }) {
                if team.quizzes == nil {
                    team.quizzes = []
                }
                if !team.quizzes!.contains(where: { $0.id == quizId }) {
                    team.quizzes!.append(quiz)
                }
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

    private func toggleQuiz(_ quiz: Quiz) {
        if selectedQuizIds.contains(quiz.id) {
            selectedQuizIds.remove(quiz.id)
        } else {
            selectedQuizIds.insert(quiz.id)
        }
    }
}

// MARK: - Quiz Checkbox Row
struct QuizCheckboxRow: View {
    let quiz: Quiz
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.blue : Color.secondary.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isSelected ? Color.blue.opacity(0.1) : Color.clear)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(.blue)
                    }
                }

                // Quiz Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.caption)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                            .font(.caption2)
                        Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                            .font(.caption2)
                    }
                    .foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color(nsColor: .controlBackgroundColor))
            )
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.blue.opacity(0.3) : Color.clear, lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
    }
}
