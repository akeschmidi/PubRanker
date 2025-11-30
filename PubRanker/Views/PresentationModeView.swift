//
//  PresentationModeView.swift
//  PubRanker
//
//  Presentation Mode - Live Leaderboard für zweiten Bildschirm
//

import SwiftUI

struct PresentationModeView: View {
    @Bindable var quiz: Quiz
    @State private var currentTime = Date()
    @State private var previousRankings: [String: Int] = [:]
    @State private var showConfetti = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var sortedTeams: [Team] {
        quiz.sortedTeamsByScore
    }

    var body: some View {
        ZStack {
            // Background Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),
                    Color(red: 0.1, green: 0.1, blue: 0.2)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                presentationHeader
                    .padding(.horizontal, 60)
                    .padding(.top, 20)
                    .padding(.bottom, 10)

                // Aktive Runde Banner
                if let currentRound = quiz.currentRound {
                    activeRoundBanner(currentRound)
                        .padding(.horizontal, 60)
                        .padding(.vertical, 12)
                }

                // PODIUM für Top 3
                if sortedTeams.count >= 3 {
                    podiumView
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                } else if !sortedTeams.isEmpty {
                    // Falls weniger als 3 Teams, zeige einfache Podium-Version
                    simplePodiumView
                        .padding(.horizontal, 60)
                        .padding(.vertical, 20)
                }

                // Weitere Plätze (ab Platz 4)
                if sortedTeams.count > 3 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("WEITERE PLÄTZE")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(.white.opacity(0.6))
                            .padding(.horizontal, 60)
                            .padding(.top, 16)
                            .padding(.bottom, 8)

                        // Grid Layout für mehr Platz
                        LazyVGrid(
                            columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ],
                            spacing: 8
                        ) {
                            let rankings = quiz.getTeamRankings()
                            let remainingRankings = rankings.dropFirst(3)
                            ForEach(remainingRankings, id: \.team.id) { ranking in
                                CompactTeamRow(
                                    team: ranking.team,
                                    rank: ranking.rank,
                                    previousRank: previousRankings[ranking.team.id.uuidString] ?? ranking.rank,
                                    quiz: quiz
                                )
                            }
                        }
                        .padding(.horizontal, 60)
                        .padding(.bottom, 20)
                    }
                }

                Spacer(minLength: 0)
            }

            // Confetti overlay for round completion
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
        }
        .onReceive(timer) { _ in
            currentTime = Date()
        }
        .onChange(of: sortedTeams.map { $0.getTotalScore(for: quiz) }) { oldScores, newScores in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                updateRankings()
            }
        }
        .onAppear {
            updateRankings()
        }
    }

    private var presentationHeader: some View {
        HStack {
            // Trophy Icon & Quiz Name
            HStack(spacing: 12) {
                Image(systemName: "trophy.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: .yellow.opacity(0.5), radius: 8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(quiz.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !quiz.venue.isEmpty {
                        HStack(spacing: 6) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 10))
                            Text(quiz.venue)
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            Spacer()
        }
    }

    private func activeRoundBanner(_ round: Round) -> some View {
        HStack(spacing: 20) {
            // Play Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .green.opacity(0.5), radius: 10)

                Image(systemName: "play.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(.white)
            }

            // Runden Info
            Text(round.name)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            // Max Punkte Info
            VStack(alignment: .trailing, spacing: 4) {
                Text("MAX. PUNKTE")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(1)

                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.yellow)

                    Text("\(round.maxPoints)")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.yellow)
                }
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 20)
        .background(
            ZStack {
                // Gradient Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.green.opacity(0.25),
                                Color.green.opacity(0.15)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )

                // Border
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            colors: [.green.opacity(0.6), .green.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )

                // Glow
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.green.opacity(0.1))
                    .blur(radius: 10)
            }
        )
        .shadow(color: .green.opacity(0.3), radius: 15, y: 5)
    }

    private var podiumView: some View {
        let rankings = quiz.getTeamRankings()
        let topRankings = Array(rankings.prefix(3))
        
        return HStack(alignment: .bottom, spacing: 30) {
            // 2. Platz (links, niedriger)
            if topRankings.count >= 2 {
                let secondPlace = topRankings[1]
                PresentationPodiumPlace(
                    team: secondPlace.team,
                    rank: secondPlace.rank,
                    previousRank: previousRankings[secondPlace.team.id.uuidString] ?? secondPlace.rank,
                    height: 180,
                    quiz: quiz
                )
            } else {
                Spacer()
            }

            // 1. Platz (mitte, am höchsten)
            if !topRankings.isEmpty {
                let firstPlace = topRankings[0]
                PresentationPodiumPlace(
                    team: firstPlace.team,
                    rank: firstPlace.rank,
                    previousRank: previousRankings[firstPlace.team.id.uuidString] ?? firstPlace.rank,
                    height: 220,
                    quiz: quiz
                )
            } else {
                Spacer()
            }

            // 3. Platz (rechts, am niedrigsten)
            if topRankings.count >= 3 {
                let thirdPlace = topRankings[2]
                PresentationPodiumPlace(
                    team: thirdPlace.team,
                    rank: thirdPlace.rank,
                    previousRank: previousRankings[thirdPlace.team.id.uuidString] ?? thirdPlace.rank,
                    height: 150,
                    quiz: quiz
                )
            } else {
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var simplePodiumView: some View {
        let rankings = quiz.getTeamRankings()
        let topRankings = Array(rankings.prefix(3))
        
        return HStack(spacing: 40) {
            ForEach(topRankings, id: \.team.id) { ranking in
                PresentationPodiumPlace(
                    team: ranking.team,
                    rank: ranking.rank,
                    previousRank: previousRankings[ranking.team.id.uuidString] ?? ranking.rank,
                    height: 320,
                    quiz: quiz
                )
            }
        }
    }

    private func updateRankings() {
        // Store previous rankings for comparison
        for (index, team) in sortedTeams.enumerated() {
            previousRankings[team.id.uuidString] = index + 1
        }
    }
}

// MARK: - Presentation Podium Place (für Top 3)

struct PresentationPodiumPlace: View {
    let team: Team
    let rank: Int
    let previousRank: Int
    let height: CGFloat
    let quiz: Quiz

    var teamColor: Color {
        Color(hex: team.color) ?? .blue
    }

    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(red: 0.75, green: 0.75, blue: 0.75)
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2)
        default: return .blue
        }
    }

    var rankChanged: Bool {
        rank != previousRank
    }

    var rankImproved: Bool {
        rank < previousRank
    }

    var body: some View {
        VStack(spacing: 0) {
            // Team Info oben
            VStack(spacing: 6) {
                // Rank Change Indicator
                if rankChanged {
                    Image(systemName: rankImproved ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(rankImproved ? .green : .red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.3))
                }

                // Medaille/Rang
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [rankColor, rankColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: rankColor.opacity(0.6), radius: 10)

                    VStack(spacing: 2) {
                        if rank == 1 {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white)
                        } else {
                            Text("#\(rank)")
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                        }

                        Image(systemName: rankIcon)
                            .font(.system(size: 12))
                            .foregroundStyle(.white.opacity(0.9))
                    }
                }

                // Team Name
                Text(team.name)
                    .font(.system(size: rank == 1 ? 22 : 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                // Score mit Team-Farbe
                HStack(spacing: 6) {
                    Circle()
                        .fill(teamColor)
                        .frame(width: 12, height: 12)
                        .shadow(color: teamColor.opacity(0.6), radius: 4)

                    Text("\(team.getTotalScore(for: quiz))")
                        .font(.system(size: rank == 1 ? 36 : 32, weight: .bold, design: .rounded))
                        .foregroundStyle(rankColor)
                        .contentTransition(.numericText())
                        .monospacedDigit()

                    Text("PTS")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            .padding(.bottom, 8)

            // Podest-Sockel
            ZStack(alignment: .bottom) {
                // Hauptsockel
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [rankColor.opacity(0.4), rankColor.opacity(0.2)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: height)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(rankColor.opacity(0.6), lineWidth: 3)
                    }

                // Rang-Nummer auf Sockel
                Text("\(rank)")
                    .font(.system(size: rank == 1 ? 80 : 70, weight: .black, design: .rounded))
                    .foregroundStyle(rankColor.opacity(0.2))
                    .padding(.bottom, 20)
            }
        }
        .frame(width: rank == 1 ? 240 : 220)
    }

    private var rankIcon: String {
        switch rank {
        case 1: return "sparkles"
        case 2: return "medal.fill"
        case 3: return "rosette"
        default: return ""
        }
    }
}

// MARK: - Compact Team Row (für Platz 4+)

struct CompactTeamRow: View {
    let team: Team
    let rank: Int
    let previousRank: Int
    let quiz: Quiz

    var teamColor: Color {
        Color(hex: team.color) ?? .blue
    }

    var rankChanged: Bool {
        rank != previousRank
    }

    var rankImproved: Bool {
        rank < previousRank
    }

    var body: some View {
        HStack(spacing: 8) {
            // Rang
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 32, height: 32)

                Text("\(rank)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
            }

            // Rank Change
            Group {
                if rankChanged {
                    Image(systemName: rankImproved ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(rankImproved ? .green : .red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .frame(width: 20)

            // Team Color
            Circle()
                .fill(teamColor)
                .frame(width: 14, height: 14)
                .shadow(color: teamColor.opacity(0.6), radius: 3)

            // Team Name
            Text(team.name)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: 4)

            // Score
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))

                Text("\(team.getTotalScore(for: quiz))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text("PTS")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                }
        )
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []

    struct ConfettiPiece: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var rotation: Double
        var color: Color
        var velocity: CGFloat
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    Rectangle()
                        .fill(piece.color)
                        .frame(width: 10, height: 20)
                        .rotationEffect(.degrees(piece.rotation))
                        .position(x: piece.x, y: piece.y)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
    }

    private func createConfetti(in size: CGSize) {
        let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple, .pink]

        for _ in 0..<100 {
            let piece = ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                y: -50,
                rotation: Double.random(in: 0...360),
                color: colors.randomElement()!,
                velocity: CGFloat.random(in: 2...5)
            )
            confettiPieces.append(piece)
        }

        animateConfetti(in: size)
    }

    private func animateConfetti(in size: CGSize) {
        Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            for i in confettiPieces.indices {
                confettiPieces[i].y += confettiPieces[i].velocity
                confettiPieces[i].rotation += 5

                if confettiPieces[i].y > size.height + 50 {
                    timer.invalidate()
                }
            }
        }
    }
}

#Preview {
    PresentationModeView(quiz: Quiz(name: "Test Quiz", venue: "Pub", date: Date()))
}
