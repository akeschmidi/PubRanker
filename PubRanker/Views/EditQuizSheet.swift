//
//  EditQuizSheet.swift
//  PubRanker
//
//  Created on 01.11.2025
//

import SwiftUI

struct EditQuizSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    @State private var quizName: String = ""
    @State private var venueName: String = ""
    @State private var quizDate: Date = Date()
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Quiz-Details") {
                    TextField("Quiz-Name", text: $quizName)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Veranstaltungsort", text: $venueName)
                        .textFieldStyle(.roundedBorder)
                    
                    DatePicker("Datum & Uhrzeit", 
                              selection: $quizDate,
                              displayedComponents: [.date, .hourAndMinute])
                }
                
                Section("Statistiken") {
                    LabeledContent("Teams", value: "\(quiz.safeTeams.count)")
                    LabeledContent("Runden", value: "\(quiz.safeRounds.count)")
                    LabeledContent("Max. Punkte", value: "\(quiz.safeRounds.reduce(0) { $0 + $1.maxPoints })")
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Quiz löschen", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle("Quiz bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sichern") {
                        saveChanges()
                        dismiss()
                    }
                    .disabled(quizName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Quiz löschen?", isPresented: $showingDeleteConfirmation) {
                Button("Abbrechen", role: .cancel) {}
                Button("Löschen", role: .destructive) {
                    deleteQuiz()
                }
            } message: {
                Text("Möchtest du '\(quiz.name)' wirklich löschen? Diese Aktion kann nicht rückgängig gemacht werden.")
            }
        }
        .onAppear {
            quizName = quiz.name
            venueName = quiz.venue
            quizDate = quiz.date
        }
    }
    
    private func saveChanges() {
        quiz.name = quizName.trimmingCharacters(in: .whitespacesAndNewlines)
        quiz.venue = venueName.trimmingCharacters(in: .whitespacesAndNewlines)
        quiz.date = quizDate
        // Speichern nach Änderung
        try? modelContext.save()
    }
    
    private func deleteQuiz() {
        viewModel.deleteQuiz(quiz)
        dismiss()
    }
}
