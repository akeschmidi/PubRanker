//
//  PlanningSidebarView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct PlanningSidebarView: View {
    @Binding var selectedQuiz: Quiz?
    @Binding var showingNewQuizSheet: Bool
    let plannedQuizzes: [Quiz]
    let viewModel: QuizViewModel
    let onEditQuiz: ((Quiz) -> Void)?
    let onDeleteQuiz: ((Quiz) -> Void)?
    
    init(
        selectedQuiz: Binding<Quiz?>,
        showingNewQuizSheet: Binding<Bool>,
        plannedQuizzes: [Quiz],
        viewModel: QuizViewModel,
        onEditQuiz: ((Quiz) -> Void)? = nil,
        onDeleteQuiz: ((Quiz) -> Void)? = nil
    ) {
        self._selectedQuiz = selectedQuiz
        self._showingNewQuizSheet = showingNewQuizSheet
        self.plannedQuizzes = plannedQuizzes
        self.viewModel = viewModel
        self.onEditQuiz = onEditQuiz
        self.onDeleteQuiz = onDeleteQuiz
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: AppSpacing.sm) {
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    Label("Planung", systemImage: "calendar.badge.plus")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Quizzes vorbereiten und planen")
                        .font(.subheadline)
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                Spacer()
                
                // Moderner + Button
                Button {
                    showingNewQuizSheet = true
                } label: {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Neues Quiz")
                            .font(.headline)
                    }
                }
                .primaryGradientButton()
                .keyboardShortcut("n", modifiers: .command)
                .help("Neues Quiz erstellen (⌘N)")
            }
            .padding(AppSpacing.md)
            .background(Color.appBackgroundSecondary)
            
            Divider()
            
            // Quiz List
            List(selection: $selectedQuiz) {
                if plannedQuizzes.isEmpty {
                    ContentUnavailableView(
                        "Keine geplanten Quizzes",
                        systemImage: "calendar.badge.plus",
                        description: Text("Erstelle dein erstes Quiz um loszulegen")
                    )
                } else {
                    Section("Geplante Quizzes (\(plannedQuizzes.count))") {
                        ForEach(plannedQuizzes) { quiz in
                            PlannedQuizRow(
                                quiz: quiz,
                                onEdit: onEditQuiz != nil ? { onEditQuiz?(quiz) } : nil,
                                onDelete: onDeleteQuiz != nil ? { onDeleteQuiz?(quiz) } : nil
                            )
                            .tag(quiz)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .scrollContentBackground(.hidden)
        }
        .navigationTitle("")
        .sheet(isPresented: $showingNewQuizSheet, onDismiss: {
            // Wähle das neu erstellte Quiz aus
            if let newQuiz = viewModel.selectedQuiz {
                selectedQuiz = newQuiz
            }
        }) {
            NewQuizSheet(viewModel: viewModel)
        }
    }
}





