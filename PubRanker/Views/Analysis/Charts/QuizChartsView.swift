//
//  QuizChartsView.swift
//  PubRanker
//
//  Created on 24.11.2025
//

import SwiftUI
import SwiftData
import Charts

struct QuizChartsView: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Visualisierungen")
                .font(.title2)
                .bold()
                .padding(.horizontal)

            // Team Points Bar Chart
            TeamPointsChart(quiz: quiz)

            // Round Performance Line Chart
            if quiz.safeRounds.count > 1 {
                RoundPerformanceChart(quiz: quiz)
            }

            // Round Distribution Bar Chart
            RoundDistributionChart(quiz: quiz)
        }
    }
}

// MARK: - Team Points Chart
struct TeamPointsChart: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.blue)
                Text("Punkteverteilung")
                    .font(.headline)
            }
            .padding(.horizontal)

            if quiz.safeTeams.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.bar.fill",
                    message: "Keine Teams vorhanden",
                    description: "Füge Teams zum Quiz hinzu, um die Punkteverteilung zu sehen"
                )
            } else {
                Chart {
                    ForEach(quiz.sortedTeamsByScore) { team in
                        BarMark(
                            x: .value("Punkte", team.totalScore),
                            y: .value("Team", team.name)
                        )
                        .foregroundStyle(Color(hex: team.color) ?? .blue)
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("\(team.totalScore)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                        }
                    }
                }
                .frame(height: CGFloat(max(300, quiz.safeTeams.count * 40)))
                .chartXAxis {
                    AxisMarks(position: .bottom)
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Round Performance Chart
struct RoundPerformanceChart: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.purple)
                Text("Performance über Runden")
                    .font(.headline)
            }
            .padding(.horizontal)

            if quiz.safeTeams.isEmpty || quiz.safeRounds.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    message: quiz.safeTeams.isEmpty ? "Keine Teams vorhanden" : "Keine Runden vorhanden",
                    description: quiz.safeTeams.isEmpty ? "Füge Teams zum Quiz hinzu" : "Füge Runden zum Quiz hinzu"
                )
            } else {
                Chart {
                    ForEach(quiz.sortedTeamsByScore.prefix(5)) { team in
                        ForEach(quiz.sortedRounds) { round in
                            if let score = team.getScore(for: round) {
                                LineMark(
                                    x: .value("Runde", round.name),
                                    y: .value("Punkte", score)
                                )
                                .foregroundStyle(Color(hex: team.color) ?? .blue)
                                .symbol {
                                    Circle()
                                        .fill(Color(hex: team.color) ?? .blue)
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartLegend(position: .bottom, spacing: 8)
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                if quiz.safeTeams.count > 5 {
                    Text("Zeigt die Top 5 Teams")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }
            }
        }
    }
}

// MARK: - Round Distribution Chart
struct RoundDistributionChart: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(.orange)
                Text("Punkteverteilung pro Runde")
                    .font(.headline)
            }
            .padding(.horizontal)

            if quiz.safeRounds.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.bar.xaxis",
                    message: "Keine Runden vorhanden",
                    description: "Füge Runden zum Quiz hinzu, um die Verteilung zu sehen"
                )
            } else if quiz.safeTeams.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.bar.xaxis",
                    message: "Keine Teams vorhanden",
                    description: "Füge Teams zum Quiz hinzu, um die Verteilung zu sehen"
                )
            } else {
                Chart {
                    ForEach(quiz.sortedRounds) { round in
                        let avgScore = quiz.safeTeams.reduce(0.0) { total, team in
                            total + Double(team.getScore(for: round) ?? 0)
                        } / Double(quiz.safeTeams.count)
                        let maxScore = quiz.safeTeams.compactMap { $0.getScore(for: round) }.max() ?? 0

                        BarMark(
                            x: .value("Runde", round.name),
                            y: .value("Durchschnitt", avgScore)
                        )
                        .foregroundStyle(.blue.opacity(0.5))

                        BarMark(
                            x: .value("Runde", round.name),
                            y: .value("Maximum", maxScore)
                        )
                        .foregroundStyle(.blue)
                    }
                }
                .frame(height: 250)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartForegroundStyleScale([
                    "Durchschnitt": .blue.opacity(0.5),
                    "Maximum": .blue
                ])
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }
}
