//
//  EmailComposerView.swift
//  PubRanker
//
//  Created on 23.11.2025
//  Note: This view is macOS-only due to HSplitView usage
//

import SwiftUI
import SwiftData

#if os(macOS)

struct EmailComposerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quiz.date, order: .reverse) private var allQuizzes: [Quiz]

    let teams: [Team]
    let quiz: Quiz?

    @State private var selectedTeamIds: Set<UUID> = []
    @State private var selectedQuizIds: Set<UUID> = []
    @State private var subject: String = ""
    @State private var emailBody: String = ""
    @State private var searchText: String = ""
    @State private var showTemplates: Bool = false
    @State private var filterMode: FilterMode = .allTeams
    @State private var sortOption: EmailTeamSortOption = .nameAsc

    enum FilterMode {
        case allTeams
        case byQuiz
    }

    enum EmailTeamSortOption: String, CaseIterable {
        case nameAsc = "A → Z"
        case nameDesc = "Z → A"
        case contactPerson = "Kontaktperson"
        case email = "E-Mail"

        var icon: String {
            switch self {
            case .nameAsc: return "arrow.up"
            case .nameDesc: return "arrow.down"
            case .contactPerson: return "person"
            case .email: return "envelope"
            }
        }
    }

    init(teams: [Team], quiz: Quiz? = nil) {
        self.teams = teams
        self.quiz = quiz
    }

    var filteredTeams: [Team] {
        var result = teams

        // Filter by quiz (only when in byQuiz mode)
        if filterMode == .byQuiz && !selectedQuizIds.isEmpty {
            result = result.filter { team in
                guard let teamQuizzes = team.quizzes else { return false }
                return teamQuizzes.contains { selectedQuizIds.contains($0.id) }
            }
        }

        // Filter by search
        if !searchText.isEmpty {
            result = result.filter { team in
                team.name.localizedCaseInsensitiveContains(searchText) ||
                team.email.localizedCaseInsensitiveContains(searchText) ||
                team.contactPerson.localizedCaseInsensitiveContains(searchText)
            }
        }

        return result
    }

    var teamsWithEmail: [Team] {
        let filtered = filteredTeams.filter { !$0.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

        switch sortOption {
        case .nameAsc:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .nameDesc:
            return filtered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedDescending }
        case .contactPerson:
            return filtered.sorted { $0.contactPerson.localizedCaseInsensitiveCompare($1.contactPerson) == .orderedAscending }
        case .email:
            return filtered.sorted { $0.email.localizedCaseInsensitiveCompare($1.email) == .orderedAscending }
        }
    }

    var selectedTeams: [Team] {
        teamsWithEmail.filter { selectedTeamIds.contains($0.id) }
    }

    var allSelected: Bool {
        !teamsWithEmail.isEmpty && selectedTeamIds.count == teamsWithEmail.count
    }
    
    /// Dynamischer Titel basierend auf Quiz-Auswahl
    private var emailComposerTitle: String {
        if let quiz = quiz {
            return String(format: NSLocalizedString("email.composer.quiz.title", comment: ""), quiz.name)
        } else {
            return NSLocalizedString("email.composer.title", comment: "")
        }
    }
    
    /// Dynamischer Untertitel mit Empfänger-Anzahl
    private var emailComposerSubtitle: String {
        let count = teamsWithEmail.count
        if count > 0 {
            return String(format: NSLocalizedString("email.composer.recipientsAvailable", comment: ""), count)
        }
        return ""
    }

    var body: some View {
        NavigationStack {
            HSplitView {
                // Left Sidebar - Team Selection
                teamSelectionPanel
                    .frame(minWidth: 300, idealWidth: 350, maxWidth: 400)

                // Main Content - Email Composer
                emailComposerPanel
                    .frame(minWidth: 500)
            }
            .navigationTitle(emailComposerTitle)
            .navigationSubtitle(emailComposerSubtitle)
            .toolbarBackground(.visible, for: .windowToolbar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text(NSLocalizedString("navigation.cancel", comment: ""))
                    }
                    .secondaryGlassButton()
                    .keyboardShortcut(.cancelAction)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        sendEmail()
                    } label: {
                        Label(NSLocalizedString("email.composer.send", comment: ""), systemImage: "envelope.open.fill")
                    }
                    .disabled(selectedTeams.isEmpty || subject.isEmpty)
                    .primaryGlassButton()
                    .keyboardShortcut(.return, modifiers: .command)
                }
            }
            .onAppear(perform: initializeEmail)
        }
        #if os(macOS)
        .frame(minWidth: 1000, idealWidth: 1200, minHeight: 700, idealHeight: 800)
        #else
        .frame(minWidth: 320, minHeight: 600)
        #endif
    }

    // MARK: - Team Selection Panel

    private var teamSelectionPanel: some View {
        VStack(spacing: 0) {
            // Header with count and sort
            HStack {
                Text(NSLocalizedString("quiz.teams", comment: ""))
                    .font(.headline)

                Spacer()

                // Sort Dropdown
                Menu {
                    ForEach(EmailTeamSortOption.allCases, id: \.self) { option in
                        Button {
                            sortOption = option
                        } label: {
                            Label(option.rawValue, systemImage: option.icon)
                        }
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: sortOption.icon)
                            .font(.caption)
                        Text(sortOption.rawValue)
                            .font(.caption)
                        Image(systemName: "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(Color.appPrimary)
                    .padding(.horizontal, AppSpacing.xs)
                    .padding(.vertical, AppSpacing.xxs)
                    .background(Color.appPrimary.opacity(0.1))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Text("\(selectedTeams.count)/\(teamsWithEmail.count)")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
            }
            .padding()
            .padding(.top, 50)
            .background(.background)

            Divider()

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color.appTextSecondary)
                TextField(NSLocalizedString("email.composer.search", comment: ""), text: $searchText)
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
            .padding(AppSpacing.xxs)
            .background(Color.appBackgroundSecondary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xs))
            .padding(.horizontal, AppSpacing.screenPadding)
            .padding(.top, AppSpacing.xs)

            // Filter Mode Selector
            if !allQuizzes.isEmpty && quiz == nil {
                VStack(spacing: 8) {
                    Picker(NSLocalizedString("common.filter", comment: ""), selection: $filterMode) {
                        Text(NSLocalizedString("email.composer.filter.all", comment: "")).tag(FilterMode.allTeams)
                        Text(NSLocalizedString("email.composer.filter.byQuiz", comment: "")).tag(FilterMode.byQuiz)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: filterMode) { _, newValue in
                        if newValue == .allTeams {
                            selectedQuizIds.removeAll()
                        }
                    }

                    if filterMode == .byQuiz {
                        Menu {
                            ForEach(allQuizzes) { quiz in
                                Button {
                                    if selectedQuizIds.contains(quiz.id) {
                                        selectedQuizIds.remove(quiz.id)
                                    } else {
                                        selectedQuizIds.insert(quiz.id)
                                    }
                                } label: {
                                    HStack {
                                        if selectedQuizIds.contains(quiz.id) {
                                            Image(systemName: "checkmark")
                                        }
                                        Text(quiz.name)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedQuizIds.isEmpty ? NSLocalizedString("email.composer.selectQuizzes", comment: "") : String(format: NSLocalizedString("email.composer.quizzesSelected", comment: ""), selectedQuizIds.count, selectedQuizIds.count == 1 ? "" : "zes"))
                                    .foregroundStyle(selectedQuizIds.isEmpty ? .secondary : .primary)
                                Spacer()
                                Image(systemName: "chevron.down")
                                    .foregroundStyle(.secondary)
                                    .font(.caption)
                            }
                            .padding(8)
                            .background(Color.appBackgroundSecondary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xs))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }

            Divider()

            // Select All Toggle
            HStack {
                Toggle(isOn: Binding(
                    get: { allSelected },
                    set: { newValue in
                        if newValue {
                            selectedTeamIds = Set(teamsWithEmail.map { $0.id })
                        } else {
                            selectedTeamIds.removeAll()
                        }
                    }
                )) {
                    Text(allSelected ? "Alle abwählen" : "Alle auswählen")
                        .font(.subheadline)
                }
                .toggleStyle(.switch)

                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, AppSpacing.xs)
            .background(.background)

            Divider()

            // Team List
            if teamsWithEmail.isEmpty {
                ContentUnavailableView {
                    Label(NSLocalizedString("email.composer.noTeams", comment: ""), systemImage: "person.slash")
                } description: {
                    Text(NSLocalizedString("email.composer.noTeams.description", comment: ""))
                }
                .frame(maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 4) {
                        ForEach(teamsWithEmail) { team in
                            TeamSelectionRow(
                                team: team,
                                isSelected: selectedTeamIds.contains(team.id)
                            ) {
                                toggleTeam(team)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                }
            }
        }
    }

    private func toggleTeam(_ team: Team) {
        if selectedTeamIds.contains(team.id) {
            selectedTeamIds.remove(team.id)
        } else {
            selectedTeamIds.insert(team.id)
        }
    }

    // MARK: - Email Composer Panel

    private var emailComposerPanel: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Recipients Section (Compact, wraps automatically)
                if !selectedTeams.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(NSLocalizedString("email.composer.to", comment: ""))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(String(format: NSLocalizedString("email.composer.recipientCount", comment: ""), selectedTeams.count, selectedTeams.count == 1 ? "" : "s"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        FlowLayout(spacing: 6) {
                            ForEach(selectedTeams) { team in
                                RecipientTag(team: team) {
                                    selectedTeamIds.remove(team.id)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, AppSpacing.md)
                    .background(Color.appBackgroundSecondary.opacity(0.3))

                    Divider()
                }

                // Subject Field
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("email.composer.subject", comment: ""))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField(NSLocalizedString("email.composer.subject.placeholder", comment: ""), text: $subject)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()

                Divider()

                // Message Body
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(NSLocalizedString("email.composer.body", comment: ""))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            showTemplates = true
                        } label: {
                            Label(NSLocalizedString("email.composer.insertTemplate", comment: ""), systemImage: "doc.text")
                                .font(.caption)
                        }
                        .buttonStyle(.borderless)
                        .popover(isPresented: $showTemplates) {
                            TemplatePickerView { template in
                                applyTemplate(template)
                                showTemplates = false
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top)

                    TextEditor(text: $emailBody)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                        .background(Color.appBackground)
                        .frame(minHeight: 300)
                        .overlay {
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                }
            }
            .padding(.top, 50)
        }
        .scrollClipDisabled(false)
        .background(Color(nsColor: .textBackgroundColor))
    }

    // MARK: - Helper Functions

    private func initializeEmail() {
        if let quiz = quiz {
            subject = EmailService.defaultSubject(for: quiz)
            emailBody = EmailService.defaultBody(for: quiz)
        } else {
            subject = NSLocalizedString("email.composer.defaultSubject", comment: "")
            emailBody = NSLocalizedString("email.composer.defaultBody", comment: "")
        }

        if !teamsWithEmail.isEmpty {
            selectedTeamIds = Set(teamsWithEmail.map { $0.id })
        }
    }

    private func sendEmail() {
        EmailService.sendEmail(
            to: selectedTeams,
            subject: subject,
            body: emailBody
        )
        dismiss()
    }

    private func applyTemplate(_ template: EmailTemplate) {
        subject = template.subject
        emailBody = template.body
    }

    private var selectedQuizzes: [Quiz] {
        allQuizzes.filter { selectedQuizIds.contains($0.id) }
    }
}

// MARK: - Team Selection Row

struct TeamSelectionRow: View {
    let team: Team
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button {
            onToggle()
        } label: {
            HStack(spacing: 10) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isSelected ? Color.appPrimary : Color.appTextSecondary)
                    .font(.title3)

                // Team Icon
                TeamIconView(team: team, size: 28)

                // Team Info
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.body)
                        .foregroundStyle(Color.appTextPrimary)

                    if !team.contactPerson.isEmpty {
                        Text(team.contactPerson)
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    Text(team.email)
                        .font(.caption2)
                        .foregroundStyle(Color.appPrimary)
                }

                Spacer()
            }
            .padding(.horizontal, AppSpacing.xxs)
            .padding(.vertical, AppSpacing.xxs)
            .contentShape(Rectangle())
            .background(isSelected ? Color.appPrimary.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xs))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recipient Tag

struct RecipientTag: View {
    let team: Team
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            TeamIconView(team: team, size: 16)
            Text(team.name)
                .font(.caption)
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.xxs)
        .padding(.vertical, AppSpacing.xxxs)
        .background(Color.appPrimary.opacity(0.15))
        .clipShape(Capsule())
        .overlay {
            Capsule()
                .strokeBorder(Color.appPrimary.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - Template Picker View

struct TemplatePickerView: View {
    let onSelect: (EmailTemplate) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "doc.text.fill")
                    .foregroundStyle(Color.appPrimary)
                Text(NSLocalizedString("email.composer.templates.title", comment: ""))
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(.regularMaterial)

            Divider()

            ScrollView {
                VStack(spacing: 8) {
                    ForEach(EmailTemplate.templates) { template in
                        Button {
                            onSelect(template)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: template.icon)
                                    .font(.title3)
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                                    Text(template.name)
                                        .font(.headline)
                                        .foregroundStyle(Color.appTextPrimary)

                                    Text(template.subject)
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextSecondary)
                                        .lineLimit(2)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(12)
                            .background(.quaternary.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
        .frame(width: 450, height: 500)
    }
}


// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += lineHeight + spacing
                    lineHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                lineHeight = max(lineHeight, size.height)
                x += size.width + spacing
            }

            self.size = CGSize(width: maxWidth, height: y + lineHeight)
        }
    }
}
#endif

// MARK: - iOS Email Composer

#if os(iOS)
import MessageUI

/// Simplified Email Composer for iOS/iPadOS
/// Uses native MFMailComposeViewController for sending
struct EmailComposerView: View {
    @Environment(\.dismiss) private var dismiss
    
    let teams: [Team]
    let quiz: Quiz?
    
    @State private var selectedTeamIds: Set<UUID> = []
    @State private var subject: String = ""
    @State private var emailBody: String = ""
    @State private var searchText: String = ""
    @State private var showingMailComposer = false
    @State private var showingNoMailAlert = false
    @State private var mailResult: String?
    
    init(teams: [Team], quiz: Quiz? = nil) {
        self.teams = teams
        self.quiz = quiz
    }
    
    private var filteredTeams: [Team] {
        let teamsWithEmail = teams.filter { !$0.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if searchText.isEmpty {
            return teamsWithEmail
        }
        
        return teamsWithEmail.filter { team in
            team.name.localizedCaseInsensitiveContains(searchText) ||
            team.email.localizedCaseInsensitiveContains(searchText) ||
            team.contactPerson.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private var selectedTeams: [Team] {
        filteredTeams.filter { selectedTeamIds.contains($0.id) }
    }
    
    private var allSelected: Bool {
        !filteredTeams.isEmpty && selectedTeamIds.count == filteredTeams.count
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Subject & Body
                VStack(spacing: AppSpacing.sm) {
                    TextField(NSLocalizedString("email.composer.subject", comment: "Subject"), text: $subject)
                        .textFieldStyle(.roundedBorder)
                    
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $emailBody)
                            .frame(minHeight: 100, maxHeight: 150)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        if emailBody.isEmpty {
                            Text(NSLocalizedString("email.composer.body.placeholder", comment: "Message placeholder"))
                                .foregroundStyle(Color.gray.opacity(0.5))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 12)
                                .allowsHitTesting(false)
                        }
                    }
                }
                .padding()
                .background(Color.adaptiveCardBackground)
                
                Divider()
                
                // Team Selection Header
                HStack {
                    Text("\(selectedTeamIds.count) von \(filteredTeams.count) Teams ausgewählt")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Spacer()
                    
                    Button {
                        if allSelected {
                            selectedTeamIds.removeAll()
                        } else {
                            selectedTeamIds = Set(filteredTeams.map { $0.id })
                        }
                    } label: {
                        Text(allSelected ? "Keine" : "Alle")
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, AppSpacing.xs)
                
                // Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(Color.appTextTertiary)
                    TextField(NSLocalizedString("email.composer.search", comment: "Search teams"), text: $searchText)
                }
                .padding(AppSpacing.xs)
                .background(Color.adaptiveControlBackground)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                
                Divider()
                    .padding(.top, AppSpacing.xs)
                
                // Team List
                List(filteredTeams, selection: $selectedTeamIds) { team in
                    TeamEmailRow(team: team, isSelected: selectedTeamIds.contains(team.id)) {
                        if selectedTeamIds.contains(team.id) {
                            selectedTeamIds.remove(team.id)
                        } else {
                            selectedTeamIds.insert(team.id)
                        }
                    }
                }
                .listStyle(.plain)
            }
            .navigationTitle(quiz != nil ? "E-Mail: \(quiz!.name)" : NSLocalizedString("email.composer.title", comment: ""))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(NSLocalizedString("navigation.cancel", comment: "")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        sendEmail()
                    } label: {
                        Label(NSLocalizedString("email.composer.send", comment: ""), systemImage: "envelope.fill")
                    }
                    .disabled(selectedTeams.isEmpty)
                }
            }
            .onAppear {
                setupDefaults()
            }
            .sheet(isPresented: $showingMailComposer) {
                if EmailService.canUseMailComposer {
                    MailComposeView(
                        recipients: selectedTeams.map { $0.email },
                        subject: subject,
                        body: emailBody
                    ) { result in
                        handleMailResult(result)
                    }
                }
            }
            .alert("E-Mail", isPresented: $showingNoMailAlert) {
                Button("OK") {}
            } message: {
                Text("E-Mail konnte nicht gesendet werden. Bitte konfiguriere eine E-Mail-App auf diesem Gerät.")
            }
        }
    }
    
    private func setupDefaults() {
        // Pre-select all teams
        selectedTeamIds = Set(filteredTeams.map { $0.id })
        
        // Set default subject and body if quiz is provided
        if let quiz = quiz {
            subject = EmailService.defaultSubject(for: quiz)
            emailBody = EmailService.defaultBody(for: quiz)
        }
    }
    
    private func sendEmail() {
        if EmailService.canUseMailComposer {
            showingMailComposer = true
        } else {
            // Fallback to mailto: URL
            let recipients = selectedTeams.map { $0.email }.joined(separator: ",")
            EmailService.sendEmail(to: selectedTeams, subject: subject, body: emailBody)
            dismiss()
        }
    }
    
    private func handleMailResult(_ result: Result<MFMailComposeResult, Error>) {
        switch result {
        case .success(let mailResult):
            switch mailResult {
            case .sent:
                print("✅ E-Mail gesendet")
            case .saved:
                print("📝 E-Mail gespeichert")
            case .cancelled:
                print("❌ E-Mail abgebrochen")
            case .failed:
                print("❌ E-Mail fehlgeschlagen")
            @unknown default:
                break
            }
        case .failure(let error):
            print("❌ E-Mail Fehler: \(error.localizedDescription)")
        }
        dismiss()
    }
}

// MARK: - Team Email Row (iOS)

private struct TeamEmailRow: View {
    let team: Team
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: AppSpacing.sm) {
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.appSuccess : Color.appTextTertiary)
                    .font(.title3)
                
                // Team color
                Circle()
                    .fill(Color(hex: team.color) ?? .blue)
                    .frame(width: 12, height: 12)
                
                // Team info
                VStack(alignment: .leading, spacing: 2) {
                    Text(team.name)
                        .font(.body)
                        .foregroundStyle(Color.appTextPrimary)
                    
                    Text(team.email)
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
#endif