//
//  TeamDetailView.swift
//  PubRanker
//
//  Created on 23.11.2025
//  Updated for Universal App (macOS + iPadOS) - Version 3.0
//

import SwiftUI
import SwiftData

struct TeamDetailView: View {
    let team: Team
    @Bindable var viewModel: QuizViewModel
    @Binding var selectedWorkflow: ContentView.WorkflowPhase
    @Binding var showingEditSheet: Bool
    @Binding var showingDeleteAlert: Bool
    
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Team Header - Adaptive layout for iPad
                teamHeaderCard
                
                // Quiz-Zuordnungen
                quizAssignmentsSection
            }
            .padding(AppSpacing.sectionSpacing)
        }
        .background(Color.appBackgroundSecondary)
    }
    
    // MARK: - Team Header Card
    
    @ViewBuilder
    private var teamHeaderCard: some View {
        VStack(spacing: AppSpacing.md) {
            // Row 1: Icon + Name + Buttons
            HStack(alignment: .top, spacing: AppSpacing.md) {
                // Team Icon
                TeamIconView(team: team, size: 80)
                    .shadow(color: (Color(hex: team.color) ?? Color.appPrimary).opacity(0.3), radius: 8, y: 3)

                // Team Name & Info
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(team.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appTextPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)

                    // Quiz Count Badge
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: "link.circle.fill")
                            .font(.body)
                            .foregroundStyle(Color(hex: team.color) ?? Color.appPrimary)
                        Text("\(team.quizzes?.count ?? 0) Quiz zugeordnet")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appTextSecondary)
                    }

                    // Bestätigungsstatus
                    HStack(spacing: AppSpacing.xxs) {
                        Image(systemName: team.isConfirmed ? "checkmark.circle.fill" : "circle")
                            .font(.body)
                            .foregroundStyle(team.isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                        Text(team.isConfirmed ? "Bestätigt" : "Nicht bestätigt")
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(team.isConfirmed ? Color.appSuccess : Color.appTextSecondary)
                    }
                }

                Spacer(minLength: 0)

                // Action Buttons - Consistent across platforms
                VStack(spacing: AppSpacing.xs) {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Bearbeiten", systemImage: "pencil")
                            .font(.body.weight(.semibold))
                            .frame(minWidth: 120)
                    }
                    .primaryGlassButton(size: .small)

                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        Label("Löschen", systemImage: "trash")
                            .font(.body.weight(.semibold))
                            .frame(minWidth: 120)
                    }
                    .destructiveGlassButton(size: .small)
                }
            }

            // Row 2: Kontaktinformationen in Cards
            if !team.contactPerson.isEmpty || !team.email.isEmpty {
                Divider()

                HStack(spacing: AppSpacing.sm) {
                    // Kontaktperson Card
                    if !team.contactPerson.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "person.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.appPrimary)
                                Text("Kontaktperson")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .textCase(.uppercase)
                            }
                            Text(team.contactPerson)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.appTextPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.sm)
                        .background(Color.appPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }

                    // E-Mail Card
                    if !team.email.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            HStack(spacing: AppSpacing.xxs) {
                                Image(systemName: "envelope.fill")
                                    .font(.caption)
                                    .foregroundStyle(Color.appPrimary)
                                Text("E-Mail")
                                    .font(.caption)
                                    .foregroundStyle(Color.appTextSecondary)
                                    .textCase(.uppercase)
                            }
                            Text(team.email)
                                .font(.body)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.appTextPrimary)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(AppSpacing.sm)
                        .background(Color.appPrimary.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                    }

                    // Erstellungsdatum Card
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        HStack(spacing: AppSpacing.xxs) {
                            Image(systemName: "calendar")
                                .font(.caption)
                                .foregroundStyle(Color.appPrimary)
                            Text("Erstellt am")
                                .font(.caption)
                                .foregroundStyle(Color.appTextSecondary)
                                .textCase(.uppercase)
                        }
                        Text(team.createdAt.formatted(date: .abbreviated, time: .omitted))
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.appTextPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(AppSpacing.sm)
                    .background(Color.appPrimary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
                }
            } else {
                // Nur Erstellungsdatum, wenn keine Kontaktinfos
                Divider()

                HStack(spacing: AppSpacing.xxs) {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.appPrimary)
                    Text("Erstellt am")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                        .textCase(.uppercase)
                    Spacer()
                    Text(team.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(Color.appTextPrimary)
                }
                .padding(AppSpacing.sm)
                .background(Color.appPrimary.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .elevated, cornerRadius: AppCornerRadius.lg)
    }
}

// MARK: - Quiz Assignments Section

extension TeamDetailView {
    @ViewBuilder
    var quizAssignmentsSection: some View {
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





