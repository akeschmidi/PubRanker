//
//  AboutSheet.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import AppKit

// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFeedbackDialog = false
    @State private var showingEmailDialog = false
    
    var appName: String {
        Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "PubRanker"
    }
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var copyright: String {
        Bundle.main.infoDictionary?["NSHumanReadableCopyright"] as? String ?? "© 2025"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                if let appIcon = NSApplication.shared.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128, height: 128)
                        .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                } else {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 128, height: 128)
                        
                        Image(systemName: "trophy.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .black.opacity(0.2), radius: 10, y: 5)
                }
                
                VStack(spacing: 8) {
                    Text(appName)
                        .font(.system(size: 32, weight: .bold))
                    
                    Text("QuizMaster Hub")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                    
                    Text("Version \(appVersion) (\(buildNumber))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 30)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Beschreibung
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Über PubRanker", systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        
                        Text("PubRanker ist eine umfassende Quiz-Management-App für macOS. Planen Sie Quiz-Veranstaltungen, verwalten Sie Teams, führen Sie Quiz durch und analysieren Sie Ergebnisse - alles an einem Ort.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // Features
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Hauptfunktionen", systemImage: "star.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            FeatureRow(icon: "person.3.fill", text: "Team-Management mit globalen Teams")
                            FeatureRow(icon: "calendar.badge.plus", text: "Quiz-Planung und -Vorbereitung")
                            FeatureRow(icon: "play.circle.fill", text: "Live-Punkteeingabe während des Quiz")
                            FeatureRow(icon: "chart.bar.fill", text: "Detaillierte Analyse und Statistiken")
                            FeatureRow(icon: "envelope.fill", text: "E-Mail-Vorlagen für Teams")
                        }
                    }
                    
                    Divider()
                    
                    // Technische Informationen
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Technische Informationen", systemImage: "gearshape.fill")
                            .font(.headline)
                            .foregroundStyle(.purple)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            InfoRow(label: "Version", value: "\(appVersion) (\(buildNumber))")
                            InfoRow(label: "Bundle ID", value: Bundle.main.bundleIdentifier ?? "N/A")
                            InfoRow(label: "Plattform", value: "macOS")
                            InfoRow(label: "Copyright", value: copyright)
                        }
                    }
                }
                .padding(30)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button {
                    showingFeedbackDialog = true
                } label: {
                    Label("Bewerten & Feedback", systemImage: "star.fill")
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Schließen") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .keyboardShortcut(.escape)
            }
            .padding(20)
        }
        .frame(width: 600, height: 700)
        .alert("Bewertung & Feedback", isPresented: $showingFeedbackDialog) {
            Button("Im App Store bewerten") {
                openAppStoreReview()
            }
            Button("Features vermisst?") {
                showingEmailDialog = true
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Helfen Sie uns, PubRanker zu verbessern!")
        }
        .alert("Feedback senden", isPresented: $showingEmailDialog) {
            Button("E-Mail öffnen") {
                openEmailFeedback()
            }
            Button("E-Mail-Adresse kopieren") {
                copyEmailToClipboard()
            }
            Button("Abbrechen", role: .cancel) {}
        } message: {
            Text("Kontaktieren Sie uns unter:\n\nake_schmidi@me.com")
        }
    }
    
    private func openAppStoreReview() {
        // App Store Review URL
        // Format: https://apps.apple.com/app/id[APP_ID]?action=write-review
        // Für macOS: macappstore://apps.apple.com/app/id[APP_ID]?action=write-review
        
        // Fallback: Öffne die App Store Seite (ohne spezifische App-ID)
        if let url = URL(string: "macappstore://apps.apple.com/app/id6754255330?action=write-review") {
            NSWorkspace.shared.open(url)
        } else {
            // Alternative: Öffne App Store Connect oder zeige Info
            let alert = NSAlert()
            alert.messageText = "App Store Bewertung"
            alert.informativeText = "Die App ist noch nicht im App Store verfügbar. Bitte bewerten Sie die App, sobald sie veröffentlicht wurde."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
    }
    
    private func openEmailFeedback() {
        let email = "ake_schmidi@me.com"
        let subject = "PubRanker Feedback"
        let body = "Hallo,\n\nich hätte folgende Anregungen für PubRanker:\n\n"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            NSWorkspace.shared.open(url)
        }
    }
    
    private func copyEmailToClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString("ake_schmidi@me.com", forType: .string)
        
        // Zeige kurze Bestätigung
        let alert = NSAlert()
        alert.messageText = "E-Mail-Adresse kopiert"
        alert.informativeText = "Die E-Mail-Adresse wurde in die Zwischenablage kopiert."
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
        }
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label + ":")
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .monospacedDigit()
        }
    }
}

