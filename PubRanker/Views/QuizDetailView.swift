//
//  QuizDetailView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import AppKit

struct QuizDetailView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var selectedTab: DetailTab = .leaderboard
    @State private var showingTeamWizard = false
    @State private var showingRoundWizard = false
    @State private var showingSetupDialog = false
    @State private var hasCheckedInitialSetup = false
    
    enum DetailTab: String, CaseIterable, Identifiable {
        case leaderboard = "Rangliste"
        case rounds = "Runden"
        case teams = "Teams"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .leaderboard: return "trophy.fill"
            case .rounds: return "list.number"
            case .teams: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            QuizHeaderView(quiz: quiz, viewModel: viewModel)
            
            Divider()
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .leaderboard:
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
        .alert("🎯 Quiz-Setup", isPresented: $showingSetupDialog) {
            Button("Später einrichten", role: .cancel) {
                showingSetupDialog = false
            }
            Button("Jetzt starten 🚀") {
                showingSetupDialog = false
                // Kleine Verzögerung für bessere UX
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingTeamWizard = true
                    selectedTab = .teams
                }
            }
            .keyboardShortcut(.defaultAction)
        } message: {
            Text("Möchten Sie jetzt Teams und Runden einrichten?\n\n✓ Teams hinzufügen\n✓ Runden definieren\n\nSie können dies auch später über die Tabs machen.")
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
    @State private var showingExportDialog = false
    @State private var exportedFileURL: URL?
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 20) {
                // Quiz Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(quiz.name)
                            .font(.title2)
                            .bold()
                        
                        if quiz.isActive {
                            Label("Live", systemImage: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .clipShape(Capsule())
                        } else if quiz.isCompleted {
                            Label("Beendet", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Label("\(quiz.safeTeams.count) Teams", systemImage: "person.3")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    // Export Button (immer verfügbar, aber prominent bei abgeschlossenen Quizzen)
                    Menu {
                        Button {
                            exportQuiz(format: .json)
                        } label: {
                            Label("Als JSON exportieren", systemImage: "doc.text")
                        }
                        
                        Button {
                            exportQuiz(format: .csv)
                        } label: {
                            Label("Als CSV exportieren", systemImage: "tablecells")
                        }
                    } label: {
                        if quiz.isCompleted {
                            Label("Exportieren", systemImage: "square.and.arrow.up")
                        } else {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                    .buttonStyle(quiz.isCompleted ? .bordered : .borderless)
                    .help("Quiz exportieren")
                    
                    if quiz.isActive {
                        Button {
                            viewModel.completeQuiz(quiz)
                        } label: {
                            Label("Quiz beenden", systemImage: "flag.checkered")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .keyboardShortcut("e", modifiers: .command)
                        .help("Quiz beenden (⌘E)")
                    } else if !quiz.isCompleted {
                        Button {
                            viewModel.startQuiz(quiz)
                        } label: {
                            Label("Quiz starten", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .keyboardShortcut("s", modifiers: .command)
                        .help("Quiz starten (⌘S)")
                    }
                }
            }
            
            // Progress Bar
            if quiz.safeRounds.count > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Fortschritt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(quiz.completedRoundsCount) von \(quiz.safeRounds.count) Runden")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ProgressView(value: quiz.progress)
                        .tint(.blue)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .windowBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .alert("Quiz exportiert", isPresented: $showingExportDialog) {
            if let fileURL = exportedFileURL {
                Button("Im Finder anzeigen") {
                    NSWorkspace.shared.selectFile(fileURL.path, inFileViewerRootedAtPath: "")
                }
                Button("Teilen...") {
                    let picker = NSSharingServicePicker(items: [fileURL])
                    if let view = NSApp.keyWindow?.contentView {
                        picker.show(relativeTo: .zero, of: view, preferredEdge: .minY)
                    }
                }
            }
            Button("OK") {}
        } message: {
            if let fileURL = exportedFileURL {
                Text("Das Quiz wurde erfolgreich exportiert:\n\(fileURL.lastPathComponent)")
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
