//
//  GlobalEditTeamSheet.swift
//  PubRanker
//
//  Created on 23.11.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#else
import UIKit
#endif

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
    @State private var showingImagePicker = false

    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Team-Name", text: $teamName)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)

                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "photo.circle.fill")
                                .font(.title3)
                                .foregroundStyle(Color.appPrimary)
                            Text("Team-Icon")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }

                        HStack(spacing: AppSpacing.md) {
                            // Aktuelles Icon anzeigen
                            TeamIconView(team: team, size: 80)
                                .shadow(color: (Color(hex: team.color) ?? Color.appPrimary).opacity(0.3), radius: 6, y: 3)

                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("Bild auswählen", systemImage: "photo")
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity)
                                }
                                .primaryGlassButton(size: .small)

                                if team.imageData != nil {
                                    Button {
                                        team.imageData = nil
                                    } label: {
                                        Label("Bild entfernen", systemImage: "trash")
                                            .font(.subheadline)
                                            .frame(maxWidth: .infinity)
                                    }
                                    .destructiveGlassButton(size: .small)
                                }
                            }
                            .frame(maxWidth: 180)
                        }
                        .padding(AppSpacing.sm)
                        .background(Color.appPrimary.opacity(0.05))
                        .cornerRadius(AppCornerRadius.md)
                    }
                        
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "paintpalette.fill")
                                .font(.title3)
                                .foregroundStyle(Color.appPrimary)
                            Text("Team-Farbe")
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }

                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: AppSpacing.sm) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? Color.appPrimary)
                                    .frame(width: 50, height: 50)
                                    .overlay {
                                        if selectedColor == colorHex {
                                            Circle()
                                                .stroke(Color.appTextPrimary, lineWidth: 4)
                                            Circle()
                                                .stroke(Color.white, lineWidth: 2)
                                                .padding(2)
                                        }
                                    }
                                    .shadow(color: (Color(hex: colorHex) ?? Color.appPrimary).opacity(0.4), radius: 4, y: 2)
                                    .onTapGesture {
                                        selectedColor = colorHex
                                        team.imageData = nil
                                    }
                            }
                        }
                    }
                } header: {
                    Label("Team-Informationen", systemImage: "person.3.fill")
                        .font(.headline)
                        .foregroundStyle(Color.appPrimary)
                }

                Section {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "person.fill")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                        TextField("Kontaktperson (optional)", text: $contactPerson)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.name)
                    }

                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "envelope.fill")
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                        TextField("E-Mail (optional)", text: $email)
                            .textFieldStyle(.roundedBorder)
                            .textContentType(.emailAddress)
                    }
                } header: {
                    Label("Kontaktinformationen", systemImage: "person.text.rectangle.fill")
                        .font(.headline)
                        .foregroundStyle(Color.appPrimary)
                }

                Section {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        HStack {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "link.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(Color.appSecondary)
                                Text("Quiz-Zuordnung")
                                    .font(.headline)
                                    .foregroundStyle(Color.appTextPrimary)
                            }
                            Spacer()
                            HStack(spacing: AppSpacing.xxxs) {
                                Text("\(selectedQuizIds.count)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.appSecondary)
                                    .monospacedDigit()
                                Text("ausgewählt")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                        }

                        if plannedQuizzes.isEmpty {
                            HStack {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .foregroundStyle(Color.appTextSecondary)
                                    .font(.body)
                                Text("Keine geplanten Quizzes verfügbar")
                                    .font(.body)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(AppSpacing.xs)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.appBackgroundSecondary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                        } else {
                            VStack(spacing: AppSpacing.xxs) {
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
        .frame(minWidth: 700, minHeight: 800)
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
    
    private func loadImage(from url: URL) {
        // Security-Scoped Resource Zugriff anfordern
        // fileImporter gibt bereits Security-Scoped URLs zurück, aber wir müssen
        // explizit den Zugriff anfordern, um die Datei lesen zu können
        guard url.startAccessingSecurityScopedResource() else {
            print("⚠️ Fehler: Kein Zugriff auf die Datei - Security-Scoped Resource konnte nicht gestartet werden")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        // Prüfen ob die Datei existiert und lesbar ist
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("⚠️ Fehler: Datei existiert nicht: \(url.path)")
            return
        }
        
        // Bild laden und validieren
        do {
            let imageData = try Data(contentsOf: url)
            
            // Prüfen ob es tatsächlich ein Bild ist
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
            
            // Bild speichern
            team.imageData = imageData
            print("✅ Bild erfolgreich geladen: \(url.lastPathComponent)")
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }

    private func toggleQuiz(_ quiz: Quiz) {
        if selectedQuizIds.contains(quiz.id) {
            selectedQuizIds.remove(quiz.id)
        } else {
            selectedQuizIds.insert(quiz.id)
        }
    }
}





