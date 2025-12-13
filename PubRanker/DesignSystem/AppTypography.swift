//
//  AppTypography.swift
//  PubRanker
//
//  Typography System - Konsistente Schriftgrößen und Text-Styles
//

import SwiftUI

// MARK: - Typography Scale

/// Typografisches System basierend auf einer harmonischen Skala
/// Verwendet optimierte Schriftgrößen für macOS
extension Font {

    // MARK: - Display Styles (Große Überschriften)

    /// XXL - Hero Text (48pt) - Für Splash Screens, Hero Sections
    static var appDisplayXXL = Font.system(size: 48, weight: .bold, design: .rounded)

    /// XL - Main Titles (36pt) - Haupttitel, Sektionen
    static var appDisplayXL = Font.system(size: 36, weight: .bold, design: .rounded)

    /// Large - Section Headers (28pt) - Große Section Headers
    static var appDisplayLarge = Font.system(size: 28, weight: .bold, design: .rounded)

    // MARK: - Title Styles (Überschriften)

    /// Title 1 (24pt, Bold) - Primäre Überschriften
    static var appTitle1 = Font.system(size: 24, weight: .bold, design: .rounded)

    /// Title 2 (20pt, Semibold) - Sekundäre Überschriften
    static var appTitle2 = Font.system(size: 20, weight: .semibold, design: .rounded)

    /// Title 3 (18pt, Semibold) - Tertiäre Überschriften
    static var appTitle3 = Font.system(size: 18, weight: .semibold, design: .rounded)

    // MARK: - Body Styles (Fließtext)

    /// Body Large (16pt, Regular) - Großer Fließtext, wichtige Inhalte
    static var appBodyLarge = Font.system(size: 16, weight: .regular, design: .default)

    /// Body (14pt, Regular) - Standard Fließtext
    static var appBody = Font.system(size: 14, weight: .regular, design: .default)

    /// Body Small (13pt, Regular) - Kleinerer Fließtext
    static var appBodySmall = Font.system(size: 13, weight: .regular, design: .default)

    // MARK: - Label Styles (UI-Elemente)

    /// Label Large (15pt, Medium) - Große Labels, Buttons
    static var appLabelLarge = Font.system(size: 15, weight: .medium, design: .default)

    /// Label (13pt, Medium) - Standard Labels
    static var appLabel = Font.system(size: 13, weight: .medium, design: .default)

    /// Label Small (12pt, Medium) - Kleine Labels
    static var appLabelSmall = Font.system(size: 12, weight: .medium, design: .default)

    // MARK: - Caption Styles (Metadaten)

    /// Caption Large (12pt, Regular) - Große Captions
    static var appCaptionLarge = Font.system(size: 12, weight: .regular, design: .default)

    /// Caption (11pt, Regular) - Standard Captions, Metadaten
    static var appCaption = Font.system(size: 11, weight: .regular, design: .default)

    /// Caption Small (10pt, Regular) - Kleine Captions
    static var appCaptionSmall = Font.system(size: 10, weight: .regular, design: .default)

    // MARK: - Number Styles (Scores, Statistiken)

    /// Score Hero (64pt, Bold) - Riesige Scores, Hero Numbers
    static var appScoreHero = Font.system(size: 64, weight: .bold, design: .rounded)

    /// Score Large (48pt, Bold) - Große Scores
    static var appScoreLarge = Font.system(size: 48, weight: .bold, design: .rounded)

    /// Score Medium (36pt, Bold) - Mittlere Scores
    static var appScoreMedium = Font.system(size: 36, weight: .bold, design: .rounded)

    /// Score Small (24pt, Bold) - Kleine Scores
    static var appScoreSmall = Font.system(size: 24, weight: .bold, design: .rounded)
}

// MARK: - Text Modifiers

extension View {

    // MARK: - Display Modifiers

    func displayXXL(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appDisplayXXL)
            .foregroundStyle(color)
    }

    func displayXL(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appDisplayXL)
            .foregroundStyle(color)
    }

    func displayLarge(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appDisplayLarge)
            .foregroundStyle(color)
    }

    // MARK: - Title Modifiers

    func title1(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appTitle1)
            .foregroundStyle(color)
    }

    func title2(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appTitle2)
            .foregroundStyle(color)
    }

    func title3(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appTitle3)
            .foregroundStyle(color)
    }

    // MARK: - Body Modifiers

    func bodyLarge(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appBodyLarge)
            .foregroundStyle(color)
    }

    func bodyText(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appBody)
            .foregroundStyle(color)
    }

    func bodySmall(_ color: Color = Color.appTextSecondary) -> some View {
        self
            .font(.appBodySmall)
            .foregroundStyle(color)
    }

    // MARK: - Label Modifiers

    func labelLarge(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appLabelLarge)
            .foregroundStyle(color)
    }

    func labelText(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appLabel)
            .foregroundStyle(color)
    }

    func labelSmall(_ color: Color = Color.appTextSecondary) -> some View {
        self
            .font(.appLabelSmall)
            .foregroundStyle(color)
    }

    // MARK: - Caption Modifiers

    func captionLarge(_ color: Color = Color.appTextSecondary) -> some View {
        self
            .font(.appCaptionLarge)
            .foregroundStyle(color)
    }

    func captionText(_ color: Color = Color.appTextSecondary) -> some View {
        self
            .font(.appCaption)
            .foregroundStyle(color)
    }

    func captionSmall(_ color: Color = Color.appTextTertiary) -> some View {
        self
            .font(.appCaptionSmall)
            .foregroundStyle(color)
    }

    // MARK: - Score Modifiers

    func scoreHero(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appScoreHero)
            .foregroundStyle(color)
            .monospacedDigit()
    }

    func scoreLarge(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appScoreLarge)
            .foregroundStyle(color)
            .monospacedDigit()
    }

    func scoreMedium(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appScoreMedium)
            .foregroundStyle(color)
            .monospacedDigit()
    }

    func scoreSmall(_ color: Color = Color.appTextPrimary) -> some View {
        self
            .font(.appScoreSmall)
            .foregroundStyle(color)
            .monospacedDigit()
    }
}

// MARK: - Animation Extensions

extension View {

    /// Standard Button Press Animation - Subtle Scale Down
    func buttonPressAnimation() -> some View {
        self.buttonStyle(AnimatedButtonStyle())
    }

    /// Bounce Effect - Playful Feedback
    func bounceEffect(trigger: Bool) -> some View {
        self.scaleEffect(trigger ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: trigger)
    }

    /// Slide In Animation - From Edge
    func slideIn(from edge: Edge = .leading, delay: Double = 0) -> some View {
        self.transition(.move(edge: edge).combined(with: .opacity))
            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: UUID())
    }
}

// MARK: - Animated Button Style

struct AnimatedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Shimmer Effect (Loading State)

extension View {
    func shimmer(isActive: Bool = true) -> some View {
        self.modifier(ShimmerModifier(isActive: isActive))
    }
}

struct ShimmerModifier: ViewModifier {
    let isActive: Bool
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        .clear,
                                        .white.opacity(0.3),
                                        .clear
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .rotationEffect(.degrees(30))
                            .offset(x: phase * geometry.size.width * 2 - geometry.size.width)
                            .onAppear {
                                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                                    phase = 1
                                }
                            }
                    }
                    .clipped()
                }
            }
    }
}
