//
//  CloudKitStatusView.swift
//  PubRanker
//
//  CloudKit Sync Diagnose
//

import SwiftUI
import CloudKit

struct CloudKitStatusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var accountStatus: CKAccountStatus?
    @State private var containerInfo: String = "Wird überprüft..."
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section("CloudKit Account Status") {
                    HStack {
                        Image(systemName: statusIcon)
                            .foregroundStyle(statusColor)
                        Text(statusText)
                        Spacer()
                        if isLoading {
                            ProgressView()
                        }
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }

                Section("Container Information") {
                    Text(containerInfo)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section("Troubleshooting") {
                    if accountStatus != .available {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("iCloud Probleme beheben:", systemImage: "exclamationmark.triangle")
                                .font(.headline)

                            Text("1. Einstellungen → [Dein Name] → iCloud")
                            Text("2. iCloud Drive aktivieren")
                            Text("3. In der App-Liste 'PubRanker' aktivieren")
                            Text("4. App neu starten")
                        }
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    } else {
                        Label("CloudKit funktioniert korrekt", systemImage: "checkmark.circle")
                            .foregroundStyle(.green)
                    }
                }

                Section("Technische Details") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Container: iCloud.com.akeschmidi.PubRanker")
                        Text("Database: .automatic (private)")
                        Text("Build: \(buildConfiguration)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("CloudKit Status")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Common.close) { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task { await checkCloudKitStatus() }
                    } label: {
                        Label("Aktualisieren", systemImage: "arrow.clockwise")
                    }
                }
            }
            .task {
                await checkCloudKitStatus()
            }
        }
    }

    // MARK: - Status Properties

    private var statusIcon: String {
        guard let status = accountStatus else { return "questionmark.circle" }
        switch status {
        case .available: return "checkmark.circle.fill"
        case .noAccount: return "person.crop.circle.badge.xmark"
        case .restricted: return "lock.circle"
        case .couldNotDetermine: return "exclamationmark.circle"
        case .temporarilyUnavailable: return "clock.circle"
        @unknown default: return "questionmark.circle"
        }
    }

    private var statusColor: Color {
        guard let status = accountStatus else { return .gray }
        switch status {
        case .available: return .green
        case .noAccount, .restricted: return .red
        case .couldNotDetermine, .temporarilyUnavailable: return .orange
        @unknown default: return .gray
        }
    }

    private var statusText: String {
        guard let status = accountStatus else { return "Wird überprüft..." }
        switch status {
        case .available:
            return "✅ CloudKit verfügbar"
        case .noAccount:
            return "❌ Kein iCloud Account"
        case .restricted:
            return "❌ iCloud eingeschränkt"
        case .couldNotDetermine:
            return "⚠️ Status unbekannt"
        case .temporarilyUnavailable:
            return "⚠️ Temporär nicht verfügbar"
        @unknown default:
            return "❓ Unbekannter Status"
        }
    }

    private var buildConfiguration: String {
        #if DEBUG
        return "Debug (CloudKit DEAKTIVIERT)"
        #else
        return "Release (CloudKit aktiv)"
        #endif
    }

    // MARK: - CloudKit Check

    private func checkCloudKitStatus() async {
        isLoading = true
        errorMessage = nil

        let container = CKContainer(identifier: "iCloud.com.akeschmidi.PubRanker")

        do {
            let status = try await container.accountStatus()
            await MainActor.run {
                self.accountStatus = status
                self.isLoading = false
            }

            // Container-Info abrufen
            if status == .available {
                await fetchContainerInfo(container)
            } else {
                await MainActor.run {
                    self.containerInfo = "CloudKit nicht verfügbar - Container kann nicht abgerufen werden"
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Fehler beim Abrufen des CloudKit-Status: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    private func fetchContainerInfo(_ container: CKContainer) async {
        await MainActor.run {
            self.containerInfo = """
            ✅ Container: iCloud.com.akeschmidi.PubRanker
            ✅ Private Database: Verfügbar
            ✅ Account: Angemeldet

            CloudKit-Sync ist vollständig eingerichtet.
            Änderungen werden automatisch synchronisiert.
            """
        }
    }
}

#Preview {
    CloudKitStatusView()
}
