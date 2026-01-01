//
//  CloudKitSyncManager.swift
//  PubRanker
//
//  CloudKit Sync Manager für schnellere Synchronisation
//

import Foundation
import SwiftData
import Combine

@Observable
@MainActor
final class CloudKitSyncManager {
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }

    private(set) var syncStatus: SyncStatus = .idle
    private(set) var lastSyncDate: Date?

    private var eventMonitor: Any?
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        #if !DEBUG
        setupNotificationObservers()
        #endif
    }

    deinit {
        // removeObserver ist thread-safe und kann synchron aufgerufen werden
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Notification Observers

    private func setupNotificationObservers() {
        let center = NotificationCenter.default

        // Import-Ereignisse (Daten von CloudKit empfangen)
        center.addObserver(
            self,
            selector: #selector(handleImportNotification(_:)),
            name: Notification.Name("NSPersistentStoreRemoteChange"),
            object: nil
        )

        // Export-Ereignisse (Daten zu CloudKit senden)
        center.addObserver(
            self,
            selector: #selector(handleExportNotification(_:)),
            name: Notification.Name("NSPersistentCloudKitContainer.eventChangedNotification"),
            object: nil
        )

        print("✅ CloudKit Sync Manager: Notifications registriert")
    }

    @objc private func handleImportNotification(_ notification: Notification) {
        Task { @MainActor in
            print("📥 CloudKit: Import-Event empfangen")
            syncStatus = .syncing

            // Kurze Verzögerung, dann Status zurücksetzen
            try? await Task.sleep(for: .seconds(1))
            syncStatus = .success
            lastSyncDate = Date()

            // Nach 3 Sekunden zurück zu idle
            try? await Task.sleep(for: .seconds(3))
            if case .success = syncStatus {
                syncStatus = .idle
            }
        }
    }

    @objc private func handleExportNotification(_ notification: Notification) {
        Task { @MainActor in
            print("📤 CloudKit: Export-Event empfangen")
            syncStatus = .syncing

            try? await Task.sleep(for: .seconds(1))
            syncStatus = .success
            lastSyncDate = Date()

            try? await Task.sleep(for: .seconds(3))
            if case .success = syncStatus {
                syncStatus = .idle
            }
        }
    }

    // MARK: - Manual Sync

    func forceSyncNow() async {
        #if DEBUG
        print("⚠️ CloudKit Sync im Debug-Build deaktiviert")
        return
        #else
        print("🔄 Manueller Sync wird ausgelöst...")
        syncStatus = .syncing

        do {
            // Save erzwingt einen Export zu CloudKit
            try modelContext.save()

            // Kurze Wartezeit
            try await Task.sleep(for: .seconds(2))

            syncStatus = .success
            lastSyncDate = Date()
            print("✅ Manueller Sync abgeschlossen")

            // Nach 3 Sekunden zurück zu idle
            try await Task.sleep(for: .seconds(3))
            if case .success = syncStatus {
                syncStatus = .idle
            }
        } catch {
            print("❌ Sync-Fehler: \(error.localizedDescription)")
            syncStatus = .error(error.localizedDescription)

            // Nach 5 Sekunden zurück zu idle
            try? await Task.sleep(for: .seconds(5))
            if case .error = syncStatus {
                syncStatus = .idle
            }
        }
        #endif
    }

    // MARK: - Status Helpers

    var isSyncing: Bool {
        if case .syncing = syncStatus {
            return true
        }
        return false
    }

    var statusIcon: String {
        switch syncStatus {
        case .idle:
            return "icloud"
        case .syncing:
            return "icloud.and.arrow.up.fill"
        case .success:
            return "icloud.and.arrow.up"
        case .error:
            return "icloud.slash"
        }
    }

    var statusColor: String {
        switch syncStatus {
        case .idle:
            return "secondary"
        case .syncing:
            return "blue"
        case .success:
            return "green"
        case .error:
            return "red"
        }
    }

    var statusText: String {
        switch syncStatus {
        case .idle:
            if let lastSync = lastSyncDate {
                let formatter = RelativeDateTimeFormatter()
                formatter.unitsStyle = .short
                return "Zuletzt: \(formatter.localizedString(for: lastSync, relativeTo: Date()))"
            }
            return "Bereit"
        case .syncing:
            return "Synchronisiert..."
        case .success:
            return "Synchronisiert"
        case .error(let message):
            return "Fehler: \(message)"
        }
    }
}
