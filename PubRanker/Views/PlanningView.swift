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
    @Query(filter: #Predicate<Quiz> { !$0.isActive && !$0.isCompleted }, sort: \Quiz.date, order: .reverse) 
    private var plannedQuizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @State private var showingNewQuizSheet = false
    @State private var selectedQuiz: Quiz?
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            sidebar
        } detail: {
            if let quiz = selectedQuiz {
                planningDetailView(for: quiz)
            } else {
                emptyState
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            viewModel.setContext(modelContext)
            if selectedQuiz == nil && !plannedQuizzes.isEmpty {
                selectedQuiz = plannedQuizzes.first
            }
        }
    }
    
    private var sidebar: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Label("Quiz Planen", systemImage: "calendar.badge.plus")
                    .font(.title2)
                    .bold()
                Text("Bereite deine Quiz vor")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingNewQuizSheet = true
                } label: {
                    Label("Neues Quiz", systemImage: "plus.circle.fill")
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
        .sheet(isPresented: $showingNewQuizSheet) {
            NewQuizSheet(viewModel: viewModel)
        }
    }
    
    private func planningDetailView(for quiz: Quiz) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                // Quiz Info Header
                quizInfoCard(quiz)
                
                // Quick Stats
                quickStatsRow(quiz)
                
                Divider()
                
                // Setup Sections
                VStack(spacing: 16) {
                    setupSection(
                        title: "Teams hinzufügen",
                        icon: "person.3.fill",
                        color: .blue,
                        count: quiz.safeTeams.count,
                        isComplete: !quiz.safeTeams.isEmpty
                    ) {
                        TeamManagementView(quiz: quiz, viewModel: viewModel)
                    }
                    
                    setupSection(
                        title: "Runden definieren",
                        icon: "list.number",
                        color: .green,
                        count: quiz.safeRounds.count,
                        isComplete: !quiz.safeRounds.isEmpty
                    ) {
                        RoundManagementView(quiz: quiz, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
    }
    
    private func quizInfoCard(_ quiz: Quiz) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.title)
                        .bold()
                    
                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Start Quiz Button oben rechts
                if !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                    Button {
                        viewModel.startQuiz(quiz)
                        // Wechsle zur Durchführungsphase
                        selectedWorkflow = .execution
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                            Text("Quiz starten")
                                .font(.headline)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .green.opacity(0.3), radius: 6)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Quiz starten (⌘S)")
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
    
    private func quickStatsRow(_ quiz: Quiz) -> some View {
        HStack(spacing: 16) {
            statCard(title: "Teams", value: "\(quiz.safeTeams.count)", icon: "person.3.fill", color: .blue)
            statCard(title: "Runden", value: "\(quiz.safeRounds.count)", icon: "list.number", color: .green)
            statCard(title: "Max. Punkte", value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })", icon: "star.fill", color: .orange)
        }
        .padding(.horizontal)
    }
    
    private func statCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(value)
                .font(.title)
                .bold()
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(nsColor: .controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private func setupSection<Content: View>(
        title: String,
        icon: String,
        color: Color,
        count: Int,
        isComplete: Bool,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                    .foregroundStyle(color)
                
                Spacer()
                
                if isComplete {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
                
                Text("\(count)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.2))
                    .clipShape(Capsule())
            }
            
            content()
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private var emptyState: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Bereit für dein erstes Quiz?")
                        .font(.title)
                        .bold()
                    
                    Text("Plane und organisiere dein Pub Quiz ganz einfach")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Großer CTA Button
                Button {
                    showingNewQuizSheet = true
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Neues Quiz erstellen")
                                .font(.headline)
                            Text("Starte mit der Planung")
                                .font(.caption)
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct PlannedQuizRow: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(quiz.name)
                .font(.headline)
            
            HStack(spacing: 12) {
                if !quiz.venue.isEmpty {
                    Label(quiz.venue, systemImage: "mappin.circle")
                        .font(.caption)
                }
                Text(quiz.date, style: .date)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
            
            HStack(spacing: 8) {
                Label("\(quiz.safeTeams.count)", systemImage: "person.3")
                    .font(.caption2)
                Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                    .font(.caption2)
            }
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
