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
        VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
            Text("Visualisierungen")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

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
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.appPrimary)
                Text("Punkteverteilung")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

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
                        .foregroundStyle(Color.appPrimary)
                        .cornerRadius(AppCornerRadius.xs)
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("\(team.totalScore)")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                                .padding(.leading, AppSpacing.xxxs)
                        }
                    }
                }
                .frame(height: CGFloat(max(300, quiz.safeTeams.count * 40)))
                .chartXAxis {
                    AxisMarks(position: .bottom) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                .padding(AppSpacing.md)
                .appCard(style: .glassmorphism)
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }
}

// MARK: - Round Performance Chart
struct RoundPerformanceChart: View {
    let quiz: Quiz

    // Vordefinierte, gut unterscheidbare Farben
    private let chartColors: [Color] = [
        Color.appPrimary,
        Color.appAccent,
        Color.appSuccess,
        Color.appSecondary,
        Color.appPrimaryDark
    ]

    private func getChartColor(for index: Int) -> Color {
        chartColors[index % chartColors.count]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.appSecondary)
                Text("Performance über Runden")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            if quiz.safeTeams.isEmpty || quiz.safeRounds.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    message: quiz.safeTeams.isEmpty ? "Keine Teams vorhanden" : "Keine Runden vorhanden",
                    description: quiz.safeTeams.isEmpty ? "Füge Teams zum Quiz hinzu" : "Füge Runden zum Quiz hinzu"
                )
            } else {
                VStack(spacing: AppSpacing.sm) {
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
                                                    .stroke(Color.appBackground, lineWidth: 2)
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
                                .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                            AxisValueLabel()
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .chartXAxis {
                        AxisMarks { value in
                            AxisGridLine()
                                .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                            AxisValueLabel()
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                    .padding(AppSpacing.md)
                    .appCard(style: .glassmorphism)

                    // Custom Legend
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        Text("Legende")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: AppSpacing.xxs) {
                            ForEach(Array(quiz.sortedTeamsByScore.prefix(5).enumerated()), id: \.element.id) { index, team in
                                HStack(spacing: AppSpacing.xxs) {
                                    Circle()
                                        .fill(getChartColor(for: index))
                                        .frame(width: 12, height: 12)
                                    Text(team.name)
                                        .font(.caption)
                                        .foregroundStyle(Color.appTextPrimary)
                                        .lineLimit(1)
                                    Spacer(minLength: 0)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenPadding)

                    if quiz.safeTeams.count > 5 {
                        Text("Zeigt die Top 5 Teams")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .padding(.horizontal, AppSpacing.screenPadding)
                    }
                }
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }
}

// MARK: - Round Distribution Chart
struct RoundDistributionChart: View {
    let quiz: Quiz

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(Color.appAccent)
                Text("Punkteverteilung pro Runde")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

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
                        .foregroundStyle(Color.appAccent)
                        .cornerRadius(AppCornerRadius.xs)
                        .annotation(position: .top, alignment: .center) {
                            Text("Ø \(String(format: "%.1f", avgScore))")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                        }

                        BarMark(
                            x: .value("Runde", round.name),
                            y: .value("Maximum", maxScore)
                        )
                        .foregroundStyle(Color.appSuccess)
                        .cornerRadius(AppCornerRadius.xs)
                        .annotation(position: .top, alignment: .center) {
                            Text("Max \(maxScore)")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                        }
                    }
                }
                .frame(height: 300)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                .chartForegroundStyleScale([
                    "Durchschnitt": Color.appAccent,
                    "Maximum": Color.appSuccess
                ])
                .chartLegend(position: .bottom, spacing: AppSpacing.xxs) {
                    HStack(spacing: AppSpacing.md) {
                        HStack(spacing: AppSpacing.xxxs) {
                            Circle()
                                .fill(Color.appAccent)
                                .frame(width: 12, height: 12)
                            Text("Durchschnitt")
                                .font(.caption)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        HStack(spacing: AppSpacing.xxxs) {
                            Circle()
                                .fill(Color.appSuccess)
                                .frame(width: 12, height: 12)
                            Text("Maximum")
                                .font(.caption)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                    }
                }
                .padding(AppSpacing.md)
                .appCard(style: .glassmorphism)
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }
}
