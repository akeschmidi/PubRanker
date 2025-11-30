//
//  CompactQuizHeader.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct CompactQuizHeader: View {
    let quiz: Quiz
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onStart: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Quiz Info
            HStack(spacing: 12) {
                Image(systemName: "calendar.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quiz.name)
                        .font(.title2)
                        .bold()
                    
                    HStack(spacing: 12) {
                        if !quiz.venue.isEmpty {
                            Label(quiz.venue, systemImage: "mappin.circle")
                                .font(.body)
                        }
                        Label(quiz.date.formatted(date: .abbreviated, time: .shortened), systemImage: "clock")
                            .font(.body)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Action Buttons (kompakter)
            HStack(spacing: 8) {
                Button {
                    onEdit()
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .font(.title3)
                }
                .buttonStyle(.plain)
                .help("Quiz bearbeiten")
                
                Button {
                    onDelete()
                } label: {
                    Image(systemName: "trash.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
                .help("Quiz löschen")
                
                if !quiz.safeTeams.isEmpty && !quiz.safeRounds.isEmpty {
                    Button {
                        onStart()
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "play.circle.fill")
                                .font(.body)
                            Text("Starten")
                                .font(.body)
                                .bold()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(color: .green.opacity(0.3), radius: 4)
                    }
                    .buttonStyle(.plain)
                    .keyboardShortcut("s", modifiers: .command)
                    .help("Quiz starten (⌘S)")
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }
}





