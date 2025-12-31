//
//  AppCard.swift
//  PubRanker
//
//  Created on 30.11.2025
//  Version 3.0 Design System - Universal (macOS + iPadOS)
//

import SwiftUI

/// Modern Card Component with Glassmorphism support
/// Part of PubRanker 3.0 Design System
struct AppCard<Content: View>: View {
    let content: Content
    var style: CardStyle
    var padding: CGFloat
    var cornerRadius: CGFloat
    
    init(
        style: CardStyle = .default,
        padding: CGFloat = AppSpacing.cardPadding,
        cornerRadius: CGFloat = AppCornerRadius.md,
        @ViewBuilder content: () -> Content
    ) {
        self.content = content()
        self.style = style
        self.padding = padding
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(style.background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style.borderColor, lineWidth: style.borderWidth)
            }
            .shadow(style.shadow)
    }
}

/// Card Style Variants
enum CardStyle {
    case `default`
    case glassmorphism
    case elevated
    case outlined
    case gradient(Gradient)
    case primary
    case secondary
    case accent
    
    var background: some View {
        Group {
            switch self {
            case .default:
                Color.adaptiveControlBackground
            case .glassmorphism:
                Rectangle()
                    .fill(.ultraThinMaterial)
            case .elevated:
                Color.adaptiveCardBackground
            case .outlined:
                Color.clear
            case .gradient(let gradient):
                Rectangle()
                    .fill(gradient)
            case .primary:
                Rectangle()
                    .fill(Color.gradientPrimary)
            case .secondary:
                Rectangle()
                    .fill(Color.gradientSecondary)
            case .accent:
                Rectangle()
                    .fill(Color.gradientAccent)
            }
        }
    }
    
    var borderColor: Color {
        switch self {
        case .default, .elevated:
            return Color.secondary.opacity(0.1)
        case .glassmorphism:
            return Color.white.opacity(0.2)
        case .outlined:
            return Color.secondary.opacity(0.3)
        case .gradient, .primary, .secondary, .accent:
            return Color.clear
        }
    }
    
    var borderWidth: CGFloat {
        switch self {
        case .outlined:
            return 1.5
        default:
            return 1
        }
    }
    
    var shadow: Shadow {
        switch self {
        case .default:
            return AppShadow.sm
        case .glassmorphism:
            return AppShadow.md
        case .elevated:
            return AppShadow.lg
        case .outlined:
            return AppShadow.none
        case .gradient, .primary, .secondary, .accent:
            return AppShadow.md
        }
    }
}

// MARK: - View Extension for easy Card usage

extension View {
    /// Apply AppCard styling to any view
    func appCard(
        style: CardStyle = .default,
        padding: CGFloat = AppSpacing.cardPadding,
        cornerRadius: CGFloat = AppCornerRadius.md
    ) -> some View {
        AppCard(style: style, padding: padding, cornerRadius: cornerRadius) {
            self
        }
    }
}

// MARK: - Usage Examples

/*
 USAGE EXAMPLES:
 
 // Default Card
 AppCard {
     VStack {
         Text("Card Content")
     }
 }
 
 // Glassmorphism Card
 AppCard(style: .glassmorphism) {
     VStack {
         Text("Glass Card")
     }
 }
 
 // Gradient Card
 AppCard(style: .gradient(Color.gradientPubTheme)) {
     VStack {
         Text("Gradient Card")
     }
 }
 
 // Primary Card
 AppCard(style: .primary) {
     VStack {
         Text("Primary Card")
             .foregroundStyle(.white)
     }
 }
 
 // Using View Extension
 VStack {
     Text("Content")
 }
 .appCard(style: .elevated)
 
 // Custom Padding & Corner Radius
 AppCard(
     style: .glassmorphism,
     padding: AppSpacing.lg,
     cornerRadius: AppCornerRadius.xl
 ) {
     VStack {
         Text("Custom Card")
     }
 }
 */








