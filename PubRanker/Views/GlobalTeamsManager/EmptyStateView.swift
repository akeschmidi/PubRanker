//
//  EmptyStateView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI

struct EmptyStateView: View {
    let onCreateTeam: () -> Void
    
    var body: some View {
        VStack(spacing: AppSpacing.sectionSpacing) {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.appPrimary.opacity(0.1), Color.appPrimaryLight.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimaryLight],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: AppSpacing.xs) {
                    Text("Keine Teams vorhanden")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)

                    Text("Erstellen Sie Ihr erstes Team, um es später einfach zu Quizzes hinzuzufügen")
                        .font(.body)
                        .foregroundStyle(Color.appTextSecondary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 450)
                }
            }

            Button {
                onCreateTeam()
            } label: {
                Label("Erstes Team erstellen", systemImage: "plus.circle.fill")
                    .font(.body)
            }
            .primaryGradientButton(size: .large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}





