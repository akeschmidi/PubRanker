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
        HStack(spacing: AppSpacing.xs) {
            TeamIconView(team: team, size: 36)
            
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text(team.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)
                
                if let quizzes = team.quizzes, !quizzes.isEmpty {
                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "link.circle.fill")
                            .font(.caption)
                        Text("\(quizzes.count)")
                            .font(.caption)
                            .monospacedDigit()
                    }
                    .foregroundStyle(Color.appSecondary)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, AppSpacing.xxxs)
        .padding(.horizontal, AppSpacing.xxxs)
        .contentShape(Rectangle())
    }
}


