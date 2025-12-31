//
//  PlanningView.swift
//  PubRanker
//
//  Created on 31.10.2025
//

import SwiftUI
import SwiftData

struct PlanningView: View {
    @Environment(\.modelContext) private var modelContext
    // Sortiert: Nächste Quiz zuerst (aufsteigend nach Datum)
    @Query(filter: #Predicate<Quiz> { !$0.isActive && !$0.isCompleted }, sort: \Quiz.date, order: .forward)
    private var plannedQuizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @State private var showingNewQuizSheet = false
    @State private var showingEditQuizSheet = false
    @State private var selectedQuiz: Quiz?
    @State private var quizToDelete: Quiz?
    @State private var showingDeleteConfirmation = false
    @Query(sort: \Team.createdAt, order: .reverse) private var allTeams: [Team]
    @State private var showingGlobalTeamPicker = false
    @State private var selectedDetailTab: PlanningDetailTab = .overview
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            PlanningSidebarView(
                selectedQuiz: $selectedQuiz,
                showingNewQuizSheet: $showingNewQuizSheet,
                plannedQuizzes: plannedQuizzes,
                viewModel: viewModel
            )
            #if os(iOS)
            .navigationSplitViewColumnWidth(min: 280, ideal: 320, max: 380)
            #else
            .navigationSplitViewColumnWidth(min: 320, ideal: 380, max: 500)
            #endif
        } detail: {
            if let quiz = selectedQuiz {
                PlanningDetailView(
                    quiz: quiz,
                    selectedDetailTab: $selectedDetailTab,
                    selectedWorkflow: $selectedWorkflow,
                    viewModel: viewModel,
                    onEdit: {
                        showingEditQuizSheet = true
                    },
                    onDelete: {
                        quizToDelete = quiz
                        showingDeleteConfirmation = true
                    }
                )
            } else {
                PlanningEmptyStateView {
                    showingNewQuizSheet = true
                }
            }
        }
        #if os(iOS)
        .navigationSplitViewStyle(.prominentDetail)
        #else
        .navigationSplitViewStyle(.balanced)
        #endif
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                EmptyView()
            }
        }
        .onAppear {
            viewModel.setContext(modelContext)
            // If navigating from Teams Manager with a selected quiz, use it
            if let navigationQuiz = viewModel.selectedQuiz {
                selectedQuiz = navigationQuiz
                viewModel.selectedQuiz = nil // Clear after using
            } else if selectedQuiz == nil && !plannedQuizzes.isEmpty {
                selectedQuiz = plannedQuizzes.first
            }
        }
        .onChange(of: viewModel.selectedQuiz) { oldValue, newValue in
            // If viewModel.selectedQuiz is set externally (e.g., from Teams Manager), update local selection
            if let newQuiz = newValue {
                selectedQuiz = newQuiz
                viewModel.selectedQuiz = nil // Clear after using
            }
        }
        .onChange(of: plannedQuizzes) { oldValue, newValue in
            // Wenn das aktuell ausgewählte Quiz gelöscht wurde
            if let selected = selectedQuiz, !newValue.contains(where: { $0.id == selected.id }) {
                selectedQuiz = newValue.first
            }
        }
        .sheet(isPresented: $showingEditQuizSheet) {
            if let quiz = selectedQuiz {
                EditQuizSheet(quiz: quiz, viewModel: viewModel)
            }
        }
        .sheet(isPresented: $showingGlobalTeamPicker) {
            if let quiz = selectedQuiz {
                GlobalTeamPickerSheet(quiz: quiz, availableTeams: availableGlobalTeams(for: quiz), modelContext: modelContext)
            }
        }
        .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation) {
            Button("Abbrechen", role: .cancel) {
                quizToDelete = nil
            }
            Button("Löschen", role: .destructive) {
                if let quiz = quizToDelete {
                    viewModel.deleteQuiz(quiz)
                    quizToDelete = nil
                }
            }
        } message: {
            if let quiz = quizToDelete {
                Text("Möchtest du das Quiz '\(quiz.name)' wirklich löschen?")
            }
        }
    }
    
    private func availableGlobalTeams(for quiz: Quiz) -> [Team] {
        return allTeams.filter { team in
            // Teams die noch keinem Quiz zugeordnet sind oder nicht diesem Quiz
            (team.quizzes?.isEmpty ?? true) || !(team.quizzes?.contains(where: { $0.id == quiz.id }) ?? false)
        }
    }
}
