//
//  PubRankerApp.swift
//  PubRanker
//
//  Created on 20.10.2025
//

import SwiftUI
import SwiftData

@main
struct PubRankerApp: App {
    @State private var viewModel = QuizViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
        }
        .modelContainer(for: [Quiz.self, Team.self, Round.self])
    }
}
