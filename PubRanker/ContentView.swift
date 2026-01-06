//
//  ContentView.swift
//  PubRanker
//
//  Created on 20.10.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI
import Combine

struct ContentView: View {
    @Environment(QuizViewModel.self) private var viewModel
    @Environment(\.modelContext) private var modelContext
    @State private var selectedWorkflow: WorkflowPhase = .planning
    @State private var showingAboutSheet = false
    @State private var showingDebugView = false
    @State private var syncManager: CloudKitSyncManager?
    @StateObject private var easterEggManager = EasterEggManager()
    
    /// Trigger für View-Refresh nach CloudKit-Pull
    @State private var refreshTrigger = UUID()

    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    enum WorkflowPhase: String, CaseIterable, Identifiable {
        case teamsmanager = "Teams"
        case planning = "Planen"
        case execution = "Durchführen"
        case analysis = "Auswerten"

        var id: String { rawValue }

        var icon: String {
            switch self {
            case .teamsmanager: return "person.3.fill"
            case .planning: return "calendar.badge.plus"
            case .execution: return "play.circle.fill"
            case .analysis: return "chart.bar.fill"
            }
        }

        var description: String {
            switch self {
            case .teamsmanager: return "Teams erstellen und verwalten"
            case .planning: return "Quiz vorbereiten und planen"
            case .execution: return "Aktive Quiz durchführen"
            case .analysis: return "Quiz auswerten und exportieren"
            }
        }
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Main Navigation Header
                mainNavigationHeader

                // Content based on selected workflow phase
                Group {
                    switch selectedWorkflow {
                    case .teamsmanager:
                        GlobalTeamsManagerView(viewModel: viewModel, selectedWorkflow: $selectedWorkflow)
                    case .planning:
                        PlanningView(viewModel: viewModel, selectedWorkflow: $selectedWorkflow)
                    case .execution:
                        ExecutionView(viewModel: viewModel, selectedWorkflow: $selectedWorkflow)
                    case .analysis:
                        AnalysisView(viewModel: viewModel)
                    }
                }
            }
            #if os(macOS)
            .frame(minWidth: 1000, minHeight: 600)
            #endif

            // Easter Egg Overlays
            EasterEggOverlayContainer(easterEggManager: easterEggManager)
        }
        .onAppear {
            // CloudKit Sync Manager initialisieren
            if syncManager == nil {
                syncManager = CloudKitSyncManager(modelContext: modelContext)
            }
        }
        .onDisappear {
            easterEggManager.cleanup()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("PubRankerForceRefresh"))) { _ in
            // Trigger View-Refresh nach CloudKit-Pull
            print("🔄 Force Refresh empfangen - Views werden aktualisiert")
            refreshTrigger = UUID()
        }
        .id(refreshTrigger)
        .environment(syncManager ?? CloudKitSyncManager(modelContext: modelContext))
    }
    
    // MARK: - Adaptive Layout Properties
    
    private var navigationButtonWidth: CGFloat {
        #if os(iOS)
        return horizontalSizeClass == .compact ? 70 : 85
        #else
        return 90
        #endif
    }
    
    private var mainNavigationHeader: some View {
        headerContent
            .sheet(isPresented: $showingAboutSheet) {
                AboutSheet()
            }
            .sheet(isPresented: $showingDebugView) {
                DebugDataView()
            }
    }

    @ViewBuilder
    private var headerContent: some View {
        let content = HStack(spacing: 0) {
            titleSection
            Spacer()
            workflowPicker
            Spacer()
            rightButtons
        }

        content.modifier(HeaderPaddingModifier())
    }

    private var titleSection: some View {
        HStack(spacing: AppSpacing.xs) {
            EasterEggIconView(easterEggManager: easterEggManager)
            #if os(macOS)
            EasterEggTitleView(easterEggManager: easterEggManager)
            #else
            if horizontalSizeClass != .compact {
                EasterEggTitleView(easterEggManager: easterEggManager)
            }
            #endif
        }
        #if os(iOS)
        .padding(.leading, AppSpacing.sm)
        #else
        .padding(.leading, AppSpacing.lg)
        #endif
    }

    private var workflowPicker: some View {
        HStack(spacing: AppSpacing.xxs) {
            ForEach(WorkflowPhase.allCases) { phase in
                phaseButton(for: phase)
            }
        }
        #if os(iOS)
        .padding(2)
        #else
        .padding(AppSpacing.xxxs)
        #endif
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(Color.appBackgroundSecondary.opacity(0.9))
                .shadow(radius: 2, y: 1)
        )
    }

    private func phaseButton(for phase: WorkflowPhase) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedWorkflow = phase
            }
        } label: {
            VStack(spacing: AppSpacing.xxxs) {
                Image(systemName: phase.icon)
                    .font(.title3)
                Text(phase.rawValue)
                    .font(.caption)
                    .fontWeight(selectedWorkflow == phase ? .semibold : .regular)
            }
            .foregroundStyle(selectedWorkflow == phase ? .white : Color.appTextPrimary)
            .frame(width: navigationButtonWidth)
            .padding(.vertical, AppSpacing.xs)
            .background(phaseBackground(for: phase))
        }
        .buttonStyle(.plain)
        #if os(macOS)
        .help(phase.description)
        #endif
    }

    private func phaseBackground(for phase: WorkflowPhase) -> some View {
        Group {
            if selectedWorkflow == phase {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .fill(Color.appPrimary)
                    .shadow(radius: 2, y: 1)
            } else {
                RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                    .fill(Color.appBackgroundSecondary.opacity(0.5))
            }
        }
    }

    private var rightButtons: some View {
        HStack(spacing: 0) {
            EasterEggClickCounter(easterEggManager: easterEggManager)

            #if !DEBUG
            // CloudKit Sync Button (nur in Release-Builds)
            CloudKitSyncButton()
                .padding(.trailing, AppSpacing.xs)
            #endif

            #if DEBUG
            Button {
                showingDebugView = true
            } label: {
                Image(systemName: "ladybug")
                    .font(.title3)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .buttonStyle(.plain)
            #if os(macOS)
            .help("Debug & Testdaten")
            #endif
            .padding(.trailing, AppSpacing.xs)
            #endif

            Button {
                showingAboutSheet = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title3)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .buttonStyle(.plain)
            #if os(macOS)
            .help("App-Informationen")
            #endif
            #if os(iOS)
            .padding(.trailing, AppSpacing.sm)
            #else
            .padding(.trailing, AppSpacing.lg)
            #endif
        }
    }
}


#Preview {
    ContentView()
        .environment(QuizViewModel())
        .modelContainer(for: [Quiz.self, Team.self, Round.self], inMemory: true)
}
