//
//  PlanningEmptyStateView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI

struct PlanningEmptyStateView: View {
    let onCreateQuiz: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.xl) {
            Spacer()
            
            VStack(spacing: AppSpacing.sectionSpacing) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.3), Color.appSecondary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(AppShadow.lg)

                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(Color.gradientPubTheme)
                }
                
                VStack(spacing: AppSpacing.xxs) {
                    Text("Noch keine Quizzes geplant")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)
                    
                    Text("Erstelle dein erstes Quiz und füge Teams sowie Runden hinzu")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                }
                
                // Großer CTA Button
                Button {
                    onCreateQuiz()
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)

                        VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                            Text("Neues Quiz")
                                .font(.body)
                                .bold()
                            Text("Hier starten")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: 300)
                }
                .primaryGlassButton(size: .large)
                .keyboardShortcut("n", modifiers: .command)
                .shadow(AppShadow.lg)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}





