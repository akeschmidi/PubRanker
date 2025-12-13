//
//  AnalysisSharedComponents.swift
//  PubRanker
//
//  Created on 24.11.2025
//

import SwiftUI

// MARK: - Chart Empty State
struct ChartEmptyStateView: View {
    let icon: String
    let message: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary.opacity(0.5))

            VStack(spacing: 8) {
                Text(message)
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .padding()
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
    }
}

// MARK: - Analysis Tab Enum
enum AnalysisTab: CaseIterable {
    case quizAnalysis
    case teamStatistics
    case overallStatistics

    var rawValue: String {
        switch self {
        case .quizAnalysis: return NSLocalizedString("analysisTab.quizAnalysis", comment: "Quiz Analysis")
        case .teamStatistics: return NSLocalizedString("analysisTab.teamStatistics", comment: "Team Statistics")
        case .overallStatistics: return NSLocalizedString("analysisTab.overallStatistics", comment: "Overall Statistics")
        }
    }

    var icon: String {
        switch self {
        case .quizAnalysis: return "chart.bar.fill"
        case .teamStatistics: return "person.3.fill"
        case .overallStatistics: return "chart.pie.fill"
        }
    }
}

// MARK: - Helper Functions
extension View {
    func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
}

// MARK: - Active Quiz Row
struct ActiveQuizRowAnalysis: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(Color.appSuccess)
                    .frame(width: 8, height: 8)

                Text(quiz.name)
                    .font(.headline)
            }

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
                Label("Aktiv", systemImage: "clock.fill")
                    .font(.caption2)
                    .foregroundStyle(.green)
                Text("\(quiz.safeTeams.count) Teams")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Completed Quiz Row
struct CompletedQuizRow: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)

                Text(quiz.name)
                    .font(.headline)
            }

            HStack(spacing: 12) {
                if !quiz.venue.isEmpty {
                    Label(quiz.venue, systemImage: "mappin.circle")
                        .font(.caption)
                }
                Text(quiz.date, style: .date)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            if let winner = quiz.sortedTeamsByScore.first {
                HStack(spacing: 8) {
                    Label("Sieger:", systemImage: "trophy.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                    Text(winner.name)
                        .font(.caption2)
                        .bold()
                    Text("(\(winner.totalScore))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
