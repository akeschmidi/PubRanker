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
    @State private var visibleRankCount = 0  // Anzahl der sichtbaren Plätze (von unten nach oben)

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var sortedTeams: [Team] {
        quiz.sortedTeamsByScore
    }

    var totalTeams: Int {
        sortedTeams.count
    }

    var allTeamsVisible: Bool {
        visibleRankCount >= totalTeams
    }

    // Prüft ob ein Team an dieser Position in der Liste sichtbar sein soll
    // Position ist der Index im sortierten Array (0 = bestes Team, N-1 = schlechtestes Team)
    func isTeamVisible(atIndex index: Int) -> Bool {
        guard visibleRankCount > 0 else { return false }
        // Von unten nach oben: Team ist sichtbar wenn index >= (totalTeams - visibleRankCount)
        return index >= (totalTeams - visibleRankCount)
    }

    // Prüft ob mindestens ein Podium-Team (Top 3) sichtbar ist
    var hasVisiblePodiumTeams: Bool {
        guard visibleRankCount > 0 else { return false }
        // Top 3 sind Indices 0, 1, 2
        return (0..<min(3, totalTeams)).contains { isTeamVisible(atIndex: $0) }
    }

    // Prüft ob mindestens ein Team ab Position 4 sichtbar ist
    var hasVisibleAdditionalTeams: Bool {
        guard totalTeams > 3 && visibleRankCount > 0 else { return false }
        // Ab Position 4 sind Indices 3...totalTeams-1
        return (3..<totalTeams).contains { isTeamVisible(atIndex: $0) }
    }

    var adaptiveGridColumns: [GridItem] {
        #if os(iOS)
        // iPad Querformat: 3 Spalten für mehr Teams
        return [
            GridItem(.flexible(), spacing: AppSpacing.xs),
            GridItem(.flexible(), spacing: AppSpacing.xs),
            GridItem(.flexible(), spacing: AppSpacing.xs)
        ]
        #else
        return [
            GridItem(.flexible(), spacing: AppSpacing.xs),
            GridItem(.flexible(), spacing: AppSpacing.xs)
        ]
        #endif
    }

    var body: some View {
        ZStack {
            // Background Gradient
            Color.gradientPubTheme
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    presentationHeader
                        #if os(iOS)
                        .padding(.horizontal, AppSpacing.lg)
                        .padding(.top, AppSpacing.xs)
                        .padding(.bottom, AppSpacing.xxxs)
                        #else
                        .padding(.horizontal, AppSpacing.xxxl)
                        .padding(.top, AppSpacing.md)
                        .padding(.bottom, AppSpacing.xxs)
                        #endif

                    // Aktive Runde Banner
                    if let currentRound = quiz.currentRound {
                        activeRoundBanner(currentRound)
                            #if os(iOS)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.xxxs)
                            #else
                            .padding(.horizontal, AppSpacing.xxxl)
                            .padding(.vertical, AppSpacing.xs)
                            #endif
                    }

                    // PODIUM für Top 3
                    if sortedTeams.count >= 3 && hasVisiblePodiumTeams {
                        podiumView
                            #if os(iOS)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.xs)
                            #else
                            .padding(.horizontal, AppSpacing.xxxl)
                            .padding(.vertical, AppSpacing.md)
                            #endif
                    } else if !sortedTeams.isEmpty && sortedTeams.count < 3 && hasVisiblePodiumTeams {
                        // Falls weniger als 3 Teams, zeige einfache Podium-Version
                        simplePodiumView
                            #if os(iOS)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.vertical, AppSpacing.xs)
                            #else
                            .padding(.horizontal, AppSpacing.xxxl)
                            .padding(.vertical, AppSpacing.md)
                            #endif
                    }

                    // Weitere Plätze (ab Platz 4)
                    if sortedTeams.count > 3 && hasVisibleAdditionalTeams {
                        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                            Text(L10n.CommonUI.additionalPlaces)
                                #if os(iOS)
                                .font(.system(size: 14, weight: .bold))
                                #else
                                .font(.system(size: 18, weight: .bold))
                                #endif
                                .foregroundStyle(.white.opacity(0.6))
                                #if os(iOS)
                                .padding(.horizontal, AppSpacing.lg)
                                .padding(.top, AppSpacing.xxs)
                                #else
                                .padding(.horizontal, AppSpacing.xxxl)
                                .padding(.top, AppSpacing.sm)
                                #endif
                                .padding(.bottom, AppSpacing.xxs)

                            // Grid Layout für mehr Platz
                            LazyVGrid(
                                columns: adaptiveGridColumns,
                                spacing: AppSpacing.xxs
                            ) {
                                let rankings = quiz.getTeamRankings()
                                let remainingRankings = Array(rankings.dropFirst(3))
                                ForEach(Array(remainingRankings.enumerated()), id: \.element.team.id) { index, ranking in
                                    let actualIndex = index + 3  // Index 3, 4, 5...
                                    if isTeamVisible(atIndex: actualIndex) {
                                        CompactTeamRow(
                                            team: ranking.team,
                                            rank: ranking.rank,
                                            previousRank: previousRankings[ranking.team.id.uuidString] ?? ranking.rank,
                                            quiz: quiz
                                        )
                                        .transition(.asymmetric(
                                            insertion: .move(edge: .bottom).combined(with: .opacity),
                                            removal: .opacity
                                        ))
                                    }
                                }
                            }
                            #if os(iOS)
                            .padding(.horizontal, AppSpacing.lg)
                            .padding(.bottom, AppSpacing.xs)
                            #else
                            .padding(.horizontal, AppSpacing.xxxl)
                            .padding(.bottom, AppSpacing.md)
                            #endif
                        }
                    }

                    Spacer(minLength: 0)
                }
            }

            // Confetti overlay for round completion
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }

            // Animation Control Button
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    animationControlButton
                        .padding(.trailing, AppSpacing.xl)
                        .padding(.bottom, AppSpacing.xl)
                }
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
            // App Icon & Quiz Name
            HStack(spacing: AppSpacing.xs) {
                // App Icon mit abgerundeten Ecken
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.appBackground)
                        .frame(width: 48, height: 48)

                    Image("AppIconImage")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 48, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .shadow(AppShadow.secondary)

                VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                    Text(quiz.name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    if !quiz.venue.isEmpty {
                        HStack(spacing: AppSpacing.xxxs) {
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

    private var animationControlButton: some View {
        Button {
            showNextPlace()
        } label: {
            HStack(spacing: AppSpacing.xs) {
                if allTeamsVisible {
                    Image(systemName: "arrow.counterclockwise.circle.fill")
                        .font(.system(size: 24))
                    Text(L10n.Presentation.reset)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                } else {
                    Image(systemName: "chevron.up.circle.fill")
                        .font(.system(size: 24))
                    Text(L10n.Presentation.nextPlace)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    if visibleRankCount > 0 {
                        Text("(\(visibleRankCount)/\(totalTeams))")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, AppSpacing.lg)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(allTeamsVisible ? Color.appAccent : Color.appSuccess)
                    .shadow(color: .black.opacity(0.3), radius: 10, y: 5)
            )
        }
        .buttonStyle(.plain)
    }

    private func showNextPlace() {
        if allTeamsVisible {
            // Zurücksetzen
            withAnimation(.easeOut(duration: 0.3)) {
                visibleRankCount = 0
            }
        } else {
            // Nächsten Platz anzeigen
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                visibleRankCount += 1
            }
        }
    }

    private func activeRoundBanner(_ round: Round) -> some View {
        HStack(spacing: AppSpacing.md) {
            // Play Icon
            ZStack {
                Circle()
                    .fill(Color.gradientSuccess)
                    .frame(width: 50, height: 50)
                    .shadow(AppShadow.success)

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
            VStack(alignment: .trailing, spacing: AppSpacing.xxxs) {
                Text(L10n.CommonUI.maxPointsLabel)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
                    .tracking(1)

                HStack(spacing: AppSpacing.xxxs) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.appSecondary)

                    Text(round.maxPoints.map(String.init) ?? "—")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.appSecondary)
                }
            }
        }
        .padding(.horizontal, AppSpacing.xl)
        .padding(.vertical, AppSpacing.md)
        .background(
            ZStack {
                // Gradient Background
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(Color.appSuccess.opacity(0.2))

                // Border
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .stroke(Color.appSuccess.opacity(0.5), lineWidth: 2)

                // Glow
                RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                    .fill(Color.appSuccess.opacity(0.1))
                    .blur(radius: 10)
            }
        )
        .shadow(AppShadow.success)
    }

    private var podiumView: some View {
        let rankings = quiz.getTeamRankings()
        let topRankings = Array(rankings.prefix(3))

        return HStack(alignment: .bottom, spacing: 30) {
            // 2. Platz (links, niedriger) - Index 1
            if topRankings.count >= 2 {
                let secondPlace = topRankings[1]
                if isTeamVisible(atIndex: 1) {
                    PresentationPodiumPlace(
                        team: secondPlace.team,
                        rank: secondPlace.rank,
                        previousRank: previousRankings[secondPlace.team.id.uuidString] ?? secondPlace.rank,
                        height: podiumHeight(for: 2),
                        quiz: quiz
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.3).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    Spacer()
                }
            } else {
                Spacer()
            }

            // 1. Platz (mitte, am höchsten) - Index 0
            if !topRankings.isEmpty {
                let firstPlace = topRankings[0]
                if isTeamVisible(atIndex: 0) {
                    PresentationPodiumPlace(
                        team: firstPlace.team,
                        rank: firstPlace.rank,
                        previousRank: previousRankings[firstPlace.team.id.uuidString] ?? firstPlace.rank,
                        height: podiumHeight(for: 1),
                        quiz: quiz
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.3).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    Spacer()
                }
            } else {
                Spacer()
            }

            // 3. Platz (rechts, am niedrigsten) - Index 2
            if topRankings.count >= 3 {
                let thirdPlace = topRankings[2]
                if isTeamVisible(atIndex: 2) {
                    PresentationPodiumPlace(
                        team: thirdPlace.team,
                        rank: thirdPlace.rank,
                        previousRank: previousRankings[thirdPlace.team.id.uuidString] ?? thirdPlace.rank,
                        height: podiumHeight(for: 3),
                        quiz: quiz
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.3).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else {
                    Spacer()
                }
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
            ForEach(Array(topRankings.enumerated()), id: \.element.team.id) { index, ranking in
                if isTeamVisible(atIndex: index) {
                    PresentationPodiumPlace(
                        team: ranking.team,
                        rank: ranking.rank,
                        previousRank: previousRankings[ranking.team.id.uuidString] ?? ranking.rank,
                        height: 320,
                        quiz: quiz
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.3).combined(with: .opacity),
                        removal: .opacity
                    ))
                }
            }
        }
    }

    private func updateRankings() {
        // Store previous rankings for comparison
        for (index, team) in sortedTeams.enumerated() {
            previousRankings[team.id.uuidString] = index + 1
        }
    }

    private func podiumHeight(for rank: Int) -> CGFloat {
        #if os(iOS)
        // iPad: Kompaktere Podium-Höhen
        switch rank {
        case 1: return 140
        case 2: return 120
        case 3: return 100
        default: return 100
        }
        #else
        // macOS: Original Höhen
        switch rank {
        case 1: return 220
        case 2: return 180
        case 3: return 160
        default: return 160
        }
        #endif
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
        case 1: return Color.appSecondary
        case 2: return Color.appTextSecondary
        case 3: return Color.appPrimary
        default: return Color.appAccent
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
            VStack(spacing: AppSpacing.xxxs) {
                // Rank Change Indicator
                if rankChanged {
                    Image(systemName: rankImproved ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(rankImproved ? Color.appSuccess : Color.red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.3))
                }

                // Medaille/Rang
                ZStack {
                    Circle()
                        .fill(rankColor)
                        .frame(width: 60, height: 60)
                        .shadow(radius: 4, y: 2)

                    TeamIconView(team: team, size: 50)
                }

                // Team Name
                Text(team.name)
                    .font(.system(size: rank == 1 ? 22 : 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                // Score mit Team-Icon
                HStack(spacing: AppSpacing.xxxs) {
                    TeamIconView(team: team, size: 20)

                    Text("\(team.getTotalScore(for: quiz))")
                        .font(.system(size: rank == 1 ? 36 : 32, weight: .bold, design: .rounded))
                        .foregroundStyle(rankColor)
                        .contentTransition(.numericText())
                        .monospacedDigit()

                    Text(L10n.CommonUI.points)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.5))
                }
                .padding(.top, AppSpacing.xxxs)
            }
            .padding(.horizontal, AppSpacing.xs)
            .padding(.top, AppSpacing.xs)
            .padding(.bottom, AppSpacing.xxs)

            // Podest-Sockel
            ZStack(alignment: .bottom) {
                // Hauptsockel
                RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                    .fill(rankColor.opacity(0.3))
                    .frame(height: height)
                    .overlay {
                        RoundedRectangle(cornerRadius: AppCornerRadius.md, style: .continuous)
                            .stroke(rankColor.opacity(0.6), lineWidth: 3)
                    }

                // Rang-Nummer auf Sockel
                Text("\(rank)")
                    .font(.system(size: rank == 1 ? 80 : 70, weight: .black, design: .rounded))
                    .foregroundStyle(rankColor.opacity(0.2))
                    .padding(.bottom, AppSpacing.md)
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
        HStack(spacing: AppSpacing.xxs) {
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
                        .foregroundStyle(rankImproved ? Color.appSuccess : Color.red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .frame(width: 20)

            // Team Icon
            TeamIconView(team: team, size: 14)

            // Team Name
            Text(team.name)
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: AppSpacing.xxxs)

            // Score
            HStack(spacing: AppSpacing.xxxs) {
                Image(systemName: "star.fill")
                    .font(.system(size: 12))
                    .foregroundStyle(.white.opacity(0.5))

                Text("\(team.getTotalScore(for: quiz))")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(L10n.CommonUI.points)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xxs)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(.white.opacity(0.05))
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
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
        let colors: [Color] = [
            Color.appPrimary,
            Color.appSecondary,
            Color.appAccent,
            Color.appSuccess,
            Color.red,
            Color.blue,
            Color.purple
        ]

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
