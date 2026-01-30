//
//  ExecutionAddTeamSheet.swift
//  PubRanker
//
//  Created for adding teams during live quiz execution
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct ExecutionAddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel

    @State private var selectedMode: TeamAddMode = .new
    @Query(sort: \Team.name) private var allTeams: [Team]

    // New team form states
    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil

    // Existing teams selection
    @State private var selectedTeamIDs: Set<UUID> = []
    @State private var searchText = ""

    enum TeamAddMode: String, CaseIterable, Identifiable {
        case new
        case existing

        var id: String { rawValue }

        func localizedTitle() -> String {
            switch self {
            case .new:
                return L10n.Execution.AddTeam.modeNew
            case .existing:
                return L10n.Execution.AddTeam.modeExisting
            }
        }
    }

    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]

    // Filter out teams already in the quiz
    private var availableTeams: [Team] {
        let existingTeamIDs = Set(quiz.safeTeams.map { $0.id })
        let filtered = allTeams.filter { !existingTeamIDs.contains($0.id) }

        if searchText.isEmpty {
            return filtered
        } else {
            return filtered.filter { team in
                team.name.localizedCaseInsensitiveContains(searchText) ||
                team.contactPerson.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Control
                Picker("Mode", selection: $selectedMode) {
                    ForEach(TeamAddMode.allCases) { mode in
                        Text(mode.localizedTitle()).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(AppSpacing.md)

                Divider()

                // Content based on mode
                switch selectedMode {
                case .new:
                    newTeamForm
                case .existing:
                    existingTeamsList
                }
            }
            .navigationTitle(L10n.Execution.AddTeam.title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Navigation.cancel) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    confirmButton
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 600, minHeight: 500)
        #endif
    }

    // MARK: - New Team Form

    private var newTeamForm: some View {
        Form {
            Section("Team-Informationen") {
                TextField("Team-Name", text: $teamName)
                    .textFieldStyle(.roundedBorder)

                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Team-Icon")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)

                    HStack(spacing: AppSpacing.sm) {
                        // Preview
                        Group {
                            if let imageData = imageData {
                                PlatformImage(data: imageData)
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 60, height: 60)
                                    .clipShape(Circle())
                                    .overlay {
                                        Circle()
                                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                    }
                                    .shadow(AppShadow.sm)
                            } else {
                                Circle()
                                    .fill(Color(hex: selectedColor) ?? Color.appPrimary)
                                    .frame(width: 60, height: 60)
                                    .overlay {
                                        Circle()
                                            .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                    }
                                    .shadow(AppShadow.sm)
                            }
                        }

                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Button {
                                showingImagePicker = true
                            } label: {
                                Label("Bild auswählen", systemImage: "photo")
                            }
                            .primaryGlassButton()

                            if imageData != nil {
                                Button {
                                    imageData = nil
                                } label: {
                                    Label("Bild entfernen", systemImage: "trash")
                                }
                                .accentGlassButton()
                            }
                        }
                    }

                    Divider()

                    // Color selection
                    Text("Farbe")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: AppSpacing.xs) {
                        ForEach(availableColors, id: \.self) { colorHex in
                            Circle()
                                .fill(Color(hex: colorHex) ?? Color.appPrimary)
                                .frame(width: 40, height: 40)
                                .overlay {
                                    if selectedColor == colorHex {
                                        Circle()
                                            .stroke(Color.appTextPrimary, lineWidth: 3)
                                    }
                                }
                                .shadow(AppShadow.sm)
                                .onTapGesture {
                                    selectedColor = colorHex
                                    imageData = nil // Remove image when color is selected
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
        }
        .formStyle(.grouped)
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    loadImage(from: url)
                }
            case .failure(let error):
                print("Fehler beim Auswählen des Bildes: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Existing Teams List

    private var existingTeamsList: some View {
        VStack(spacing: 0) {
            // Search bar
            #if os(macOS)
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.appTextSecondary)
                TextField("Team suchen...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.sm)
            .background(Color.appBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
            .padding(AppSpacing.md)
            #else
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.appTextSecondary)
                TextField("Team suchen...", text: $searchText)
                    .textFieldStyle(.plain)
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.sm)
            .background(Color.appBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
            .padding(AppSpacing.md)
            #endif

            Divider()

            // Teams list
            if availableTeams.isEmpty {
                ContentUnavailableView(
                    L10n.Execution.AddTeam.noAvailableTeams,
                    systemImage: "person.slash",
                    description: Text(L10n.Execution.AddTeam.noAvailableTeamsDescription)
                )
            } else {
                List(availableTeams) { team in
                    TeamCheckboxRow(
                        team: team,
                        isSelected: selectedTeamIDs.contains(team.id)
                    ) {
                        toggleTeamSelection(team)
                    }
                }
                .listStyle(.plain)
            }
        }
    }

    // MARK: - Confirm Button

    private var confirmButton: some View {
        Group {
            switch selectedMode {
            case .new:
                Button(L10n.Execution.AddTeam.createAndAdd) {
                    createAndAddNewTeam()
                    dismiss()
                }
                .disabled(teamName.isEmpty)

            case .existing:
                Button(L10n.Execution.AddTeam.addSelected(selectedTeamIDs.count)) {
                    addSelectedTeams()
                    dismiss()
                }
                .disabled(selectedTeamIDs.isEmpty)
            }
        }
    }

    // MARK: - Actions

    private func createAndAddNewTeam() {
        // Create new team
        let team = Team(name: teamName, color: selectedColor)
        team.contactPerson = contactPerson
        team.email = email
        team.imageData = imageData
        team.setConfirmed(for: quiz, isConfirmed: false)

        // Add to quiz
        viewModel.addTeam(
            to: quiz,
            name: teamName,
            color: selectedColor,
            contactPerson: contactPerson,
            email: email,
            isConfirmed: false,
            imageData: imageData
        )

        // Initialize scores for all rounds
        initializeScoresForAllRounds(team)
    }

    private func addSelectedTeams() {
        for teamId in selectedTeamIDs {
            if let team = allTeams.first(where: { $0.id == teamId }) {
                viewModel.addExistingTeam(team, to: quiz)
                initializeScoresForAllRounds(team)
            }
        }
    }

    private func initializeScoresForAllRounds(_ team: Team) {
        for round in quiz.sortedRounds {
            if !team.hasScore(for: round) {
                team.addScore(for: round, points: 0)
            }
        }
        viewModel.saveContext()
    }

    private func toggleTeamSelection(_ team: Team) {
        if selectedTeamIDs.contains(team.id) {
            selectedTeamIDs.remove(team.id)
        } else {
            selectedTeamIDs.insert(team.id)
        }
    }

    private func loadImage(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            print("⚠️ Fehler: Kein Zugriff auf die Datei")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️ Fehler: Datei existiert nicht")
            return
        }

        do {
            let imageData = try Data(contentsOf: url)

            #if os(macOS)
            guard NSImage(data: imageData) != nil else {
                print("⚠️ Fehler: Datei ist kein gültiges Bild")
                return
            }
            #else
            guard UIImage(data: imageData) != nil else {
                print("⚠️ Fehler: Datei ist kein gültiges Bild")
                return
            }
            #endif

            self.imageData = imageData
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }
}

// MARK: - Team Checkbox Row

struct TeamCheckboxRow: View {
    let team: Team
    let isSelected: Bool
    let action: () -> Void

    private var teamColor: Color {
        Color(hex: team.color) ?? Color.appPrimary
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                // Checkbox
                ZStack {
                    RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                        .fill(isSelected ? Color.appPrimary : Color.appBackgroundSecondary)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                        .stroke(isSelected ? Color.appPrimary : Color.appTextTertiary.opacity(0.3), lineWidth: 1.5)
                }

                // Team icon/color
                if let imageData = team.imageData {
                    PlatformImage(data: imageData)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .overlay {
                            Circle()
                                .stroke(teamColor.opacity(0.3), lineWidth: 2)
                        }
                } else {
                    Circle()
                        .fill(teamColor)
                        .frame(width: 40, height: 40)
                        .overlay {
                            Circle()
                                .stroke(teamColor.opacity(0.3), lineWidth: 2)
                        }
                }

                // Team info
                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(team.name)
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    if !team.contactPerson.isEmpty {
                        Text(team.contactPerson)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    if let quizzes = team.quizzes, !quizzes.isEmpty {
                        Text("\(quizzes.count) Quiz\(quizzes.count != 1 ? "zes" : "")")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }

                Spacer()
            }
            .padding(AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .fill(isSelected ? Color.appPrimary.opacity(0.05) : Color.appBackgroundSecondary)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .stroke(isSelected ? teamColor.opacity(0.3) : Color.clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }
}
