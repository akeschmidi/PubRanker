//
//  CloudKitSyncButton.swift
//  PubRanker
//
//  CloudKit Sync Status und manueller Sync-Button
//

import SwiftUI
import SwiftData

struct CloudKitSyncButton: View {
    @Environment(CloudKitSyncManager.self) private var syncManager
    @State private var showingDiagnostics = false
    @State private var diagnosticsText = ""

    var body: some View {
        Button {
            Task {
                // Vollständiger Sync: Push + Pull
                await syncManager.fullSync()
            }
        } label: {
            Image(systemName: syncManager.statusIcon)
                .symbolEffect(.pulse, isActive: syncManager.isSyncing)
                .foregroundStyle(statusColor)
        }
        .buttonStyle(.plain)
        .disabled(syncManager.isSyncing)
        #if os(macOS)
        .help(helpText)
        #endif
        .contextMenu {
            Button {
                Task {
                    await syncManager.fullSync()
                }
            } label: {
                Label("Vollständiger Sync", systemImage: "arrow.triangle.2.circlepath")
            }
            
            Divider()
            
            Button {
                Task {
                    await syncManager.forceSyncNow()
                }
            } label: {
                Label("Hochladen (Push)", systemImage: "arrow.up.to.line.circle")
            }
            
            Button {
                Task {
                    await syncManager.pullFromCloud()
                }
            } label: {
                Label("Herunterladen (Pull)", systemImage: "arrow.down.to.line.circle")
            }
            
            Divider()
            
            Button {
                Task {
                    diagnosticsText = await syncManager.runDiagnostics()
                    showingDiagnostics = true
                }
            } label: {
                Label("Diagnose anzeigen", systemImage: "stethoscope")
            }
            
            Button {
                Task {
                    await syncManager.checkCloudKitStatus()
                }
            } label: {
                Label("Status aktualisieren", systemImage: "arrow.clockwise")
            }
        }
        .alert("CloudKit Diagnose", isPresented: $showingDiagnostics) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(diagnosticsText)
        }
    }

    private var statusColor: Color {
        switch syncManager.syncStatus {
        case .idle:
            return Color.appTextSecondary
        case .syncing:
            return .blue
        case .success:
            return .green
        case .error:
            return .orange
        case .notAvailable:
            return .red
        }
    }

    private var helpText: String {
        #if DEBUG
        return "CloudKit Sync ist im Debug-Build deaktiviert"
        #else
        switch syncManager.syncStatus {
        case .idle:
            return "Klicken für Sync\nRechtsklick für mehr Optionen"
        case .syncing:
            return "Synchronisiert mit iCloud..."
        case .success:
            return "Erfolgreich synchronisiert"
        case .error(let message):
            return "Sync-Fehler: \(message)"
        case .notAvailable(let reason):
            return "Nicht verfügbar: \(reason)\nRechtsklick für Diagnose"
        }
        #endif
    }
}

#Preview {
    @Previewable @State var syncManager = CloudKitSyncManager(
        modelContext: ModelContext(
            try! ModelContainer(
                for: Quiz.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        )
    )

    CloudKitSyncButton()
        .environment(syncManager)
        .padding()
}
