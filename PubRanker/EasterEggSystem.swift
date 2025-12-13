//
//  EasterEggSystem.swift
//  PubRanker
//
//  Created on 23.11.2025
//

import SwiftUI
import AppKit

// MARK: - Easter Egg Manager
class EasterEggManager: ObservableObject {
    @Published var clickCount = 0
    @Published var unlockedAchievements: Set<String> = []
    @Published var showingAchievement = false
    @Published var currentAchievement: Achievement? = nil
    @Published var matrixMode = false
    
    private var lastClickTime: Date = Date()
    private var matrixTimer: Timer? = nil
    
    struct Achievement: Identifiable {
        let id: String
        let title: String
        let description: String
        let icon: String
        let color: Color
    }
    
    private let achievements: [Int: Achievement] = [
        3: Achievement(
            id: "curious",
            title: "Neugierig",
            description: "Du hast das Icon 3x angeklickt",
            icon: "questionmark.circle.fill",
            color: .blue
        ),
        5: Achievement(
            id: "persistent",
            title: "Hartnäckig",
            description: "Du hast das Icon 5x angeklickt",
            icon: "hand.tap.fill",
            color: .orange
        ),
        7: Achievement(
            id: "explorer",
            title: "Entdecker",
            description: "Du hast das Icon 7x angeklickt",
            icon: "magnifyingglass",
            color: .purple
        ),
        10: Achievement(
            id: "easter_egg_master",
            title: "Easter Egg Master",
            description: "Du hast das Icon 10x angeklickt!",
            icon: "star.fill",
            color: .yellow
        ),
        15: Achievement(
            id: "dedicated",
            title: "Hingebungsvoll",
            description: "Du hast das Icon 15x angeklickt",
            icon: "heart.fill",
            color: .red
        ),
        20: Achievement(
            id: "obsessed",
            title: "Besessen",
            description: "Du hast das Icon 20x angeklickt",
            icon: "flame.fill",
            color: .orange
        ),
        30: Achievement(
            id: "legendary",
            title: "Legendär",
            description: "Du hast das Icon 30x angeklickt!",
            icon: "crown.fill",
            color: .yellow
        ),
        42: Achievement(
            id: "matrix_master",
            title: "Matrix Master",
            description: "Die Antwort auf alles! Matrix-Modus aktiviert!",
            icon: "eye.fill",
            color: .green
        )
    ]
    
    func handleIconClick() {
        let now = Date()
        // Reset counter if more than 2 seconds passed since last click
        if now.timeIntervalSince(lastClickTime) > 2.0 {
            clickCount = 0
        }
        
        clickCount += 1
        lastClickTime = now
        
        // Check for achievements
        if let achievement = achievements[clickCount], !unlockedAchievements.contains(achievement.id) {
            unlockedAchievements.insert(achievement.id)
            currentAchievement = achievement
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                showingAchievement = true
            }
            
            // Auto-hide after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                withAnimation {
                    self.showingAchievement = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.currentAchievement = nil
                }
            }
        }
        
        // Activate Matrix Mode at click 42
        if clickCount >= 42 && !matrixMode {
            withAnimation {
                matrixMode = true
            }
            
            // Auto-deactivate Matrix Mode after 10 seconds
            matrixTimer?.invalidate()
            matrixTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
                withAnimation {
                    self?.matrixMode = false
                }
                self?.matrixTimer = nil
            }
        }
    }
    
    func cleanup() {
        matrixTimer?.invalidate()
        matrixTimer = nil
    }
}

// MARK: - Easter Egg Icon View
struct EasterEggIconView: View {
    @ObservedObject var easterEggManager: EasterEggManager
    
    var body: some View {
        Group {
            if let appIcon = NSApplication.shared.applicationIconImage {
                Image(nsImage: appIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            } else {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        }
        .scaleEffect(easterEggManager.matrixMode ? 1.2 : 1.0)
        .rotationEffect(.degrees(easterEggManager.matrixMode ? 180 : 0))
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: easterEggManager.matrixMode)
        .onTapGesture {
            easterEggManager.handleIconClick()
        }
    }
}

// MARK: - Easter Egg Title View
struct EasterEggTitleView: View {
    @ObservedObject var easterEggManager: EasterEggManager
    
    var body: some View {
        HStack(spacing: AppSpacing.xs) {
            // App Icon Badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: easterEggManager.matrixMode 
                                ? [.green, .green.opacity(0.7)]
                                : [Color.appPrimaryDark, Color.appPrimaryLight],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 40, height: 40)
                    .shadow(AppShadow.sm)
                
                Image(systemName: "trophy.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            // Title Text
            VStack(alignment: .leading, spacing: AppSpacing.xxxs) {
                Text("PubRanker")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        easterEggManager.matrixMode 
                            ? LinearGradient(
                                colors: [.green, .green.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            : LinearGradient(
                                colors: [Color.appPrimaryDark, Color.appPrimaryLight],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                    )
                
                Text("QuizMaster Hub")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(
                        easterEggManager.matrixMode 
                            ? .green.opacity(0.7)
                            : Color.appTextSecondary
                    )
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
        }
        .padding(.vertical, AppSpacing.xxs)
        .padding(.horizontal, AppSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(
                    easterEggManager.matrixMode
                        ? Color.black.opacity(0.3)
                        : Color.appBackgroundSecondary.opacity(0.5)
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .strokeBorder(
                    easterEggManager.matrixMode
                        ? .green.opacity(0.3)
                        : Color.appPrimary.opacity(0.2),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Easter Egg Click Counter
struct EasterEggClickCounter: View {
    @ObservedObject var easterEggManager: EasterEggManager
    
    var body: some View {
        if easterEggManager.clickCount > 0 {
            HStack(spacing: AppSpacing.xxxs) {
                Image(systemName: "hand.tap.fill")
                    .font(.caption)
                    .foregroundStyle(Color.appTextSecondary)
                Text("\(easterEggManager.clickCount)")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(Color.appTextSecondary)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, AppSpacing.xs)
            .padding(.vertical, AppSpacing.xxxs)
            .background(
                Capsule()
                    .fill(Color.appBackgroundSecondary.opacity(0.8))
            )
            .overlay(
                Capsule()
                    .strokeBorder(Color.appTextTertiary.opacity(0.2), lineWidth: 1)
            )
            .transition(.scale.combined(with: .opacity))
        }
    }
}

// MARK: - Easter Egg Overlay Container
struct EasterEggOverlayContainer: View {
    @ObservedObject var easterEggManager: EasterEggManager
    
    var body: some View {
        ZStack {
            // Matrix Mode Overlay (ab Klick 42)
            if easterEggManager.matrixMode {
                MatrixRainView()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
            
            // Achievement Overlay
            if easterEggManager.showingAchievement, let achievement = easterEggManager.currentAchievement {
                AchievementOverlay(achievement: achievement)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1000)
            }
        }
    }
}

// MARK: - Achievement Overlay
struct AchievementOverlay: View {
    let achievement: EasterEggManager.Achievement
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(achievement.color.opacity(0.2))
                    .frame(width: 100, height: 100)
                
                Image(systemName: achievement.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(achievement.color)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            
            VStack(spacing: 8) {
                Text("Achievement Unlocked!")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Text(achievement.title)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(achievement.color)
                
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .opacity(opacity)
        }
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .padding(40)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}

// MARK: - Matrix Rain View
struct MatrixRainView: View {
    @State private var columns: [MatrixColumn] = []
    @State private var animationTimer: Timer?
    private let columnCount = 30
    
    struct MatrixColumn: Identifiable {
        let id: Int
        var characters: [String] = []
        var opacities: [Double] = []
    }
    
    private let matrixChars = ["?", "!", "T", "Q", "0", "1", "P", "R", "K", "W", "X", "Y", "Z"]
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(columns) { column in
                    VStack(spacing: 2) {
                        ForEach(Array(column.characters.enumerated()), id: \.offset) { index, char in
                            Text(char)
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .foregroundStyle(.green)
                                .opacity(column.opacities[safe: index] ?? 0)
                        }
                    }
                    .frame(width: max(geometry.size.width / CGFloat(columnCount), 15))
                }
            }
        }
        .background(Color.black.opacity(0.2))
        .allowsHitTesting(false)
        .onAppear {
            setupColumns()
            startAnimation()
        }
        .onDisappear {
            stopAnimation()
        }
    }
    
    private func setupColumns() {
        columns = (0..<columnCount).map { id in
            let charCount = Int.random(in: 25...35)
            var chars: [String] = []
            var ops: [Double] = []
            
            for i in 0..<charCount {
                chars.append(matrixChars.randomElement() ?? "?")
                // Create trailing effect: first few characters are bright, rest fade
                if i < 8 {
                    ops.append(1.0 - (Double(i) * 0.12))
                } else {
                    ops.append(Double.random(in: 0.1...0.4))
                }
            }
            
            return MatrixColumn(
                id: id,
                characters: chars,
                opacities: ops
            )
        }
    }
    
    private func startAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { _ in
            withAnimation(.linear(duration: 0.15)) {
                for i in columns.indices {
                    // Rotate characters to create falling effect
                    if !columns[i].characters.isEmpty {
                        let first = columns[i].characters.removeFirst()
                        columns[i].characters.append(first)
                        
                        // Rotate opacities
                        let firstOpacity = columns[i].opacities.removeFirst()
                        columns[i].opacities.append(firstOpacity)
                        
                        // Update trailing effect
                        for j in 0..<min(8, columns[i].opacities.count) {
                            columns[i].opacities[j] = 1.0 - (Double(j) * 0.12)
                        }
                    }
                }
            }
        }
    }
    
    private func stopAnimation() {
        animationTimer?.invalidate()
        animationTimer = nil
    }
}

// MARK: - Array Extension
extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}





