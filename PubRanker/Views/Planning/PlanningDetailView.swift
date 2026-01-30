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
    @Bindable var viewModel: QuizViewModel
    var onEdit: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    @State private var showingEmailComposer = false

    private var emailAction: (() -> Void)? {
        return { showingEmailComposer = true }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Kompakter Header (nur Info, keine Buttons)
            CompactQuizHeader(
                quiz: quiz,
                onEmail: emailAction
            )
            
            Divider()

            // Custom Glass Tab Selector
            glassTabSelector
                #if os(iOS)
                .padding(.horizontal, AppSpacing.sm)
                .padding(.vertical, AppSpacing.xs)
                #else
                .padding(.horizontal, AppSpacing.screenPadding)
                .padding(.vertical, AppSpacing.xs)
                #endif

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
        .sheet(isPresented: $showingEmailComposer) {
            EmailComposerView(teams: quiz.safeTeams, quiz: quiz)
        }
    }
    
    // MARK: - Glass Tab Selector
    
    private var glassTabSelector: some View {
        HStack(spacing: AppSpacing.xxxs) {
            ForEach(PlanningDetailTab.allCases) { tab in
                planningTabButton(for: tab)
            }
        }
        .padding(4)
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
    
    private func planningTabButton(for tab: PlanningDetailTab) -> some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedDetailTab = tab
            }
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: tab.icon)
                    .font(.body)
                Text(tab.title)
                    .font(.body)
                    .fontWeight(selectedDetailTab == tab ? .semibold : .regular)
            }
            .foregroundStyle(selectedDetailTab == tab ? .white : Color.appTextPrimary)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xs)
            .background(planningTabBackground(for: tab))
            .contentShape(Rectangle())
        }
        .buttonStyle(GlassTabButtonStyle(isSelected: selectedDetailTab == tab))
        #if os(macOS)
        .help(tab.title)
        #endif
    }
    
    private func planningTabBackground(for tab: PlanningDetailTab) -> some View {
        Group {
            if selectedDetailTab == tab {
                // Aktiver Tab mit Primary Color
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
                // Inaktive Tabs - transparent
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.clear)
            }
        }
    }
}

// MARK: - Overview Tab Content
struct OverviewTabContent: View {
    let quiz: Quiz
    @Binding var selectedDetailTab: PlanningDetailTab
    @Bindable var viewModel: QuizViewModel

    @State private var showingTeamWizard = false
    @State private var showingRoundWizard = false
    @State private var selectedRound: Round? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.md) {
                // Quick Stats - klickbar für Teams und Runden hinzufügen
                QuickStatsGrid(
                    quiz: quiz,
                    onTeamsTap: { showingTeamWizard = true },
                    onRoundsTap: { showingRoundWizard = true }
                )

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
                    CompactRoundsOverview(quiz: quiz, onManage: {
                        selectedDetailTab = .rounds
                    }, onRoundTap: { round in
                        selectedRound = round
                    })
                }
            }
            .padding(AppSpacing.screenPadding)
        }
        .sheet(isPresented: $showingTeamWizard) {
            TeamWizardSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(isPresented: $showingRoundWizard) {
            RoundWizardSheet(quiz: quiz, viewModel: viewModel)
        }
        .sheet(item: $selectedRound) { round in
            EditRoundSheet(round: round, quiz: quiz, viewModel: viewModel)
        }
    }
}





