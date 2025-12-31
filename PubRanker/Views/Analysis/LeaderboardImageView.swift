//
//  LeaderboardImageView.swift
//  PubRanker
//
//  Created for email export feature - renders leaderboard as static image
//

import SwiftUI

struct LeaderboardImageView: View {
    let quiz: Quiz

    private let imageWidth: CGFloat = 800
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            // Header
            headerSection

            // Top 3 Podium
            if quiz.safeTeams.count >= 3 {
                topThreePodium
            }

            // Complete Leaderboard
            leaderboardSection

            // Footer
            footerSection
        }
        .frame(width: imageWidth)
        .fixedSize(horizontal: false, vertical: true)
        .padding(AppSpacing.lg)
        .background(Color.appBackground)
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            // Quiz Name
            Text(quiz.name)
                .font(.system(size: 36, weight: .heavy))
                .foregroundStyle(Color.appTextPrimary)
                .multilineTextAlignment(.center)

            // Venue & Date
            HStack(spacing: AppSpacing.lg) {
                if !quiz.venue.isEmpty {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color.appPrimary)
                        Text(quiz.venue)
                            .font(.title3)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }

                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "calendar")
                        .foregroundStyle(Color.appPrimary)
                    Text(dateFormatter.string(from: quiz.date))
                        .font(.title3)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }

            // Statistik-Übersicht
            HStack(spacing: AppSpacing.xl) {
                statisticBadge(
                    icon: "person.3.fill",
                    value: "\(quiz.safeTeams.count)",
                    label: "Teams",
                    color: Color.appPrimary
                )

                statisticBadge(
                    icon: "list.number",
                    value: "\(quiz.safeRounds.count)",
                    label: "Runden",
                    color: Color.appSuccess
                )

                statisticBadge(
                    icon: "star.fill",
                    value: "\(totalPoints)",
                    label: "Gesamtpunkte",
                    color: Color.appSecondary
                )
            }
            .padding(.vertical, AppSpacing.sm)

            Divider()
                .padding(.horizontal, AppSpacing.xl)
        }
        .padding(.bottom, AppSpacing.sm)
    }

    private func statisticBadge(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            HStack(spacing: AppSpacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)

                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.appTextPrimary)
                    .monospacedDigit()
            }

            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)
        }
    }

    private var totalPoints: Int {
        quiz.safeTeams.reduce(0) { $0 + $1.getTotalScore(for: quiz) }
    }

    // MARK: - Top 3 Podium

    private var topThreePodium: some View {
        let rankings = quiz.getTeamRankings()
        let topThree = Array(rankings.prefix(3))

        return VStack(spacing: AppSpacing.md) {
            Text("🏆 SIEGERTREPPCHEN")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .padding(.bottom, AppSpacing.xs)

            HStack(alignment: .bottom, spacing: AppSpacing.md) {
                // 2nd Place (Silver)
                if topThree.count > 1 {
                    podiumPlace(
                        team: topThree[1].team,
                        rank: 2,
                        height: 100,
                        medal: "🥈"
                    )
                }

                // 1st Place (Gold) - Tallest
                if !topThree.isEmpty {
                    podiumPlace(
                        team: topThree[0].team,
                        rank: 1,
                        height: 140,
                        medal: "🥇"
                    )
                }

                // 3rd Place (Bronze)
                if topThree.count > 2 {
                    podiumPlace(
                        team: topThree[2].team,
                        rank: 3,
                        height: 80,
                        medal: "🥉"
                    )
                }
            }
        }
        .padding(AppSpacing.md)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.lg)
                .fill(Color.appBackgroundSecondary.opacity(0.5))
        )
    }

    private func podiumPlace(team: Team, rank: Int, height: CGFloat, medal: String) -> some View {
        let score = team.getTotalScore(for: quiz)

        return VStack(spacing: AppSpacing.xs) {
            // Medal
            Text(medal)
                .font(.system(size: rank == 1 ? 48 : 40))

            // Team Icon/Image
            ZStack {
                Circle()
                    .fill(teamColor(team))
                    .frame(width: rank == 1 ? 70 : 60, height: rank == 1 ? 70 : 60)
                    .shadow(radius: 3, y: 1)

                if let imageData = team.imageData,
                   let image = PlatformNativeImage(data: imageData) {
                    #if os(macOS)
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: rank == 1 ? 70 : 60, height: rank == 1 ? 70 : 60)
                        .clipShape(Circle())
                    #else
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: rank == 1 ? 70 : 60, height: rank == 1 ? 70 : 60)
                        .clipShape(Circle())
                    #endif
                } else {
                    Text(String(team.name.prefix(2).uppercased()))
                        .font(.system(size: rank == 1 ? 20 : 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            // Team Name
            Text(team.name)
                .font(.system(size: rank == 1 ? 18 : 16, weight: .bold))
                .foregroundStyle(Color.appTextPrimary)
                .lineLimit(1)
                .frame(maxWidth: 180)

            // Score
            Text("\(score)")
                .font(.system(size: rank == 1 ? 28 : 24, weight: .heavy))
                .foregroundStyle(rankColor(rank))
                .monospacedDigit()

            Text("PUNKTE")
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
                .textCase(.uppercase)

            // Podium Base
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(
                    LinearGradient(
                        colors: [rankColor(rank), rankColor(rank).opacity(0.7)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: rank == 1 ? 200 : 160, height: height)
                .overlay {
                    Text("\(rank)")
                        .font(.system(size: rank == 1 ? 48 : 40, weight: .black))
                        .foregroundStyle(.white.opacity(0.3))
                }
        }
    }

    // MARK: - Leaderboard

    private var leaderboardSection: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Rangliste")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)

            ForEach(Array(quiz.getTeamRankings().enumerated()), id: \.element.team.id) { index, ranking in
                teamRow(team: ranking.team, rank: ranking.rank)

                if index < quiz.getTeamRankings().count - 1 {
                    Divider()
                        .padding(.horizontal, AppSpacing.sm)
                }
            }
        }
        .padding(AppSpacing.md)
        .appCard(style: .glassmorphism, cornerRadius: AppCornerRadius.lg)
    }

    private func teamRow(team: Team, rank: Int) -> some View {
        let isTopThree = rank <= 3
        let maxScore = quiz.sortedTeamsByScore.first?.getTotalScore(for: quiz) ?? 1
        let teamScore = team.getTotalScore(for: quiz)
        let progress = maxScore > 0 ? CGFloat(teamScore) / CGFloat(maxScore) : 0

        return HStack(spacing: AppSpacing.sm) {
            // Rang Badge
            ZStack {
                if isTopThree {
                    Circle()
                        .fill(rankColor(rank))
                        .frame(width: 60, height: 60)
                        .shadow(radius: 3, y: 1)

                    if rank == 1 {
                        Image(systemName: "crown.fill")
                            .font(.title3)
                            .foregroundStyle(.white)
                    } else {
                        Text("\(rank)")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                            .monospacedDigit()
                    }
                } else {
                    Circle()
                        .fill(Color.appBackgroundSecondary)
                        .frame(width: 50, height: 50)

                    Text("\(rank)")
                        .font(.title3)
                        .bold()
                        .foregroundStyle(Color.appTextSecondary)
                        .monospacedDigit()
                }
            }

            // Team Icon/Image
            ZStack {
                Circle()
                    .fill(teamColor(team))
                    .frame(width: 40, height: 40)

                if let imageData = team.imageData,
                   let image = PlatformNativeImage(data: imageData) {
                    #if os(macOS)
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    #else
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    #endif
                } else {
                    Text(String(team.name.prefix(2).uppercased()))
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }
            }

            // Team Info
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(team.name)
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                    .lineLimit(1)

                // Fortschrittsbalken mit fester Breite
                if quiz.safeTeams.count > 1 && maxScore > 0 {
                    ZStack(alignment: .leading) {
                        // Hintergrund
                        RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                            .fill(Color.appTextTertiary.opacity(0.2))
                            .frame(width: 350, height: 6)

                        // Fortschritt
                        RoundedRectangle(cornerRadius: AppCornerRadius.xs)
                            .fill(isTopThree ? rankColor(rank) : Color.appPrimary)
                            .frame(width: 350 * progress, height: 6)
                    }
                }
            }

            Spacer()

            // Punkte
            VStack(spacing: AppSpacing.xxxs) {
                Text("\(teamScore)")
                    .font(.system(size: 32, weight: .bold))
                    .monospacedDigit()
                    .foregroundStyle(isTopThree ? rankColor(rank) : Color.appTextPrimary)

                Text("PUNKTE")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .textCase(.uppercase)
            }
        }
        .padding(.vertical, AppSpacing.xs)
        .padding(.horizontal, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(isTopThree ? rankColor(rank).opacity(0.05) : Color.clear)
        )
        .overlay {
            if isTopThree {
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .stroke(rankColor(rank).opacity(0.3), lineWidth: 2)
            }
        }
    }

    // MARK: - Footer

    private var footerSection: some View {
        VStack(spacing: AppSpacing.md) {
            Divider()
                .padding(.horizontal, AppSpacing.xl)

            // Call to Action
            VStack(spacing: AppSpacing.xs) {
                HStack(spacing: AppSpacing.sm) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.appSecondary)

                    Text("Gefällt dir PubRanker?")
                        .font(.subheadline)
                        .bold()
                        .foregroundStyle(Color.appTextPrimary)

                    Image(systemName: "star.fill")
                        .foregroundStyle(Color.appSecondary)
                }

                Text("Hol dir die App im Mac App Store!")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
            }

            // QR Code + Link
            HStack(spacing: AppSpacing.lg) {
                // QR Code
                if let qrImage = generateQRCode(from: "https://apps.apple.com/ch/app/pubranker/id6754255330") {
                    VStack(spacing: AppSpacing.xs) {
                        qrImage
                            .interpolation(.none)
                            .resizable()
                            .frame(width: 80, height: 80)
                            .background(Color.white)
                            .cornerRadius(AppCornerRadius.sm)

                        Text("QR-Code scannen")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextTertiary)
                    }
                }

                // App Info
                VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: "chart.bar.fill")
                            .foregroundStyle(Color.appPrimary)
                        Text("PubRanker")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                    }

                    Text("Die perfekte Quiz-Management App")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)

                    Text("apps.apple.com/pubranker")
                        .font(.caption)
                        .foregroundStyle(Color.appPrimary)
                        .italic()
                }
            }
            .padding(AppSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: AppCornerRadius.md)
                    .fill(Color.appBackgroundSecondary.opacity(0.3))
            )

            // Timestamp
            Text("Erstellt am \(Date().formatted(date: .long, time: .shortened))")
                .font(.caption2)
                .foregroundStyle(Color.appTextTertiary)
        }
        .padding(.top, AppSpacing.sm)
    }

    // MARK: - QR Code Generator

    private func generateQRCode(from string: String) -> Image? {
        let data = Data(string.utf8)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("M", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else { return nil }

        // Scale up the QR code
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)

        #if os(macOS)
        let rep = NSCIImageRep(ciImage: scaledImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return Image(nsImage: nsImage)
        #else
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }
        let uiImage = UIImage(cgImage: cgImage)
        return Image(uiImage: uiImage)
        #endif
    }

    // MARK: - Helper

    private func rankColor(_ rank: Int) -> Color {
        switch rank {
        case 1: return Color.appSecondary   // Gold
        case 2: return Color.appTextSecondary  // Silver
        case 3: return Color.appPrimary     // Bronze
        default: return Color.appTextSecondary
        }
    }

    private func teamColor(_ team: Team) -> Color {
        Color(hex: team.color) ?? Color.appPrimary
    }
}
