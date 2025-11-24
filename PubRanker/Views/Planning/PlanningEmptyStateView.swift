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
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                // Icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 50))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .cyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                VStack(spacing: 8) {
                    Text("Bereit für dein erstes Quiz?")
                        .font(.title2)
                        .bold()
                    
                    Text("Plane und organisiere dein Pub Quiz ganz einfach")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                // Großer CTA Button
                Button {
                    onCreateQuiz()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Neues Quiz erstellen")
                                .font(.body)
                                .bold()
                            Text("Starte mit der Planung")
                                .font(.subheadline)
                        }
                    }
                    .frame(maxWidth: 300)
                    .padding(.vertical, 20)
                    .padding(.horizontal, 32)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .blue.opacity(0.3), radius: 12, y: 6)
                }
                .buttonStyle(.plain)
                .keyboardShortcut("n", modifiers: .command)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

