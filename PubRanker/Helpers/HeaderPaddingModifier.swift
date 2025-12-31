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
            .background(
                LinearGradient(
                    colors: [Color.appBackgroundSecondary, Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        #else
        content
            .padding(.bottom, AppSpacing.xxxs)
            .background(
                LinearGradient(
                    colors: [Color.appBackgroundSecondary, Color.appBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        #endif
    }
}
