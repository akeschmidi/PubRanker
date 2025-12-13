//
//  DesignSystemDemoView.swift
//  PubRanker
//
//  Created on 30.11.2025
//  Version 2.0 Design System Demo
//

import SwiftUI
import AppKit
import Charts

/// Demo View to showcase the new Design System components
struct DesignSystemDemoView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("appearance") private var appearance: String = "system"
    @State private var currentColorScheme: ColorScheme?
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.sectionSpacing) {
                // Header with Dark Mode Toggle
                headerSection
                
                Divider()
                
                // Colors Section
                colorsSection
                
                Divider()
                
                // Cards Section
                cardsSection
                
                Divider()
                
                // Buttons Section
                buttonsSection
                
                Divider()
                
                // Gradients Section
                gradientsSection
                
                Divider()
                
                // Spacing & Shadows Section
                spacingShadowsSection
                
                Divider()
                
                // Real-World Examples Section
                realWorldExamplesSection
                
                Divider()
                
                // Component Combinations Section
                componentCombinationsSection
                
                Divider()
                
                // Corner Radius Section
                cornerRadiusSection
                
                Divider()
                
                // SwiftCharts Examples Section
                chartsExamplesSection
            }
            .padding(AppSpacing.screenPadding)
        }
        .background(Color.appBackground)
    }
    
    // MARK: - Header
    
    private var headerSection: some View {
        VStack(spacing: AppSpacing.md) {
            HStack {
                Spacer()
                
                // Dark Mode Toggle Button
                Button {
                    toggleColorScheme()
                } label: {
                    HStack(spacing: AppSpacing.xs) {
                        Image(systemName: colorScheme == .dark ? "sun.max.fill" : "moon.fill")
                            .font(.title3)
                        Text(colorScheme == .dark ? "Light Mode" : "Dark Mode")
                            .font(.subheadline)
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppSpacing.md)
                    .padding(.vertical, AppSpacing.xs)
                    .background(
                        LinearGradient(
                            colors: colorScheme == .dark 
                                ? [Color(red: 1.0, green: 0.8, blue: 0.0), Color(red: 1.0, green: 0.6, blue: 0.0)]
                                : [Color(red: 0.2, green: 0.2, blue: 0.3), Color(red: 0.1, green: 0.1, blue: 0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
                    .shadow(AppShadow.md)
                }
                .buttonStyle(.plain)
            }
            
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.appPrimary)
            
            Text("PubRanker 2.0 Design System")
                .font(.title)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            Text("Moderne UI-Komponenten mit Glassmorphism & Gradients")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.lg)
        .preferredColorScheme(currentColorScheme)
    }
    
    // MARK: - Color Scheme Toggle
    
    private func toggleColorScheme() {
        let newScheme: ColorScheme = colorScheme == .dark ? .light : .dark
        currentColorScheme = newScheme
        
        // Update system appearance for macOS
        if let window = NSApplication.shared.windows.first {
            window.appearance = NSAppearance(named: newScheme == .dark ? .darkAqua : .aqua)
        }
        
        // Save preference
        appearance = newScheme == .dark ? "dark" : "light"
    }
    
    private var effectiveColorScheme: ColorScheme {
        currentColorScheme ?? colorScheme
    }
    
    // MARK: - Colors
    
    private var colorsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Farbpalette")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                colorCard(name: "Primary", color: .appPrimary, description: "Braun - Pub Theme")
                colorCard(name: "Secondary", color: .appSecondary, description: "Gold - Bier Theme")
                colorCard(name: "Accent", color: .appAccent, description: "Orange - Highlight")
                colorCard(name: "Success", color: .appSuccess, description: "Grün - Positiv")
                colorCard(name: "Background", color: .appBackground, description: "Hintergrund")
                colorCard(name: "Text Primary", color: .appTextPrimary, description: "Haupttext")
            }
        }
    }
    
    private func colorCard(name: String, color: Color, description: String) -> some View {
        VStack(spacing: AppSpacing.xs) {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(color)
                .frame(height: 80)
                .overlay {
                    RoundedRectangle(cornerRadius: AppCornerRadius.md)
                        .stroke(Color.appTextTertiary.opacity(0.3), lineWidth: 1)
                }
            
            Text(name)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
            
            Text(description)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppSpacing.sm)
        .appCard(style: .outlined)
    }
    
    // MARK: - Cards
    
    private var cardsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Card-Komponenten")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                // Default Card
                AppCard {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Image(systemName: "square.fill")
                            .font(.title)
                            .foregroundStyle(Color.appPrimary)
                        Text("Default Card")
                            .font(.headline)
                        Text("Standard Card mit Background")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                
                // Glassmorphism Card
                AppCard(style: .glassmorphism) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Image(systemName: "sparkles")
                            .font(.title)
                            .foregroundStyle(Color.appAccent)
                        Text("Glassmorphism")
                            .font(.headline)
                        Text("Frosted Glass Effekt")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                
                // Primary Gradient Card
                AppCard(style: .primary) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                        Text("Primary Gradient")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Braun Theme")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                
                // Elevated Card
                AppCard(style: .elevated) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.appSuccess)
                        Text("Elevated Card")
                            .font(.headline)
                        Text("Mit größerem Shadow")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Buttons
    
    private var buttonsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Gradient-Buttons")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            VStack(spacing: AppSpacing.md) {
                HStack(spacing: AppSpacing.md) {
                    Button {
                        // Demo action
                    } label: {
                        Label("Primary", systemImage: "star.fill")
                    }
                    .primaryGradientButton()
                    
                    Button {
                        // Demo action
                    } label: {
                        Label("Secondary", systemImage: "sparkles")
                    }
                    .secondaryGradientButton()
                    
                    Button {
                        // Demo action
                    } label: {
                        Label("Accent", systemImage: "flame.fill")
                    }
                    .accentGradientButton()
                    
                    Button {
                        // Demo action
                    } label: {
                        Label("Success", systemImage: "checkmark.circle.fill")
                    }
                    .successGradientButton()
                }
                
                HStack(spacing: AppSpacing.md) {
                    Button("Small") { }
                        .primaryGradientButton(size: .small)
                    
                    Button("Medium") { }
                        .primaryGradientButton(size: .medium)
                    
                    Button("Large") { }
                        .primaryGradientButton(size: .large)
                }
            }
        }
    }
    
    // MARK: - Gradients
    
    private var gradientsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Gradients")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                gradientCard(name: "Primary", gradient: Color.gradientPrimary)
                gradientCard(name: "Secondary", gradient: Color.gradientSecondary)
                gradientCard(name: "Accent", gradient: Color.gradientAccent)
                gradientCard(name: "Pub Theme", gradient: Color.gradientPubTheme)
            }
        }
    }
    
    private func gradientCard(name: String, gradient: LinearGradient) -> some View {
        VStack(spacing: AppSpacing.xs) {
            RoundedRectangle(cornerRadius: AppCornerRadius.md)
                .fill(gradient)
                .frame(height: 100)
                .shadow(AppShadow.md)
            
            Text(name)
                .font(.headline)
                .foregroundStyle(Color.appTextPrimary)
        }
        .padding(AppSpacing.sm)
    }
    
    // MARK: - Spacing & Shadows
    
    private var spacingShadowsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Spacing & Shadows")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                // Spacing Demo
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Spacing System (4pt Grid)")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xxs) {
                        spacingDemo(label: "xxxs", value: AppSpacing.xxxs)
                        spacingDemo(label: "xxs", value: AppSpacing.xxs)
                        spacingDemo(label: "xs", value: AppSpacing.xs)
                        spacingDemo(label: "sm", value: AppSpacing.sm)
                        spacingDemo(label: "md", value: AppSpacing.md)
                        spacingDemo(label: "lg", value: AppSpacing.lg)
                    }
                }
                .padding(AppSpacing.md)
                .appCard(style: .outlined)
                
                // Shadow Demo
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text("Shadow System (Elevation)")
                        .font(.headline)
                    
                    HStack(spacing: AppSpacing.md) {
                        shadowDemo(label: "sm", shadow: AppShadow.sm)
                        shadowDemo(label: "md", shadow: AppShadow.md)
                        shadowDemo(label: "lg", shadow: AppShadow.lg)
                        shadowDemo(label: "xl", shadow: AppShadow.xl)
                    }
                }
                .padding(AppSpacing.md)
                .appCard(style: .outlined)
            }
        }
    }
    
    private func spacingDemo(label: String, value: CGFloat) -> some View {
        HStack(spacing: AppSpacing.sm) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
                .frame(width: 50, alignment: .leading)
            
            Rectangle()
                .fill(Color.appPrimary)
                .frame(width: value, height: 20)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            
            Text("\(Int(value))pt")
                .font(.caption2)
                .foregroundStyle(Color.appTextTertiary)
                .monospacedDigit()
        }
    }
    
    private func shadowDemo(label: String, shadow: Shadow) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            RoundedRectangle(cornerRadius: AppCornerRadius.sm)
                .fill(Color.appBackgroundSecondary)
                .frame(width: 80, height: 80)
                .shadow(shadow)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
        }
    }
    
    // MARK: - Real-World Examples
    
    private var realWorldExamplesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Praktische Beispiele")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                // Quiz Card Example
                quizCardExample
                
                // Team Stats Card Example
                teamStatsCardExample
                
                // Action Button Group Example
                actionButtonGroupExample
                
                // Status Badge Example
                statusBadgeExample
            }
        }
    }
    
    private var quizCardExample: some View {
        AppCard(style: .glassmorphism) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "trophy.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appSecondary)
                    
                    Spacer()
                    
                    Text("Aktiv")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.white)
                        .padding(.horizontal, AppSpacing.xs)
                        .padding(.vertical, 4)
                        .background(Color.appSuccess)
                        .clipShape(Capsule())
                }
                
                Text("Pub Quiz #42")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                
                HStack(spacing: AppSpacing.sm) {
                    Label("Kneipe XYZ", systemImage: "mappin.circle")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                    
                    Label("Heute", systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
                
                HStack(spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("8")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appPrimary)
                        Text("Teams")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("5/10")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(Color.appAccent)
                        Text("Runden")
                            .font(.caption2)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
    }
    
    private var teamStatsCardExample: some View {
        AppCard(style: .primary) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Circle()
                        .fill(.white.opacity(0.3))
                        .frame(width: 50, height: 50)
                        .overlay {
                            Image(systemName: "person.3.fill")
                                .foregroundStyle(.white)
                        }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Die Überflieger")
                            .font(.headline)
                            .foregroundStyle(.white)
                        Text("Team-Statistiken")
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    Spacer()
                }
                
                Divider()
                    .background(.white.opacity(0.3))
                
                HStack(spacing: AppSpacing.lg) {
                    VStack(spacing: 4) {
                        Text("12")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                        Text("Siege")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 4) {
                        Text("85%")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                        Text("Siegrate")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                    
                    VStack(spacing: 4) {
                        Text("1.2")
                            .font(.title2)
                            .bold()
                            .foregroundStyle(.white)
                        Text("Ø Platz")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
        }
    }
    
    private var actionButtonGroupExample: some View {
        AppCard(style: .outlined) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Aktionen")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                
                VStack(spacing: AppSpacing.xs) {
                    Button {
                        // Demo action
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Quiz starten")
                            Spacer()
                        }
                    }
                    .primaryGradientButton(size: .medium)
                    
                    Button {
                        // Demo action
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Ergebnisse exportieren")
                            Spacer()
                        }
                    }
                    .secondaryGradientButton(size: .medium)
                    
                    Button {
                        // Demo action
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("E-Mail senden")
                            Spacer()
                        }
                    }
                    .accentGradientButton(size: .medium)
                }
            }
        }
    }
    
    private var statusBadgeExample: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Status-Badges")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    statusBadgeRow(label: "Geplant", color: .appTextSecondary, icon: "calendar")
                    statusBadgeRow(label: "Aktiv", color: .appSuccess, icon: "circle.fill")
                    statusBadgeRow(label: "Abgeschlossen", color: .appPrimary, icon: "checkmark.circle.fill")
                    statusBadgeRow(label: "Fehler", color: .appAccent, icon: "exclamationmark.triangle.fill")
                }
            }
        }
    }
    
    private func statusBadgeRow(label: String, color: Color, icon: String) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextPrimary)
            Spacer()
            Capsule()
                .fill(color.opacity(0.2))
                .frame(width: 60, height: 20)
                .overlay {
                    Text("Live")
                        .font(.caption2)
                        .bold()
                        .foregroundStyle(color)
                }
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Component Combinations
    
    private var componentCombinationsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Komponenten-Kombinationen")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                // Card with Button
                cardWithButtonExample
                
                // Gradient Header Card
                gradientHeaderCardExample
                
                // Icon Card with Shadow
                iconCardExample
                
                // Stats Grid Card
                statsGridCardExample
            }
        }
    }
    
    private var cardWithButtonExample: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(Color.appSecondary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Premium Feature")
                            .font(.headline)
                            .foregroundStyle(Color.appTextPrimary)
                        Text("Erweiterte Funktionen")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    
                    Spacer()
                }
                
                Button {
                    // Demo action
                } label: {
                    Text("Jetzt aktivieren")
                        .frame(maxWidth: .infinity)
                }
                .primaryGradientButton(size: .small)
            }
        }
    }
    
    private var gradientHeaderCardExample: some View {
        VStack(spacing: 0) {
            // Gradient Header
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                Text("Statistiken")
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(AppSpacing.md)
            .background(Color.gradientPrimary)
            
            // Content
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                statRow(label: "Gesamt Quiz", value: "24")
                statRow(label: "Aktive Teams", value: "156")
                statRow(label: "Durchschnitt", value: "8.2")
            }
            .padding(AppSpacing.md)
            .background(Color(nsColor: .controlBackgroundColor))
        }
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
        .shadow(AppShadow.md)
    }
    
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.body)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text(value)
                .font(.headline)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .monospacedDigit()
        }
    }
    
    private var iconCardExample: some View {
        AppCard(style: .glassmorphism) {
            VStack(spacing: AppSpacing.md) {
                ZStack {
                    Circle()
                        .fill(Color.gradientAccent)
                        .frame(width: 80, height: 80)
                        .shadow(AppShadow.lg)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                }
                
                VStack(spacing: AppSpacing.xxs) {
                    Text("Glassmorphism")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                    Text("Mit Gradient Icon")
                        .font(.caption)
                        .foregroundStyle(Color.appTextSecondary)
                }
            }
        }
    }
    
    private var statsGridCardExample: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Quick Stats")
                    .font(.headline)
                    .foregroundStyle(Color.appTextPrimary)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.xs) {
                    quickStatBox(value: "42", label: "Quiz", color: .appPrimary)
                    quickStatBox(value: "128", label: "Teams", color: .appSecondary)
                    quickStatBox(value: "89%", label: "Rate", color: .appSuccess)
                    quickStatBox(value: "1.5", label: "Ø Platz", color: .appAccent)
                }
            }
        }
    }
    
    private func quickStatBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3)
                .bold()
                .foregroundStyle(color)
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.appTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppSpacing.xs)
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.xs))
    }
    
    // MARK: - Corner Radius
    
    private var cornerRadiusSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Corner Radius System")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                Text("Verschiedene Rundungsgrade für unterschiedliche UI-Elemente")
                    .font(.subheadline)
                    .foregroundStyle(Color.appTextSecondary)
                
                HStack(spacing: AppSpacing.md) {
                    cornerRadiusDemo(label: "xs", radius: AppCornerRadius.xs)
                    cornerRadiusDemo(label: "sm", radius: AppCornerRadius.sm)
                    cornerRadiusDemo(label: "md", radius: AppCornerRadius.md)
                    cornerRadiusDemo(label: "lg", radius: AppCornerRadius.lg)
                    cornerRadiusDemo(label: "xl", radius: AppCornerRadius.xl)
                    cornerRadiusDemo(label: "xxl", radius: AppCornerRadius.xxl)
                }
            }
            .padding(AppSpacing.md)
            .appCard(style: .outlined)
        }
    }
    
    private func cornerRadiusDemo(label: String, radius: CGFloat) -> some View {
        VStack(spacing: AppSpacing.xxs) {
            RoundedRectangle(cornerRadius: radius)
                .fill(Color.gradientPrimary)
                .frame(width: 80, height: 80)
                .shadow(AppShadow.md)
            
            VStack(spacing: 2) {
                Text(label)
                    .font(.caption)
                    .bold()
                    .foregroundStyle(Color.appTextPrimary)
                Text("\(Int(radius))pt")
                    .font(.caption2)
                    .foregroundStyle(Color.appTextSecondary)
                    .monospacedDigit()
            }
        }
    }
    
    // MARK: - SwiftCharts Examples
    
    private var chartsExamplesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("SwiftCharts Beispiele")
                .font(.title2)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
            
            Text("Charts mit Design System Farben & Styles")
                .font(.subheadline)
                .foregroundStyle(Color.appTextSecondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                // Bar Chart Example
                barChartExample
                
                // Line Chart Example
                lineChartExample
                
                // Area Chart Example
                areaChartExample
                
                // Pie Chart Example
                pieChartExample
            }
        }
    }
    
    // MARK: - Sample Data
    
    private struct ChartDataPoint: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let category: String?
    }
    
    private var sampleBarData: [ChartDataPoint] {
        [
            ChartDataPoint(label: "Team A", value: 85, category: nil),
            ChartDataPoint(label: "Team B", value: 72, category: nil),
            ChartDataPoint(label: "Team C", value: 91, category: nil),
            ChartDataPoint(label: "Team D", value: 68, category: nil),
            ChartDataPoint(label: "Team E", value: 95, category: nil)
        ]
    }
    
    private var sampleLineData: [ChartDataPoint] {
        [
            ChartDataPoint(label: "Runde 1", value: 15, category: "Team A"),
            ChartDataPoint(label: "Runde 2", value: 22, category: "Team A"),
            ChartDataPoint(label: "Runde 3", value: 18, category: "Team A"),
            ChartDataPoint(label: "Runde 4", value: 25, category: "Team A"),
            ChartDataPoint(label: "Runde 5", value: 20, category: "Team A"),
            ChartDataPoint(label: "Runde 1", value: 12, category: "Team B"),
            ChartDataPoint(label: "Runde 2", value: 19, category: "Team B"),
            ChartDataPoint(label: "Runde 3", value: 16, category: "Team B"),
            ChartDataPoint(label: "Runde 4", value: 21, category: "Team B"),
            ChartDataPoint(label: "Runde 5", value: 18, category: "Team B")
        ]
    }
    
    // MARK: - Bar Chart Example
    
    private var barChartExample: some View {
        AppCard(style: .glassmorphism) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "chart.bar.fill")
                        .foregroundStyle(Color.appPrimary)
                    Text("Punkteverteilung")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                }
                
                Chart {
                    ForEach(sampleBarData) { dataPoint in
                        BarMark(
                            x: .value("Team", dataPoint.label),
                            y: .value("Punkte", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.appPrimary, Color.appPrimaryLight],
                                startPoint: .bottom,
                                endPoint: .top
                            )
                        )
                        .cornerRadius(AppCornerRadius.xs)
                        .annotation(position: .top, alignment: .center) {
                            Text("\(Int(dataPoint.value))")
                                .font(.caption2)
                                .foregroundStyle(Color.appTextSecondary)
                        }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
            }
        }
    }
    
    // MARK: - Line Chart Example
    
    private var lineChartExample: some View {
        AppCard(style: .elevated) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(Color.appAccent)
                    Text("Performance Trend")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                }
                
                Chart {
                    ForEach(Array(sampleLineData.filter { $0.category == "Team A" }.enumerated()), id: \.element.id) { index, dataPoint in
                        LineMark(
                            x: .value("Runde", dataPoint.label),
                            y: .value("Punkte", dataPoint.value),
                            series: .value("Team", "Team A")
                        )
                        .foregroundStyle(Color.gradientPrimary)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol {
                            Circle()
                                .fill(Color.appPrimary)
                                .frame(width: 8, height: 8)
                                .overlay {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                }
                        }
                        .interpolationMethod(.catmullRom)
                    }
                    
                    ForEach(Array(sampleLineData.filter { $0.category == "Team B" }.enumerated()), id: \.element.id) { index, dataPoint in
                        LineMark(
                            x: .value("Runde", dataPoint.label),
                            y: .value("Punkte", dataPoint.value),
                            series: .value("Team", "Team B")
                        )
                        .foregroundStyle(Color.gradientSecondary)
                        .lineStyle(StrokeStyle(lineWidth: 3))
                        .symbol {
                            Circle()
                                .fill(Color.appSecondary)
                                .frame(width: 8, height: 8)
                                .overlay {
                                    Circle()
                                        .stroke(.white, lineWidth: 2)
                                }
                        }
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                        AxisGridLine()
                            .foregroundStyle(Color.appTextTertiary.opacity(0.3))
                    }
                }
                
                // Legend
                HStack(spacing: AppSpacing.md) {
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.appPrimary)
                            .frame(width: 12, height: 12)
                        Text("Team A")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.appSecondary)
                            .frame(width: 12, height: 12)
                        Text("Team B")
                            .font(.caption)
                            .foregroundStyle(Color.appTextSecondary)
                    }
                }
            }
        }
    }
    
    // MARK: - Area Chart Example
    
    private var areaChartExample: some View {
        AppCard(style: .primary) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "chart.xyaxis.line")
                        .foregroundStyle(.white)
                    Text("Punkte-Entwicklung")
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                
                Chart {
                    ForEach(Array(sampleLineData.filter { $0.category == "Team A" }.enumerated()), id: \.element.id) { index, dataPoint in
                        AreaMark(
                            x: .value("Runde", dataPoint.label),
                            y: .value("Punkte", dataPoint.value)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.6), Color.white.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                        
                        LineMark(
                            x: .value("Runde", dataPoint.label),
                            y: .value("Punkte", dataPoint.value)
                        )
                        .foregroundStyle(.white)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .symbol {
                            Circle()
                                .fill(.white)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel()
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                        AxisGridLine()
                            .foregroundStyle(.white.opacity(0.2))
                    }
                }
            }
        }
    }
    
    // MARK: - Pie Chart Example
    
    private var pieChartExample: some View {
        AppCard {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                HStack {
                    Image(systemName: "chart.pie.fill")
                        .foregroundStyle(Color.appSuccess)
                    Text("Platzierungsverteilung")
                        .font(.headline)
                        .foregroundStyle(Color.appTextPrimary)
                }
                
                HStack(spacing: AppSpacing.lg) {
                    Chart {
                        SectorMark(
                            angle: .value("1. Platz", 12),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.appSecondary)
                        
                        SectorMark(
                            angle: .value("2. Platz", 8),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.appTextSecondary)
                        
                        SectorMark(
                            angle: .value("3. Platz", 5),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.appAccent)
                        
                        SectorMark(
                            angle: .value("Andere", 10),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(Color.appTextTertiary)
                    }
                    .frame(width: 150, height: 150)
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        pieLegendRow(color: Color.appSecondary, label: "1. Platz", value: 12)
                        pieLegendRow(color: Color.appTextSecondary, label: "2. Platz", value: 8)
                        pieLegendRow(color: Color.appAccent, label: "3. Platz", value: 5)
                        pieLegendRow(color: Color.appTextTertiary, label: "Andere", value: 10)
                    }
                }
            }
        }
    }
    
    private func pieLegendRow(color: Color, label: String, value: Int) -> some View {
        HStack(spacing: AppSpacing.xs) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.appTextSecondary)
            Spacer()
            Text("\(value)")
                .font(.caption)
                .bold()
                .foregroundStyle(Color.appTextPrimary)
                .monospacedDigit()
        }
    }
}

#Preview {
    DesignSystemDemoView()
        .frame(width: 1000, height: 800)
}

