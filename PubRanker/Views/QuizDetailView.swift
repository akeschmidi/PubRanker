//
//  QuizDetailView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct QuizDetailView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    @State private var selectedTab: DetailTab = .leaderboard
    
    enum DetailTab: String, CaseIterable, Identifiable {
        case leaderboard = "Rangliste"
        case rounds = "Runden"
        case teams = "Teams"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .leaderboard: return "trophy.fill"
            case .rounds: return "list.number"
            case .teams: return "person.3.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            QuizHeaderView(quiz: quiz, viewModel: viewModel)
            
            Divider()
            
            // Content based on selected tab
            Group {
                switch selectedTab {
                case .leaderboard:
                    LeaderboardView(quiz: quiz, viewModel: viewModel)
                case .rounds:
                    RoundManagementView(quiz: quiz, viewModel: viewModel)
                case .teams:
                    TeamManagementView(quiz: quiz, viewModel: viewModel)
                }
            }
        }
        .navigationTitle(quiz.name)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Ansicht", selection: $selectedTab) {
                    ForEach(DetailTab.allCases) { tab in
                        Label(tab.rawValue, systemImage: tab.icon)
                            .tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 400)
            }
        }
    }
}

struct QuizHeaderView: View {
    @Bindable var quiz: Quiz
    @Bindable var viewModel: QuizViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top, spacing: 20) {
                // Quiz Info
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(quiz.name)
                            .font(.title2)
                            .bold()
                        
                        if quiz.isActive {
                            Label("Live", systemImage: "circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.green)
                                .clipShape(Capsule())
                        } else if quiz.isCompleted {
                            Label("Beendet", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .clipShape(Capsule())
                        }
                    }
                    
                    HStack(spacing: 16) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Label("\(quiz.safeTeams.count) Teams", systemImage: "person.3")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                // Action Buttons
                HStack(spacing: 12) {
                    if quiz.isActive {
                        Button {
                            viewModel.completeQuiz(quiz)
                        } label: {
                            Label("Quiz beenden", systemImage: "flag.checkered")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red)
                        .keyboardShortcut("e", modifiers: .command)
                        .help("Quiz beenden (⌘E)")
                    } else if !quiz.isCompleted {
                        Button {
                            viewModel.startQuiz(quiz)
                        } label: {
                            Label("Quiz starten", systemImage: "play.fill")
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                        .keyboardShortcut("s", modifiers: .command)
                        .help("Quiz starten (⌘S)")
                    }
                }
            }
            
            // Progress Bar
            if quiz.safeRounds.count > 0 {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Fortschritt")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(quiz.completedRoundsCount) von \(quiz.safeRounds.count) Runden")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ProgressView(value: quiz.progress)
                        .tint(.blue)
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color(nsColor: .controlBackgroundColor), Color(nsColor: .windowBackgroundColor)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
