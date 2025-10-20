//
//  ContentView.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI

struct ContentView: View {
    @Environment(QuizViewModel.self) private var viewModel
    
    var body: some View {
        QuizListView(viewModel: viewModel)
    }
}

#Preview {
    ContentView()
        .environment(QuizViewModel())
        .modelContainer(for: [Quiz.self, Team.self, Round.self], inMemory: true)
}
