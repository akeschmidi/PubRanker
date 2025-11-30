//
//  TeamsGridView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct TeamsGridView: View {
    let teams: [Team]
    @Bindable var viewModel: QuizViewModel
    let onDelete: (Team) -> Void
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
            ], spacing: 20) {
                ForEach(teams) { team in
                    TeamCard(team: team, viewModel: viewModel, onDelete: {
                        onDelete(team)
                    })
                }
            }
            .padding(24)
        }
    }
}





