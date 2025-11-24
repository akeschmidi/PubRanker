//
//  TeamDetailView.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import SwiftData

struct TeamDetailView: View {
    let team: Team
    @Binding var showingEditSheet: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Team Header
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        TeamIconView(team: team, size: 80)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text(team.name)
                                .font(.system(size: 32, weight: .bold))
                        }
                        
                        Spacer()
                    }
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
                
                // Team Info
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.blue)
                        Text("Team-Informationen")
                            .font(.title3)
                            .bold()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        if !team.contactPerson.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .foregroundStyle(.blue)
                                    .font(.body)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Kontaktperson")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(team.contactPerson)
                                        .font(.body)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        if !team.email.isEmpty {
                            HStack(spacing: 12) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.blue)
                                    .font(.body)
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("E-Mail")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(team.email)
                                        .font(.body)
                                }
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.blue.opacity(0.05))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        
                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .foregroundStyle(.blue)
                                .font(.body)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Erstellt am")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(team.createdAt.formatted(date: .abbreviated, time: .omitted))
                                    .font(.body)
                            }
                            Spacer()
                        }
                        .padding(12)
                        .background(Color.blue.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
                
                // Quiz-Zuordnungen
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "link.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.purple)
                        Text("Quiz-Zuordnungen")
                            .font(.title3)
                            .bold()
                        if let quizzes = team.quizzes, !quizzes.isEmpty {
                            Text("(\(quizzes.count))")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if let quizzes = team.quizzes, !quizzes.isEmpty {
                        VStack(spacing: 12) {
                            ForEach(quizzes) { quiz in
                                QuizAssignmentRow(quiz: quiz)
                            }
                        }
                    } else {
                        HStack(spacing: 12) {
                            Image(systemName: "circle.dotted")
                                .foregroundStyle(.secondary)
                                .font(.body)
                                .frame(width: 24)
                            Text("Nicht zugeordnet")
                                .font(.body)
                                .foregroundStyle(.secondary)
                            Spacer()
                        }
                        .padding(16)
                        .background(Color.secondary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(nsColor: .controlBackgroundColor))
                        .shadow(color: Color.black.opacity(0.05), radius: 8, y: 2)
                )
                
                // Action Buttons
                HStack(spacing: 12) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.body)
                            Text("Bearbeiten")
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.blue)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.5), lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.circle.fill")
                                .font(.body)
                            Text("Löschen")
                                .font(.body)
                                .bold()
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [Color.red.opacity(0.15), Color.red.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.red)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1.5)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
        }
    }
}

// MARK: - Quiz Assignment Row
struct QuizAssignmentRow: View {
    let quiz: Quiz
    
    var body: some View {
        HStack(spacing: 16) {
            // Quiz Icon/Color Indicator
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.purple.opacity(0.6), .purple.opacity(0.4)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(quiz.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(.primary)
                
                HStack(spacing: 16) {
                    if !quiz.venue.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                            Text(quiz.venue)
                                .font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text(quiz.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.purple.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.purple.opacity(0.2), lineWidth: 1)
                }
        )
    }
}

