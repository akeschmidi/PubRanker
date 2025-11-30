//
//  GlobalAddTeamSheet.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct GlobalAddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: QuizViewModel
    let modelContext: ModelContext

    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil

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
                        Text("Team-Icon")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            // Vorschau
                            Group {
                                if let imageData = imageData, let nsImage = NSImage(data: imageData) {
                                    Image(nsImage: nsImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 60, height: 60)
                                        .clipShape(Circle())
                                        .overlay {
                                            Circle()
                                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                        }
                                        .shadow(color: Color.black.opacity(0.2), radius: 4)
                                } else {
                                    Circle()
                                        .fill(Color(hex: selectedColor) ?? .blue)
                                        .frame(width: 60, height: 60)
                                        .overlay {
                                            Circle()
                                                .stroke(Color.white.opacity(0.6), lineWidth: 2)
                                        }
                                        .shadow(color: Color(hex: selectedColor)?.opacity(0.4) ?? .clear, radius: 4)
                                }
                            }
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("Bild auswählen", systemImage: "photo")
                                }
                                .buttonStyle(.bordered)
                                
                                if imageData != nil {
                                    Button {
                                        imageData = nil
                                    } label: {
                                        Label("Bild entfernen", systemImage: "trash")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        
                        Divider()
                        
                        // Farbauswahl
                        Text("Farbe")
                            .font(.body)
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
                                        imageData = nil // Bild entfernen wenn Farbe gewählt wird
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
            .navigationTitle("Neues Team erstellen")
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
        team.imageData = imageData

        modelContext.insert(team)
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
            guard NSImage(data: imageData) != nil else {
                print("⚠️ Fehler: Datei ist kein gültiges Bild")
                return
            }
            
            // Bild speichern
            self.imageData = imageData
            print("✅ Bild erfolgreich geladen: \(url.lastPathComponent)")
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }
}





