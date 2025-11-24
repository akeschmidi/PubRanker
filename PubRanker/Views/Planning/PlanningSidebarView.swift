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
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Quiz Planen", systemImage: "calendar.badge.plus")
                        .font(.title2)
                        .bold()
                    Text("Bereite deine Quiz vor")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Moderner + Button
                Button {
                    showingNewQuizSheet = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        Text("Neues Quiz")
                            .font(.headline)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .shadow(color: .blue.opacity(0.3), radius: 6, y: 3)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
                .help("Neues Quiz erstellen (⌘N)")
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            
            Divider()
            
            // Quiz List
            List(selection: $selectedQuiz) {
                if plannedQuizzes.isEmpty {
                    ContentUnavailableView(
                        "Keine geplanten Quiz",
                        systemImage: "calendar.badge.plus",
                        description: Text("Erstelle dein erstes Quiz")
                    )
                } else {
                    Section("Geplante Quiz (\(plannedQuizzes.count))") {
                        ForEach(plannedQuizzes) { quiz in
                            PlannedQuizRow(quiz: quiz)
                                .tag(quiz)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
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

