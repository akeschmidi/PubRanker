//
//  HeaderPaddingModifier.swift
//  PubRanker
//
//  Created on 30.12.2025
//

import SwiftUI

struct HeaderPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .padding(.top, 0)
            .padding(.bottom, 0)
            .background(headerBackground)
        #else
        content
            .padding(.bottom, AppSpacing.xxxs)
            .background(headerBackground)
        #endif
    }
    
    private var headerBackground: some View {
        ZStack {
            // Basis Gradient
            LinearGradient(
                colors: [Color.appBackgroundSecondary.opacity(0.5), Color.appBackground.opacity(0.3)],
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Liquid Glass Effect (macOS 26)
            Rectangle()
                .fill(.clear)
                .glassEffectUnpadded(.regular)
        }
        .overlay(alignment: .bottom) {
            // Subtile Trennlinie
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.white.opacity(0.05),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }
}
