//
//  PubRankerApp.swift
//  PubRanker
//
//  Created on 20.10.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI
import SwiftData

#if canImport(AppKit)
import AppKit
#endif

@main
struct PubRankerApp: App {
    @State private var viewModel = QuizViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                #if os(macOS)
                .background(WindowAccessor())
                #endif
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        #endif
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
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

// MARK: - Window Accessor for transparent titlebar (macOS only)
#if os(macOS)
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                window.tabbingMode = .disallowed
                
                // Hide window tab overview button
                if let titlebarContainer = window.standardWindowButton(.closeButton)?.superview?.superview {
                    for subview in titlebarContainer.subviews {
                        let className = String(describing: type(of: subview))
                        if className.contains("NSTitlebarAccessoryClipView") || 
                           className.contains("NSToolbarView") {
                            subview.isHidden = true
                        }
                    }
                }
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
