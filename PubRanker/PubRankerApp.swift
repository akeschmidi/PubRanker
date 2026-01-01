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
        print("🔧 DEBUG BUILD - CloudKit Sync ist DEAKTIVIERT")
        print("   Für CloudKit-Tests: Release-Build verwenden oder Scheme auf Release ändern")
        // Use local storage in debug mode for faster development
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        #else
        print("📦 RELEASE BUILD - CloudKit Sync ist AKTIVIERT")
        print("   Container: iCloud.com.akeschmidi.PubRanker")
        print("   Database: .automatic (private)")
        // Use iCloud in release mode
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )
        #endif

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            print("✅ ModelContainer erfolgreich erstellt")
            #if !DEBUG
            print("✅ CloudKit Synchronisation aktiv")
            print("   Tipp: Prüfe CloudKit Status über Einstellungen → CloudKit Status")
            #endif
            return container
        } catch {
            print("❌ ModelContainer Fehler: \(error)")
            print("❌ Details: \(error.localizedDescription)")

            // Last resort: try in-memory only
            do {
                let memoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                print("⚠️ Fallback: In-Memory Speicher (Daten gehen beim Beenden verloren!)")
                return try ModelContainer(for: schema, configurations: [memoryConfiguration])
            } catch {
                fatalError("💥 FATAL: ModelContainer konnte nicht erstellt werden: \(error)")
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
