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
    @State private var selectedTab: AboutTab = .about
    
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
        "iSupport.ch © 2025"
    }
    
    enum AboutTab {
        case about
        case designSystem
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if DEBUG
            // Tab Picker - only in Debug mode
            Picker("Tab", selection: $selectedTab) {
                Label(L10n.About.title, systemImage: "info.circle.fill")
                    .tag(AboutTab.about)
                Label(L10n.CommonUI.designSystem, systemImage: "paintpalette.fill")
                    .tag(AboutTab.designSystem)
            }
            .pickerStyle(.segmented)
            .padding(AppSpacing.md)
            
            Divider()
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .about:
                    aboutContent
                case .designSystem:
                    DesignSystemDemoView()
                }
            }
            #else
            // Release mode - only About content
            aboutContent
            #endif
        }
        .frame(width: 1000, height: 800)
    }
    
    private var aboutContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                if let appIcon = NSApplication.shared.applicationIconImage {
                    Image(nsImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 128, height: 128)
                        .shadow(AppShadow.lg)
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
                    .shadow(AppShadow.lg)
                }
                
                VStack(spacing: AppSpacing.xxs) {
                    Text(appName)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(Color.appTextPrimary)
                    
                    Text(L10n.About.quizMasterHub)
                        .font(.title3)
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Text(L10n.About.version(appVersion, buildNumber))
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
            .padding(.top, AppSpacing.xxl)
            .padding(.bottom, AppSpacing.lg)
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                    // Beschreibung
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Label(L10n.About.title, systemImage: "info.circle.fill")
                            .font(.headline)
                            .foregroundStyle(Color.appPrimary)
                        
                        Text(L10n.About.description)
                            .font(.body)
                            .foregroundStyle(Color.appTextSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // Features
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Label(L10n.About.Features.title, systemImage: "star.fill")
                            .font(.headline)
                            .foregroundStyle(Color.appAccent)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            FeatureRow(icon: "person.3.fill", text: L10n.About.Features.teamManagement)
                            FeatureRow(icon: "calendar.badge.plus", text: L10n.About.Features.planning)
                            FeatureRow(icon: "play.circle.fill", text: L10n.About.Features.liveScoring)
                            FeatureRow(icon: "chart.bar.fill", text: L10n.About.Features.analysis)
                            FeatureRow(icon: "envelope.fill", text: L10n.About.Features.email)
                        }
                    }
                    
                    Divider()
                    
                    // Technische Informationen
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Label(L10n.About.Technical.title, systemImage: "gearshape.fill")
                            .font(.headline)
                            .foregroundStyle(Color.appSecondary)
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                            InfoRow(label: L10n.About.Technical.version, value: "\(appVersion) (\(buildNumber))")
                            InfoRow(label: L10n.About.Technical.bundleId, value: Bundle.main.bundleIdentifier ?? "N/A")
                            InfoRow(label: L10n.About.Technical.platform, value: "macOS")
                            InfoRow(label: L10n.About.Technical.copyright, value: copyright)
                        }
                    }
                }
                .padding(AppSpacing.lg)
            }
            
            Divider()
            
            // Footer
            HStack {
                Button {
                    showingFeedbackDialog = true
                } label: {
                    Label(L10n.About.Feedback.rate, systemImage: "star.fill")
                }
                .secondaryGradientButton()
                
                Spacer()
                
                Button(L10n.Common.close) {
                    dismiss()
                }
                .primaryGradientButton()
                .keyboardShortcut(.escape)
            }
            .padding(AppSpacing.md)
        }
        .alert(L10n.About.Feedback.title, isPresented: $showingFeedbackDialog) {
            Button(L10n.About.Feedback.rateAppStore) {
                openAppStoreReview()
            }
            Button(L10n.About.Feedback.missingFeatures) {
                showingEmailDialog = true
            }
            Button(L10n.Navigation.cancel, role: .cancel) {}
        } message: {
            Text(L10n.About.Feedback.message)
        }
        .alert(L10n.About.Feedback.send, isPresented: $showingEmailDialog) {
            Button(L10n.About.Feedback.emailOpen) {
                openEmailFeedback()
            }
            Button(L10n.About.Feedback.emailCopy) {
                copyEmailToClipboard()
            }
            Button(L10n.Navigation.cancel, role: .cancel) {}
        } message: {
            Text(L10n.About.Feedback.emailMessage)
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
            alert.messageText = L10n.About.AppStore.review
            alert.informativeText = L10n.About.AppStore.notAvailable
            alert.alertStyle = .informational
            alert.addButton(withTitle: L10n.Alert.ok)
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
        alert.messageText = L10n.About.Feedback.emailCopied
        alert.informativeText = L10n.About.Feedback.emailCopiedMessage
        alert.alertStyle = .informational
        alert.addButton(withTitle: L10n.Alert.ok)
        alert.runModal()
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color.appPrimary)
                .frame(width: 24)
            
            Text(text)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
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
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.body)
                .foregroundStyle(Color.appTextPrimary)
                .monospacedDigit()
        }
    }
}

