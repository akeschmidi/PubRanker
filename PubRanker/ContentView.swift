//
//  ContentView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import AppKit

struct ContentView: View {
    @Environment(QuizViewModel.self) private var viewModel
    @State private var selectedWorkflow: WorkflowPhase = .planning
    @State private var showingAboutSheet = false
    @State private var showingDebugView = false
    @StateObject private var easterEggManager = EasterEggManager()
    
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
                
                //Divider()
                
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
            .frame(minWidth: 1000, minHeight: 100)
            
            // Easter Egg Overlays
            EasterEggOverlayContainer(easterEggManager: easterEggManager)
        }
        .onDisappear {
            easterEggManager.cleanup()
        }
    }
    
    private var mainNavigationHeader: some View {
        HStack(spacing: 0) {
            // App Title
            HStack(spacing: AppSpacing.xs) {
                EasterEggIconView(easterEggManager: easterEggManager)

                EasterEggTitleView(easterEggManager: easterEggManager)
            }
            .padding(.leading, AppSpacing.lg)

            Spacer()

            // Modern Workflow Phase Picker
            HStack(spacing: AppSpacing.xxs) {
                ForEach(WorkflowPhase.allCases) { phase in
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
                        .frame(width: 90)
                        .padding(.vertical, AppSpacing.xs)
                        .background(
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
                        )
                    }
                    .buttonStyle(.plain)
                    .help(phase.description)
                }
            }
            .padding(AppSpacing.xxxs)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.appBackgroundSecondary.opacity(0.9))
                    .shadow(radius: 2, y: 1)
            )

            Spacer()

            // Click Counter (oben rechts)
            EasterEggClickCounter(easterEggManager: easterEggManager)

            #if DEBUG
            // Debug Button
            Button {
                showingDebugView = true
            } label: {
                Image(systemName: "ladybug")
                    .font(.title3)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .buttonStyle(.plain)
            .help("Debug & Testdaten")
            .padding(.trailing, AppSpacing.xs)
            #endif

            // Help Button
            Button {
                showingAboutSheet = true
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title3)
                    .foregroundStyle(Color.appTextSecondary)
            }
            .buttonStyle(.plain)
            .help("App-Informationen")
            .padding(.trailing, AppSpacing.lg)
        }
        //.padding(.top, AppSpacing.xxxs)
        .padding(.bottom, AppSpacing.sm)
        .background(
            LinearGradient(
                colors: [Color.appBackgroundSecondary, Color.appBackground],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .sheet(isPresented: $showingAboutSheet) {
            AboutSheet()
        }
        .sheet(isPresented: $showingDebugView) {
            DebugDataView()
        }
    }
}


#Preview {
    ContentView()
        .environment(QuizViewModel())
        .modelContainer(for: [Quiz.self, Team.self, Round.self], inMemory: true)
}
