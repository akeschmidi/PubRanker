//
//  QuizDetailView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct QuizDetailView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var selectedTab: DetailTab = .overview
    @State private var showingTeamWizard = false
    @State private var showingRoundWizard = false
    @State private var showingSetupDialog = false
    @State private var showingEmailComposer = false
    @State private var hasCheckedInitialSetup = false
    
    enum DetailTab: String, CaseIterable, Identifiable {
        case overview = "Übersicht"
        case rounds = "Runden"
        case teams = "Teams"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .overview: return "trophy.fill"
            case .rounds: return "list.number"
            case .teams: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            QuizHeaderView(quiz: quiz, viewModel: viewModel, showingEmailComposer: $showingEmailComposer)
            
            Divider()
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .overview:
                    LeaderboardView(quiz: quiz, viewModel: viewModel)
                case .rounds:
                    RoundManagementView(quiz: quiz, viewModel: viewModel)
                case .teams:
                    TeamManagementView(quiz: quiz, viewModel: viewModel)
                }
            }
        }
        .navigationTitle(quiz.name)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Ansicht", selection: $selectedTab) {
                    ForEach(DetailTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 400)
            }
        }
        .sheet(isPresented: $showingTeamWizard, onDismiss: {
            // Nach Team-Setup: Prüfe ob Runden-Setup nötig ist
            // Nur wenn tatsächlich Teams hinzugefügt wurden
            if !quiz.safeTeams.isEmpty && quiz.safeRounds.isEmpty {
                // Kleine Verzögerung für bessere UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingRoundWizard = true
                }
            }
        }) {
            TeamSetupWizard(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingRoundWizard) {
            RoundWizardSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingEmailComposer) {
            EmailComposerView(teams: quiz.safeTeams, quiz: quiz)
        }
        .alert(NSLocalizedString("setup.dialog.title", comment: "Setup dialog title"), isPresented: $showingSetupDialog) {
            Button(NSLocalizedString("setup.dialog.later", comment: "Setup later button"), role: .cancel) {
                showingSetupDialog = false
            }
            Button(NSLocalizedString("setup.dialog.start", comment: "Start setup now button")) {
                showingSetupDialog = false
                // Kleine Verzögerung für bessere UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingTeamWizard = true
                    selectedTab = .teams
                }
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text(NSLocalizedString("setup.dialog.message", comment: "Setup dialog message"))
        }
        .onAppear {
            checkInitialSetup()
        }
    }
    
    private func checkInitialSetup() {
        // Nur beim ersten Mal prüfen
        guard !hasCheckedInitialSetup else { return }
        hasCheckedInitialSetup = true
        
        // Wenn Quiz neu ist (keine Teams UND keine Runden), Setup-Dialog anzeigen
        if quiz.safeTeams.isEmpty && quiz.safeRounds.isEmpty {
            // Kleine Verzögerung für bessere UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                showingSetupDialog = true
            }
        }
    }
}

struct QuizHeaderView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    var showingEmailComposer: Binding<Bool>?  // Optional - only on macOS
    @State private var showingExportDialog = false
    @State private var exportedFileURL: URL?
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            HStack(alignment: .top, spacing: AppSpacing.md) {
                // Quiz Info
                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    HStack {
                        Text(quiz.name)
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                        
                        if quiz.isActive {
                            Label(NSLocalizedString("status.live", comment: "Live status"), systemImage: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppSpacing.xxs)
                                .padding(.vertical, AppSpacing.xxxs)
                                .background(Color.appSuccess)
                                .clipShape(Capsule())
                        } else if quiz.isCompleted {
                            Label(NSLocalizedString("status.completed", comment: "Completed status"), systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, AppSpacing.xxs)
                                .padding(.vertical, AppSpacing.xxxs)
                                .background(Color.appPrimary)
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: AppSpacing.sm) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                        
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                        
                        Label(String(format: NSLocalizedString("quiz.teams.count", comment: "Teams count"), quiz.safeTeams.count), systemImage: "person.3")
                            .font(.subheadline)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: AppSpacing.xs) {
                    // E-Mail Button
                    if !quiz.safeTeams.isEmpty, let emailBinding = showingEmailComposer {
                        Button {
                            emailBinding.wrappedValue = true
                        } label: {
                            Label(NSLocalizedString("email.send.quiz", comment: "Email to quiz teams"), systemImage: "envelope.fill")
                        }
                        .accentGradientButton()
                        .helpText(NSLocalizedString("email.send.quiz", comment: "Email to quiz teams"))
                    }
                    
                    // Export Button (immer verfügbar, aber prominent bei abgeschlossenen Quizzen)
                    Menu {
                        Button {
                            exportQuiz(format: .json)
                        } label: {
                            Label(NSLocalizedString("export.json", comment: "Export as JSON"), systemImage: "doc.text")
                        }
                        
                        Button {
                            exportQuiz(format: .csv)
                        } label: {
                            Label(NSLocalizedString("export.csv", comment: "Export as CSV"), systemImage: "tablecells")
                        }
                    } label: {
                        if quiz.isCompleted {
                            Label(NSLocalizedString("export.title", comment: "Export"), systemImage: "square.and.arrow.up")
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .secondaryGradientButton()
                    .helpText(NSLocalizedString("export.title", comment: "Export quiz"))
                    
                    if quiz.isActive {
                        Button {
                            viewModel.completeQuiz(quiz)
                        } label: {
                            Label(NSLocalizedString("status.complete", comment: "Complete quiz"), systemImage: "flag.checkered")
                        }
                        .accentGradientButton()
                        .keyboardShortcut("e", modifiers: .command)
                        .helpText(NSLocalizedString("status.complete", comment: "Complete quiz") + " (⌘E)")
                    } else if !quiz.isCompleted {
                        Button {
                            viewModel.startQuiz(quiz)
                        } label: {
                            Label(NSLocalizedString("status.start", comment: "Start quiz"), systemImage: "play.fill")
                        }
                        .primaryGradientButton()
                        .keyboardShortcut("s", modifiers: .command)
                        .helpText(NSLocalizedString("status.start", comment: "Start quiz") + " (⌘S)")
                    }
                }
            }
            
            // Progress Bar
            if quiz.safeRounds.count > 0 {
                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    HStack {
                        Text(NSLocalizedString("status.progress", comment: "Progress"))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        Spacer()
                        Text(String(format: NSLocalizedString("status.roundsCompleted", comment: "Rounds completed"), quiz.completedRoundsCount, quiz.safeRounds.count))
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                    
                    ProgressView(value: quiz.progress)
                        .tint(Color.appPrimary)
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            LinearGradient(
                colors: [Color.appBackgroundSecondary, Color.appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert(NSLocalizedString("export.success.title", comment: "Export success title"), isPresented: $showingExportDialog) {
            if let fileURL = exportedFileURL {
                #if os(macOS)
                Button(NSLocalizedString("export.showInFinder", comment: "Show in Finder")) {
                    NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
                }
                Button(NSLocalizedString("export.share", comment: "Share")) {
                    let picker = NSSharingServicePicker(items: [fileURL])
                    if let view = NSApp.keyWindow?.contentView {
                        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
                    }
                }
                #else
                Button(NSLocalizedString("export.share", comment: "Share")) {
                    // iOS Share wird über UIActivityViewController gehandhabt
                }
                #endif
            }
            Button("OK") {}
        } message: {
            if let fileURL = exportedFileURL {
                Text(String(format: NSLocalizedString("export.success.message", comment: "Export success message"), fileURL.lastPathComponent))
            }
        }
    }
    
    private func exportQuiz(format: ExportFormat) {
        if let fileURL = viewModel.saveQuizExport(quiz: quiz, format: format) {
            exportedFileURL = fileURL
            showingExportDialog = true
        }
    }
}
