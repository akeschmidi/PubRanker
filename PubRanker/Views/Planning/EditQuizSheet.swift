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

    @State private var quizName: String = ""
    @State private var venueName: String = ""
    @State private var quizDate: Date = Date()
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            detailsView
                .navigationTitle("Quiz bearbeiten")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Schliessen") {
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
                    Text("Möchtest du das Quiz '\(quiz.name)' wirklich löschen?")
                }
        }
        .frame(minWidth: 600, minHeight: 500)
        .onAppear {
            quizName = quiz.name
            venueName = quiz.venue
            quizDate = quiz.date
        }
    }
    
    private var detailsView: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Quiz-Details Card
                AppCard(style: .glassmorphism) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Header
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color.appPrimary)
                            Text("Quiz-Details")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Quiz-Name
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Label("Quiz-Name", systemImage: "textformat")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            
                            TextField("Name eingeben", text: $quizName)
                                .textFieldStyle(.roundedBorder)
                                .font(.title3)
                        }
                        
                        // Veranstaltungsort
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Label("Veranstaltungsort", systemImage: "mappin.circle")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            
                            TextField("Ort eingeben", text: $venueName)
                                .textFieldStyle(.roundedBorder)
                                .font(.body)
                        }
                        
                        // Datum & Uhrzeit
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Label("Datum & Uhrzeit", systemImage: "calendar")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                            
                            DatePicker("", 
                                      selection: $quizDate,
                                      displayedComponents: [.date, .hourAndMinute])
                                .labelsHidden()
                                .datePickerStyle(.compact)
                        }
                    }
                }
                
                // Statistiken Card
                AppCard(style: .glassmorphism) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Header
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .font(.title2)
                                .foregroundStyle(Color.appSuccess)
                            Text("Statistiken")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        
                        Divider()
                        
                        // Stats Grid
                        HStack(spacing: AppSpacing.xs) {
                            statBox(
                                title: "Teams",
                                value: "\(quiz.safeTeams.count)",
                                icon: "person.3.fill",
                                color: Color.appPrimary
                            )
                            
                            statBox(
                                title: "Runden",
                                value: "\(quiz.safeRounds.count)",
                                icon: "list.number",
                                color: Color.appSuccess
                            )
                            
                            statBox(
                                title: "Max. Punkte",
                                value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })",
                                icon: "star.fill",
                                color: Color.appAccent
                            )
                        }
                    }
                }
                
                // Status Card
                AppCard(style: .glassmorphism) {
                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Header
                        HStack {
                            Image(systemName: "flag.fill")
                                .font(.title2)
                                .foregroundStyle(Color.appSecondary)
                            Text("Status")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                            Spacer()
                        }
                        
                        Divider()
                        
                        HStack(spacing: AppSpacing.md) {
                            statusIndicator(
                                title: quiz.isActive ? "Aktiv" : "Geplant",
                                icon: quiz.isActive ? "play.circle.fill" : "calendar",
                                color: quiz.isActive ? Color.appSuccess : Color.appTextSecondary
                            )
                            
                            statusIndicator(
                                title: quiz.isCompleted ? "Abgeschlossen" : "Vorbereitung",
                                icon: quiz.isCompleted ? "checkmark.circle.fill" : "hourglass.circle",
                                color: quiz.isCompleted ? Color.appPrimary : Color.appAccent
                            )
                        }
                    }
                }
            }
            .padding(AppSpacing.screenPadding)
        }
    }
    
    private func statBox(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            Image(systemName: icon)
                .font(.title)
                .foregroundStyle(color)
                .shadow(AppShadow.sm)

            Text(value)
                .font(.system(size: AppSpacing.xl, weight: .bold))
                .foregroundStyle(color)
                .monospacedDigit()

            Text(title)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.sm)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
    }
    
    private func statusIndicator(title: String, icon: String, color: Color) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: AppSpacing.xl, height: AppSpacing.xl)
                .background(color.opacity(0.2))
                .clipShape(Circle())
                .shadow(AppShadow.sm)
            
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Text("Status")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
            }
            
            Spacer()
        }
        .padding(AppSpacing.xs)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
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
                        "Keine Teams verfügbar",
                        systemImage: "person.3.slash",
                        description: Text("Alle Teams sind bereits diesem Quiz zugeordnet")
                    )
                } else {
                    List(filteredTeams, selection: $selectedTeams) { team in
                        HStack(spacing: AppSpacing.xs) {
                            TeamIconView(team: team, size: AppSpacing.xl)

                            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                                Text(team.name)
                                    .font(.body)

                                if !team.contactPerson.isEmpty {
                                    HStack(spacing: AppSpacing.xxxs) {
                                        Image(systemName: "person.fill")
                                            .font(.subheadline)
                                        Text(team.contactPerson)
                                            .font(.subheadline)
                                    }
                                    .foregroundStyle(Color.appTextSecondary)
                                }

                                if team.isConfirmed(for: quiz) {
                                    HStack(spacing: AppSpacing.xxxs) {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color.appSuccess)
                                            .font(.body)
                                        Text("Bestätigt")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.appSuccess)
                                    }
                                }
                            }

                            Spacer()

                            if selectedTeams.contains(team.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.appPrimary)
                                    .font(.title3)
                            }
                        }
                        .padding(.vertical, AppSpacing.xxxs)
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
                    Button("\(selectedTeams.count) hinzufügen") {
                        addSelectedTeams()
                        dismiss()
                    }
                    .primaryGradientButton()
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

