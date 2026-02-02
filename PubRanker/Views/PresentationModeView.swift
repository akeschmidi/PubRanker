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

    /// Prüft ob alle Runden abgeschlossen sind
    var allRoundsCompleted: Bool {
        let rounds = quiz.safeRounds
        guard !rounds.isEmpty else { return false }
        return rounds.allSatisfy { $0.isCompleted }
    }

    /// Prüft ob alle Teams in der letzten Runde Punkte haben
    var allTeamsHaveScoresInLastRound: Bool {
        let rounds = quiz.safeRounds
        let teams = quiz.safeTeams
        guard let lastRound = rounds.max(by: { $0.orderIndex < $1.orderIndex }),
              !teams.isEmpty else { return false }
        return teams.allSatisfy { team in
            team.hasScore(for: lastRound)
        }
    }

    /// Prüft ob Konfetti gezeigt werden soll (Quiz abgeschlossen ODER alle Runden abgeschlossen ODER alle Teams haben Punkte in der letzten Runde)
    var shouldShowCelebration: Bool {
        return quiz.isCompleted || allRoundsCompleted || allTeamsHaveScoresInLastRound
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
        // iPad: 2 Spalten mit mehr Platz für bessere Lesbarkeit
        return [
            GridItem(.flexible(), spacing: AppSpacing.sm),
            GridItem(.flexible(), spacing: AppSpacing.sm)
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
                    .allowsHitTesting(false)
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

            // Unsichtbarer Button für ESC-Shortcut
            Button("") {
                handleClose()
            }
            .keyboardShortcut(.escape, modifiers: [])
            .opacity(0)
            .frame(width: 0, height: 0)
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
        .onChange(of: visibleRankCount) { oldValue, newValue in
            // Konfetti wenn der erste Platz enthüllt wird
            if newValue == totalTeams && oldValue < totalTeams && totalTeams > 0 {
                if shouldShowCelebration {
                    triggerCelebration()
                }
            }
        }
    }

    // MARK: - Celebration

    private func triggerCelebration() {
        showConfetti = true

        // Nach 8 Sekunden Konfetti ausblenden
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            withAnimation(.easeOut(duration: 1.0)) {
                showConfetti = false
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
                Text(L10n.Presentation.close)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, AppSpacing.sm)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.5))
            )
            .overlay(
                Capsule()
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
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

        return GeometryReader { geometry in
            #if os(iOS)
            // iPad: Breitere Karten für bessere Darstellung
            let availableWidth = geometry.size.width
            let cardWidth = min((availableWidth - 60) / 3, 320)
            let spacing: CGFloat = 20
            #else
            // macOS: Original Layout
            let cardWidth: CGFloat? = nil
            let spacing: CGFloat = 30
            #endif

            HStack(alignment: .bottom, spacing: spacing) {
                // 2. Platz (links, niedriger) - Index 1
                if topRankings.count >= 2 {
                    let secondPlace = topRankings[1]
                    if isTeamVisible(atIndex: 1) {
                        PresentationPodiumPlace(
                            team: secondPlace.team,
                            rank: secondPlace.rank,
                            previousRank: previousRankings[secondPlace.team.id.uuidString] ?? secondPlace.rank,
                            height: podiumHeight(for: 2),
                            quiz: quiz,
                            customWidth: cardWidth
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
                            quiz: quiz,
                            customWidth: cardWidth
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
                            quiz: quiz,
                            customWidth: cardWidth
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(minHeight: 350)
    }

    private var simplePodiumView: some View {
        let rankings = quiz.getTeamRankings()
        let topRankings = Array(rankings.prefix(3))
        let visibleTeamCount = topRankings.count

        return GeometryReader { geometry in
            let availableWidth = geometry.size.width

            #if os(iOS)
            // iPad: Breitere Karten, die den verfügbaren Platz besser nutzen
            let cardWidth = min(availableWidth / CGFloat(max(visibleTeamCount, 1)) - 30, 400)
            let spacing: CGFloat = 20
            let podiumHeight: CGFloat = 180
            #else
            // macOS: Original Layout
            let cardWidth: CGFloat = 240
            let spacing: CGFloat = 40
            let podiumHeight: CGFloat = 320
            #endif

            HStack(spacing: spacing) {
                Spacer()
                ForEach(topRankings.indices, id: \.self) { index in
                    let ranking = topRankings[index]
                    if isTeamVisible(atIndex: index) {
                        PresentationPodiumPlace(
                            team: ranking.team,
                            rank: ranking.rank,
                            previousRank: previousRankings[ranking.team.id.uuidString] ?? ranking.rank,
                            height: podiumHeight,
                            quiz: quiz,
                            customWidth: cardWidth
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.3).combined(with: .opacity),
                            removal: .opacity
                        ))
                    }
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(minHeight: 400)
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
    var customWidth: CGFloat? = nil

    var teamColor: Color {
        Color(hex: team.color) ?? .blue
    }

    var cardWidth: CGFloat {
        if let customWidth = customWidth {
            return customWidth
        }
        return rank == 1 ? 240 : 220
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
                        #if os(iOS)
                        .font(.system(size: 18))
                        #else
                        .font(.system(size: 20))
                        #endif
                        .foregroundStyle(rankImproved ? Color.appSuccess : Color.red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        #if os(iOS)
                        .font(.system(size: 18))
                        #else
                        .font(.system(size: 20))
                        #endif
                        .foregroundStyle(.white.opacity(0.3))
                }

                // Medaille/Rang
                ZStack {
                    Circle()
                        .fill(rankColor)
                        #if os(iOS)
                        .frame(width: 60, height: 60)
                        #else
                        .frame(width: 80, height: 80)
                        #endif
                        .shadow(radius: 4, y: 2)

                    #if os(iOS)
                    TeamIconView(team: team, size: 52)
                    #else
                    TeamIconView(team: team, size: 70)
                    #endif
                }

                // Team Name - GROSS für Präsentation
                Text(team.name)
                    #if os(iOS)
                    .font(.system(size: rank == 1 ? 28 : 24, weight: .bold, design: .rounded))
                    #else
                    .font(.system(size: rank == 1 ? 36 : 32, weight: .bold, design: .rounded))
                    #endif
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.6)

                // Score mit Team-Icon
                HStack(spacing: AppSpacing.xxxs) {
                    #if os(iOS)
                    TeamIconView(team: team, size: 16)
                    #else
                    TeamIconView(team: team, size: 20)
                    #endif

                    Text("\(team.getTotalScore(for: quiz))")
                        #if os(iOS)
                        .font(.system(size: rank == 1 ? 28 : 24, weight: .bold, design: .rounded))
                        #else
                        .font(.system(size: rank == 1 ? 36 : 32, weight: .bold, design: .rounded))
                        #endif
                        .foregroundStyle(rankColor)
                        .contentTransition(.numericText())
                        .monospacedDigit()

                    Text(L10n.CommonUI.points)
                        #if os(iOS)
                        .font(.system(size: 12, weight: .semibold))
                        #else
                        .font(.system(size: 14, weight: .semibold))
                        #endif
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
                        #if os(iOS)
                        .font(.system(size: rank == 1 ? 70 : 60, weight: .black, design: .rounded))
                        #else
                        .font(.system(size: rank == 1 ? 100 : 85, weight: .black, design: .rounded))
                        #endif
                        .foregroundStyle(.white)
                        .shadow(color: rankColor, radius: 8)
                        .shadow(color: .black.opacity(0.5), radius: 4, y: 2)

                    // Platz-Label
                    Text(L10n.Presentation.place)
                        #if os(iOS)
                        .font(.system(size: 14, weight: .bold))
                        #else
                        .font(.system(size: 16, weight: .bold))
                        #endif
                        .foregroundStyle(.white.opacity(0.7))
                        .tracking(4)
                }
                .padding(.bottom, AppSpacing.sm)
            }
        }
        .frame(width: cardWidth)
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
                    #if os(iOS)
                    .frame(width: 48, height: 48)
                    #else
                    .frame(width: 56, height: 56)
                    #endif
                    .shadow(color: Color.appPrimary.opacity(0.5), radius: 6, y: 2)

                // Rang-Nummer
                Text("\(rank)")
                    #if os(iOS)
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    #else
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    #endif
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, y: 1)
            }

            // Rank Change - größer
            Group {
                if rankChanged {
                    Image(systemName: rankImproved ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                        #if os(iOS)
                        .font(.system(size: 20))
                        #else
                        .font(.system(size: 24))
                        #endif
                        .foregroundStyle(rankImproved ? Color.appSuccess : Color.red)
                } else {
                    Image(systemName: "minus.circle.fill")
                        #if os(iOS)
                        .font(.system(size: 20))
                        #else
                        .font(.system(size: 24))
                        #endif
                        .foregroundStyle(.white.opacity(0.2))
                }
            }
            #if os(iOS)
            .frame(width: 24)
            #else
            .frame(width: 30)
            #endif

            // Team Icon - größer für bessere Sichtbarkeit
            #if os(iOS)
            TeamIconView(team: team, size: 36)
            #else
            TeamIconView(team: team, size: 44)
            #endif

            // Team Name - GROSS für Präsentation
            Text(team.name)
                #if os(iOS)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                #else
                .font(.system(size: 28, weight: .bold, design: .rounded))
                #endif
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Spacer(minLength: AppSpacing.xxxs)

            // Score - größer für Präsentation
            HStack(spacing: AppSpacing.xxs) {
                Image(systemName: "star.fill")
                    #if os(iOS)
                    .font(.system(size: 16))
                    #else
                    .font(.system(size: 20))
                    #endif
                    .foregroundStyle(Color.appSecondary)

                Text("\(team.getTotalScore(for: quiz))")
                    #if os(iOS)
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    #else
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    #endif
                    .foregroundStyle(.white)
                    .monospacedDigit()

                Text(L10n.CommonUI.points)
                    #if os(iOS)
                    .font(.system(size: 13, weight: .medium))
                    #else
                    .font(.system(size: 15, weight: .medium))
                    #endif
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
            }
            .fixedSize(horizontal: true, vertical: false)
        }
        .padding(.horizontal, AppSpacing.md)
        #if os(iOS)
        .padding(.vertical, AppSpacing.xs)
        #else
        .padding(.vertical, AppSpacing.sm)
        #endif
        .frame(maxWidth: .infinity)
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

// MARK: - Confetti View (Canvas-basiert für bessere Performance)

struct ConfettiView: View {
    @State private var startTime: Date = Date()
    @State private var confettiPieces: [ConfettiPiece] = []

    struct ConfettiPiece {
        let startX: CGFloat
        let startY: CGFloat
        let velocityX: CGFloat
        let velocityY: CGFloat
        let rotationSpeed: Double
        let color: Color
        let size: CGFloat
        let shape: Int  // 0 = rect, 1 = circle
    }

    var body: some View {
        GeometryReader { geometry in
            TimelineView(.animation(minimumInterval: 1/60)) { timeline in
                let elapsed = timeline.date.timeIntervalSince(startTime)

                Canvas { context, size in
                    for piece in confettiPieces {
                        let gravity: CGFloat = 150
                        let airResistance: CGFloat = 0.98

                        let t = CGFloat(elapsed)
                        let damping = pow(airResistance, t * 60)

                        let x = piece.startX + piece.velocityX * t * 30 * damping
                        let y = piece.startY + piece.velocityY * t * 30 * damping + 0.5 * gravity * t * t

                        // Fade out am unteren Rand
                        let fadeStart = size.height - 150
                        let opacity = y > fadeStart ? max(0, 1 - (y - fadeStart) / 150) : 1.0

                        guard y < size.height + 50 && opacity > 0.01 else { continue }

                        let rotation = Angle.degrees(piece.rotationSpeed * elapsed * 60)

                        context.opacity = opacity
                        context.translateBy(x: x, y: y)
                        context.rotate(by: rotation)

                        let rect = CGRect(x: -piece.size/2, y: -piece.size/2, width: piece.size, height: piece.size * 2)

                        if piece.shape == 0 {
                            context.fill(Path(rect), with: .color(piece.color))
                        } else {
                            context.fill(Circle().path(in: CGRect(x: -piece.size/2, y: -piece.size/2, width: piece.size, height: piece.size)), with: .color(piece.color))
                        }

                        context.rotate(by: -rotation)
                        context.translateBy(x: -x, y: -y)
                        context.opacity = 1
                    }
                }
                .allowsHitTesting(false)
            }
            .allowsHitTesting(false)
            .onAppear {
                startTime = Date()
                createConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }

    private func createConfetti(in size: CGSize) {
        var pieces: [ConfettiPiece] = []

        let colors: [Color] = [
            .red, .orange, .yellow, .green, .blue, .purple, .pink, .cyan, .mint,
            Color.appPrimary, Color.appSecondary, Color.appSuccess
        ]

        let centerX = size.width / 2
        let centerY = size.height / 3

        // Hauptexplosion vom Zentrum (200 Partikel)
        for _ in 0..<200 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 8...22)

            pieces.append(ConfettiPiece(
                startX: centerX + CGFloat.random(in: -30...30),
                startY: centerY + CGFloat.random(in: -30...30),
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - 8,
                rotationSpeed: Double.random(in: -15...15),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 6...14),
                shape: Int.random(in: 0...1)
            ))
        }

        // Linke Explosion (80 Partikel)
        let leftX = size.width * 0.15
        for _ in 0..<80 {
            let angle = Double.random(in: -0.3...(Double.pi + 0.3))
            let speed = CGFloat.random(in: 6...18)

            pieces.append(ConfettiPiece(
                startX: leftX,
                startY: centerY,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - 5,
                rotationSpeed: Double.random(in: -12...12),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 5...12),
                shape: Int.random(in: 0...1)
            ))
        }

        // Rechte Explosion (80 Partikel)
        let rightX = size.width * 0.85
        for _ in 0..<80 {
            let angle = Double.random(in: (Double.pi - 0.3)...(2 * Double.pi + 0.3))
            let speed = CGFloat.random(in: 6...18)

            pieces.append(ConfettiPiece(
                startX: rightX,
                startY: centerY,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - 5,
                rotationSpeed: Double.random(in: -12...12),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 5...12),
                shape: Int.random(in: 0...1)
            ))
        }

        // Konfetti-Regen von oben (120 Partikel)
        for _ in 0..<120 {
            pieces.append(ConfettiPiece(
                startX: CGFloat.random(in: 0...size.width),
                startY: CGFloat.random(in: -200...(-20)),
                velocityX: CGFloat.random(in: -3...3),
                velocityY: CGFloat.random(in: 2...8),
                rotationSpeed: Double.random(in: -10...10),
                color: colors.randomElement() ?? .blue,
                size: CGFloat.random(in: 5...12),
                shape: Int.random(in: 0...1)
            ))
        }

        // Goldene Sterne für den Sieger (40 Partikel)
        for _ in 0..<40 {
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 12...20)

            pieces.append(ConfettiPiece(
                startX: centerX,
                startY: centerY - 50,
                velocityX: cos(angle) * speed,
                velocityY: sin(angle) * speed - 10,
                rotationSpeed: Double.random(in: -20...20),
                color: [Color.yellow, Color.orange].randomElement() ?? .yellow,
                size: CGFloat.random(in: 12...18),
                shape: 1
            ))
        }

        confettiPieces = pieces
    }
}

#Preview {
    PresentationModeView(quiz: Quiz(name: "Test Quiz", venue: "Pub", date: Date()))
}
