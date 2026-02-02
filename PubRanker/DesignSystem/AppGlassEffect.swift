//
//  AppGlassEffect.swift
//  PubRanker
//
//  Created on 28.01.2026
//  macOS 26 "Liquid Glass" Design System - Mock Implementation
//
//  WICHTIG: Diese Datei enthält Mock-Implementierungen der macOS 26 APIs.
//  Sobald Xcode 26 verfügbar ist, können diese durch die echten APIs ersetzt werden.
//

import SwiftUI

// MARK: - Glass Effect Mock Implementation

/// Intensität des Glass Effects
enum GlassEffectIntensity {
    case regular
    case prominent
}

/// ViewModifier für den "Liquid Glass" Effekt (Mock für macOS 26 API)
struct GlassEffectModifier: ViewModifier {
    var intensity: GlassEffectIntensity
    var unpadded: Bool
    
    func body(content: Content) -> some View {
        content
            .background(glassBackground)
            .if(!unpadded) { view in
                view.padding(AppSpacing.xs)
            }
    }
    
    @ViewBuilder
    private var glassBackground: some View {
        switch intensity {
        case .regular:
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        case .prominent:
            Rectangle()
                .fill(.thinMaterial)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.15),
                            Color.white.opacity(0.08),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
    }
}

// MARK: - View Extensions

extension View {
    /// Wendet den Liquid Glass Effekt an (Mock für macOS 26 .glassEffect())
    /// 
    /// Diese Methode simuliert die macOS 26 API und wird durch die echte API ersetzt,
    /// sobald Xcode 26 verfügbar ist.
    func glassEffect(_ intensity: GlassEffectIntensity = .regular) -> some View {
        modifier(GlassEffectModifier(intensity: intensity, unpadded: false))
    }
    
    /// Wendet den Liquid Glass Effekt ohne automatisches Padding an
    /// (Mock für macOS 26 .glassEffectUnpadded())
    func glassEffectUnpadded(_ intensity: GlassEffectIntensity = .regular) -> some View {
        modifier(GlassEffectModifier(intensity: intensity, unpadded: true))
    }
    
    /// Adaptive Glass Effect - verwendet native glassEffect() ab macOS 26, sonst Mock-Fallback
    ///
    /// Diese Methode verwendet automatisch die native macOS 26 API wenn verfügbar,
    /// ansonsten fällt sie auf die Mock-Implementierung zurück.
    @ViewBuilder
    func adaptiveGlassEffect(_ intensity: GlassEffectIntensity = .regular) -> some View {
        // Native glassEffect() API ist ab macOS 26 / iOS 26 verfügbar
        // Sobald Xcode 26 released wird, kann der auskommentierte Code aktiviert werden:
        //
        // if #available(macOS 26.0, iOS 26.0, *) {
        //     switch intensity {
        //     case .regular:
        //         self.glassEffect()
        //     case .prominent:
        //         self.glassEffect(.prominent)
        //     }
        // } else {
        //     self.glassEffect(intensity) // Mock fallback
        // }
        //
        // Aktuell: Verwende Mock-Implementierung für alle Plattformen
        self.glassEffect(intensity)
    }
}

// MARK: - Glass Button Styles (macOS 26 Liquid Glass Design)

/// Glass Button Style für macOS 26 "Liquid Glass" Design
/// Modernere, transparentere Buttons mit Capsule-Form und subtilen Farben
struct GlassButtonStyle: ButtonStyle {
    var variant: GlassButtonVariant
    var size: ButtonSize
    var intensity: GlassEffectIntensity

    init(
        variant: GlassButtonVariant = .primary,
        size: ButtonSize = .medium,
        intensity: GlassEffectIntensity = .regular
    ) {
        self.variant = variant
        self.size = size
        self.intensity = intensity
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(size.font.weight(.medium))
            .foregroundStyle(variant.foregroundColor)
            .padding(.horizontal, size.horizontalPadding + 4)
            .padding(.vertical, size.verticalPadding + 2)
            .if(size.minHeight != nil) { view in
                view.frame(minHeight: size.minHeight)
            }
            .background(
                Capsule()
                    .fill(variant.glassBackground)
                    .opacity(configuration.isPressed ? 0.85 : 1.0)
            )
            .background(
                // Subtiler innerer Glow
                Capsule()
                    .fill(variant.tintColor.opacity(0.15))
                    .blur(radius: 8)
                    .offset(y: 2)
            )
            .overlay {
                // Doppelter Rand für Glass-Effekt
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.2),
                                variant.tintColor.opacity(0.3)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .overlay {
                // Innerer Highlight am oberen Rand
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
                    .padding(1)
            }
            .shadow(color: variant.tintColor.opacity(0.25), radius: configuration.isPressed ? 4 : 8, y: configuration.isPressed ? 2 : 4)
            .shadow(color: Color.black.opacity(0.1), radius: 2, y: 1)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

/// Glass Button Varianten für macOS 26 Design
enum GlassButtonVariant {
    case primary
    case secondary
    case success
    case destructive
    case accent

    /// Haupt-Tint-Farbe für die Variante
    var tintColor: Color {
        switch self {
        case .primary:
            return Color.appPrimary
        case .secondary:
            return Color.appSecondary
        case .success:
            return Color.appSuccess
        case .destructive:
            return Color(red: 220/255, green: 38/255, blue: 38/255)
        case .accent:
            return Color.appAccent
        }
    }

    /// Glass-Hintergrund mit Material und Farbton
    var glassBackground: LinearGradient {
        // Subtiler Gradient mit Transparenz
        LinearGradient(
            colors: [
                tintColor.opacity(0.7),
                tintColor.opacity(0.85)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var foregroundColor: Color {
        .white
    }

    var borderColor: Color {
        Color.white.opacity(0.4)
    }

    var shadow: Shadow {
        Shadow(color: tintColor.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Glass Button View Extensions

extension View {
    /// Apply Primary Glass Button Style (Liquid Glass Design)
    func primaryGlassButton(
        size: ButtonSize = .medium,
        intensity: GlassEffectIntensity = .regular
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(variant: .primary, size: size, intensity: intensity))
    }
    
    /// Apply Secondary Glass Button Style (Liquid Glass Design)
    func secondaryGlassButton(
        size: ButtonSize = .medium,
        intensity: GlassEffectIntensity = .regular
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(variant: .secondary, size: size, intensity: intensity))
    }
    
    /// Apply Success Glass Button Style (Liquid Glass Design)
    func successGlassButton(
        size: ButtonSize = .medium,
        intensity: GlassEffectIntensity = .regular
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(variant: .success, size: size, intensity: intensity))
    }
    
    /// Apply Destructive Glass Button Style (Liquid Glass Design)
    func destructiveGlassButton(
        size: ButtonSize = .medium,
        intensity: GlassEffectIntensity = .regular
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(variant: .destructive, size: size, intensity: intensity))
    }
    
    /// Apply Accent Glass Button Style (Liquid Glass Design)
    func accentGlassButton(
        size: ButtonSize = .medium,
        intensity: GlassEffectIntensity = .regular
    ) -> some View {
        self.buttonStyle(GlassButtonStyle(variant: .accent, size: size, intensity: intensity))
    }
}

// MARK: - Usage Examples

/*
 USAGE EXAMPLES:
 
 // Glass Button mit Primary Style
 Button("Start Quiz") {
     // action
 }
 .primaryGlassButton()
 
 // Glass Button mit Success Style
 Button("Complete") {
     // action
 }
 .successGlassButton()
 
 // Glass Button mit verschiedenen Intensitäten
 Button("Prominent") {
     // action
 }
 .primaryGlassButton(intensity: .prominent)
 
 // Glass Effect auf beliebige Views anwenden
 VStack {
     Text("Content")
 }
 .glassEffect()
 
 // Glass Effect ohne Padding
 HStack {
     Image(systemName: "star.fill")
     Text("Rating")
 }
 .glassEffectUnpadded()
 
 // Glass Effect mit Prominent Intensity
 Text("Important")
     .glassEffect(.prominent)
 */
