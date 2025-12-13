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
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @Binding var showingEditSheet: Bool
    @Binding var showingDeleteAlert: Bool
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Team Header - Kompakt mit allen Infos
                HStack(alignment: .top, spacing: AppSpacing.lg) {
                    // Team Icon
                    TeamIconView(team: team, size: 100)
                        .shadow(color: (Color(hex: team.color) ?? Color.appPrimary).opacity(0.3), radius: 12, y: 4)

                    VStack(alignment: .leading, spacing: AppSpacing.sm) {
                        // Team Name
                        Text(team.name)
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.appTextPrimary)
                            .lineLimit(2)

                        // Kompakte Info-Zeilen
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            // Quiz Count
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "link.circle.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color(hex: team.color) ?? Color.appPrimary)
                                    .frame(width: 16)
                                Text("\(team.quizzes?.count ?? 0) Quiz")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.appTextSecondary)
                            }

                            // Kontaktperson
                            if !team.contactPerson.isEmpty {
                                HStack(spacing: AppSpacing.xxs) {
                                    Image(systemName: "person.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.appPrimary)
                                        .frame(width: 16)
                                    Text(team.contactPerson)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }

                            // E-Mail
                            if !team.email.isEmpty {
                                HStack(spacing: AppSpacing.xxs) {
                                    Image(systemName: "envelope.fill")
                                        .font(.caption)
                                        .foregroundStyle(Color.appPrimary)
                                        .frame(width: 16)
                                    Text(team.email)
                                        .font(.subheadline)
                                        .foregroundStyle(Color.appTextSecondary)
                                }
                            }

                            // Erstellt am
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "calendar")
                                    .font(.caption)
                                    .foregroundStyle(Color.appPrimary)
                                    .frame(width: 16)
                            Text("Erstellt: \(team.createdAt.formatted(date: .abbreviated, time: .omitted))")
                                .font(.subheadline)
                                .foregroundStyle(Color.appTextSecondary)
                            }
                        }
                    }

                    Spacer()

                    // Action Buttons - Schöne Buttons rechts
                    VStack(spacing: AppSpacing.xs) {
                        Button {
                            showingEditSheet = true
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "pencil")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text("Bearbeiten")
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .frame(minWidth: 120)
                            .background(
                                LinearGradient(
                                    colors: [Color.appPrimary, Color.appPrimary.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                            .shadow(color: Color.appPrimary.opacity(0.3), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)

                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "trash")
                                    .font(.body)
                                    .fontWeight(.semibold)
                                Text("Löschen")
                                    .font(.body)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(.white)
                            .padding(.horizontal, AppSpacing.sm)
                            .padding(.vertical, AppSpacing.xs)
                            .frame(minWidth: 120)
                            .background(
                                LinearGradient(
                                    colors: [Color.appAccent, Color.appAccent.opacity(0.8)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                            .shadow(color: Color.appAccent.opacity(0.3), radius: 4, y: 2)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.leading, AppSpacing.md)
                }
                .padding(AppSpacing.sectionSpacing)
                .appCard(style: .elevated, cornerRadius: AppCornerRadius.lg)

                // Quiz-Zuordnungen
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "link.circle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.appSecondary)
                        Text("Quiz-Zuordnungen")
                            .font(.title3)
                            .bold()
                            .foregroundStyle(Color.appTextPrimary)
                        if let quizzes = team.quizzes, !quizzes.isEmpty {
                            Text("(\(quizzes.count))")
                                .font(.title3)
                                .foregroundStyle(Color.appTextSecondary)
                                .monospacedDigit()
                        }
                    }

                    if let quizzes = team.quizzes, !quizzes.isEmpty {
                        QuizAssignmentsGroupedView(
                            quizzes: quizzes,
                            team: team,
                            viewModel: viewModel,
                            selectedWorkflow: $selectedWorkflow
                        )
                    } else {
                        HStack(spacing: AppSpacing.xs) {
                            Image(systemName: "circle.dotted")
                                .foregroundStyle(Color.appTextSecondary)
                                .font(.body)
                                .frame(width: 24)
                            Text("Nicht zugeordnet")
                                .font(.body)
                                .foregroundStyle(Color.appTextSecondary)
                            Spacer()
                        }
                        .padding(AppSpacing.sm)
                        .background(Color.appTextTertiary.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }
                }
                .padding(AppSpacing.md)
                .appCard(style: .elevated, cornerRadius: AppCornerRadius.lg)
            }
            .padding(AppSpacing.sectionSpacing)
        }
    }
}

// MARK: - Grouped Quiz Assignments View
struct QuizAssignmentsGroupedView: View {
    let quizzes: [Quiz]
    let team: Team
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase

    private var plannedQuizzes: [Quiz] {
        quizzes.filter { !$0.isActive && !$0.isCompleted }.sorted { $0.date < $1.date }
    }

    private var activeQuizzes: [Quiz] {
        quizzes.filter { $0.isActive }.sorted { $0.date < $1.date }
    }

    private var completedQuizzes: [Quiz] {
        quizzes.filter { $0.isCompleted }.sorted { $0.date > $1.date }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            // GEPLANTE QUIZ
            if !plannedQuizzes.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(Color.appPrimary)
                        Text("GEPLANT")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(Color.appPrimary)
                            .textCase(.uppercase)
                        Text("(\(plannedQuizzes.count))")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, AppSpacing.xs)

                    ForEach(plannedQuizzes) { quiz in
                        QuizAssignmentRow(
                            quiz: quiz,
                            team: team,
                            viewModel: viewModel,
                            selectedWorkflow: $selectedWorkflow,
                            status: .planned
                        )
                    }
                }
            }

            // LAUFENDE QUIZ
            if !activeQuizzes.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "play.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appSuccess)
                        Text("LÄUFT")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(Color.appSuccess)
                            .textCase(.uppercase)
                        Text("(\(activeQuizzes.count))")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, AppSpacing.xs)

                    ForEach(activeQuizzes) { quiz in
                        QuizAssignmentRow(
                            quiz: quiz,
                            team: team,
                            viewModel: viewModel,
                            selectedWorkflow: $selectedWorkflow,
                            status: .active
                        )
                    }
                }
            }

            // ABGESCHLOSSENE QUIZ
            if !completedQuizzes.isEmpty {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        Text("ABGESCHLOSSEN")
                            .font(.caption)
                            .bold()
                            .foregroundStyle(Color.appTextSecondary)
                            .textCase(.uppercase)
                        Text("(\(completedQuizzes.count))")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                            .monospacedDigit()
                    }
                    .padding(.horizontal, AppSpacing.xs)

                    ForEach(completedQuizzes) { quiz in
                        QuizAssignmentRow(
                            quiz: quiz,
                            team: team,
                            viewModel: viewModel,
                            selectedWorkflow: $selectedWorkflow,
                            status: .completed
                        )
                    }
                }
            }
        }
    }
}

// MARK: - Quiz Status Enum
enum QuizStatus {
    case planned
    case active
    case completed

    var color: Color {
        switch self {
        case .planned: return Color.appPrimary
        case .active: return Color.appSuccess
        case .completed: return Color.appTextSecondary
        }
    }

    var backgroundColor: Color {
        switch self {
        case .planned: return Color.appPrimary.opacity(0.08)
        case .active: return Color.appSuccess.opacity(0.08)
        case .completed: return Color.appTextTertiary.opacity(0.05)
        }
    }

    var borderColor: Color {
        switch self {
        case .planned: return Color.appPrimary.opacity(0.3)
        case .active: return Color.appSuccess.opacity(0.3)
        case .completed: return Color.appTextTertiary.opacity(0.2)
        }
    }

    var icon: String {
        switch self {
        case .planned: return "chevron.right"
        case .active: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        }
    }

    var label: String? {
        switch self {
        case .planned: return nil
        case .active: return "Läuft"
        case .completed: return "Abgeschlossen"
        }
    }
}

// MARK: - Quiz Assignment Row
struct QuizAssignmentRow: View {
    let quiz: Quiz
    let team: Team
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    let status: QuizStatus

    private var canNavigate: Bool {
        status == .planned
    }

    var body: some View {
        Button {
            guard canNavigate else { return }
            viewModel.selectedQuiz = quiz
            selectedWorkflow = .planning
        } label: {
            HStack(spacing: AppSpacing.sm) {
                // Quiz Icon mit Status-Farbe
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [status.color.opacity(0.6), status.color.opacity(0.4)],
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

            VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                Text(quiz.name)
                    .font(.body)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)

                HStack(spacing: AppSpacing.sm) {
                    if !quiz.venue.isEmpty {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                            Text(quiz.venue)
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.appTextSecondary)
                    }

                    HStack(spacing: AppSpacing.xxxs) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text(quiz.date.formatted(date: .abbreviated, time: .shortened))
                            .font(.subheadline)
                    }
                    .foregroundStyle(Color.appTextSecondary)

                    // Bestätigungsstatus
                    if team.isConfirmed {
                        HStack(spacing: AppSpacing.xxxs) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.caption)
                            Text("Bestätigt")
                                .font(.subheadline)
                        }
                        .foregroundStyle(Color.appSuccess)
                    }
                }
            }

            Spacer()

            // Status Icon oder Chevron
            if let label = status.label {
                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: status.icon)
                        .font(.caption)
                    Text(label)
                        .font(.caption)
                        .bold()
                }
                .foregroundStyle(status.color)
            } else {
                Image(systemName: status.icon)
                    .font(.body)
                    .foregroundStyle(status.color)
            }
            }
            .padding(AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(status.backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.md)
                            .stroke(status.borderColor, lineWidth: 1.5)
                    }
            )
        }
        .buttonStyle(.plain)
        .allowsHitTesting(canNavigate)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: status)
    }
}





