//
//  EditableTeamRow.swift
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

struct EditableTeamRow: View {
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var contactPerson: String = ""
    @State private var email: String = ""
    @State private var isConfirmed: Bool = false
    @State private var showingColorPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showingImagePicker = false
    
    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Hauptinhalt
            HStack(spacing: AppSpacing.sm) {
                // Team-Icon (Bild oder Farbe)
                TeamIconView(team: team, size: 40)
                .helpText(isEditing ? "Team-Icon ändern" : "Team-Icon")
                .onTapGesture {
                    if isEditing {
                        showingColorPicker.toggle()
                    }
                }
                .popover(isPresented: $showingColorPicker) {
                    VStack(spacing: AppSpacing.md) {
                        Text("Team-Icon wählen")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        
                        // Bildauswahl
                        Button {
                            showingImagePicker = true
                            showingColorPicker = false
                        } label: {
                            Label("Bild auswählen", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, AppSpacing.xxs)
                        }
                        .primaryGradientButton()
                        
                        // Bild entfernen, wenn vorhanden
                        if team.imageData != nil {
                            Button {
                                team.imageData = nil
                                showingColorPicker = false
                            } label: {
                                Label("Bild entfernen", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, AppSpacing.xxs)
                            }
                            .accentGradientButton()
                        }
                        
                        Divider()
                        
                        // Farbauswahl
                        Text("Farbe wählen")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: AppSpacing.xs), count: 6), spacing: AppSpacing.xs) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? Color.appPrimary)
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        if team.color == colorHex {
                                            Circle()
                                                .stroke(Color.appTextPrimary, lineWidth: AppSpacing.xxxs)
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                                .font(.title3)
                                                .bold()
                                        }
                                    }
                                    .shadow(AppShadow.sm)
                                    .onTapGesture {
                                        team.color = colorHex
                                        team.imageData = nil // Bild entfernen wenn Farbe gewählt wird
                                        showingColorPicker = false
                                    }
                            }
                        }
                    }
                    .padding(AppSpacing.md)
                }
                
                // Team-Informationen
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    if isEditing {
                        VStack(alignment: .leading, spacing: AppSpacing.xs) {
                            // Team Name
                            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                                Text("Team-Name")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .bold()
                                TextField("Team-Name", text: $editedName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Divider()
                            
                            // Team Details
                            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                                Text("Kontaktinformationen")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .bold()
                                
                                TextField("Kontaktperson", text: $contactPerson)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("E-Mail", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                
                                Toggle("Bestätigt", isOn: $isConfirmed)
                                    #if os(macOS)
                                    .toggleStyle(.checkbox)
                                    #endif
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            // Team Name
                            Text(team.name)
                                .font(.title3)
                                .bold()
                                .foregroundStyle(Color.appTextPrimary)
                            
                            // Details
                            if !team.contactPerson.isEmpty || !team.email.isEmpty || team.isConfirmed(for: quiz) {
                                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                                    if !team.contactPerson.isEmpty {
                                        HStack(spacing: AppSpacing.xxxs) {
                                            Image(systemName: "person.fill")
                                                .font(.caption)
                                                .foregroundStyle(Color.appTextSecondary)
                                                .frame(width: AppSpacing.sm)
                                            Text(team.contactPerson)
                                                .font(.subheadline)
                                                .foregroundStyle(Color.appTextSecondary)
                                        }
                                    }

                                    if !team.email.isEmpty {
                                        HStack(spacing: AppSpacing.xxxs) {
                                            Image(systemName: "envelope.fill")
                                                .font(.caption)
                                                .foregroundStyle(Color.appTextSecondary)
                                                .frame(width: AppSpacing.sm)
                                            Text(team.email)
                                                .font(.subheadline)
                                                .foregroundStyle(Color.appTextSecondary)
                                        }
                                    }
                                    
                                    if team.isConfirmed(for: quiz) {
                                        HStack(spacing: AppSpacing.xxxs) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.appSuccess)
                                                .font(.caption)
                                            Text("Bestätigt")
                                                .font(.subheadline)
                                                .foregroundStyle(Color.appSuccess)
                                                .bold()
                                        }
                                        .padding(.top, AppSpacing.xxxs)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons - Größer und besser sichtbar
                HStack(spacing: AppSpacing.xs) {
                    if isEditing {
                        // Speichern Button (nur im Bearbeitungsmodus)
                        Button {
                            saveChanges()
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.body)
                                Text("Speichern")
                                    .font(.body)
                            }
                        }
                        .successGradientButton()
                        .helpText("Änderungen speichern")
                        
                        // Abbrechen Button (nur im Bearbeitungsmodus)
                        Button {
                            isEditing = false
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.body)
                                Text("Abbrechen")
                                    .font(.body)
                            }
                        }
                        .secondaryGradientButton()
                        .helpText("Bearbeitung abbrechen")
                    } else {
                        // Bearbeiten Button (immer sichtbar wenn nicht im Bearbeitungsmodus)
                        Button {
                            editedName = team.name
                            contactPerson = team.contactPerson
                            email = team.email
                            isConfirmed = team.isConfirmed(for: quiz)
                            isEditing = true
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "pencil")
                                    .font(.body)
                                Text("Bearbeiten")
                                    .font(.body)
                            }
                        }
                        .primaryGradientButton()
                        .helpText("Team bearbeiten")
                        
                        // Löschen Button - Größer und prominenter
                        Button {
                            showingDeleteConfirmation = true
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "trash")
                                    .font(.body)
                            }
                        }
                        .accentGradientButton()
                        .helpText("Team entfernen")
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, isEditing ? AppSpacing.md : AppSpacing.sm)
        }
        .appCard(style: .default, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: team.color)?.opacity(0.4) ?? Color.appPrimary.opacity(0.4),
                            Color(hex: team.color)?.opacity(0.2) ?? Color.appPrimary.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: AppSpacing.xxxs
                )
        }
        .alert("Team entfernen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {}
            Button("Entfernen", role: .destructive) {
                viewModel.deleteTeam(team, from: quiz)
            }
        } message: {
            Text("'\(team.name)' wird aus diesem Quiz entfernt, bleibt aber im globalen Team-Manager erhalten.")
        }
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
    
    private func saveChanges() {
        let trimmedName = editedName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            viewModel.updateTeamName(team, newName: trimmedName)
        }
        viewModel.updateTeamDetails(team, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed)
        isEditing = false
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
}





