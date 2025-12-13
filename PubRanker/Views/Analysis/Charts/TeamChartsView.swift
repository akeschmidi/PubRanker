//
//  TeamChartsView.swift
//  PubRanker
//
//  Created on 24.11.2025
//

import SwiftUI
import SwiftData
import Charts

struct TeamChartsView: View {
    let stats: TeamStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
            Text("Diagramme")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .padding(.horizontal, AppSpacing.screenPadding)

            // Performance Trend Line Chart
            PerformanceTrendChart(stats: stats)

            // Placement Distribution Pie Chart
            PlacementDistributionChart(stats: stats)

            // Points Progress Chart
            if stats.quizHistory.count > 1 {
                PointsProgressChart(stats: stats)
            }
        }
    }
}

// MARK: - Performance Trend Chart
struct PerformanceTrendChart: View {
    let stats: TeamStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.appPrimary)
                Text("Platzierungs-Trend")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            if stats.quizHistory.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.line.uptrend.xyaxis",
                    message: "Keine Quiz-Teilnahmen",
                    description: "Das Team hat noch an keinen abgeschlossenen Quiz teilgenommen"
                )
            } else {
                Chart {
                    ForEach(Array(stats.quizHistory.reversed().enumerated()), id: \.element.quizName) { index, performance in
                        LineMark(
                            x: .value("Quiz", index + 1),
                            y: .value("Platzierung", performance.rank)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 8, height: 8)
                        }

                        PointMark(
                            x: .value("Quiz", index + 1),
                            y: .value("Platzierung", performance.rank)
                        )
                        .foregroundStyle(performance.rank.rankColor())
                        .symbolSize(100)
                    }
                }
                .frame(height: 250)
                .chartYScale(domain: .automatic(includesZero: false, reversed: true))
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
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

                Text("Niedrigere Platzierung = Besser")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                    .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }
}

// MARK: - Placement Distribution Chart
struct PlacementDistributionChart: View {
    let stats: TeamStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(Color.appAccent)
                Text("Platzierungsverteilung")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            if stats.participationCount == 0 {
                ChartEmptyStateView(
                    icon: "chart.pie.fill",
                    message: "Keine Teilnahmen",
                    description: "Das Team hat noch an keinen Quiz teilgenommen"
                )
            } else {
                HStack(spacing: 40) {
                    // Donut Chart
                    Chart {
                        SectorMark(
                            angle: .value("Anzahl", stats.winsCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appSecondary, Color.appSecondaryLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        SectorMark(
                            angle: .value("Anzahl", stats.secondPlaceCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appTextSecondary, Color.appTextSecondary.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        SectorMark(
                            angle: .value("Anzahl", stats.thirdPlaceCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appAccent, Color.appAccentLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                        SectorMark(
                            angle: .value("Anzahl", max(1, stats.participationCount - stats.winsCount - stats.secondPlaceCount - stats.thirdPlaceCount)),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                    .frame(width: 200, height: 200)

                    // Legend
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Legende")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .bold()
                        
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            placementLegendRow(color: Color.appSecondary, label: "1. Platz", count: stats.winsCount)
                            placementLegendRow(color: Color.appTextSecondary, label: "2. Platz", count: stats.secondPlaceCount)
                            placementLegendRow(color: Color.appAccent, label: "3. Platz", count: stats.thirdPlaceCount)
                            placementLegendRow(color: Color.appTextTertiary.opacity(0.3), label: "Andere", count: stats.participationCount - stats.winsCount - stats.secondPlaceCount - stats.thirdPlaceCount)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(AppSpacing.md)
                .appCard(style: .glassmorphism)
                .padding(.horizontal, AppSpacing.screenPadding)
            }
        }
    }

    private func placementLegendRow(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: AppSpacing.xxs) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Text("\(count)")
                .font(.subheadline)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .monospacedDigit()
        }
    }
}

// MARK: - Points Progress Chart
struct PointsProgressChart: View {
    let stats: TeamStats

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(Color.appSecondary)
                Text("Punkte-Entwicklung")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
            }
            .padding(.horizontal, AppSpacing.screenPadding)

            if stats.quizHistory.isEmpty {
                ChartEmptyStateView(
                    icon: "chart.bar.xaxis",
                    message: "Keine Quiz-Historie",
                    description: "Das Team hat noch an keinen abgeschlossenen Quiz teilgenommen"
                )
            } else {
                Chart {
                    ForEach(Array(stats.quizHistory.reversed().enumerated()), id: \.element.quizName) { index, performance in
                        BarMark(
                            x: .value("Quiz", "\(index + 1)"),
                            y: .value("Punkte", performance.points)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(hex: stats.teamColor) ?? Color.appPrimary,
                                    (Color(hex: stats.teamColor) ?? Color.appPrimary).opacity(0.7)
                                ],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(AppCornerRadius.xs)
                        .annotation(position: .top, alignment: .center) {
                            Text("\(performance.points)")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                        }
                    }

                    RuleMark(y: .value("Durchschnitt", stats.averagePoints))
                        .foregroundStyle(Color.appAccent)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("Ø \(String(format: "%.1f", stats.averagePoints))")
                                .font(.caption)
                                .foregroundStyle(Color.appAccent)
                                .monospacedDigit()
                                .padding(.leading, AppSpacing.xxxs)
                        }
                }
                .frame(height: 250)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
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

// MARK: - Helper Extension
extension Int {
    func rankColor() -> Color {
        switch self {
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appAccent
        default: return Color.appPrimary
        }
    }
}
