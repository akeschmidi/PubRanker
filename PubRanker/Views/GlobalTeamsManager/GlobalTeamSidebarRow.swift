//
//  GlobalTeamSidebarRow.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct GlobalTeamSidebarRow: View {
    let team: Team
    
    var body: some View {
        HStack(spacing: 12) {
            TeamIconView(team: team, size: 36)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(team.name)
                    .font(.body)
                    .bold()
                    .lineLimit(1)
                
                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "link.circle.fill")
                            .font(.caption)
                        Text("\(quizzes.count)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundStyle(.purple)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 4)
        .contentShape(Rectangle())
    }
}

