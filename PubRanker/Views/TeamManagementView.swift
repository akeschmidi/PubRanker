//
//  TeamManagementView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct TeamManagementView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]

    @State private var showingAddTeamSheet = false
    @State private var showingTeamWizard = false
    @State private var showingGlobalTeamPicker = false
    @State private var selectedTeam: Team?

    var availableGlobalTeams: [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }

    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if quiz.safeTeams.isEmpty {
                emptyStateView
            } else {
                detailView
            }
        }
        .navigationSplitViewStyle(.balanced)
        .sheet(isPresented: $showingAddTeamSheet) {
            AddTeamSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingTeamWizard) {
            TeamWizardSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingGlobalTeamPicker) {
            GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams, modelContext: modelContext)
        }
        .onAppear {
            if selectedTeam == nil && !quiz.safeTeams.isEmpty {
                selectedTeam = quiz.safeTeams.first
            }
        }
        .onChange(of: quiz.safeTeams) { oldValue, newValue in
            if let selected = selectedTeam, !newValue.contains(where: { $0.id == selected.id }) {
                selectedTeam = newValue.first
            } else if selectedTeam == nil && !newValue.isEmpty {
                selectedTeam = newValue.first
            }
        }
    }
    
    // MARK: - Sidebar
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Teams verwalten", systemImage: "person.3.fill")
                        .font(.title2)
                        .bold()
                    Text("\(quiz.safeTeams.count) Team\(quiz.safeTeams.count == 1 ? "" : "s")")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Moderner + Button
                Button {
                    showingAddTeamSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Neues Team")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .help("Neues Team erstellen")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Teams List
            List(selection: $selectedTeam) {
                if quiz.safeTeams.isEmpty {
                    ContentUnavailableView(
                        "Keine Teams",
                        systemImage: "person.3.fill",
                        description: Text("Füge Teams hinzu")
                    )
                } else {
                    Section("Teams (\(quiz.safeTeams.count))") {
                        ForEach(quiz.safeTeams) { team in
                            TeamSidebarRow(team: team, quiz: quiz)
                                .tag(team)
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                viewModel.deleteTeam(quiz.safeTeams[index], from: quiz)
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
    }
    
    // MARK: - Detail View
    
    private var detailView: some View {
        VStack(spacing: 0) {
            // Action Bar
            teamsActionBar
            
            Divider()
            
            // Content
            if let team = selectedTeam {
                teamDetailView(team: team)
            } else {
                teamsOverviewView
            }
        }
    }
    
    private func teamDetailView(team: Team) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Team Header
                HStack(spacing: 16) {
                    TeamIconView(team: team, size: 60)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(team.name)
                            .font(.title2)
                            .bold()
                        
                        HStack(spacing: 16) {
                            if team.isConfirmed {
                                Label("Bestätigt", systemImage: "checkmark.circle.fill")
                                    .font(.body)
                                    .foregroundStyle(.green)
                            }
                            
                            if !team.contactPerson.isEmpty {
                                Label(team.contactPerson, systemImage: "person.fill")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                            
                            if !team.email.isEmpty {
                                Label(team.email, systemImage: "envelope.fill")
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                
                // Team Stats
                HStack(spacing: 12) {
                    statCard(title: "Punkte", value: "\(team.totalScore)", icon: "star.fill", color: .orange)
                    statCard(title: "Runden", value: "\(quiz.safeRounds.filter { team.hasScore(for: $0) }.count)", icon: "list.number", color: .blue)
                }
                
                // Runden-Übersicht
                if !quiz.safeRounds.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Runden-Ergebnisse", systemImage: "chart.bar.fill")
                            .font(.title3)
                            .bold()
                        
                        ForEach(quiz.sortedRounds) { round in
                            roundScoreRow(team: team, round: round)
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding()
        }
    }
    
    private var teamsOverviewView: some View {
        ScrollView {
            VStack(spacing: 12) {
                ForEach(quiz.safeTeams) { team in
                    TeamRowView(team: team, quiz: quiz, viewModel: viewModel)
                }
            }
            .padding()
        }
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title)
                    .bold()
                    .monospacedDigit()
                
                Text(title)
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func roundScoreRow(team: Team, round: Round) -> some View {
        HStack {
            Text(round.name)
                .font(.body)
            
            Spacer()
            
            if let score = team.getScore(for: round) {
                Text("\(score) / \(round.maxPoints)")
                    .font(.body)
                    .bold()
                    .foregroundStyle(score == round.maxPoints ? .green : .primary)
            } else {
                Text("— / \(round.maxPoints)")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    // MARK: - Action Bar
    
    private var teamsActionBar: some View {
        HStack(spacing: 12) {
            Button {
                showingTeamWizard = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.3.fill")
                        .font(.body)
                    Text("Mehrere Teams")
                        .font(.body)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
            
            if !availableGlobalTeams.isEmpty {
                Button {
                    showingGlobalTeamPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "square.stack.3d.up.fill")
                            .font(.body)
                        Text("Aus Team-Manager (\(availableGlobalTeams.count))")
                            .font(.body)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple.opacity(0.1))
                    .foregroundStyle(.purple)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.purple, lineWidth: 2)
                    }
                }
                .buttonStyle(.plain)
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(Color(nsColor: .controlBackgroundColor))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(NSLocalizedString("empty.noTeams", comment: "No teams"))
                    .font(.title2)
                    .bold()

                Text(NSLocalizedString("empty.noTeams.management", comment: "Add teams to start quiz"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button {
                        showingTeamWizard = true
                    } label: {
                        Label(NSLocalizedString("team.new.multiple", comment: "Multiple teams"), systemImage: "person.3.fill")
                            .font(.body)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    Button {
                        showingAddTeamSheet = true
                    } label: {
                        Label(NSLocalizedString("team.new.single", comment: "Single team"), systemImage: "plus.circle")
                            .font(.body)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Divider()
                    .padding(.horizontal, 40)

                Button {
                    showingGlobalTeamPicker = true
                } label: {
                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "square.stack.3d.up.fill")
                            Text("Aus vorhandenen Teams wählen")
                                .font(.body)
                        }
                        if !availableGlobalTeams.isEmpty {
                            Text("\(availableGlobalTeams.count) verfügbare Teams")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } else {
                            Text("Erstellen Sie zuerst Teams im Team-Manager")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .disabled(availableGlobalTeams.isEmpty)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Team Sidebar Row
struct TeamSidebarRow: View {
    let team: Team
    let quiz: Quiz
    
    var body: some View {
        HStack(spacing: 12) {
            TeamIconView(team: team, size: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(team.name)
                    .font(.body)
                
                if team.isConfirmed {
                    Label("Bestätigt", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }
            
            Spacer()
            
            if quiz.isActive {
                Text("\(team.totalScore)")
                    .font(.body)
                    .bold()
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Team Row View
struct TeamRowView: View {
    @Bindable var team: Team
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var isEditing = false
    @State private var editedName: String = ""
    @State private var showingDetails = false
    
    var body: some View {
        HStack {
            // Status indicator
            Circle()
                .fill(team.isConfirmed ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            TeamIconView(team: team, size: 40)
            
            if isEditing {
                TextField("Team Name", text: $editedName, onCommit: {
                    saveChanges()
                })
                .textFieldStyle(.roundedBorder)
                .font(.body)
            } else {
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.body)
                    
                    if !team.contactPerson.isEmpty {
                        Text(team.contactPerson)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Confirmed badge
            if team.isConfirmed {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
                    .font(.body)
            }
            
            Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), team.totalScore))
                .font(.body)
                .foregroundStyle(.secondary)
            
            // Details button
            Button {
                showingDetails = true
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.plain)
            .help("Team-Details anzeigen")
            
            // Edit name button
            Button {
                if isEditing {
                    saveChanges()
                } else {
                    editedName = team.name
                    isEditing = true
                }
            } label: {
                Image(systemName: isEditing ? "checkmark" : "pencil")
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showingDetails) {
            TeamDetailsSheet(team: team, viewModel: viewModel)
        }
    }
    
    private func saveChanges() {
        if !editedName.isEmpty {
            viewModel.updateTeamName(team, newName: editedName)
        }
        isEditing = false
    }
}

struct AddTeamSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    
    @State private var mode: TeamAddMode = .create
    @State private var teamName = ""
    @State private var selectedColor = "#007AFF"
    @State private var contactPerson = ""
    @State private var email = ""
    @State private var isConfirmed = false
    @State private var showingImagePicker = false
    @State private var imageData: Data? = nil
    @State private var selectedTeamId: UUID? = nil
    
    enum TeamAddMode: String, CaseIterable {
        case create = "Neues Team"
        case select = "Aus vorhandenen wählen"
    }
    
    var availableTeams: [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }
    
    let availableColors = [
        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Mode Picker
                Section {
                    Picker("Modus", selection: $mode) {
                        ForEach(TeamAddMode.allCases, id: \.self) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                if mode == .create {
                    createTeamSection
                } else {
                    selectTeamSection
                }
            }
            .navigationTitle("Team hinzufügen")
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
                    Button(mode == .create ? "Hinzufügen" : "Auswählen") {
                        if mode == .create {
                            addNewTeam()
                        } else {
                            selectExistingTeam()
                        }
                    }
                    .disabled(mode == .create ? teamName.isEmpty : selectedTeamId == nil)
                }
            }
        }
        .frame(minWidth: 400, minHeight: 300)
    }
    
    private var createTeamSection: some View {
        Group {
            Section("Team Details") {
                TextField("Team Name", text: $teamName)
                    
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
                    TextField("Kontaktperson", text: $contactPerson)
                        .textContentType(.name)
                    
                    TextField("E-Mail", text: $email)
                        .textContentType(.emailAddress)
                }
                
            Section("Status") {
                Toggle("Bestätigt", isOn: $isConfirmed)
                    .help("Team hat die Teilnahme bestätigt")
            }
        }
    }
    
    private var selectTeamSection: some View {
        Section {
            if availableTeams.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "person.3.slash")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Keine verfügbaren Teams")
                        .font(.title3)
                    Text("Erstellen Sie zuerst Teams im Team-Manager")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                List(availableTeams, selection: $selectedTeamId) { team in
                    HStack(spacing: 12) {
                        TeamIconView(team: team, size: 40)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(team.name)
                                .font(.body)
                            
                            if !team.contactPerson.isEmpty {
                                Text(team.contactPerson)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if selectedTeamId == team.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedTeamId = team.id
                    }
                }
                .listStyle(.inset)
            }
        } header: {
            Text("Verfügbare Teams")
        } footer: {
            if !availableTeams.isEmpty {
                Text("\(availableTeams.count) Team\(availableTeams.count == 1 ? "" : "s") verfügbar")
            }
        }
    }
    
    private func addNewTeam() {
        viewModel.addTeam(to: quiz, name: teamName, color: selectedColor, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed, imageData: imageData)
        dismiss()
    }
    
    private func selectExistingTeam() {
        guard let selectedId = selectedTeamId,
              let team = availableTeams.first(where: { $0.id == selectedId }) else {
            return
        }
        
        // Team zum Quiz hinzufügen
        if team.quizzes == nil {
            team.quizzes = []
        }
        if !team.quizzes!.contains(where: { $0.id == quiz.id }) {
            team.quizzes!.append(quiz)
        }
        
        if quiz.teams == nil {
            quiz.teams = []
        }
        if !quiz.teams!.contains(where: { $0.id == team.id }) {
            quiz.teams!.append(team)
        }
        
        try? modelContext.save()
        dismiss()
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

// MARK: - Team Details Sheet
struct TeamDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var team: Team
    @Bindable var viewModel: QuizViewModel
    @State private var contactPerson: String = ""
    @State private var email: String = ""
    @State private var isConfirmed: Bool = false
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Team-Informationen") {
                    Text(team.name)
                        .font(.title3)
                        .bold()
                    
                    // Team-Icon Auswahl
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Team-Icon")
                            .font(.body)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 16) {
                            // Aktuelles Icon anzeigen
                            TeamIconView(team: team, size: 60)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Button {
                                    showingImagePicker = true
                                } label: {
                                    Label("Bild auswählen", systemImage: "photo")
                                }
                                .buttonStyle(.bordered)
                                
                                if team.imageData != nil {
                                    Button {
                                        team.imageData = nil
                                    } label: {
                                        Label("Bild entfernen", systemImage: "trash")
                                    }
                                    .buttonStyle(.bordered)
                                }
                                
                                // Farbauswahl
                                Menu {
                                    ForEach([
                                        "#007AFF", "#FF3B30", "#34C759", "#FF9500",
                                        "#5856D6", "#FF2D55", "#5AC8FA", "#FFCC00",
                                        "#AF52DE", "#00C7BE", "#32ADE6", "#FF6482"
                                    ], id: \.self) { colorHex in
                                        Button {
                                            team.color = colorHex
                                            team.imageData = nil
                                        } label: {
                                            HStack {
                                                Circle()
                                                    .fill(Color(hex: colorHex) ?? .blue)
                                                    .frame(width: 20, height: 20)
                                                if team.color == colorHex {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Label("Farbe wählen", systemImage: "paintpalette")
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                
                Section("Kontaktinformationen") {
                    TextField("Kontaktperson", text: $contactPerson)
                        .textContentType(.name)
                    
                    TextField("E-Mail", text: $email)
                        .textContentType(.emailAddress)
                }
                
                Section("Status") {
                    Toggle("Bestätigt", isOn: $isConfirmed)
                        .help("Team hat die Teilnahme bestätigt")
                }
            }
            .navigationTitle("Team-Details")
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
                        viewModel.updateTeamDetails(team, contactPerson: contactPerson, email: email, isConfirmed: isConfirmed)
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 500, minHeight: 400)
        .onAppear {
            contactPerson = team.contactPerson
            email = team.email
            isConfirmed = team.isConfirmed
        }
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

// MARK: - Team Wizard Sheet
struct TeamWizardSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    
    @State private var mode: TeamWizardMode = .create
    @State private var numberOfTeams: Int = 4
    @State private var teamNames: [String] = []
    @FocusState private var focusedField: Int?
    @State private var selectedTeamIds: Set<UUID> = []
    
    let presetCounts = [4, 6, 8, 10]
    
    enum TeamWizardMode: String, CaseIterable {
        case create = "Neue Teams erstellen"
        case select = "Aus vorhandenen wählen"
    }
    
    var availableTeams: [Team] {
        allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }
    
    var body: some View {
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
                    
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Teams hinzufügen")
                        .font(.title2)
                        .bold()
                    
                    Text(mode == .create ? "Erstellen Sie mehrere Teams auf einmal" : "Wählen Sie Teams aus vorhandenen aus")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 20)
            
            // Mode Picker
            Picker("Modus", selection: $mode) {
                ForEach(TeamWizardMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)
            .padding(.bottom, 20)
            
            ScrollView {
                VStack(spacing: 32) {
                    if mode == .create {
                        createTeamsContent
                    } else {
                        selectTeamsContent
                    }
                }
                .padding(.horizontal, 40)
            }
            
            // Action Buttons
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button {
                    if mode == .create {
                        createTeams()
                    } else {
                        selectTeams()
                    }
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text(mode == .create ? "\(numberOfTeams) Teams erstellen" : "\(selectedTeamIds.count) Teams auswählen")
                    }
                    .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(mode == .select && selectedTeamIds.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.vertical, 24)
        }
        .frame(width: 650, height: 750)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            if mode == .create {
                updateTeamNames()
                focusedField = 0
            }
        }
    }
    
    private var createTeamsContent: some View {
        Group {
            // Number of Teams
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .foregroundStyle(.blue)
                                .font(.title3)
                            Text("Anzahl der Teams")
                                .font(.title3)
                                .bold()
                        }
                        
                        HStack {
                            Button {
                                if numberOfTeams > 2 {
                                    numberOfTeams -= 1
                                    updateTeamNames()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(numberOfTeams)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)
                            
                            Button {
                                if numberOfTeams < 20 {
                                    numberOfTeams += 1
                                    updateTeamNames()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Quick buttons
                        HStack(spacing: 8) {
                            ForEach(presetCounts, id: \.self) { count in
                                Button("\(count)") {
                                    numberOfTeams = count
                                    updateTeamNames()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    Divider()
                    
                    // Team Names
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(.purple)
                                .font(.title3)
                            Text("Team-Namen")
                                .font(.title3)
                                .bold()
                        }
                        
                        VStack(spacing: 12) {
                            ForEach(0..<numberOfTeams, id: \.self) { index in
                                HStack(spacing: 12) {
                                    // Color Circle
                                    Circle()
                                        .fill(getTeamColor(for: index))
                                        .frame(width: 24, height: 24)
                                        .shadow(color: getTeamColor(for: index).opacity(0.3), radius: 3)
                                    
                                    // Team Number
                                    Text("T\(index + 1)")
                                        .font(.body)
                                        .foregroundStyle(.secondary)
                                        .frame(width: 30)
                                    
                                    // Text Field
                                    TextField("Team \(index + 1)", text: Binding(
                                        get: { teamNames.indices.contains(index) ? teamNames[index] : "" },
                                        set: { newValue in
                                            while teamNames.count <= index {
                                                teamNames.append("")
                                            }
                                            teamNames[index] = newValue
                                        }
                                    ))
                                    .textFieldStyle(.roundedBorder)
                                    .focused($focusedField, equals: index)
                                    .onSubmit {
                                        if index < numberOfTeams - 1 {
                                            focusedField = index + 1
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Vorschau")
                            .font(.title3)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<min(numberOfTeams, 3), id: \.self) { index in
                                HStack {
                                    Circle()
                                        .fill(getTeamColor(for: index))
                                        .frame(width: 16, height: 16)
                                    
                                    Text(getTeamName(for: index))
                                        .font(.body)
                                }
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(nsColor: .controlBackgroundColor))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            
                            if numberOfTeams > 3 {
                                Text("... und \(numberOfTeams - 3) weitere Teams")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                    .padding(.leading, 12)
                            }
                        }
                    }
        }
    }
    
    private var selectTeamsContent: some View {
        Group {
            if availableTeams.isEmpty {
                VStack(spacing: 24) {
                    Image(systemName: "person.3.slash")
                        .font(.system(size: 60))
                        .foregroundStyle(.secondary)
                    
                    VStack(spacing: 8) {
                        Text("Keine verfügbaren Teams")
                            .font(.title2)
                            .bold()
                        
                        Text("Erstellen Sie zuerst Teams im Team-Manager")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "list.bullet.circle.fill")
                            .foregroundStyle(.blue)
                            .font(.title3)
                        Text("Verfügbare Teams")
                            .font(.title3)
                            .bold()
                        Spacer()
                        Text("\(selectedTeamIds.count) ausgewählt")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    
                    List(availableTeams, selection: $selectedTeamIds) { team in
                        HStack(spacing: 12) {
                            TeamIconView(team: team, size: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(team.name)
                                    .font(.body)
                                
                                if !team.contactPerson.isEmpty {
                                    Text(team.contactPerson)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            if selectedTeamIds.contains(team.id) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if selectedTeamIds.contains(team.id) {
                                selectedTeamIds.remove(team.id)
                            } else {
                                selectedTeamIds.insert(team.id)
                            }
                        }
                    }
                    .listStyle(.inset)
                    .frame(height: 400)
                }
            }
        }
    }
    
    private func updateTeamNames() {
        while teamNames.count < numberOfTeams {
            teamNames.append("")
        }
    }
    
    private func getTeamName(for index: Int) -> String {
        if teamNames.indices.contains(index) && !teamNames[index].isEmpty {
            return teamNames[index]
        }
        return "Team \(index + 1)"
    }
    
    private func getTeamColor(for index: Int) -> Color {
        let colors: [Color] = [
            .blue, .red, .green, .orange, .purple, .pink,
            .cyan, .yellow, .mint, .indigo, .brown, .teal
        ]
        return colors[index % colors.count]
    }
    
    private func getTeamColorHex(for index: Int) -> String {
        let colors = [
            "#007AFF", "#FF3B30", "#34C759", "#FF9500", "#AF52DE", "#FF2D55",
            "#32ADE6", "#FFCC00", "#00C7BE", "#5856D6", "#A2845E", "#30B0C7"
        ]
        return colors[index % colors.count]
    }
    
    private func createTeams() {
        for index in 0..<numberOfTeams {
            let name = getTeamName(for: index)
            let color = getTeamColorHex(for: index)
            viewModel.addTeam(to: quiz, name: name, color: color)
        }
    }
    
    private func selectTeams() {
        for teamId in selectedTeamIds {
            guard let team = availableTeams.first(where: { $0.id == teamId }) else { continue }
            
            // Team zum Quiz hinzufügen
            if team.quizzes == nil {
                team.quizzes = []
            }
            if !team.quizzes!.contains(where: { $0.id == quiz.id }) {
                team.quizzes!.append(quiz)
            }
            
            if quiz.teams == nil {
                quiz.teams = []
            }
            if !quiz.teams!.contains(where: { $0.id == team.id }) {
                quiz.teams!.append(team)
            }
        }
        
        try? modelContext.save()
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
        if searchText.isEmpty {
            return availableTeams
        }
        return availableTeams.filter { team in
            team.name.localizedCaseInsensitiveContains(searchText) ||
            team.contactPerson.localizedCaseInsensitiveContains(searchText)
        }
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
                            Circle()
                                .fill(Color(hex: team.color) ?? .blue)
                                .frame(width: 24, height: 24)
                                .shadow(color: (Color(hex: team.color) ?? .blue).opacity(0.3), radius: 3)

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



