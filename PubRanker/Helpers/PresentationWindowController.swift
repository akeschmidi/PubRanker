//
//  PresentationWindowController.swift
//  PubRanker
//
//  Controller for Presentation Mode window on second screen
//

import SwiftUI
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

// MARK: - Presentation Manager

@Observable
class PresentationManager {
    static let shared = PresentationManager()

    private(set) var isPresenting = false
    private var windowController: PresentationWindowController?
    private var currentQuiz: Quiz?

    private init() {}

    func startPresentation(for quiz: Quiz) {
        guard !isPresenting else { 
            // If already presenting, just update the quiz
            updateQuiz(quiz)
            return
        }

        currentQuiz = quiz
        windowController = PresentationWindowController(quiz: quiz, presentationManager: self)
        windowController?.showPresentation()
        isPresenting = true
    }

    func stopPresentation() {
        guard isPresenting else { return }

        windowController?.closePresentation()
        windowController = nil
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
        windowController?.updateQuiz(quiz)
    }
    
    func handleWindowClosed() {
        // Window was closed by user (e.g., clicking the close button)
        // Update state to reflect that presentation is no longer active
        windowController = nil
        currentQuiz = nil
        isPresenting = false
    }
}
