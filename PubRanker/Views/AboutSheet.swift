//
//  AboutSheet.swift
//  PubRanker
//
//  Created on 23.11.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingFeedbackDialog = false
    @State private var showingEmailDialog = false
    @State private var showingCopiedConfirmation = false
    @State private var showingCloudKitStatus = false
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
    
    private var platformName: String {
        #if os(macOS)
        return "macOS"
        #else
        return UIDevice.current.userInterfaceIdiom == .pad ? "iPadOS" : "iOS"
        #endif
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
        #if os(macOS)
        .frame(width: 1000, height: 800)
        #endif
    }
    
    private var aboutContent: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                // App Icon
                appIconView
                
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
                            InfoRow(label: L10n.About.Technical.platform, value: platformName)
                            InfoRow(label: L10n.About.Technical.copyright, value: copyright)
                        }

                        Button {
                            showingCloudKitStatus = true
                        } label: {
                            HStack {
                                Image(systemName: "icloud.fill")
                                    .foregroundStyle(Color.appPrimary)
                                Text("CloudKit Sync Status prüfen")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                            }
                            .padding(AppSpacing.xs)
                            .background(
                                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                                    .fill(Color.appBackgroundSecondary)
                            )
                        }
                        .buttonStyle(.plain)
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
                .secondaryGlassButton()
                
                Spacer()
                
                Button(L10n.Common.close) {
                    dismiss()
                }
                .primaryGlassButton()
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
        .alert(L10n.About.Feedback.emailCopied, isPresented: $showingCopiedConfirmation) {
            Button(L10n.Alert.ok, role: .cancel) {}
        } message: {
            Text(L10n.About.Feedback.emailCopiedMessage)
        }
        .sheet(isPresented: $showingCloudKitStatus) {
            CloudKitStatusView()
        }
    }
    
    // MARK: - App Icon View
    
    @ViewBuilder
    private var appIconView: some View {
        #if os(macOS)
        if let appIcon = NSApplication.shared.applicationIconImage {
            Image(nsImage: appIcon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
                .shadow(AppShadow.lg)
        } else {
            fallbackIconView
        }
        #else
        // Auf iOS: Verwende das App Icon aus den Assets
        if let iconsDictionary = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
           let primaryIconsDictionary = iconsDictionary["CFBundlePrimaryIcon"] as? [String: Any],
           let iconFiles = primaryIconsDictionary["CFBundleIconFiles"] as? [String],
           let lastIcon = iconFiles.last,
           let uiImage = UIImage(named: lastIcon) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 128, height: 128)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(AppShadow.lg)
        } else {
            fallbackIconView
        }
        #endif
    }
    
    private var fallbackIconView: some View {
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
    
    // MARK: - Actions
    
    private func openAppStoreReview() {
        #if os(macOS)
        if let url = URL(string: AppConstants.macAppStoreReviewURL) {
            NSWorkspace.shared.open(url)
        }
        #else
        if let url = URL(string: AppConstants.iOSAppStoreReviewURL) {
            UIApplication.shared.open(url)
        }
        #endif
    }
    
    private func openEmailFeedback() {
        let email = "ake_schmidi@me.com"
        let subject = "PubRanker Feedback"
        let body = "Hallo,\n\nich hätte folgende Anregungen für PubRanker:\n\n"
        
        if let url = URL(string: "mailto:\(email)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")") {
            #if os(macOS)
            NSWorkspace.shared.open(url)
            #else
            UIApplication.shared.open(url)
            #endif
        }
    }
    
    private func copyEmailToClipboard() {
        let email = "ake_schmidi@me.com"
        
        #if os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(email, forType: .string)
        #else
        UIPasteboard.general.string = email
        #endif
        
        showingCopiedConfirmation = true
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
