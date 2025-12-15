//
//  DebugDataView.swift
//  PubRanker
//
//  Created on 14.12.2024
//

import SwiftUI
import SwiftData

struct DebugDataView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var quizzes: [Quiz]
    @Query private var teams: [Team]

    @State private var showingConfirmation = false
    @State private var actionToConfirm: DebugAction?

    var body: some View {
        NavigationStack {
            List {
                Section("Aktuelle Daten") {
                    HStack {
                        Text("Quizze")
                        Spacer()
                        Text("\(quizzes.count)")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Teams")
                        Spacer()
                        Text("\(teams.count)")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Testdaten laden") {
                    Button {
                        actionToConfirm = .quickDemo
                        showingConfirmation = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quick Demo")
                                .font(.headline)
                            Text("1 aktives Quiz mit 24 Teams, 4 abgeschlossene Runden")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        actionToConfirm = .fullDemo
                        showingConfirmation = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Vollständiges Demo")
                                .font(.headline)
                            Text("7 Quizze (1 aktiv, 1 abgeschlossen, 5 geplant)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        actionToConfirm = .globalTeams
                        showingConfirmation = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Nur Globale Teams")
                                .font(.headline)
                            Text("35 Teams ohne Quiz-Zuordnung")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Daten verwalten") {
                    Button(role: .destructive) {
                        actionToConfirm = .deleteAll
                        showingConfirmation = true
                    } label: {
                        Label("Alle Daten löschen", systemImage: "trash")
                    }
                }

                Section {
                    Text("Diese View ist nur für Entwicklung/Testing gedacht. Testdaten enthalten realistische Team-Namen, Scores und Quiz-Szenarien.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Debug & Testdaten")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
            .confirmationDialog(
                actionToConfirm?.title ?? "",
                isPresented: $showingConfirmation,
                titleVisibility: .visible
            ) {
                Button(actionToConfirm?.confirmButtonText ?? "Bestätigen", role: actionToConfirm?.isDestructive == true ? .destructive : nil) {
                    performAction(actionToConfirm)
                }
                Button("Abbrechen", role: .cancel) {}
            } message: {
                Text(actionToConfirm?.message ?? "")
            }
        }
    }

    // MARK: - Actions

    private func performAction(_ action: DebugAction?) {
        guard let action else { return }

        switch action {
        case .quickDemo:
            loadQuickDemo()
        case .fullDemo:
            loadFullDemo()
        case .globalTeams:
            loadGlobalTeams()
        case .deleteAll:
            deleteAllData()
        }
    }

    private func loadQuickDemo() {
        let quiz = SampleData.setupQuickDemo(in: modelContext)
        print("Quick Demo geladen: \(quiz.name)")
    }

    private func loadFullDemo() {
        SampleData.setupFullDemo(in: modelContext)
        print("Vollständiges Demo geladen")
    }

    private func loadGlobalTeams() {
        let teams = SampleData.createGlobalTeams(in: modelContext)
        try? modelContext.save()
        print("\(teams.count) Teams geladen")
    }

    private func deleteAllData() {
        // Lösche alle Quizze (Teams bleiben durch deleteRule: .nullify erhalten)
        for quiz in quizzes {
            modelContext.delete(quiz)
        }

        // Lösche alle Teams
        for team in teams {
            modelContext.delete(team)
        }

        try? modelContext.save()
        print("Alle Daten gelöscht")
    }
}

// MARK: - Debug Action

enum DebugAction {
    case quickDemo
    case fullDemo
    case globalTeams
    case deleteAll

    var title: String {
        switch self {
        case .quickDemo:
            return "Quick Demo laden?"
        case .fullDemo:
            return "Vollständiges Demo laden?"
        case .globalTeams:
            return "Globale Teams laden?"
        case .deleteAll:
            return "Alle Daten löschen?"
        }
    }

    var message: String {
        switch self {
        case .quickDemo:
            return "Lädt 1 aktives Quiz mit 24 Teams und 8 Runden (4 abgeschlossen)."
        case .fullDemo:
            return "Lädt 7 verschiedene Quizze: 1 aktives, 1 abgeschlossenes und 5 geplante Quizze in verschiedenen Planungsstadien."
        case .globalTeams:
            return "Lädt 35 Teams in die globale Team-Verwaltung."
        case .deleteAll:
            return "Löscht ALLE Quizze und Teams unwiderruflich. Diese Aktion kann nicht rückgängig gemacht werden!"
        }
    }

    var confirmButtonText: String {
        switch self {
        case .deleteAll:
            return "Löschen"
        default:
            return "Laden"
        }
    }

    var isDestructive: Bool {
        self == .deleteAll
    }
}

// MARK: - Preview

#Preview {
    let schema = Schema([
        Quiz.self,
        Round.self,
        Team.self
    ])

    let configuration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: true
    )

    let container = try! ModelContainer(
        for: schema,
        configurations: configuration
    )

    DebugDataView()
        .modelContainer(container)
}
