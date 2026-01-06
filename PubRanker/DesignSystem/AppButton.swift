//
//  AppButton.swift
//  PubRanker
//
//  Created on 30.11.2025
//  Version 2.0 Design System - Core Components
//

import SwiftUI

/// Modern Gradient Button Style for Primary Actions
/// Part of PubRanker 2.0 Design System
struct GradientButtonStyle: ButtonStyle {
    var gradient: LinearGradient
    var size: ButtonSize
    var shadow: Shadow
    
    init(
        gradient: LinearGradient = Color.gradientPrimary,
        size: ButtonSize = .medium,
        shadow: Shadow = AppShadow.md
    ) {
        self.gradient = gradient
        self.size = size
        self.shadow = shadow
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(gradient)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(shadow)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Button Size Variants
enum ButtonSize {
    case small
    case medium
    case large
    
    var font: Font {
        switch self {
        case .small:
            return .subheadline
        case .medium:
            return .body
        case .large:
            return .title3
        }
    }
    
    var horizontalPadding: CGFloat {
        switch self {
        case .small:
            return AppSpacing.sm
        case .medium:
            return AppSpacing.md
        case .large:
            return AppSpacing.lg
        }
    }
    
    var verticalPadding: CGFloat {
        switch self {
        case .small:
            return AppSpacing.xxs
        case .medium:
            return AppSpacing.xs
        case .large:
            return AppSpacing.sm
        }
    }

    /// Minimum height to ensure touch target on iPad (44pt HIG)
    var minHeight: CGFloat? {
        #if os(iOS)
        // On iPad, ensure minimum touch target
        return AppSpacing.touchTarget
        #else
        return nil
        #endif
    }
}

/// Primary Gradient Button Style
struct PrimaryGradientButtonStyle: ButtonStyle {
    var size: ButtonSize
    
    init(size: ButtonSize = .medium) {
        self.size = size
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .if(size.minHeight != nil) { view in
                view.frame(minHeight: size.minHeight)
            }
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.gradientPrimary)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(AppShadow.primary)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Secondary Gradient Button Style
struct SecondaryGradientButtonStyle: ButtonStyle {
    var size: ButtonSize

    init(size: ButtonSize = .medium) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .if(size.minHeight != nil) { view in
                view.frame(minHeight: size.minHeight)
            }
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.gradientSecondary)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(AppShadow.secondary)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Accent Gradient Button Style
struct AccentGradientButtonStyle: ButtonStyle {
    var size: ButtonSize

    init(size: ButtonSize = .medium) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .if(size.minHeight != nil) { view in
                view.frame(minHeight: size.minHeight)
            }
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.gradientAccent)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(AppShadow.accent)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Success Gradient Button Style
struct SuccessGradientButtonStyle: ButtonStyle {
    var size: ButtonSize

    init(size: ButtonSize = .medium) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .if(size.minHeight != nil) { view in
                view.frame(minHeight: size.minHeight)
            }
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.gradientSuccess)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(AppShadow.success)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Destructive Gradient Button Style (for delete actions)
struct DestructiveGradientButtonStyle: ButtonStyle {
    var size: ButtonSize

    init(size: ButtonSize = .medium) {
        self.size = size
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font)
            .foregroundStyle(.white)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .if(size.minHeight != nil) { view in
                view.frame(minHeight: size.minHeight)
            }
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.gradientDestructive)
                    .opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            }
            .shadow(color: Color(red: 220/255, green: 38/255, blue: 38/255).opacity(0.3), radius: 8, y: 4)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions for easy Button usage

extension View {
    /// Apply Primary Gradient Button Style
    func primaryGradientButton(size: ButtonSize = .medium) -> some View {
        self.buttonStyle(PrimaryGradientButtonStyle(size: size))
    }
    
    /// Apply Secondary Gradient Button Style
    func secondaryGradientButton(size: ButtonSize = .medium) -> some View {
        self.buttonStyle(SecondaryGradientButtonStyle(size: size))
    }
    
    /// Apply Accent Gradient Button Style
    func accentGradientButton(size: ButtonSize = .medium) -> some View {
        self.buttonStyle(AccentGradientButtonStyle(size: size))
    }
    
    /// Apply Success Gradient Button Style
    func successGradientButton(size: ButtonSize = .medium) -> some View {
        self.buttonStyle(SuccessGradientButtonStyle(size: size))
    }

    /// Apply Destructive Gradient Button Style
    func destructiveGradientButton(size: ButtonSize = .medium) -> some View {
        self.buttonStyle(DestructiveGradientButtonStyle(size: size))
    }

    /// Apply Custom Gradient Button Style
    func gradientButton(
        gradient: LinearGradient = Color.gradientPrimary,
        size: ButtonSize = .medium
    ) -> some View {
        self.buttonStyle(GradientButtonStyle(gradient: gradient, size: size))
    }
}

// MARK: - Usage Examples

/*
 USAGE EXAMPLES:
 
 // Primary Gradient Button
 Button("Start Quiz") {
     // action
 }
 .primaryGradientButton()
 
 // Secondary Gradient Button
 Button("Save") {
     // action
 }
 .secondaryGradientButton()
 
 // Accent Gradient Button
 Button("Export") {
     // action
 }
 .accentGradientButton()
 
 // Success Gradient Button
 Button("Complete") {
     // action
 }
 .successGradientButton()
 
 // Custom Gradient Button
 Button("Custom") {
     // action
 }
 .gradientButton(gradient: Color.gradientPubTheme)
 
 // Different Sizes
 Button("Small") { }
     .primaryGradientButton(size: .small)
 
 Button("Large") { }
     .primaryGradientButton(size: .large)
 
 // With Icons
 Button {
     // action
 } label: {
     Label("Start", systemImage: "play.fill")
 }
 .primaryGradientButton()
 */

