//
//  QuizListView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import SwiftData

struct QuizListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Quiz.date, order: .reverse) private var quizzes: [Quiz]
    @Bindable var viewModel: QuizViewModel
    @State private var showingNewQuizSheet = false
    @State private var selection: Quiz?
    @State private var quizToDelete: Quiz?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            quizList
            .navigationTitle("PubRanker 🎯")
            .listStyle(.sidebar)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingNewQuizSheet = true
                    } label: {
                        Label("Neues Quiz", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                    .help("Neues Quiz erstellen (⌘N)")
                }
                
                if let selectedQuiz = selection {
                    ToolbarItem(placement: .destructiveAction) {
                        Button(role: .destructive) {
                            quizToDelete = selectedQuiz
                            showingDeleteConfirmation = true
                        } label: {
                            Label("Löschen", systemImage: "trash")
                        }
                        .help("Ausgewähltes Quiz löschen")
                    }
                }
            }
            .onChange(of: selection) { oldValue, newValue in
                viewModel.selectedQuiz = newValue
            }
            .sheet(isPresented: $showingNewQuizSheet) {
                NewQuizSheet(viewModel: viewModel)
            }
            .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation, presenting: quizToDelete) { quiz in
                Button("Abbrechen", role: .cancel) {
                    quizToDelete = nil
                }
                Button("Löschen", role: .destructive) {
                    deleteQuiz(quiz)
                }
            } message: { quiz in
                Text("Möchten Sie \"\(quiz.name)\" wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        } detail: {
            if let selectedQuiz = selection {
                QuizDetailView(quiz: selectedQuiz, viewModel: viewModel)
            } else {
                ContentUnavailableView(
                    "Kein Quiz ausgewählt",
                    systemImage: "list.bullet.clipboard",
                    description: Text("Wählen Sie ein Quiz aus der Liste oder erstellen Sie ein neues.")
                )
                .frame(minWidth: 600, minHeight: 400)
            }
        }
        .navigationSplitViewStyle(.balanced)
        .onAppear {
            viewModel.setContext(modelContext)
            // Select first active quiz if none selected
            if selection == nil && !activeQuizzes.isEmpty {
                selection = activeQuizzes.first
            }
        }
        .frame(minWidth: 900, minHeight: 600)
    }
    
    private func deleteQuiz(_ quiz: Quiz) {
        // Deselect if currently selected
        if selection?.id == quiz.id {
            selection = nil
        }
        viewModel.deleteQuiz(quiz)
        quizToDelete = nil
    }
    
    private var activeQuizzes: [Quiz] {
        quizzes.filter { $0.isActive && !$0.isCompleted }
    }
    
    private var completedQuizzes: [Quiz] {
        quizzes.filter { $0.isCompleted }
    }
    
    private var plannedQuizzes: [Quiz] {
        quizzes.filter { !$0.isActive && !$0.isCompleted }
    }
    
    private var quizList: some View {
        List(selection: $selection) {
            if !activeQuizzes.isEmpty {
                quizSection(title: "Aktive Quiz", quizzes: activeQuizzes)
            }
            
            if !completedQuizzes.isEmpty {
                quizSection(title: "Abgeschlossene Quiz", quizzes: completedQuizzes)
            }
            
            if !plannedQuizzes.isEmpty {
                quizSection(title: "Geplante Quiz", quizzes: plannedQuizzes)
            }
        }
    }
    
    private func quizSection(title: String, quizzes: [Quiz]) -> some View {
        Section(title) {
            ForEach(quizzes) { quiz in
                QuizRowView(quiz: quiz)
                    .tag(quiz)
                    .contextMenu {
                        deleteButton(for: quiz)
                    }
            }
            .onDelete { indexSet in
                handleDelete(at: indexSet, in: quizzes)
            }
        }
    }
    
    private func deleteButton(for quiz: Quiz) -> some View {
        Button(role: .destructive) {
            quizToDelete = quiz
            showingDeleteConfirmation = true
        } label: {
            Label("Löschen", systemImage: "trash")
        }
    }
    
    private func handleDelete(at indexSet: IndexSet, in quizzes: [Quiz]) {
        for index in indexSet {
            quizToDelete = quizzes[index]
            showingDeleteConfirmation = true
        }
    }
}

struct QuizRowView: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(quiz.name)
                    .font(.headline)
                
                Spacer()
                
                if quiz.isActive {
                    Label("Live", systemImage: "circle.fill")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else if quiz.isCompleted {
                    Label("Beendet", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            
            HStack {
                if !quiz.venue.isEmpty {
                    Label(quiz.venue, systemImage: "mappin.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Text(quiz.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack {
                Label("\(quiz.teams.count) Teams", systemImage: "person.3")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Label("\(quiz.rounds.count) Runden", systemImage: "list.number")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                if quiz.rounds.count > 0 {
                    ProgressView(value: quiz.progress)
                        .frame(width: 60)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct NewQuizSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var viewModel: QuizViewModel
    @State private var quizName = ""
    @State private var venue = ""
    @State private var date = Date()
    @FocusState private var focusedField: Field?
    
    enum Field {
        case name, venue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .blue.opacity(0.3), radius: 10)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 36))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: 8) {
                    Text("Neues Quiz erstellen")
                        .font(.title)
                        .bold()
                    
                    Text("Erstellen Sie ein neues Pub Quiz und fügen Sie Teams sowie Runden hinzu")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 32)
            
            // Form Content
            VStack(spacing: 24) {
                // Quiz Name
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "text.quote")
                            .foregroundStyle(.blue)
                        Text("Quiz Name")
                            .font(.headline)
                    }
                    
                    TextField("z.B. Pub Quiz im Löwen, Weihnachts-Quiz...", text: $quizName)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                        .focused($focusedField, equals: .name)
                }
                
                // Venue
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                        Text("Veranstaltungsort")
                            .font(.headline)
                    }
                    
                    TextField("z.B. Gasthaus zum Löwen, Mein Wohnzimmer...", text: $venue)
                        .textFieldStyle(.roundedBorder)
                        .font(.body)
                        .focused($focusedField, equals: .venue)
                }
                
                // Date & Time
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar.circle.fill")
                            .foregroundStyle(.green)
                        Text("Datum & Uhrzeit")
                            .font(.headline)
                    }
                    
                    DatePicker("", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Action Buttons
            HStack(spacing: 16) {
                Button {
                    dismiss()
                } label: {
                    Text("Abbrechen")
                        .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.escape)
                .buttonStyle(.bordered)
                .controlSize(.large)
                
                Button {
                    viewModel.createQuiz(name: quizName, venue: venue)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Quiz erstellen")
                    }
                    .frame(maxWidth: .infinity)
                }
                .keyboardShortcut(.return, modifiers: .command)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(quizName.isEmpty)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 32)
        }
        .frame(width: 600, height: 750)
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear {
            focusedField = .name
        }
    }
}
