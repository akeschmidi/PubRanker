//
//  ContentView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct ContentView: View {
    @Environment(QuizViewModel.self) private var viewModel
    @State private var selectedWorkflow: WorkflowPhase = .planning
    
    enum WorkflowPhase: String, CaseIterable, Identifiable {
        case planning = "Planen"
        case execution = "Durchführen"
        case analysis = "Auswerten"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .planning: return "calendar.badge.plus"
            case .execution: return "play.circle.fill"
            case .analysis: return "chart.bar.fill"
            }
        }
        
        var description: String {
            switch self {
            case .planning: return "Quiz vorbereiten und planen"
            case .execution: return "Aktive Quiz durchführen"
            case .analysis: return "Quiz auswerten und exportieren"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main Navigation Header
            mainNavigationHeader
            
            Divider()
            
            // Content based on selected workflow phase
            Group {
                switch selectedWorkflow {
                case .planning:
                    PlanningView(viewModel: viewModel, selectedWorkflow: $selectedWorkflow)
                case .execution:
                    ExecutionView(viewModel: viewModel, selectedWorkflow: $selectedWorkflow)
                case .analysis:
                    AnalysisView(viewModel: viewModel)
                }
            }
        }
        .frame(minWidth: 1000, minHeight: 700)
    }
    
    private var mainNavigationHeader: some View {
        HStack(spacing: 0) {
            // App Title
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("PubRanker")
                        .font(.title2)
                        .bold()
                    Text("QuizMaster Hub")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.leading, 24)
            
            Spacer()
            
            // Workflow Phase Picker
            Picker("Workflow", selection: $selectedWorkflow) {
                ForEach(WorkflowPhase.allCases) { phase in
                    Label(phase.rawValue, systemImage: phase.icon)
                        .tag(phase)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 500)
            
            Spacer()
            
            // Help Button
            Button {
                // Show help
            } label: {
                Image(systemName: "questionmark.circle")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 24)
        }
        .padding(.vertical, 16)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .windowBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}

#Preview {
    ContentView()
        .environment(QuizViewModel())
        .modelContainer(for: [Quiz.self, Team.self, Round.self], inMemory: true)
}
