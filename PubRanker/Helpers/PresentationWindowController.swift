//
//  PresentationWindowController.swift
//  PubRanker
//
//  Controller for Presentation Mode window
//  macOS: Separate window on second screen
//  iPadOS: Full-screen overlay in app
//
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI

#if os(macOS)
import AppKit

class PresentationWindowController: NSWindowController, NSWindowDelegate {
    private var quiz: Quiz?
    private var hostingView: NSHostingView<PresentationModeView>?
    weak var presentationManager: PresentationManager?

    convenience init(quiz: Quiz, presentationManager: PresentationManager) {
        // Create a new window
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1920, height: 1080),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.init(window: window)
        self.quiz = quiz
        self.presentationManager = presentationManager

        // Set window delegate to detect when window is closed
        window.delegate = self

        // Configure window
        window.title = "Presentation Mode - \(quiz.name)"
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.isMovableByWindowBackground = true
        window.backgroundColor = .black

        // Set content view with bindable quiz
        let contentView = PresentationModeView(quiz: quiz)
        let hostingView = NSHostingView(rootView: contentView)
        self.hostingView = hostingView
        window.contentView = hostingView

        // Try to move to second screen if available
        if let secondScreen = NSScreen.screens.count > 1 ? NSScreen.screens[1] : nil {
            window.setFrame(secondScreen.frame, display: true)
        } else {
            // Center on main screen if no second screen
            window.center()
        }
    }
    
    // MARK: - NSWindowDelegate
    
    func windowWillClose(_ notification: Notification) {
        // Notify presentation manager that window is being closed
        presentationManager?.handleWindowClosed()
    }
    
    func updateQuiz(_ newQuiz: Quiz) {
        self.quiz = newQuiz
        
        // Recreate the hosting view with updated quiz data
        if let window = window {
            let updatedView = PresentationModeView(quiz: newQuiz)
            let newHostingView = NSHostingView(rootView: updatedView)
            self.hostingView = newHostingView
            window.contentView = newHostingView
        }
        
        // Update window title
        window?.title = "Presentation Mode - \(newQuiz.name)"
    }

    func showPresentation() {
        window?.makeKeyAndOrderFront(nil)

        // Enter full screen after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.window?.toggleFullScreen(nil)
        }
    }

    func closePresentation() {
        // Exit full screen first
        if window?.styleMask.contains(.fullScreen) == true {
            window?.toggleFullScreen(nil)
        }

        // Close window after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.close()
        }
    }
}
#endif

// MARK: - Presentation Manager (Cross-Platform)

@Observable
class PresentationManager {
    static let shared = PresentationManager()

    private(set) var isPresenting = false
    private(set) var currentQuiz: Quiz?
    
    #if os(macOS)
    private var windowController: PresentationWindowController?
    #endif

    private init() {}

    func startPresentation(for quiz: Quiz) {
        guard !isPresenting else { 
            // If already presenting, just update the quiz
            updateQuiz(quiz)
            return
        }

        currentQuiz = quiz
        
        #if os(macOS)
        windowController = PresentationWindowController(quiz: quiz, presentationManager: self)
        windowController?.showPresentation()
        #endif
        
        isPresenting = true
    }

    func stopPresentation() {
        guard isPresenting else { return }

        #if os(macOS)
        windowController?.closePresentation()
        windowController = nil
        #endif
        
        currentQuiz = nil
        isPresenting = false
    }

    func togglePresentation(for quiz: Quiz) {
        if isPresenting {
            stopPresentation()
        } else {
            startPresentation(for: quiz)
        }
    }
    
    func updateQuiz(_ quiz: Quiz) {
        currentQuiz = quiz
        #if os(macOS)
        windowController?.updateQuiz(quiz)
        #endif
    }
    
    func handleWindowClosed() {
        // Window was closed by user (e.g., clicking the close button)
        // Update state to reflect that presentation is no longer active
        #if os(macOS)
        windowController = nil
        #endif
        currentQuiz = nil
        isPresenting = false
    }
}

// MARK: - iOS Presentation View (Full Screen Overlay)

#if os(iOS)
/// Full-screen presentation view for iPad
/// Shows leaderboard in a beautiful full-screen format suitable for AirPlay/external displays
struct iPadPresentationOverlay: View {
    let quiz: Quiz
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        // Presentation Content mit eingebautem Schließen-Button
        PresentationModeView(quiz: quiz, onClose: {
            onDismiss()
            dismiss()
        })
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
    }
}
#endif