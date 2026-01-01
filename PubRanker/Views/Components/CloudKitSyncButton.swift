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

    var body: some View {
        Button {
            Task {
                await syncManager.forceSyncNow()
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: syncManager.statusIcon)
                    .symbolEffect(.pulse, isActive: syncManager.isSyncing)
                    .foregroundStyle(statusColor)

                #if os(macOS)
                Text(syncManager.statusText)
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                #endif
            }
        }
        .buttonStyle(.plain)
        .disabled(syncManager.isSyncing)
        #if os(macOS)
        .help(helpText)
        #endif
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
            return .red
        }
    }

    private var helpText: String {
        #if DEBUG
        return "CloudKit Sync ist im Debug-Build deaktiviert"
        #else
        switch syncManager.syncStatus {
        case .idle:
            return "Klicken für manuellen Sync"
        case .syncing:
            return "Synchronisiert mit iCloud..."
        case .success:
            return "Erfolgreich synchronisiert"
        case .error(let message):
            return "Sync-Fehler: \(message)"
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
