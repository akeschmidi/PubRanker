//
//  RoundManagementView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import UniformTypeIdentifiers

struct RoundManagementView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var showingAddRoundSheet = false
    @State private var showingRoundWizard = false
    @State private var selectedRound: Round?
    @State private var editingCell: String?
    
    var body: some View {
        mainContent
            .sheet(isPresented: $showingAddRoundSheet) {
                QuickRoundSheet(quiz: quiz, viewModel: viewModel)
            }
            .sheet(isPresented: $showingRoundWizard) {
                RoundWizardSheet(quiz: quiz, viewModel: viewModel)
            }
            .sheet(item: $selectedRound) { round in
                EditRoundSheet(round: round, quiz: quiz, viewModel: viewModel)
            }
    }
    
    // MARK: - Computed Properties
    
    private var mainContent: some View {
        VStack(spacing: 0) {
            // Active Round Status Banner
            if quiz.isActive, let currentRound = quiz.currentRound {
                CurrentRoundBanner(quiz: quiz, currentRound: currentRound, viewModel: viewModel)
            }
            
            contentArea
        }
    }
    
    private var contentArea: some View {
        Group {
            if quiz.safeRounds.isEmpty {
                VStack(spacing: AppSpacing.md) {
                    emptyRoundsView
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                // Rundenliste anzeigen - unabhängig davon ob Teams existieren
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: AppSpacing.xs) {
                            ForEach(Array(quiz.sortedRounds.enumerated()), id: \.element.id) { index, round in
                                roundListCard(round: round, index: index)
                            }
                        }
                        .padding(AppSpacing.screenPadding)
                    }

                    // Action Buttons am unteren Rand
                    Divider()

                    HStack(spacing: AppSpacing.xs) {
                        Button {
                            showingAddRoundSheet = true
                        } label: {
                            Label("Runde hinzufügen", systemImage: "plus.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .primaryGlassButton(size: .large)
                    }
                    .padding(AppSpacing.md)
                    .background(Color.appBackgroundSecondary)
                }
            }
        }
    }
    
    // MARK: - Round List Card
    
    private func roundListCard(round: Round, index: Int) -> some View {
        HStack(spacing: AppSpacing.sm) {
            // Runden-Bild oder Nummer
            VStack(spacing: AppSpacing.xxxs) {
                if let imageData = round.imageData {
                    // Runden-Bild anzeigen
                    #if os(macOS)
                    if let nsImage = NSImage(data: imageData) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .stroke(getRoundStatusColor(for: round).opacity(0.5), lineWidth: 2)
                            )
                    }
                    #else
                    if let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                            .overlay(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .stroke(getRoundStatusColor(for: round).opacity(0.5), lineWidth: 2)
                            )
                    }
                    #endif
                } else {
                    // Fallback: Runden-Nummer
                    Text(L10n.CommonUI.roundNumber(index + 1))
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white)
                        .monospacedDigit()
                        .frame(width: 44, height: 44)
                        .background(getRoundStatusColor(for: round))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                }

                // Status-Indikator
                if round.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appSuccess)
                } else if quiz.isActive && quiz.currentRound?.id == round.id {
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.appAccent)
                        .symbolEffect(.pulse)
                }
            }
            
            // Runden-Info
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(round.name)
                    .font(.headline)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                HStack(spacing: AppSpacing.xs) {
                    if let maxPoints = round.maxPoints {
                        Label("\(maxPoints) Pkt", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    } else {
                        Label(L10n.Round.noMaxPoints, systemImage: "star.slash")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    
                    if round.isCompleted {
                        Label(L10n.CommonUI.completed, systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appSuccess)
                    } else if quiz.isActive && quiz.currentRound?.id == round.id {
                        Label(L10n.CommonUI.running, systemImage: "circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appAccent)
                    } else {
                        Label(NSLocalizedString("common.round.status.preparation", comment: "Preparation"), systemImage: "hourglass")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Fortschrittsanzeige
            if quiz.isActive {
                let completedTeams = quiz.safeTeams.filter { $0.hasScore(for: round) }.count
                let totalTeams = quiz.safeTeams.count
                
                VStack(alignment: .trailing, spacing: AppSpacing.xxxs) {
                    Text("\(completedTeams)/\(totalTeams)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                        .monospacedDigit()
                    
                    Text(L10n.CommonUI.teams)
                        .font(.caption2)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            
            // Bearbeiten-Button
            Button {
                selectedRound = round
            } label: {
                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "pencil")
                        .font(.body)
                    Text(L10n.CommonUI.edit)
                        .font(.body)
                }
            }
            .primaryGlassButton()
            .helpText(NSLocalizedString("common.round.edit.help", comment: "Edit round help"))
        }
        .padding(AppSpacing.md)
        .appCard(style: .glass, cornerRadius: AppCornerRadius.md)
        .overlay {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .stroke(Color.appTextTertiary.opacity(0.2), lineWidth: 1)
        }
    }

    // MARK: - Helper Methods

    // Helper to get round status color
    private func getRoundStatusColor(for round: Round) -> Color {
        if round.isCompleted {
            return Color.appSuccess
        } else if quiz.isActive && quiz.currentRound?.id == round.id {
            return Color.appAccent
        } else {
            return Color.appTextSecondary
        }
    }
    
    private var emptyRoundsView: some View {
        VStack(spacing: AppSpacing.md) {
            Image(systemName: "number.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.appPrimary)
            
            VStack(spacing: AppSpacing.xxs) {
                Text("Keine Runden")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                Text("Füge Runden hinzu, um das Quiz zu strukturieren")
                    .font(.body)
                    .foregroundStyle(Color.appTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: AppSpacing.xs) {
                Button {
                    showingRoundWizard = true
                } label: {
                    Label(NSLocalizedString("round.new.multiple", comment: "Multiple rounds"), systemImage: "rectangle.stack.fill")
                        .font(.headline)
                }
                .primaryGlassButton(size: .large)
                
                Button {
                    showingAddRoundSheet = true
                } label: {
                    Label(NSLocalizedString("round.new.single", comment: "Single round"), systemImage: "plus.circle")
                        .font(.headline)
                }
                .secondaryGlassButton(size: .large)
            }
        }
        .padding(AppSpacing.screenPadding)
    }
} // schließt RoundManagementView

// MARK: - Current Round Banner
struct CurrentRoundBanner: View {
    let quiz: Quiz
    let currentRound: Round
    @Bindable var viewModel: QuizViewModel
    
    var completedTeamsCount: Int {
        quiz.safeTeams.filter { $0.hasScore(for: currentRound) }.count
    }
    
    var totalTeams: Int {
        quiz.safeTeams.count
    }
    
    var progress: Double {
        guard totalTeams > 0 else { return 0 }
        return Double(completedTeamsCount) / Double(totalTeams)
    }
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack {
                // Left side - Current Round Info
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "circle.fill")
                        .font(.title3)
                        .foregroundStyle(Color.appAccent)
                        .symbolEffect(.pulse)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                        Text(L10n.CommonUI.currentRound)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .bold()
                        
                        Text(currentRound.name)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                    }
                }
                
                Spacer()
                
                // Center - Progress
                VStack(spacing: AppSpacing.xxxs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "person.3.fill")
                            .foregroundStyle(Color.appTextSecondary)
                        Text("\(completedTeamsCount) von \(totalTeams) Teams")
                            .font(.subheadline)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                            .monospacedDigit()
                    }
                    
                    ProgressView(value: progress)
                        .frame(width: 200)
                        .tint(progress == 1.0 ? Color.appSuccess : Color.appAccent)
                }
                
                Spacer()
                
                // Right side - Actions
                HStack(spacing: AppSpacing.xs) {
                    if progress == 1.0 {
                        Button {
                            viewModel.completeRound(currentRound)
                        } label: {
                            Label(NSLocalizedString("round.complete", comment: "Complete round"), systemImage: "checkmark.circle.fill")
                                .font(.headline)
                        }
                        .successGlassButton(size: .large)
                    } else {
                        VStack(alignment: .trailing, spacing: AppSpacing.xxxs) {
                            Text(String(format: NSLocalizedString("common.missing", comment: "Missing count"), totalTeams - completedTeamsCount))
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                            if let maxPoints = currentRound.maxPoints {
                                Text(String(format: NSLocalizedString("common.points.maxLabel", comment: "Max points label"), maxPoints))
                                    .font(.caption2)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .monospacedDigit()
                            }
                        }
                    }
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.appAccent.opacity(0.15), Color.appAccent.opacity(0.05)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.appAccent)
                .frame(height: 3)
        }
    }
}

// MARK: - Round Completion Indicator
struct RoundCompletionIndicator: View {
    let quiz: Quiz
    let round: Round
    
    var teamsWithScores: Int {
        quiz.safeTeams.filter { $0.hasScore(for: round) }.count
    }
    
    var totalTeams: Int {
        quiz.safeTeams.count
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<min(totalTeams, 5), id: \.self) { index in
                Circle()
                    .fill(index < teamsWithScores ? Color.appSuccess : Color.appTextTertiary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
            
            if totalTeams > 5 {
                Text("+\(totalTeams - 5)")
                    .font(.system(size: 8))
                    .foregroundStyle(Color.appTextSecondary)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 2)
        .background(Color.appBackgroundSecondary.opacity(0.5))
        .clipShape(Capsule())
    }
}

// MARK: - Score Cell Component
struct ScoreCell: View {
    let team: Team
    let round: Round
    @Bindable var viewModel: QuizViewModel
    let isEditing: Bool
    let onTap: () -> Void
    let onDismiss: () -> Void
    
    @State private var inputText: String = ""
    @FocusState private var isFocused: Bool
    @State private var saveTimer: Timer?
    
    var currentScore: Int? {
        team.getScore(for: round)
    }
    
    var hasScore: Bool {
        team.hasScore(for: round)
    }
    
    var body: some View {
        ZStack {
            if isEditing {
                VStack(spacing: 8) {
                    // TextField für direkte Eingabe
                    TextField("", text: $inputText)
                        #if os(iOS)
                        .keyboardType(.numberPad)
                        #endif
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center)
                        .font(.system(size: 28, weight: .bold))
                        .monospacedDigit()
                        .padding(.horizontal, 8)
                        .focused($isFocused)
                        .onSubmit {
                            saveScore()
                        }
                        .onChange(of: inputText) { oldValue, newValue in
                            scheduleAutoSave()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(12)
                        .background(Color.accentColor.opacity(0.15))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.accentColor, lineWidth: 3)
                        }
                    
                    // Schnell-Buttons für häufige Werte
                    if let maxPoints = round.maxPoints {
                        HStack(spacing: 6) {
                            ForEach([0, maxPoints / 2, maxPoints], id: \.self) { points in
                                Button {
                                    inputText = "\(points)"
                                    saveScore()
                                } label: {
                                    Text("\(points)")
                                        .font(.caption)
                                        .bold()
                                        .foregroundStyle(.white)
                                        .frame(minWidth: 30)
                                        .padding(.vertical, 4)
                                        .padding(.horizontal, 8)
                                        .background(Color.accentColor)
                                        .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .background(Color.accentColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: Color.accentColor.opacity(0.3), radius: 8)
            } else {
                // Display Mode
                Button(action: onTap) {
                    VStack(spacing: 6) {
                        // Score Display
                        if let score = currentScore {
                            Text("\(score)")
                                .font(.system(size: 36, weight: .bold))
                                .monospacedDigit()
                                .foregroundStyle(score == 0 ? .secondary : .primary)
                        } else {
                            Text("–")
                                .font(.system(size: 36, weight: .bold))
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        
                        // Info Label
                        if let maxPoints = round.maxPoints {
                            HStack(spacing: 2) {
                                if let score = currentScore, score > 0 {
                                    Text("\(score)")
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                    Text("/")
                                        .font(.caption2)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                                Text(String(format: NSLocalizedString("score.points", comment: "Points"), maxPoints))
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color.appBackgroundSecondary.opacity(0.5))
                            .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        Group {
                            if let score = currentScore {
                                if let maxPoints = round.maxPoints, score == maxPoints {
                                    Color.green.opacity(0.15)
                                } else if score > 0 {
                                    Color.accentColor.opacity(0.08)
                                } else {
                                    Color.clear
                                }
                            } else {
                                Color.clear
                            }
                        }
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                (currentScore ?? 0) > 0
                                    ? Color.accentColor.opacity(0.4)
                                    : Color.appTextTertiary.opacity(0.2),
                                lineWidth: (currentScore ?? 0) > 0 ? 2 : 1
                            )
                    }
                }
                .buttonStyle(.plain)
                .helpText(currentScore != nil ? String(format: NSLocalizedString("score.clickToEdit", comment: "Click to edit"), currentScore!) : NSLocalizedString("score.clickToAdd", comment: "Click to add"))
            }
        }
        .onChange(of: isEditing) { oldValue, newValue in
            if newValue {
                // Initialisiere Feld: wenn Score vorhanden zeige ihn, sonst leer
                if let score = currentScore {
                    inputText = "\(score)"
                } else {
                    inputText = ""
                }
                isFocused = true
            } else {
                // Auto-save beim Verlassen
                saveTimer?.invalidate()
                saveScore()
            }
        }
        .onChange(of: isFocused) { oldValue, newValue in
            if !newValue && isEditing {
                // Fokus verloren - speichern und schließen
                saveScore()
            }
        }
    }
    
    private func scheduleAutoSave() {
        saveTimer?.invalidate()
        saveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            // Auto-Save bei jeder Änderung (leer = Score entfernen, "0" = 0 Punkte)
            saveScore()
        }
    }
    
    private func saveScore() {
        saveTimer?.invalidate()
        
        // Leeres Feld = Score entfernen (nicht bewertet)
        if inputText.isEmpty {
            viewModel.clearScore(for: team, in: round)
            onDismiss()
            return
        }
        
        // Validiere eingegebene Zahl (inkl. 0)
        if let score = Int(inputText), score >= 0 {
            // Prüfe maxPoints nur wenn gesetzt
            if let maxPoints = round.maxPoints, score > maxPoints {
                return // Ungültige Eingabe - über Limit
            }
            viewModel.updateScore(for: team, in: round, points: score)
            onDismiss()
        }
        // Ungültige Eingabe = ignorieren und Dialog offen lassen
    }
}

// MARK: - Edit Round Sheet
struct EditRoundSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var round: Round
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var roundName = ""
    @State private var maxPoints = 10
    @State private var hasMaxPoints = false
    @State private var showingDeleteConfirmation = false
    @State private var showingImagePicker = false
    @State private var selectedImageData: Data? = nil
    @FocusState private var focusedField: Bool
    
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Header
            VStack(spacing: AppSpacing.xs) {
                Text(NSLocalizedString("common.round.edit", comment: "Edit round"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                Text(L10n.CommonUI.roundNumber(getRoundNumber()))
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .padding(.top, AppSpacing.md)

            // Form
            VStack(spacing: AppSpacing.md) {
                // Runden-Bild
                HStack(spacing: AppSpacing.md) {
                    // Bild-Vorschau
                    Group {
                        if let imageData = selectedImageData {
                            #if os(macOS)
                            if let nsImage = NSImage(data: imageData) {
                                Image(nsImage: nsImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                            #else
                            if let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            }
                            #endif
                        } else {
                            ZStack {
                                Color.appBackgroundSecondary
                                Image(systemName: "photo")
                                    .font(.title2)
                                    .foregroundStyle(Color.appTextTertiary)
                            }
                        }
                    }
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(Color.appTextTertiary.opacity(0.3), lineWidth: 1)
                    )

                    // Bild Info & Buttons
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Runden-Bild")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)

                        Text("Optional: Bild für diese Kategorie")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)

                        HStack(spacing: AppSpacing.xs) {
                            Button {
                                showingImagePicker = true
                            } label: {
                                Label(selectedImageData != nil ? "Ändern" : "Auswählen", systemImage: "photo.badge.plus")
                                    .font(.subheadline)
                            }
                            .secondaryGlassButton()

                            if selectedImageData != nil {
                                Button {
                                    selectedImageData = nil
                                } label: {
                                    Image(systemName: "trash")
                                        .font(.subheadline)
                                }
                                .accentGlassButton()
                            }
                        }
                    }

                    Spacer()
                }

                Divider()

                // Runden-Name
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(NSLocalizedString("round.name", comment: "Round name"))
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    TextField(NSLocalizedString("round.name.placeholder", comment: "Round name placeholder"), text: $roundName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .focused($focusedField)
                }

                // Toggle für maximale Punktzahl
                Toggle(isOn: $hasMaxPoints) {
                    Text(NSLocalizedString("round.maxPoints.label", comment: "Maximum points"))
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .toggleStyle(.switch)

                if hasMaxPoints {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        HStack {
                            Button {
                                if maxPoints > 1 {
                                    maxPoints -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)

                            Text("\(maxPoints)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)

                            Button {
                                if maxPoints < 100 {
                                    maxPoints += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    // Quick Presets
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text(NSLocalizedString("common.quickSelect", comment: "Quick select"))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)

                        HStack(spacing: AppSpacing.xs) {
                            ForEach([5, 10, 15, 20], id: \.self) { points in
                                Button(String(format: NSLocalizedString("common.points.count", comment: "Points count"), points)) {
                                    maxPoints = points
                                }
                                .secondaryGlassButton()
                            }
                        }
                    }
                }

            }
            .padding(.horizontal, AppSpacing.xxl)

            Spacer()
            
            // Action Buttons
            HStack(spacing: AppSpacing.sm) {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label(L10n.Navigation.delete, systemImage: "trash")
                        .frame(minWidth: 80)
                }
                .accentGlassButton(size: .large)
                
                Spacer()
                
                Button(L10n.Navigation.cancel) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                .secondaryGlassButton(size: .large)
                
                Button(L10n.Navigation.save) {
                    saveChanges()
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .primaryGlassButton(size: .large)
                .disabled(roundName.isEmpty)
            }
            .padding(.bottom, AppSpacing.md)
            .padding(.horizontal, AppSpacing.xl)
        }
        .frame(width: 550, height: 700)
        .onAppear {
            roundName = round.name
            selectedImageData = round.imageData
            if let points = round.maxPoints {
                maxPoints = points
                hasMaxPoints = true
            } else {
                maxPoints = 10
                hasMaxPoints = false
            }
            focusedField = true
        }
        .fileImporter(
            isPresented: $showingImagePicker,
            allowedContentTypes: [.image],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                if let url = urls.first {
                    if url.startAccessingSecurityScopedResource() {
                        defer { url.stopAccessingSecurityScopedResource() }
                        if let data = try? Data(contentsOf: url) {
                            selectedImageData = data
                        }
                    }
                }
            case .failure(let error):
                print("Fehler beim Laden des Bildes: \(error)")
            }
        }
        .alert(L10n.Round.Delete.confirm, isPresented: $showingDeleteConfirmation) {
            Button(L10n.Navigation.cancel, role: .cancel) {}
            Button(L10n.Navigation.delete, role: .destructive) {
                viewModel.deleteRound(round, from: quiz)
                dismiss()
            }
        } message: {
            Text(L10n.Round.Delete.confirmMessage(round.name))
        }
    }

    private func getRoundNumber() -> Int {
        guard let index = quiz.sortedRounds.firstIndex(where: { $0.id == round.id }) else {
            return 0
        }
        return index + 1
    }

    private func saveChanges() {
        let trimmedName = roundName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty {
            viewModel.updateRoundName(round, newName: trimmedName)
        }
        viewModel.updateRoundMaxPoints(round, maxPoints: hasMaxPoints ? maxPoints : nil)

        // Bild speichern
        round.imageData = selectedImageData
        viewModel.saveContext()
    }
}

// MARK: - Quick Round Sheet
struct QuickRoundSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var roundName = ""
    @State private var maxPoints = 10
    @State private var hasMaxPoints = false
    @FocusState private var focusedField: Bool

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            // Header
            VStack(spacing: AppSpacing.xxs) {
                Image(systemName: "number.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.appPrimary)

                Text(NSLocalizedString("common.round.create", comment: "Create round"))
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                Text(String(format: NSLocalizedString("common.round", comment: "Round"), quiz.safeRounds.count + 1))
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
            }
            .padding(.top, AppSpacing.md)

            // Form
            VStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Text(NSLocalizedString("round.name", comment: "Round name"))
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)

                    TextField(NSLocalizedString("round.name.placeholder", comment: "Round name placeholder"), text: $roundName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .focused($focusedField)
                }

                // Toggle für maximale Punktzahl
                Toggle(isOn: $hasMaxPoints) {
                    Text(NSLocalizedString("round.maxPoints.label", comment: "Maximum points"))
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .toggleStyle(.switch)

                if hasMaxPoints {
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        HStack {
                            Button {
                                if maxPoints > 1 {
                                    maxPoints -= 1
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)

                            Text("\(maxPoints)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)

                            Button {
                                if maxPoints < 100 {
                                    maxPoints += 1
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)

                        // Quick Presets
                        HStack(spacing: AppSpacing.xs) {
                            ForEach([5, 10, 15, 20], id: \.self) { points in
                                Button(String(format: NSLocalizedString("common.points.count", comment: "Points count"), points)) {
                                    maxPoints = points
                                }
                                .secondaryGlassButton()
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.xxl)

            Spacer()

            // Action Buttons
            HStack(spacing: AppSpacing.xs) {
                Button(L10n.Navigation.cancel) {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                .secondaryGlassButton(size: .large)

                Button(NSLocalizedString("common.round.create.button", comment: "Create round button")) {
                    viewModel.addRound(to: quiz, name: roundName, maxPoints: hasMaxPoints ? maxPoints : nil)
                    dismiss()
                }
                .keyboardShortcut(.return, modifiers: .command)
                .primaryGlassButton(size: .large)
                .disabled(roundName.isEmpty)
            }
            .padding(.bottom, AppSpacing.md)
            .padding(.horizontal, AppSpacing.xxl)
        }
        .frame(width: 500, height: 500)
        .onAppear {
            focusedField = true
        }
    }
}

// MARK: - Round Wizard Sheet
struct RoundWizardSheet: View {
    @Environment(\.dismiss) private var dismiss
    let quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var numberOfRounds: Int = 6
    @State private var maxPointsPerRound: Int = 10
    @State private var hasMaxPoints: Bool = false
    @State private var useCustomNames: Bool = false
    @State private var useCustomPoints: Bool = false
    @State private var roundNames: [String] = []
    @State private var roundPoints: [Int?] = []
    
    let presetFormats = [
        ("Klassisch", 6, 10),
        ("Kurz", 4, 10),
        ("Lang", 8, 10),
        ("Schnell", 5, 5)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appAccentLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(AppShadow.lg)
                    
                    Image(systemName: "list.number")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text(L10n.CommonUI.roundSetup)
                        .font(.title)
                        .bold()
                    
                    Text(L10n.CommonUI.roundSetupDescription)
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            ScrollView {
                VStack(spacing: 32) {
                    // Preset Formats
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("common.quickSelect", comment: "Quick select"))
                            .font(.headline)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(presetFormats, id: \.0) { preset in
                                Button {
                                    numberOfRounds = preset.1
                                    maxPointsPerRound = preset.2
                                } label: {
                                    VStack(spacing: 8) {
                                        Text(preset.0)
                                            .font(.headline)
                                        Text(String(format: NSLocalizedString("round.count.label", comment: "Rounds count"), preset.1))
                                            .font(.caption)
                                        Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), preset.2))
                                            .font(.caption2)
                                            .foregroundStyle(Color.appTextSecondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(
                                        numberOfRounds == preset.1 && maxPointsPerRound == preset.2
                                            ? Color.appPrimary.opacity(0.2)
                                            : Color.appBackgroundSecondary
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                                    .overlay {
                                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                                            .stroke(
                                                numberOfRounds == preset.1 && maxPointsPerRound == preset.2
                                                    ? Color.appPrimary
                                                    : Color.clear,
                                                lineWidth: 2
                                            )
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Number of Rounds
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "number.circle.fill")
                                .foregroundStyle(Color.appPrimary)
                            Text(L10n.CommonUI.numberOfRounds)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        
                        HStack {
                            Button {
                                if numberOfRounds > 1 {
                                    numberOfRounds -= 1
                                    updateRoundNames()
                                    updateRoundPoints()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                            
                            Text("\(numberOfRounds)")
                                .font(.system(size: 48, weight: .bold))
                                .monospacedDigit()
                                .frame(minWidth: 100)
                            
                            Button {
                                if numberOfRounds < 20 {
                                    numberOfRounds += 1
                                    updateRoundNames()
                                    updateRoundPoints()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // Quick buttons
                        HStack(spacing: AppSpacing.xxs) {
                            ForEach([4, 5, 6, 8, 10], id: \.self) { count in
                                Button("\(count)") {
                                    numberOfRounds = count
                                    updateRoundNames()
                                    updateRoundPoints()
                                }
                                .secondaryGlassButton()
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    
                    // Max Points Toggle (nur wenn nicht individuell)
                    if !useCustomPoints {
                        VStack(alignment: .leading, spacing: 12) {
                            Toggle(isOn: $hasMaxPoints) {
                                HStack {
                                    Image(systemName: "star.circle.fill")
                                        .foregroundStyle(Color.appSecondary)
                                    Text(NSLocalizedString("common.points.perRound", comment: "Max points per round"))
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)
                                }
                            }
                            .toggleStyle(.switch)

                            if hasMaxPoints {
                                HStack {
                                    Button {
                                        if maxPointsPerRound > 1 {
                                            maxPointsPerRound -= 1
                                        }
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.title)
                                    }
                                    .buttonStyle(.plain)

                                    TextField("", value: $maxPointsPerRound, format: .number)
                                        #if os(iOS)
                                        .keyboardType(.numberPad)
                                        #endif
                                        .textFieldStyle(.roundedBorder)
                                        .multilineTextAlignment(.center)
                                        .font(.system(size: 48, weight: .bold))
                                        .monospacedDigit()
                                        .frame(minWidth: 100)

                                    Button {
                                        if maxPointsPerRound < 100 {
                                            maxPointsPerRound += 1
                                        }
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.title)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .frame(maxWidth: .infinity)

                                // Quick buttons
                                HStack(spacing: AppSpacing.xxs) {
                                    ForEach([5, 10, 15, 20], id: \.self) { points in
                                        Button("\(points)") {
                                            maxPointsPerRound = points
                                        }
                                        .secondaryGlassButton()
                                    }
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    
                    Divider()
                    
                    // Custom Points Toggle
                    Toggle(isOn: $useCustomPoints) {
                        HStack {
                            Image(systemName: "star.circle.fill")
                                .foregroundStyle(Color.appSecondary)
                            Text(NSLocalizedString("common.points.custom", comment: "Custom points per round"))
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    .onChange(of: useCustomPoints) { oldValue, newValue in
                        if newValue {
                            updateRoundPoints()
                        }
                    }
                    
                    Divider()
                    
                    // Custom Names Toggle
                    Toggle(isOn: $useCustomNames) {
                        HStack {
                            Image(systemName: "pencil.circle.fill")
                                .foregroundStyle(Color.appSecondary)
                            Text(L10n.CommonUI.customNames)
                                .font(.headline)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                    .onChange(of: useCustomNames) { oldValue, newValue in
                        if newValue {
                            updateRoundNames()
                        }
                    }
                    
                    // Custom Names and/or Points List
                    if useCustomNames || useCustomPoints {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(useCustomNames && useCustomPoints ? NSLocalizedString("round.names.custom", comment: "Round names and points") : useCustomNames ? NSLocalizedString("round.names.only", comment: "Round names only") : NSLocalizedString("common.points.perRound", comment: "Max points"))
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                            
                            ForEach(0..<numberOfRounds, id: \.self) { index in
                                HStack(spacing: 12) {
                                    Text(L10n.CommonUI.roundNumber(index + 1))
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .frame(width: 30)
                                    
                                    if useCustomNames {
                                        TextField("Runde \(index + 1)", text: Binding(
                                            get: { roundNames.indices.contains(index) ? roundNames[index] : "" },
                                            set: { newValue in
                                                while roundNames.count <= index {
                                                    roundNames.append("")
                                                }
                                                roundNames[index] = newValue
                                            }
                                        ))
                                        .textFieldStyle(.roundedBorder)
                                    }
                                    
                                    if useCustomPoints {
                                        HStack {
                                            TextField(NSLocalizedString("common.points", comment: "Points"), text: Binding(
                                                get: {
                                                    if roundPoints.indices.contains(index), let points = roundPoints[index] {
                                                        return "\(points)"
                                                    }
                                                    return ""
                                                },
                                                set: { newValue in
                                                    while roundPoints.count <= index {
                                                        roundPoints.append(hasMaxPoints ? maxPointsPerRound : nil)
                                                    }
                                                    if newValue.isEmpty {
                                                        roundPoints[index] = nil
                                                    } else if let intValue = Int(newValue) {
                                                        roundPoints[index] = intValue
                                                    }
                                                }
                                            ))
                                            #if os(iOS)
                                            .keyboardType(.numberPad)
                                            #endif
                                            .textFieldStyle(.roundedBorder)
                                            .frame(width: 100)
                                            .multilineTextAlignment(.trailing)
                                            .monospacedDigit()
                                            .padding(.horizontal, 4)

                                            Text(NSLocalizedString("score.pointsUnit", comment: "Points unit"))
                                                .font(.caption)
                                                .foregroundStyle(Color.appTextSecondary)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text(L10n.CommonUI.preview)
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(0..<min(numberOfRounds, 3), id: \.self) { index in
                                HStack {
                                    Text(L10n.CommonUI.roundPreview(index + 1))
                                        .font(.subheadline)
                                    Text(getRoundName(for: index))
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    if let points = getRoundPoints(for: index) {
                                        Text(String(format: NSLocalizedString("common.points.count", comment: "Points count"), points))
                                            .font(.caption)
                                            .foregroundStyle(Color.appTextSecondary)
                                    } else {
                                        Text(L10n.Round.noMaxPoints)
                                            .font(.caption)
                                            .foregroundStyle(Color.appTextSecondary)
                                    }
                                }
                                .padding(.horizontal, AppSpacing.xs)
                                .padding(.vertical, AppSpacing.xxs)
                                .background(Color.appBackgroundSecondary)
                                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                            }

                            if numberOfRounds > 3 {
                                Text("... und \(numberOfRounds - 3) weitere")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .padding(.leading, 12)
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
            }
            
            // Action Buttons
            HStack(spacing: AppSpacing.sm) {
                Button {
                    dismiss()
                } label: {
                    Text(L10n.Navigation.cancel)
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.escape)
                .secondaryGlassButton(size: .large)
                
                Button {
                    createRounds()
                    dismiss()
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("\(numberOfRounds) Runden erstellen")
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .primaryGlassButton(size: .large)
            }
            .padding(.horizontal, AppSpacing.xxl)
            .padding(.vertical, AppSpacing.sectionSpacing)
        }
        .frame(width: 650, height: 800)
        .background(Color.appBackground)
        .onAppear {
            updateRoundNames()
            updateRoundPoints()
        }
    }
    
    private func updateRoundNames() {
        if useCustomNames {
            while roundNames.count < numberOfRounds {
                roundNames.append("Runde \(roundNames.count + 1)")
            }
        }
    }
    
    private func updateRoundPoints() {
        if useCustomPoints {
            while roundPoints.count < numberOfRounds {
                roundPoints.append(hasMaxPoints ? maxPointsPerRound : nil)
            }
        }
    }
    
    private func getRoundName(for index: Int) -> String {
        if useCustomNames && roundNames.indices.contains(index) && !roundNames[index].isEmpty {
            return roundNames[index]
        }
        return "Runde \(index + 1)"
    }
    
    private func getRoundPoints(for index: Int) -> Int? {
        if useCustomPoints && roundPoints.indices.contains(index) {
            return roundPoints[index]
        }
        return hasMaxPoints ? maxPointsPerRound : nil
    }

    private func createRounds() {
        for index in 0..<numberOfRounds {
            let name = getRoundName(for: index)
            let points = getRoundPoints(for: index)
            viewModel.addRound(to: quiz, name: name, maxPoints: points)
        }
    }
}

