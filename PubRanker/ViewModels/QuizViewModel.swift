//
//  QuizViewModel.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import Foundation
import SwiftData
import Observation

@Observable
final class QuizViewModel {
    var modelContext: ModelContext?
    var selectedQuiz: Quiz?
    var searchText: String = ""
    var showingNewQuizSheet: Bool = false
    var showingTeamSheet: Bool = false
    var showingRoundSheet: Bool = false
    
    init() {}
    
    func setContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Quiz Management
    
    func createQuiz(name: String, venue: String) {
        guard let context = modelContext else { return }
        
        let quiz = Quiz(name: name, venue: venue)
        context.insert(quiz)
        
        do {
            try context.save()
            selectedQuiz = quiz
        } catch {
            print("Error creating quiz: \(error)")
        }
    }
    
    func deleteQuiz(_ quiz: Quiz) {
        guard let context = modelContext else { return }
        
        context.delete(quiz)
        
        do {
            try context.save()
            if selectedQuiz?.id == quiz.id {
                selectedQuiz = nil
            }
        } catch {
            print("Error deleting quiz: \(error)")
        }
    }
    
    func startQuiz(_ quiz: Quiz) {
        quiz.isActive = true
        saveContext()
    }
    
    func completeQuiz(_ quiz: Quiz) {
        quiz.isActive = false
        quiz.isCompleted = true
        saveContext()
    }
    
    // MARK: - Team Management
    
    func addTeam(to quiz: Quiz, name: String, color: String = "#007AFF") {
        guard let context = modelContext else { return }
        
        let team = Team(name: name, color: color)
        team.quiz = quiz
        quiz.teams.append(team)
        context.insert(team)
        
        saveContext()
    }
    
    func deleteTeam(_ team: Team, from quiz: Quiz) {
        guard let context = modelContext else { return }
        
        if let index = quiz.teams.firstIndex(where: { $0.id == team.id }) {
            quiz.teams.remove(at: index)
        }
        context.delete(team)
        
        saveContext()
    }
    
    func updateTeamName(_ team: Team, newName: String) {
        team.name = newName
        saveContext()
    }
    
    // MARK: - Round Management
    
    func addRound(to quiz: Quiz, name: String, maxPoints: Int = 10) {
        guard let context = modelContext else { return }
        
        let orderIndex = quiz.rounds.count
        let round = Round(name: name, maxPoints: maxPoints, orderIndex: orderIndex)
        round.quiz = quiz
        quiz.rounds.append(round)
        context.insert(round)
        
        saveContext()
    }
    
    func deleteRound(_ round: Round, from quiz: Quiz) {
        guard let context = modelContext else { return }
        
        if let index = quiz.rounds.firstIndex(where: { $0.id == round.id }) {
            quiz.rounds.remove(at: index)
        }
        context.delete(round)
        
        // Reorder remaining rounds
        for (index, remainingRound) in quiz.sortedRounds.enumerated() {
            remainingRound.orderIndex = index
        }
        
        saveContext()
    }
    
    func completeRound(_ round: Round) {
        round.isCompleted = true
        saveContext()
    }
    
    // MARK: - Score Management
    
    func updateScore(for team: Team, in round: Round, points: Int) {
        team.addScore(for: round, points: points)
        saveContext()
    }
    
    func clearScore(for team: Team, in round: Round) {
        if let index = team.roundScores.firstIndex(where: { $0.roundId == round.id }) {
            team.roundScores.remove(at: index)
            team.calculateTotalScore()
            saveContext()
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    func getTeamRank(for team: Team, in quiz: Quiz) -> Int {
        let sortedTeams = quiz.sortedTeamsByScore
        return (sortedTeams.firstIndex(where: { $0.id == team.id }) ?? 0) + 1
    }
}
