//
//  GlobalAddTeamSheet.swift
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
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(spacing: 0) {
                        teamInformationSection
                        contactInformationSection
                    }
                }
                
                bottomActionBar
            }
            .navigationTitle("Neues Team erstellen")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
        .frame(minWidth: 550, minHeight: 700)
    }
    
    // MARK: - Team Information Section
    
    private var teamInformationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Team-Informationen")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
            
            teamNameField
            
            Divider()
                .padding(.vertical, AppSpacing.xxxs)
            
            teamIconSection
            
            Divider()
                .padding(.vertical, AppSpacing.xxxs)
            
            colorSelectionSection
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.md)
    }
    
    private var teamNameField: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Team-Name")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
            
            TextField("z.B. Die wilden Sieben", text: $teamName)
                .textFieldStyle(.plain)
                .font(.body)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .fill(.ultraThinMaterial)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .strokeBorder(
                            teamName.isEmpty ? Color.appPrimary.opacity(0.5) : Color.appSuccess,
                            lineWidth: teamName.isEmpty ? 1 : 2
                        )
                }
        }
    }
    
    private var teamIconSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Team-Icon")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: AppSpacing.sm) {
                iconPreview
                iconButtons
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var iconPreview: some View {
        Group {
            if let imageData = imageData {
                PlatformImage(data: imageData)
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                    }
                    .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 8)
            } else {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                (Color(hex: selectedColor) ?? Color.appPrimary).opacity(0.9),
                                (Color(hex: selectedColor) ?? Color.appPrimary)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay {
                        Circle()
                            .strokeBorder(Color.white.opacity(0.3), lineWidth: 2)
                    }
                    .shadow(color: (Color(hex: selectedColor) ?? Color.appPrimary).opacity(0.3), radius: 20, x: 0, y: 8)
            }
        }
    }
    
    private var iconButtons: some View {
        HStack(spacing: AppSpacing.sm) {
            Button {
                showingImagePicker = true
            } label: {
                Label("Bild wählen", systemImage: "photo")
                    .font(.subheadline)
            }
            .secondaryGlassButton(size: .small)
            
            if imageData != nil {
                Button {
                    imageData = nil
                } label: {
                    Image(systemName: "trash")
                        .font(.subheadline)
                }
                .destructiveGlassButton(size: .small)
            }
        }
    }
    
    private var colorSelectionSection: some View {
        VStack(spacing: AppSpacing.sm) {
            Text("Farbe")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: AppSpacing.sm), count: 6), spacing: AppSpacing.sm) {
                ForEach(availableColors, id: \.self) { colorHex in
                    colorCircleButton(for: colorHex)
                }
            }
        }
    }
    
    private func colorCircleButton(for colorHex: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                selectedColor = colorHex
                imageData = nil
            }
        } label: {
            ZStack {
                Circle()
                    .fill(Color(hex: colorHex) ?? Color.appPrimary)
                    .frame(width: 48, height: 48)
                
                if selectedColor == colorHex {
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 3)
                        .frame(width: 48, height: 48)
                    Circle()
                        .strokeBorder(Color.appTextPrimary, lineWidth: 2)
                        .frame(width: 56, height: 56)
                }
            }
            .shadow(color: (Color(hex: colorHex) ?? Color.appPrimary).opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(selectedColor == colorHex ? 1.0 : 0.9)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Contact Information Section
    
    private var contactInformationSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Kontaktinformationen")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color.appTextPrimary)
            
            contactPersonField
            emailField
        }
        .padding(AppSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.xl)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.sm)
        .padding(.bottom, 80)
    }
    
    private var contactPersonField: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Kontaktperson (optional)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
            
            TextField("Name der Kontaktperson", text: $contactPerson)
                .textFieldStyle(.plain)
                .font(.body)
                .textContentType(.name)
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .fill(.ultraThinMaterial)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("E-Mail (optional)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
            
            TextField("team@beispiel.de", text: $email)
                .textFieldStyle(.plain)
                .font(.body)
                .textContentType(.emailAddress)
                #if os(iOS)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                #endif
                .padding(.horizontal, AppSpacing.md)
                .padding(.vertical, AppSpacing.sm)
                .background(
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .fill(.ultraThinMaterial)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
    
    // MARK: - Bottom Action Bar
    
    private var bottomActionBar: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: AppSpacing.sm) {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .font(.body)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                }
                .secondaryGlassButton(size: .large)
                
                Button {
                    createTeam()
                    dismiss()
                } label: {
                    Text("Team erstellen")
                        .font(.body)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
                .primaryGlassButton(size: .large)
                .disabled(teamName.isEmpty)
                .opacity(teamName.isEmpty ? 0.5 : 1.0)
            }
            .padding(AppSpacing.md)
        }
        .background(.ultraThinMaterial)
    }
    
    // MARK: - Actions

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
            self.imageData = imageData
            print("✅ Bild erfolgreich geladen: \(url.lastPathComponent)")
        } catch {
            print("❌ Fehler beim Laden des Bildes: \(error.localizedDescription)")
        }
    }
}





