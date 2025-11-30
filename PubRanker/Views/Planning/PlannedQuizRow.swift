//
//  PlannedQuizRow.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct PlannedQuizRow: View {
    let quiz: Quiz

    private var confirmedTeamsCount: Int {
        quiz.safeTeams.filter { $0.isConfirmed }.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(quiz.name)
                .font(.headline)

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
                Label("\(confirmedTeamsCount)/\(quiz.safeTeams.count)", systemImage: "person.3")
                    .font(.caption2)
                    .foregroundStyle(confirmedTeamsCount == quiz.safeTeams.count && quiz.safeTeams.count > 0 ? .green : .secondary)
                Label("\(quiz.safeRounds.count)", systemImage: "list.number")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

