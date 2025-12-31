//
//  PlatformExtensions.swift
//  PubRanker
//
//  Created for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI

// MARK: - Platform-Adaptive View Modifiers

extension View {
    /// Apply help text on macOS only (iOS doesn't support .help())
    @ViewBuilder
    func helpText(_ text: String) -> some View {
        #if os(macOS)
        self.help(text)
        #else
        self
        #endif
    }
    
    /// Apply help text with LocalizedStringKey on macOS only
    @ViewBuilder
    func helpText(_ key: LocalizedStringKey) -> some View {
        #if os(macOS)
        self.help(key)
        #else
        self
        #endif
    }
    
    /// Apply minimum frame size - larger on macOS, adaptive on iOS
    @ViewBuilder
    func adaptiveMinFrame(macWidth: CGFloat, macHeight: CGFloat) -> some View {
        #if os(macOS)
        self.frame(minWidth: macWidth, minHeight: macHeight)
        #else
        self
        #endif
    }
    
    /// Keyboard shortcut that only applies on platforms with hardware keyboard support
    @ViewBuilder
    func adaptiveKeyboardShortcut(_ key: KeyEquivalent, modifiers: EventModifiers = .command) -> some View {
        self.keyboardShortcut(key, modifiers: modifiers)
    }
}

// MARK: - Platform Detection

struct PlatformInfo {
    static var isiPad: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad
        #else
        return false
        #endif
    }

    static var isMac: Bool {
        #if os(macOS)
        return true
        #else
        return false
        #endif
    }

    static var isiPhone: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .phone
        #else
        return false
        #endif
    }

    /// Returns true if running on iPad in landscape orientation
    static var isiPadLandscape: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad &&
               UIDevice.current.orientation.isLandscape
        #else
        return false
        #endif
    }

    /// Returns true if running on iPad in portrait orientation
    static var isiPadPortrait: Bool {
        #if os(iOS)
        return UIDevice.current.userInterfaceIdiom == .pad &&
               (UIDevice.current.orientation.isPortrait || UIDevice.current.orientation == .unknown)
        #else
        return false
        #endif
    }
}

// MARK: - Conditional View Modifier

extension View {
    /// Apply a modifier only when a condition is true
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - iPad Adaptive Label Style

/// A label style that shows icon-only on compact iPad layouts to prevent text wrapping
struct iPadAdaptiveLabelStyle: LabelStyle {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    func makeBody(configuration: Configuration) -> some View {
        #if os(iOS)
        // On iPad, show icon only to prevent text wrapping in tight spaces
        configuration.icon
        #else
        // On macOS, show full label
        HStack(spacing: 4) {
            configuration.icon
            configuration.title
        }
        #endif
    }
}

extension LabelStyle where Self == iPadAdaptiveLabelStyle {
    static var iPadAdaptive: iPadAdaptiveLabelStyle { iPadAdaptiveLabelStyle() }
}

// MARK: - iPad Compact Button Helper

extension View {
    /// Makes a button compact on iPad (icon-only) to prevent text wrapping
    @ViewBuilder
    func iPadCompactButton() -> some View {
        #if os(iOS)
        self.labelStyle(.iconOnly)
        #else
        self
        #endif
    }

    /// Apply minimum touch target size for better iPad usability
    @ViewBuilder
    func touchTarget() -> some View {
        self.frame(minWidth: AppSpacing.touchTarget, minHeight: AppSpacing.touchTarget)
    }

    /// Apply adaptive padding based on platform (larger on iPad)
    @ViewBuilder
    func adaptivePadding(_ edges: Edge.Set = .all) -> some View {
        self.padding(edges, AppSpacing.screenPaddingAdaptive)
    }
}

// MARK: - Adaptive Font Sizes

extension Font {
    /// Caption that's slightly larger on iPad for better readability
    static var adaptiveCaption: Font {
        #if os(iOS)
        return .subheadline
        #else
        return .caption
        #endif
    }

    /// Body that's optimized for the platform
    static var adaptiveBody: Font {
        #if os(iOS)
        return .body
        #else
        return .body
        #endif
    }
}

// MARK: - Platform Image Helper

/// Creates an Image from Data that works on both macOS and iOS
struct PlatformImage: View {
    let data: Data
    
    var body: some View {
        #if os(macOS)
        if let nsImage = NSImage(data: data) {
            Image(nsImage: nsImage)
                .resizable()
        } else {
            placeholderImage
        }
        #else
        if let uiImage = UIImage(data: data) {
            Image(uiImage: uiImage)
                .resizable()
        } else {
            placeholderImage
        }
        #endif
    }
    
    private var placeholderImage: some View {
        Image(systemName: "photo")
            .resizable()
            .foregroundStyle(Color.appTextTertiary)
    }
}

// MARK: - Helper to create Image from Data

extension Image {
    /// Create an Image from Data (works on both macOS and iOS)
    static func fromData(_ data: Data) -> Image? {
        #if os(macOS)
        if let nsImage = NSImage(data: data) {
            return Image(nsImage: nsImage)
        }
        #else
        if let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        #endif
        return nil
    }
}



