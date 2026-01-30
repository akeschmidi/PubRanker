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
    
    /// CloudKit Container ID - MUSS mit Entitlements übereinstimmen
    static let cloudKitContainerID = "iCloud.com.akeschmidi.PubRanker"
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Quiz.self,
            Team.self,
            Round.self
        ])

        #if DEBUG
        print("🔧 DEBUG BUILD - CloudKit Sync ist AKTIVIERT")
        print("   Container: \(cloudKitContainerID)")
        print("   Database: .automatic (private)")
        print("   ⚠️ CloudKit ist im Debug-Modus aktiv für Sync-Tests")
        #else
        print("📦 RELEASE BUILD - CloudKit Sync ist AKTIVIERT")
        print("   Container: \(cloudKitContainerID)")
        print("   Database: .automatic (private)")
        #endif

        // Use iCloud with CloudKit in both debug and release mode
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            print("✅ ModelContainer erfolgreich erstellt")
            print("✅ CloudKit Synchronisation aktiv")
            print("   Container: \(cloudKitContainerID)")
            print("   Tipp: Rechtsklick auf iCloud-Icon für Diagnose")

            // Enable remote change notifications for better sync
            // Das ermöglicht das Empfangen von Remote-Änderungen
            let storeDescription = container.configurations.first
            return container
        } catch {
            print("❌ ModelContainer Fehler: \(error)")
            print("❌ Details: \(error.localizedDescription)")

            // Versuche ohne CloudKit als Fallback
            print("⚠️ Versuche Fallback ohne CloudKit...")
            do {
                let localConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false
                )
                print("⚠️ Fallback: Lokaler Speicher (keine iCloud-Sync)")
                return try ModelContainer(for: schema, configurations: [localConfiguration])
            } catch {
                print("❌ Auch lokaler Speicher fehlgeschlagen")
            }

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
