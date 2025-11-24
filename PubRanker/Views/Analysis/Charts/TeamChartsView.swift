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
        VStack(alignment: .leading, spacing: 24) {
            Text("Diagramme")
                .font(.title2)
                .bold()
                .padding(.horizontal)

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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(.blue)
                Text("Platzierungs-Trend")
                    .font(.headline)
            }
            .padding(.horizontal)

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
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        .symbol {
                            Circle()
                                .fill(.blue)
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
                    }
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                    }
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)

                Text("Niedrigere Platzierung = Besser")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)
            }
        }
    }
}

// MARK: - Placement Distribution Chart
struct PlacementDistributionChart: View {
    let stats: TeamStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.orange)
                Text("Platzierungsverteilung")
                    .font(.headline)
            }
            .padding(.horizontal)

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
                        .foregroundStyle(.yellow)

                        SectorMark(
                            angle: .value("Anzahl", stats.secondPlaceCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(.gray)

                        SectorMark(
                            angle: .value("Anzahl", stats.thirdPlaceCount),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color(red: 0.8, green: 0.5, blue: 0.2))

                        SectorMark(
                            angle: .value("Anzahl", max(1, stats.participationCount - stats.winsCount - stats.secondPlaceCount - stats.thirdPlaceCount)),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(.secondary.opacity(0.3))
                    }
                    .frame(width: 200, height: 200)

                    // Legend
                    VStack(alignment: .leading, spacing: 12) {
                        placementLegendRow(color: .yellow, label: "1. Platz", count: stats.winsCount)
                        placementLegendRow(color: .gray, label: "2. Platz", count: stats.secondPlaceCount)
                        placementLegendRow(color: Color(red: 0.8, green: 0.5, blue: 0.2), label: "3. Platz", count: stats.thirdPlaceCount)
                        placementLegendRow(color: .secondary.opacity(0.3), label: "Andere", count: stats.participationCount - stats.winsCount - stats.secondPlaceCount - stats.thirdPlaceCount)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color(nsColor: .controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
        }
    }

    private func placementLegendRow(color: Color, label: String, count: Int) -> some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text("\(count)")
                .font(.subheadline)
                .bold()
                .monospacedDigit()
        }
    }
}

// MARK: - Points Progress Chart
struct PointsProgressChart: View {
    let stats: TeamStats

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.bar.xaxis")
                    .foregroundStyle(.purple)
                Text("Punkte-Entwicklung")
                    .font(.headline)
            }
            .padding(.horizontal)

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
                        .foregroundStyle(Color(hex: stats.teamColor) ?? .blue)
                        .annotation(position: .top, alignment: .center) {
                            Text("\(performance.points)")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    RuleMark(y: .value("Durchschnitt", stats.averagePoints))
                        .foregroundStyle(.red)
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("Ø \(String(format: "%.1f", stats.averagePoints))")
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.leading, 4)
                        }
                }
                .frame(height: 250)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
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

// MARK: - Helper Extension
extension Int {
    func rankColor() -> Color {
        switch self {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }
}
