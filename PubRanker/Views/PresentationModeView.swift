//
//  PresentationModeView.swift
//  PubRanker
//
//  Presentation Mode - Live Leaderboard für zweiten Bildschirm
//

import SwiftUI

struct PresentationModeView: View {
    @Bindable var quiz: Quiz
    var onClose: (() -> Void)? = nil
    @State private var previousRankings: [String: Int] = [:]
    @State private var showConfetti = false
    @State private var visibleRankCount = 0  // Anzahl der sichtbaren Plätze (von unten nach oben)
    @FocusState private var isFocused: Bool

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
            // Verbesserter Hintergrund mit dunklem Gradient und Muster
            presentationBackground
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
                                ForEach(remainingRankings.indices, id: \.self) { index in
                                    let ranking = remainingRankings[index]
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

            // Steuerungs-Buttons (unten rechts)
            VStack {
                Spacer()
                HStack(spacing: AppSpacing.sm) {
                    Spacer()
                    closeButton
                    animationControlButton
                }
                .padding(.trailing, AppSpacing.xl)
                .padding(.bottom, AppSpacing.xl)
            }
        }
        .focusable()
        .focused($isFocused)
        .onKeyPress(.rightArrow) {
            handleNextPlace()
            return .handled
        }
        .onKeyPress(.downArrow) {
            handleNextPlace()
            return .handled
        }
        .onKeyPress(.leftArrow) {
            handlePreviousPlace()
            return .handled
        }
        .onKeyPress(.upArrow) {
            handlePreviousPlace()
            return .handled
        }
        .onKeyPress(.space) {
            handleNextPlace()
            return .handled
        }
        .onKeyPress(.escape) {
            handleClose()
            return .handled
        }
        .onAppear {
            updateRankings()
            isFocused = true
        }
        .onChange(of: quiz.safeTeams.count) { _, _ in
            // Invalidiere Quiz-Cache wenn sich Teams ändern
            quiz.invalidateScoreCache()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                updateRankings()
            }
        }
        .onChange(of: quiz.safeRounds.count) { _, _ in
            // Invalidiere Quiz-Cache wenn sich Runden ändern
            quiz.invalidateScoreCache()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                updateRankings()
            }
        }
    }

    // MARK: - Verbesserter Hintergrund

    private var presentationBackground: some View {
        ZStack {
            // Dunkler Basis-Gradient
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.12),
                    Color(red: 0.08, green: 0.06, blue: 0.15),
                    Color(red: 0.04, green: 0.04, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Subtiler Akzent-Glow oben
            RadialGradient(
                colors: [
                    Color.appPrimary.opacity(0.15),
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 100,
                endRadius: 600
            )

            // Subtiler Gold-Glow unten rechts
            RadialGradient(
                colors: [
                    Color.appSecondary.opacity(0.1),
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 50,
                endRadius: 500
            )

            // Subtiles Raster-Muster für mehr Tiefe
            GeometryReader { geometry in
                Path { path in
                    let spacing: CGFloat = 60
                    for x in stride(from: 0, to: geometry.size.width, by: spacing) {
                        path.move(to: CGPoint(x: x, y: 0))
                        path.addLine(to: CGPoint(x: x, y: geometry.size.height))
                    }
                    for y in stride(from: 0, to: geometry.size.height, by: spacing) {
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                }
                .stroke(Color.white.opacity(0.03), lineWidth: 1)
            }
        }
    }

    // MARK: - Schließen Button

    private var closeButton: some View {
        Button {
            handleClose()
        } label: {
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                Text("Schließen")
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .opacity(0.6)
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.escape, modifiers: [])
    }

    // MARK: - Keyboard Navigation

    private func handleNextPlace() {
        if !allTeamsVisible {
            withAnimation(.spring(response: 1.5, dampingFraction: 0.7)) {
                visibleRankCount += 1
            }
        }
    }

    private func handlePreviousPlace() {
        if visibleRankCount > 0 {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                visibleRankCount -= 1
            }
        }
    }

    private func handleClose() {
        if let onClose = onClose {
            onClose()
        } else {
            #if os(macOS)
            PresentationManager.shared.stopPresentation()
            #endif
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
                    .fill(allTeamsVisible ? Color.appSuccess : Color.appPrimary)
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
            ForEach(topRankings.indices, id: \.self) { index in
                let ranking = topRankings[index]
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
                        .frame(width: 80, height: 80)
                        .shadow(radius: 4, y: 2)

                    TeamIconView(team: team, size: 70)
                }

                // Team Name - GROSS für Präsentation
                Text(team.name)
                    .font(.system(size: rank == 1 ? 36 : 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)

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

                // Rang-Nummer auf Sockel - GUT SICHTBAR
                VStack(spacing: 4) {
                    Text("\(rank)")
                        .font(.system(size: rank == 1 ? 100 : 85, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: rankColor, radius: 8)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                    // Platz-Label
                    Text(rank == 1 ? "PLATZ" : "PLATZ")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(4)
                }
                .padding(.bottom, AppSpacing.sm)
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
        HStack(spacing: AppSpacing.sm) {
            // Rang - GUT SICHTBAR mit farbigem Hintergrund
            ZStack {
                // Farbiger Hintergrund-Kreis
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.appPrimary.opacity(0.8),
                                Color.appPrimary
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .shadow(color: Color.appPrimary.opacity(0.5), radius: 6, y: 2)

                // Rang-Nummer
                Text("\(rank)")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            }

            // Rank Change - größer
            Group {
                if rankChanged {
                    Image(systemName: rankImproved ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(rankImproved ? Color.appSuccess : Color.red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            .frame(width: 30)

            // Team Icon - größer für bessere Sichtbarkeit
            TeamIconView(team: team, size: 44)

            // Team Name - GROSS für Präsentation
            Text(team.name)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: AppSpacing.xxxs)

            // Score - größer für Präsentation
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "star.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Color.appSecondary)

                Text("\(team.getTotalScore(for: quiz))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(L10n.CommonUI.points)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(.white.opacity(0.08))
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .stroke(.white.opacity(0.15), lineWidth: 1)
                }
        )
    }
}

// MARK: - Confetti View

struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    @State private var animationTimer: Timer?

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
            .onDisappear {
                // Cleanup timer
                animationTimer?.invalidate()
                animationTimer = nil
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

        // Reduziert von 100 auf 50 Partikel für bessere Performance
        for _ in 0..<50 {
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
        // Single timer für alle Partikel - bessere Performance
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { timer in
            var allOffScreen = true

            for i in confettiPieces.indices {
                confettiPieces[i].y += confettiPieces[i].velocity
                confettiPieces[i].rotation += 5

                // Check ob Partikel noch auf dem Screen ist
                if confettiPieces[i].y <= size.height + 50 {
                    allOffScreen = false
                }
            }

            // Nur invalidieren wenn ALLE Partikel außerhalb sind
            if allOffScreen {
                timer.invalidate()
                animationTimer = nil
            }
        }
    }
}

#Preview {
    PresentationModeView(quiz: Quiz(name: "Test Quiz", venue: "Pub", date: Date()))
}
