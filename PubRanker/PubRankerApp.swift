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
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Model Container with iCloud Support
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quiz.self,
            Team.self,
            Round.self
        ])
        
        #if DEBUG
        // Use local storage in debug mode for faster development
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        #else
        // Use iCloud in release mode
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        #endif
        
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            print("✅ ModelContainer created successfully")
            return container
        } catch {
            print("❌ ModelContainer Error: \(error)")
            print("Error details: \(error.localizedDescription)")
            
            // Last resort: try in-memory only
            do {
                let memoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                print("⚠️ Using in-memory storage as fallback")
                return try ModelContainer(for: schema, configurations: [memoryConfiguration])
            } catch {
                fatalError("Fatal: Could not create ModelContainer at all: \(error)")
            }
        }
    }()
}
