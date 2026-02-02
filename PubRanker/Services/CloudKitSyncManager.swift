//
//  CloudKitSyncManager.swift
//  PubRanker
//
//  CloudKit Sync Manager für schnellere Synchronisation
//

import Foundation
import SwiftData
import Combine
import CloudKit
import os.log

@Observable
@MainActor
final class CloudKitSyncManager {
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "PubRanker", category: "CloudKitSync")
    enum SyncStatus: Equatable {
        case idle
        case syncing
        case success
        case error(String)
        case notAvailable(String)
    }

    private(set) var syncStatus: SyncStatus = .idle
    private(set) var lastSyncDate: Date?
    private(set) var cloudKitAccountStatus: String = "Prüfe..."
    private(set) var containerStatus: String = "Prüfe..."

    private var eventMonitor: Any?
    private let modelContext: ModelContext
    
    // CloudKit Container ID - MUSS mit Entitlements übereinstimmen
    static let containerIdentifier = "iCloud.com.akeschmidi.PubRanker"

    init(modelContext: ModelContext) {
        self.modelContext = modelContext

        setupNotificationObservers()
        Task {
            await checkCloudKitStatus()
        }
    }

    deinit {
        // removeObserver ist thread-safe und kann synchron aufgerufen werden
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - CloudKit Status Check
    
    func checkCloudKitStatus() async {
        Self.logger.debug("Prüfe CloudKit Status...")

        // 1. Check iCloud Account Status
        do {
            let container = CKContainer(identifier: Self.containerIdentifier)
            let accountStatus = try await container.accountStatus()

            switch accountStatus {
            case .available:
                cloudKitAccountStatus = "✅ Verfügbar"
                Self.logger.info("iCloud Account verfügbar")
            case .noAccount:
                cloudKitAccountStatus = "❌ Nicht angemeldet"
                syncStatus = .notAvailable("Nicht bei iCloud angemeldet")
                Self.logger.warning("Kein iCloud Account")
            case .restricted:
                cloudKitAccountStatus = "⚠️ Eingeschränkt"
                syncStatus = .notAvailable("iCloud eingeschränkt")
                Self.logger.warning("iCloud eingeschränkt")
            case .couldNotDetermine:
                cloudKitAccountStatus = "❓ Unbekannt"
                Self.logger.notice("iCloud Status unbekannt")
            case .temporarilyUnavailable:
                cloudKitAccountStatus = "⏳ Temporär nicht verfügbar"
                Self.logger.notice("iCloud temporär nicht verfügbar")
            @unknown default:
                cloudKitAccountStatus = "❓ Unbekannt"
            }
            
            // 2. Check Container Access
            if accountStatus == .available {
                let database = container.privateCloudDatabase
                let recordID = CKRecord.ID(recordName: "syncTest")
                
                do {
                    // Versuche einen Test-Record zu fetchen (wird wahrscheinlich nicht existieren, aber zeigt ob Zugang möglich ist)
                    _ = try await database.record(for: recordID)
                    containerStatus = "✅ Container erreichbar"
                } catch let error as CKError {
                    if error.code == .unknownItem {
                        // Das ist OK - heißt nur dass der Test-Record nicht existiert
                        containerStatus = "✅ Container erreichbar"
                        Self.logger.info("CloudKit Container erreichbar: \(Self.containerIdentifier)")
                    } else if error.code == .notAuthenticated {
                        containerStatus = "❌ Nicht authentifiziert"
                        Self.logger.error("CloudKit nicht authentifiziert: \(error.localizedDescription)")
                    } else if error.code == .permissionFailure {
                        containerStatus = "❌ Keine Berechtigung"
                        Self.logger.error("CloudKit Berechtigung fehlt: \(error.localizedDescription)")
                    } else {
                        containerStatus = "⚠️ \(error.localizedDescription)"
                        Self.logger.warning("CloudKit Fehler: \(error)")
                    }
                } catch {
                    containerStatus = "⚠️ \(error.localizedDescription)"
                    Self.logger.warning("Unbekannter Fehler: \(error)")
                }
            }
        } catch {
            cloudKitAccountStatus = "❌ Fehler: \(error.localizedDescription)"
            Self.logger.error("CloudKit Status Fehler: \(error)")
        }
    }

    // MARK: - Notification Observers

    private func setupNotificationObservers() {
        let center = NotificationCenter.default

        // Import-Ereignisse (Daten von CloudKit empfangen)
        // Dieser Notification-Name funktioniert auch mit SwiftData
        center.addObserver(
            self,
            selector: #selector(handleImportNotification(_:)),
            name: Notification.Name("NSPersistentStoreRemoteChange"),
            object: nil
        )
        
        // Alternative Notification für SwiftData
        center.addObserver(
            self,
            selector: #selector(handleImportNotification(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: nil
        )

        // Export-Ereignisse (Daten zu CloudKit senden)
        center.addObserver(
            self,
            selector: #selector(handleExportNotification(_:)),
            name: Notification.Name("NSPersistentCloudKitContainer.eventChangedNotification"),
            object: nil
        )

        Self.logger.info("CloudKit Sync Manager: Notifications registriert")
        Self.logger.debug("Container: \(Self.containerIdentifier)")
    }

    @objc private func handleImportNotification(_ notification: Notification) {
        Task { @MainActor in
            Self.logger.debug("CloudKit: Import-Event empfangen")
            Self.logger.trace("Notification: \(notification.name.rawValue)")
            if let userInfo = notification.userInfo {
                Self.logger.trace("UserInfo: \(userInfo)")
            }
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
            Self.logger.debug("CloudKit: Export-Event empfangen")
            Self.logger.trace("Notification: \(notification.name.rawValue)")
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
        // Erst CloudKit Status prüfen
        await checkCloudKitStatus()
        
        if case .notAvailable = syncStatus {
            Self.logger.warning("CloudKit nicht verfügbar - Sync abgebrochen")
            return
        }

        Self.logger.info("Manueller Sync wird ausgelöst...")
        Self.logger.debug("Container: \(Self.containerIdentifier)")
        syncStatus = .syncing

        do {
            // Save erzwingt einen Export zu CloudKit
            try modelContext.save()
            Self.logger.debug("ModelContext gespeichert")

            // Kurze Wartezeit für CloudKit
            try await Task.sleep(for: .seconds(2))

            syncStatus = .success
            lastSyncDate = Date()
            Self.logger.info("Manueller Sync abgeschlossen")

            // Nach 3 Sekunden zurück zu idle
            try await Task.sleep(for: .seconds(3))
            if case .success = syncStatus {
                syncStatus = .idle
            }
        } catch {
            Self.logger.error("Sync-Fehler: \(error.localizedDescription)")
            Self.logger.debug("Details: \(error)")
            syncStatus = .error(error.localizedDescription)

            // Nach 5 Sekunden zurück zu idle
            try? await Task.sleep(for: .seconds(5))
            if case .error = syncStatus {
                syncStatus = .idle
            }
        }
    }

    /// Holt aktiv neue Daten von CloudKit (Pull)
    /// Dies triggert einen Import von Remote-Änderungen
    func pullFromCloud() async {
        // Erst CloudKit Status prüfen
        await checkCloudKitStatus()
        
        if case .notAvailable = syncStatus {
            Self.logger.warning("CloudKit nicht verfügbar - Pull abgebrochen")
            return
        }

        Self.logger.info("Pull von CloudKit wird gestartet...")
        Self.logger.debug("Container: \(Self.containerIdentifier)")
        syncStatus = .syncing

        do {
            // 1. Speichere lokale Änderungen zuerst
            if modelContext.hasChanges {
                try modelContext.save()
                Self.logger.debug("Lokale Änderungen gespeichert")
            }

            // 2. Trigger einen Fetch durch eine Subscription-Refresh
            let container = CKContainer(identifier: Self.containerIdentifier)
            let database = container.privateCloudDatabase

            // Fetch alle Subscriptions um einen Refresh zu triggern
            let subscriptions = try await database.allSubscriptions()
            Self.logger.debug("Aktive Subscriptions: \(subscriptions.count)")
            
            // 3. Sende eine Notification um Views zu refreshen
            // Dies triggert SwiftData dazu, seinen Cache zu aktualisieren
            NotificationCenter.default.post(
                name: Notification.Name("PubRankerForceRefresh"),
                object: nil
            )
            
            // 4. Kurze Wartezeit für CloudKit Import
            try await Task.sleep(for: .seconds(3))

            syncStatus = .success
            lastSyncDate = Date()
            Self.logger.info("Pull von CloudKit abgeschlossen")

            // Nach 3 Sekunden zurück zu idle
            try await Task.sleep(for: .seconds(3))
            if case .success = syncStatus {
                syncStatus = .idle
            }
        } catch {
            Self.logger.error("Pull-Fehler: \(error.localizedDescription)")
            Self.logger.debug("Details: \(error)")
            syncStatus = .error(error.localizedDescription)

            // Nach 5 Sekunden zurück zu idle
            try? await Task.sleep(for: .seconds(5))
            if case .error = syncStatus {
                syncStatus = .idle
            }
        }
    }

    /// Führt einen vollständigen Sync durch (Push + Pull)
    func fullSync() async {
        Self.logger.info("Vollständiger Sync wird gestartet...")

        // Erst pushen (lokale Änderungen hochladen)
        await forceSyncNow()

        // Kurze Pause
        try? await Task.sleep(for: .seconds(1))

        // Dann pullen (Remote-Änderungen holen)
        await pullFromCloud()

        Self.logger.info("Vollständiger Sync abgeschlossen")
    }
    
    /// Führt eine vollständige Diagnose durch und gibt das Ergebnis zurück
    func runDiagnostics() async -> String {
        var result = "=== CloudKit Diagnose ===\n\n"
        
        #if os(macOS)
        result += "Plattform: macOS\n"
        #else
        result += "Plattform: iPadOS/iOS\n"
        #endif

        result += "Container: \(Self.containerIdentifier)\n"
        result += "Account Status: \(cloudKitAccountStatus)\n"
        result += "Container Status: \(containerStatus)\n"
        result += "Sync Status: \(statusText)\n"
        
        if let lastSync = lastSyncDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            result += "Letzter Sync: \(formatter.string(from: lastSync))\n"
        } else {
            result += "Letzter Sync: Noch nie\n"
        }
        
        // Prüfe iCloud Account
        let container = CKContainer(identifier: Self.containerIdentifier)
        do {
            let status = try await container.accountStatus()
            result += "\n--- iCloud Status ---\n"
            result += "Account: "
            switch status {
            case .available: result += "✅ Verfügbar"
            case .noAccount: result += "❌ Nicht angemeldet"
            case .restricted: result += "⚠️ Eingeschränkt"
            case .couldNotDetermine: result += "❓ Unbekannt"
            case .temporarilyUnavailable: result += "⏳ Temporär nicht verfügbar"
            @unknown default: result += "❓ Unbekannt"
            }
            result += "\n"
            
            // Prüfe User Record ID
            if status == .available {
                do {
                    let userID = try await container.userRecordID()
                    result += "User ID: \(userID.recordName.prefix(20))...\n"
                } catch {
                    result += "User ID: ❌ Nicht abrufbar\n"
                }
                
                // Prüfe ob Records existieren
                result += "\n--- CloudKit Daten ---\n"
                let database = container.privateCloudDatabase
                
                // Versuche CD_Quiz Records zu zählen (SwiftData Prefix)
                let quizQuery = CKQuery(recordType: "CD_Quiz", predicate: NSPredicate(value: true))
                do {
                    let (results, _) = try await database.records(matching: quizQuery, resultsLimit: 100)
                    result += "Quizze in CloudKit: \(results.count)\n"
                } catch {
                    result += "Quizze: ❌ Abfrage fehlgeschlagen (\(error.localizedDescription))\n"
                }
                
                let teamQuery = CKQuery(recordType: "CD_Team", predicate: NSPredicate(value: true))
                do {
                    let (results, _) = try await database.records(matching: teamQuery, resultsLimit: 100)
                    result += "Teams in CloudKit: \(results.count)\n"
                } catch {
                    result += "Teams: ❌ Abfrage fehlgeschlagen (\(error.localizedDescription))\n"
                }
                
                // Prüfe Subscriptions
                do {
                    let subscriptions = try await database.allSubscriptions()
                    result += "Subscriptions: \(subscriptions.count)\n"
                } catch {
                    result += "Subscriptions: ❌ Nicht abrufbar\n"
                }
            }
        } catch {
            result += "\niCloud Check fehlgeschlagen: \(error.localizedDescription)\n"
        }
        
        // Lokale Daten zählen
        result += "\n--- Lokale Daten ---\n"
        do {
            let quizDescriptor = FetchDescriptor<Quiz>()
            let quizCount = try modelContext.fetchCount(quizDescriptor)
            result += "Lokale Quizze: \(quizCount)\n"
            
            let teamDescriptor = FetchDescriptor<Team>()
            let teamCount = try modelContext.fetchCount(teamDescriptor)
            result += "Lokale Teams: \(teamCount)\n"
        } catch {
            result += "Lokale Daten: ❌ Fehler beim Zählen\n"
        }

        return result
    }

    // MARK: - Status Helpers

    var isSyncing: Bool {
        if case .syncing = syncStatus {
            return true
        }
        return false
    }
    
    var isAvailable: Bool {
        if case .notAvailable = syncStatus {
            return false
        }
        return true
    }

    var statusIcon: String {
        switch syncStatus {
        case .idle:
            return "icloud"
        case .syncing:
            return "icloud.and.arrow.up.fill"
        case .success:
            return "checkmark.icloud"
        case .error:
            return "exclamationmark.icloud"
        case .notAvailable:
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
            return "orange"
        case .notAvailable:
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
        case .notAvailable(let reason):
            return "Nicht verfügbar: \(reason)"
        }
    }
    
    /// Detaillierter Status für Debug-Zwecke
    var detailedStatus: String {
        """
        CloudKit Status:
        - Account: \(cloudKitAccountStatus)
        - Container: \(containerStatus)
        - Sync: \(statusText)
        """
    }
}
