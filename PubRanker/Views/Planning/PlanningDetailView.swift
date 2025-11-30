//
//  PlanningDetailView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct PlanningDetailView: View {
    let quiz: Quiz
    @Binding var selectedDetailTab: PlanningDetailTab
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    let viewModel: QuizViewModel
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Kompakter Header
            CompactQuizHeader(
                quiz: quiz,
                onEdit: onEdit,
                onDelete: onDelete,
                onStart: {
                    viewModel.startQuiz(quiz)
                    selectedWorkflow = .execution
                }
            )
            
            Divider()
            
            // Tab Picker
            Picker("Ansicht", selection: $selectedDetailTab) {
                ForEach(PlanningDetailTab.allCases) { tab in
                    Label(tab.rawValue, systemImage: tab.icon)
                        .tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Tab Content
            Group {
                switch selectedDetailTab {
                case .overview:
                    OverviewTabContent(quiz: quiz, selectedDetailTab: $selectedDetailTab, viewModel: viewModel)
                case .teams:
                    TeamManagementView(quiz: quiz, viewModel: viewModel)
                case .rounds:
                    RoundManagementView(quiz: quiz, viewModel: viewModel)
                }
            }
        }
    }
}

// MARK: - Overview Tab Content
struct OverviewTabContent: View {
    let quiz: Quiz
    @Binding var selectedDetailTab: PlanningDetailTab
    let viewModel: QuizViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Stats
                QuickStatsGrid(quiz: quiz)
                
                // Status Cards
                StatusCardsSection(quiz: quiz)
                
                // Team-Übersicht (kompakt)
                if !quiz.safeTeams.isEmpty {
                    CompactTeamOverview(quiz: quiz) {
                        selectedDetailTab = .teams
                    }
                }
                
                // Runden-Übersicht (kompakt)
                if !quiz.safeRounds.isEmpty {
                    CompactRoundsOverview(quiz: quiz) {
                        selectedDetailTab = .rounds
                    }
                }
            }
            .padding()
        }
    }
}





