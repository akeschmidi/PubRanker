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

    // Vordefinierte, gut unterscheidbare Farben
    private let chartColors: [Color] = [
        .blue,
        .orange,
        .green,
        .red,
        .purple
    ]

    private func getChartColor(for index: Int) -> Color {
        chartColors[index % chartColors.count]
    }

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
                VStack(spacing: 16) {
                    Chart {
                        ForEach(Array(quiz.sortedTeamsByScore.prefix(5).enumerated()), id: \.element.id) { index, team in
                            ForEach(quiz.sortedRounds) { round in
                                if let score = team.getScore(for: round) {
                                    LineMark(
                                        x: .value("Runde", round.name),
                                        y: .value("Punkte", score),
                                        series: .value("Team", team.name)
                                    )
                                    .foregroundStyle(getChartColor(for: index))
                                    .lineStyle(StrokeStyle(lineWidth: 3))
                                    .symbol {
                                        Circle()
                                            .fill(getChartColor(for: index))
                                            .frame(width: 10, height: 10)
                                            .overlay {
                                                Circle()
                                                    .stroke(.white, lineWidth: 2)
                                            }
                                    }
                                    .interpolationMethod(.catmullRom)
                                }
                            }
                        }
                    }
                    .frame(height: 350)
                    .chartYAxis {
                        AxisMarks(position: .leading) { value in
                            AxisGridLine()
                            AxisValueLabel()
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                            AxisValueLabel()
                                .font(.caption)
                        }
                    }
                    .padding()
                    .background(Color(nsColor: .controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    // Custom Legend
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Legende")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                            ForEach(Array(quiz.sortedTeamsByScore.prefix(5).enumerated()), id: \.element.id) { index, team in
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(getChartColor(for: index))
                                        .frame(width: 12, height: 12)
                                    Text(team.name)
                                        .font(.caption)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    if quiz.safeTeams.count > 5 {
                        Text("Zeigt die Top 5 Teams")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)
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
                        .foregroundStyle(.orange)
                        .annotation(position: .top, alignment: .center) {
                            Text("Ø \(String(format: "%.1f", avgScore))")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        BarMark(
                            x: .value("Runde", round.name),
                            y: .value("Maximum", maxScore)
                        )
                        .foregroundStyle(.green)
                        .annotation(position: .top, alignment: .center) {
                            Text("Max \(maxScore)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(height: 300)
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
                    "Durchschnitt": .orange,
                    "Maximum": .green
                ])
                .chartLegend(position: .bottom, spacing: 8) {
                    HStack(spacing: 20) {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.orange)
                                .frame(width: 12, height: 12)
                            Text("Durchschnitt")
                                .font(.caption)
                        }
                        HStack(spacing: 6) {
                            Circle()
                                .fill(.green)
                                .frame(width: 12, height: 12)
                            Text("Maximum")
                                .font(.caption)
                        }
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
