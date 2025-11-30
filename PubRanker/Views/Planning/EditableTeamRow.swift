//
//  EditableTeamRow.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

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
            HStack(spacing: 16) {
                // Team-Icon (Bild oder Farbe)
                TeamIconView(team: team, size: 40)
                .help(isEditing ? "Bild oder Farbe ändern" : "Team-Icon")
                .onTapGesture {
                    if isEditing {
                        showingColorPicker.toggle()
                    }
                }
                .popover(isPresented: $showingColorPicker) {
                    VStack(spacing: 20) {
                        Text("Team-Icon wählen")
                            .font(.headline)
                        
                        // Bildauswahl
                        Button {
                            showingImagePicker = true
                            showingColorPicker = false
                        } label: {
                            Label("Bild auswählen", systemImage: "photo")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                        }
                        .buttonStyle(.bordered)
                        
                        // Bild entfernen, wenn vorhanden
                        if team.imageData != nil {
                            Button {
                                team.imageData = nil
                                showingColorPicker = false
                            } label: {
                                Label("Bild entfernen", systemImage: "trash")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Divider()
                        
                        // Farbauswahl
                        Text("Farbe wählen")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.fixed(44), spacing: 12), count: 6), spacing: 12) {
                            ForEach(availableColors, id: \.self) { colorHex in
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .blue)
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        if team.color == colorHex {
                                            Circle()
                                                .stroke(Color.primary, lineWidth: 3)
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                                .font(.title3)
                                                .bold()
                                        }
                                    }
                                    .shadow(color: Color(hex: colorHex)?.opacity(0.4) ?? .clear, radius: 2)
                                    .onTapGesture {
                                        team.color = colorHex
                                        team.imageData = nil // Bild entfernen wenn Farbe gewählt wird
                                        showingColorPicker = false
                                    }
                            }
                        }
                    }
                    .padding(20)
                }
                
                // Team-Informationen
                VStack(alignment: .leading, spacing: 8) {
                    if isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            // Team Name
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Team-Name")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .bold()
                                TextField("Team Name", text: $editedName)
                                    .textFieldStyle(.roundedBorder)
                            }
                            
                            Divider()
                            
                            // Team Details
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Kontaktinformationen")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .bold()
                                
                                TextField("Kontaktperson", text: $contactPerson)
                                    .textFieldStyle(.roundedBorder)
                                
                                TextField("E-Mail", text: $email)
                                    .textFieldStyle(.roundedBorder)
                                
                                Toggle("Bestätigt", isOn: $isConfirmed)
                                    .toggleStyle(.checkbox)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            // Team Name
                            Text(team.name)
                                .font(.title3)
                                .bold()
                                .foregroundStyle(.primary)
                            
                            // Details
                            if !team.contactPerson.isEmpty || !team.email.isEmpty || team.isConfirmed {
                                VStack(alignment: .leading, spacing: 6) {
                                    if !team.contactPerson.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "person.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .frame(width: 16)
                                            Text(team.contactPerson)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    if !team.email.isEmpty {
                                        HStack(spacing: 6) {
                                            Image(systemName: "envelope.fill")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                                .frame(width: 16)
                                            Text(team.email)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    
                                    if team.isConfirmed {
                                        HStack(spacing: 6) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                                .font(.caption)
                                            Text("Bestätigt")
                                                .font(.subheadline)
                                                .foregroundStyle(.green)
                                                .bold()
                                        }
                                        .padding(.top, 2)
                                    }
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                
                // Action Buttons - Größer und besser sichtbar
                HStack(spacing: 12) {
                    // Bearbeiten/Speichern Button - Größer und prominenter
                    Button {
                        if isEditing {
                            saveChanges()
                        } else {
                            editedName = team.name
                            contactPerson = team.contactPerson
                            email = team.email
                            isConfirmed = team.isConfirmed
                            isEditing = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isEditing ? "checkmark.circle.fill" : "pencil.circle.fill")
                                .font(.body)
                            Text(isEditing ? "Speichern" : "Bearbeiten")
                                .font(.body)
                        }
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(isEditing ? Color.green : Color.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .help(isEditing ? "Speichern" : "Bearbeiten")

                    // Löschen Button - Größer und prominenter
                    Button {
                        showingDeleteConfirmation = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.circle.fill")
                                .font(.body)
                            Text("Entfernen")
                                .font(.body)
                        }
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.red)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .buttonStyle(.plain)
                    .help("Team aus Quiz entfernen")
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, isEditing ? 20 : 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(nsColor: .controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color(hex: team.color)?.opacity(0.4) ?? .blue.opacity(0.4),
                            Color(hex: team.color)?.opacity(0.2) ?? .blue.opacity(0.2)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
        }
        .alert("Team aus Quiz entfernen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {}
            Button("Entfernen", role: .destructive) {
                viewModel.deleteTeam(team, from: quiz)
            }
        } message: {
            Text("Möchtest du '\(team.name)' wirklich aus diesem Quiz entfernen? Das Team bleibt in der globalen Team-Liste erhalten.")
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
            guard NSImage(data: imageData) != nil else {
                print("⚠️ Fehler: Datei ist kein gültiges Bild")
                return
            }
            
            // Bild speichern
            team.imageData = imageData
            print("✅ Bild erfolgreich geladen: \(url.lastPathComponent)")
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }
}





