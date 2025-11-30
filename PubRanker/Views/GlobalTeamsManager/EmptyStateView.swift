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
        VStack(spacing: 32) {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.1), .cyan.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)

                    Image(systemName: "person.3.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }

                VStack(spacing: 12) {
                    Text("Keine Teams vorhanden")
                        .font(.title2)
                        .bold()

                    Text("Erstellen Sie Ihr erstes Team, um es später einfach zu Quizzes hinzuzufügen")
                        .font(.body)
                        .foregroundStyle(.secondary)
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
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}





