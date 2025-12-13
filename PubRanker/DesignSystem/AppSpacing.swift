//
//  AppSpacing.swift
//  PubRanker
//
//  Created on 30.11.2025
//  Version 2.0 Design System
//

import SwiftUI

/// PubRanker 2.0 Spacing System
/// Provides consistent spacing across the app based on 4pt grid
struct AppSpacing {

    // MARK: - Base Spacing (4pt grid system)

    /// 4pt - Minimal spacing
    static let xxxs: CGFloat = 4

    /// 8pt - Very small spacing
    static let xxs: CGFloat = 8

    /// 12pt - Small spacing
    static let xs: CGFloat = 12

    /// 16pt - Medium-small spacing
    static let sm: CGFloat = 16

    /// 20pt - Medium spacing (most common)
    static let md: CGFloat = 20

    /// 24pt - Medium-large spacing
    static let lg: CGFloat = 24

    /// 32pt - Large spacing
    static let xl: CGFloat = 32

    /// 40pt - Extra large spacing
    static let xxl: CGFloat = 40

    /// 48pt - Extra extra large spacing
    static let xxxl: CGFloat = 48

    // MARK: - Semantic Spacing

    /// Card padding inside
    static let cardPadding: CGFloat = md // 20pt

    /// Section spacing between groups
    static let sectionSpacing: CGFloat = lg // 24pt

    /// Stack spacing for VStack/HStack
    static let stackSpacing: CGFloat = sm // 16pt

    /// List item spacing
    static let listItemSpacing: CGFloat = xs // 12pt

    /// Button padding horizontal
    static let buttonPaddingH: CGFloat = md // 20pt

    /// Button padding vertical
    static let buttonPaddingV: CGFloat = xs // 12pt

    /// Screen edge padding
    static let screenPadding: CGFloat = lg // 24pt
}

/// PubRanker 2.0 Shadow System
/// Elevation-based shadow system for depth and hierarchy
struct AppShadow {

    // MARK: - Shadow Levels

    /// No shadow (elevation 0)
    static let none = Shadow(
        color: .clear,
        radius: 0,
        x: 0,
        y: 0
    )

    /// Minimal shadow (elevation 1) - Subtle depth
    static let sm = Shadow(
        color: Color.black.opacity(0.05),
        radius: 2,
        x: 0,
        y: 1
    )

    /// Small shadow (elevation 2) - Cards, buttons
    static let md = Shadow(
        color: Color.black.opacity(0.08),
        radius: 4,
        x: 0,
        y: 2
    )

    /// Medium shadow (elevation 3) - Raised cards
    static let lg = Shadow(
        color: Color.black.opacity(0.12),
        radius: 8,
        x: 0,
        y: 4
    )

    /// Large shadow (elevation 4) - Modals, overlays
    static let xl = Shadow(
        color: Color.black.opacity(0.16),
        radius: 16,
        x: 0,
        y: 8
    )

    /// Extra large shadow (elevation 5) - Floating elements
    static let xxl = Shadow(
        color: Color.black.opacity(0.20),
        radius: 24,
        x: 0,
        y: 12
    )

    // MARK: - Colored Shadows (for special effects)

    /// Primary colored shadow (brown theme)
    static let primary = Shadow(
        color: Color.appPrimaryDark.opacity(0.25),
        radius: 8,
        x: 0,
        y: 4
    )

    /// Secondary colored shadow (gold theme)
    static let secondary = Shadow(
        color: Color.appSecondaryDark.opacity(0.25),
        radius: 8,
        x: 0,
        y: 4
    )

    /// Accent colored shadow (orange theme)
    static let accent = Shadow(
        color: Color.appAccentLight.opacity(0.25),
        radius: 8,
        x: 0,
        y: 4
    )

    /// Success colored shadow (green theme)
    static let success = Shadow(
        color: Color.appSuccessLight.opacity(0.25),
        radius: 8,
        x: 0,
        y: 4
    )
}

/// Shadow helper struct
struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - View Extensions for easy usage

extension View {

    /// Apply shadow with AppShadow
    func shadow(_ shadow: Shadow) -> some View {
        self.shadow(
            color: shadow.color,
            radius: shadow.radius,
            x: shadow.x,
            y: shadow.y
        )
    }

    /// Apply card style (padding + background + shadow)
    func cardStyle(
        background: Color = Color(nsColor: .controlBackgroundColor),
        padding: CGFloat = AppSpacing.cardPadding,
        cornerRadius: CGFloat = 12,
        shadow: Shadow = AppShadow.md
    ) -> some View {
        self
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(shadow)
    }

    /// Apply glassmorphism effect
    func glassmorphism(
        material: Material = .ultraThinMaterial,
        cornerRadius: CGFloat = 12,
        shadow: Shadow = AppShadow.md
    ) -> some View {
        self
            .background(material)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(shadow)
    }
}

// MARK: - Corner Radius System

struct AppCornerRadius {
    /// 4pt - Minimal rounding
    static let xs: CGFloat = 4

    /// 8pt - Small rounding
    static let sm: CGFloat = 8

    /// 12pt - Medium rounding (most common for cards)
    static let md: CGFloat = 12

    /// 16pt - Large rounding
    static let lg: CGFloat = 16

    /// 20pt - Extra large rounding
    static let xl: CGFloat = 20

    /// 24pt - Maximum rounding
    static let xxl: CGFloat = 24

    /// Circle (maximum possible)
    static let circle: CGFloat = .infinity
}

// MARK: - Usage Examples

/*
 SPACING USAGE:

 VStack(spacing: AppSpacing.md) {
     Text("Title")
     Text("Subtitle")
 }
 .padding(AppSpacing.screenPadding)

 SHADOW USAGE:

 Rectangle()
     .fill(.white)
     .frame(width: 200, height: 100)
     .shadow(AppShadow.md)

 CARD STYLE:

 VStack {
     Text("Card Content")
 }
 .cardStyle()

 GLASSMORPHISM:

 VStack {
     Text("Glass Content")
 }
 .glassmorphism()

 COLORED SHADOW:

 Button("Action") { }
     .buttonStyle(.borderedProminent)
     .shadow(AppShadow.primary)
 */
