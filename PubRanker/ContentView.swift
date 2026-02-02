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
            // ViewModel mit ModelContext initialisieren (WICHTIG für alle Services)
            viewModel.setContext(modelContext)
            
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
        HStack(spacing: AppSpacing.xxxs) {
            ForEach(WorkflowPhase.allCases) { phase in
                phaseButton(for: phase)
            }
        }
        #if os(iOS)
        .padding(3)
        #else
        .padding(4)
        #endif
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .fill(Color.black.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 4, x: 0, y: 2)
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
            .contentShape(Rectangle())
        }
        .buttonStyle(GlassTabButtonStyle(isSelected: selectedWorkflow == phase))
        .accessibilityLabel(phase.rawValue)
        .accessibilityHint(phase.description)
        .accessibilityAddTraits(selectedWorkflow == phase ? [.isSelected] : [])
        #if os(macOS)
        .help(phase.description)
        #endif
    }

    private func phaseBackground(for phase: WorkflowPhase) -> some View {
        Group {
            if selectedWorkflow == phase {
                // Aktiver Tab - sauber und elegant
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.95),
                                Color.appPrimary
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.25),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            )
                    }
                    .shadow(color: Color.appPrimary.opacity(0.25), radius: 8, x: 0, y: 2)
            } else {
                // Inaktive Tabs - transparent und zurückhaltend
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.clear)
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
            .accessibilityLabel("Debug & Testdaten")
            .accessibilityHint("Öffnet die Debug-Ansicht mit Testdaten")
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
            .accessibilityLabel("App-Informationen")
            .accessibilityHint("Zeigt Informationen über die App an")
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

// MARK: - Glass Tab Button Style (macOS 26 Liquid Glass Design)

struct GlassTabButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
            #if os(macOS)
            .onHover { hovering in
                if hovering && !isSelected {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
            #endif
    }
}

#Preview {
    ContentView()
        .environment(QuizViewModel())
        .modelContainer(for: [Quiz.self, Team.self, Round.self], inMemory: true)
}
