//
//  SampleData.swift
//  PubRanker
//
//  Created on 14.12.2024
//

import Foundation
import SwiftData

@MainActor
struct SampleData {

    // MARK: - Realistische Team-Namen

    static let teamNames = [
        "Quiz in My Pants",
        "The Quizzard of Oz",
        "Let's Get Quizzical",
        "Agatha Quiztie",
        "Quizteama Aguilera",
        "E=MC Hammered",
        "Smarty Pints",
        "The Brew Crew",
        "Quiz on Your Face",
        "Norfolk Enchance",
        "Universally Challenged",
        "The Fact Hunt",
        "Prestige Worldwide",
        "The Ginger Ninjas",
        "Sherlock Homies",
        "Quizmodo",
        "The Know It Ales",
        "Les Quizerables",
        "Trivia Newton John",
        "Risky Quizness",
        "Beer Pressure",
        "Quiz Team Aguilera",
        "Multiple Scoregasms",
        "Quizzy Rascals",
        "Netflix and Skill",
        "The Brainy Bunch",
        "Mind Bottling",
        "The Quizzly Bears",
        "Fictional Characters",
        "Alcoholics Unanimous",
        "Ctrl Alt Elite",
        "The Smartinis",
        "Quiz Khalifa",
        "The InQuizitors",
        "Smarty McFly"
    ]

    static let teamColors = [
        "#FF6B6B", "#4ECDC4", "#45B7D1", "#FFA07A",
        "#98D8C8", "#F7DC6F", "#BB8FCE", "#85C1E2",
        "#F8B195", "#C06C84", "#6C5B7B", "#355C7D",
        "#2ECC71", "#E74C3C", "#3498DB", "#9B59B6",
        "#1ABC9C", "#F39C12", "#E67E22", "#95A5A6",
        "#34495E", "#16A085", "#27AE60", "#2980B9",
        "#8E44AD", "#D35400", "#C0392B", "#BDC3C7",
        "#7F8C8D", "#EC7063", "#AF7AC5", "#5DADE2",
        "#48C9B0", "#F4D03F", "#EB984E"
    ]

    // MARK: - Runden-Kategorien

    static let roundCategories = [
        "Allgemeinwissen",
        "Musik & Charts",
        "Film & TV",
        "Sport & Spiele",
        "Geschichte",
        "Geografie",
        "Wissenschaft",
        "Bilderrunde",
        "Soundrunde",
        "Jokerrunde"
    ]

    // MARK: - Quiz erstellen

    static func createSampleQuiz(in context: ModelContext) -> Quiz {
        // Quiz erstellen
        let quiz = Quiz(
            name: "Winterquiz 2024",
            venue: "O'Malley's Irish Pub",
            date: Date()
        )
        quiz.isActive = true
        quiz.maxTeams = 30
        context.insert(quiz)

        // Runden erstellen
        let rounds = createRounds(for: quiz, in: context)
        quiz.rounds = rounds

        // Teams erstellen (24 Teams für dieses Quiz)
        let teams = createTeams(count: 24, in: context)
        quiz.teams = teams

        // Teams mit Quiz verknüpfen
        for team in teams {
            if team.quizzes == nil {
                team.quizzes = []
            }
            team.quizzes?.append(quiz)
            team.setConfirmed(for: quiz, isConfirmed: true)
        }

        // Scores hinzufügen
        addRealisticScores(to: teams, rounds: rounds, quiz: quiz)

        return quiz
    }

    static func createCompletedQuiz(in context: ModelContext) -> Quiz {
        let quiz = Quiz(
            name: "Oktoberquiz 2024",
            venue: "The Crown & Anchor",
            date: Calendar.current.date(byAdding: .month, value: -2, to: Date()) ?? Date()
        )
        quiz.isActive = false
        quiz.isCompleted = true
        quiz.maxTeams = 12
        context.insert(quiz)

        let rounds = createRounds(for: quiz, in: context)
        for round in rounds {
            round.isCompleted = true
        }
        quiz.rounds = rounds

        let teams = createTeams(count: 10, in: context)
        quiz.teams = teams

        for team in teams {
            if team.quizzes == nil {
                team.quizzes = []
            }
            team.quizzes?.append(quiz)
            team.setConfirmed(for: quiz, isConfirmed: true)
        }

        addRealisticScores(to: teams, rounds: rounds, quiz: quiz)

        return quiz
    }

    static func createUpcomingQuiz(
        name: String,
        venue: String,
        monthsFromNow: Int,
        maxTeams: Int,
        confirmedTeams: Int,
        in context: ModelContext
    ) -> Quiz {
        let quiz = Quiz(
            name: name,
            venue: venue,
            date: Calendar.current.date(byAdding: .month, value: monthsFromNow, to: Date()) ?? Date()
        )
        quiz.isActive = false
        quiz.isCompleted = false
        quiz.maxTeams = maxTeams
        context.insert(quiz)

        let rounds = createRounds(for: quiz, in: context)
        quiz.rounds = rounds

        let teams = createTeams(count: confirmedTeams, in: context)
        quiz.teams = teams

        for (index, team) in teams.enumerated() {
            if team.quizzes == nil {
                team.quizzes = []
            }
            team.quizzes?.append(quiz)
            // Erste 70% der Teams sind bestätigt, Rest noch offen
            team.setConfirmed(for: quiz, isConfirmed: index < Int(Double(confirmedTeams) * 0.7))
        }

        return quiz
    }

    // Legacy-Funktion für Kompatibilität
    static func createUpcomingQuiz(in context: ModelContext) -> Quiz {
        return createUpcomingQuiz(
            name: "Neujahrsquiz 2025",
            venue: "Murphy's Pub",
            monthsFromNow: 1,
            maxTeams: 30,
            confirmedTeams: 12,
            in: context
        )
    }

    // MARK: - Runden erstellen

    private static func createRounds(for quiz: Quiz, in context: ModelContext) -> [Round] {
        var rounds: [Round] = []

        let roundConfigs: [(name: String, maxPoints: Int)] = [
            ("Allgemeinwissen", 10),
            ("Musik & Charts", 10),
            ("Film & TV", 10),
            ("Bilderrunde", 15),
            ("Sport & Spiele", 10),
            ("Geschichte", 10),
            ("Soundrunde", 15),
            ("Jokerrunde", 20)
        ]

        for (index, config) in roundConfigs.enumerated() {
            let round = Round(
                name: config.name,
                maxPoints: config.maxPoints,
                orderIndex: index
            )
            round.quiz = quiz
            context.insert(round)
            rounds.append(round)
        }

        return rounds
    }

    // MARK: - Teams erstellen

    static func createTeams(count: Int? = nil, in context: ModelContext) -> [Team] {
        let teamCount = count ?? teamNames.count
        var teams: [Team] = []

        let contactPersons = [
            "Max Mustermann",
            "Anna Schmidt",
            "Tom Mueller",
            "Lisa Weber",
            "Mike Johnson",
            "Sarah Brown",
            "David Wilson",
            "Emma Davis"
        ]

        for i in 0..<min(teamCount, teamNames.count) {
            let team = Team(
                name: teamNames[i],
                color: teamColors[i % teamColors.count]
            )
            team.contactPerson = contactPersons[i % contactPersons.count]
            team.email = "\(teamNames[i].lowercased().replacingOccurrences(of: " ", with: ""))@example.com"
            team.isConfirmed = true

            context.insert(team)
            teams.append(team)
        }

        return teams
    }

    // MARK: - Realistische Scores

    private static func addRealisticScores(to teams: [Team], rounds: [Round], quiz: Quiz) {
        // Definiere verschiedene Team-Archetypen für Variation
        let teamTypes = stride(from: 0, to: teams.count, by: 1).map { _ in
            TeamType.allCases.randomElement() ?? .average
        }

        for (index, team) in teams.enumerated() {
            let teamType = teamTypes[index]

            for round in rounds {
                let maxPoints = round.maxPoints ?? 10
                let score = generateScore(
                    maxPoints: maxPoints,
                    teamType: teamType,
                    roundName: round.name
                )
                team.addScore(for: round, points: score)
            }
        }
    }

    private static func generateScore(maxPoints: Int, teamType: TeamType, roundName: String) -> Int {
        // Basis-Score basierend auf Team-Typ
        let basePercentage: Double

        switch teamType {
        case .excellent:
            basePercentage = Double.random(in: 0.75...0.95)
        case .good:
            basePercentage = Double.random(in: 0.60...0.80)
        case .average:
            basePercentage = Double.random(in: 0.45...0.65)
        case .struggling:
            basePercentage = Double.random(in: 0.30...0.50)
        case .wildcard:
            // Wildcard: Manchmal sehr gut, manchmal schlecht
            basePercentage = Bool.random() ? Double.random(in: 0.70...0.90) : Double.random(in: 0.20...0.45)
        }

        // Modifikator basierend auf Rundentyp
        var modifier = 1.0

        if roundName.contains("Musik") || roundName.contains("Sound") {
            // Musik-Runden: Mehr Variation
            modifier = Double.random(in: 0.8...1.2)
        } else if roundName.contains("Joker") {
            // Jokerrunde: Höhere Scores möglich
            modifier = Double.random(in: 1.0...1.15)
        } else if roundName.contains("Bild") {
            // Bilderrunde: Etwas schwieriger
            modifier = Double.random(in: 0.85...1.05)
        }

        let finalScore = Int(Double(maxPoints) * basePercentage * modifier)
        return max(0, min(maxPoints, finalScore))
    }

    // MARK: - Team-Typen für Variation

    private enum TeamType: CaseIterable {
        case excellent      // Konstant gute Performance
        case good          // Überdurchschnittlich
        case average       // Durchschnitt
        case struggling    // Unter Durchschnitt
        case wildcard      // Unberechenbar, mal gut, mal schlecht
    }

    // MARK: - Globale Teams erstellen

    static func createGlobalTeams(in context: ModelContext) -> [Team] {
        return createTeams(count: teamNames.count, in: context)
    }

    // MARK: - Vollständiges Demo-Setup

    static func setupFullDemo(in context: ModelContext) {
        // 1 aktives Quiz
        _ = createSampleQuiz(in: context)

        // 1 abgeschlossenes Quiz
        _ = createCompletedQuiz(in: context)

        // Mehrere geplante Quizze in verschiedenen Stadien
        _ = createUpcomingQuiz(
            name: "Valentinsquiz 2025",
            venue: "The Rose & Crown",
            monthsFromNow: 2,
            maxTeams: 30,
            confirmedTeams: 18,
            in: context
        )

        _ = createUpcomingQuiz(
            name: "Frühlingsquiz 2025",
            venue: "Biergarten am See",
            monthsFromNow: 3,
            maxTeams: 35,
            confirmedTeams: 8,
            in: context
        )

        _ = createUpcomingQuiz(
            name: "Osterquiz 2025",
            venue: "Murphy's Pub",
            monthsFromNow: 4,
            maxTeams: 28,
            confirmedTeams: 5,
            in: context
        )

        _ = createUpcomingQuiz(
            name: "Sommerquiz 2025",
            venue: "Beach Bar Sunset",
            monthsFromNow: 6,
            maxTeams: 40,
            confirmedTeams: 3,
            in: context
        )

        _ = createUpcomingQuiz(
            name: "Herbstquiz 2025",
            venue: "The Crown & Anchor",
            monthsFromNow: 9,
            maxTeams: 30,
            confirmedTeams: 0,
            in: context
        )

        // Speichere alles
        try? context.save()
    }

    // MARK: - Einzelnes aktives Quiz für schnelles Testen

    static func setupQuickDemo(in context: ModelContext) -> Quiz {
        let quiz = createSampleQuiz(in: context)

        // Markiere die ersten 4 Runden als abgeschlossen
        let rounds = quiz.sortedRounds
        for i in 0..<min(4, rounds.count) {
            rounds[i].isCompleted = true
        }

        try? context.save()
        return quiz
    }
}

// MARK: - Preview Helper

#if DEBUG
extension SampleData {
    @MainActor
    static var previewContainer: ModelContainer {
        let schema = Schema([
            Quiz.self,
            Round.self,
            Team.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        let container = try! ModelContainer(
            for: schema,
            configurations: configuration
        )

        let context = container.mainContext
        setupFullDemo(in: context)

        return container
    }
}
#endif
