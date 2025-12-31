# PubRanker 2.0 Design System - Umsetzungs-Prompt

## 🎯 Ziel
Umsetzung des modernen Design Systems in allen Views der PubRanker App. **Alle Änderungen müssen zu 100% den Design-Vorgaben entsprechen.**

---

## 📋 Design System Übersicht

### Verfügbare Komponenten

#### 1. **Farben** (`AppColors.swift`)
```swift
// Primärfarben (automatisch von Xcode generiert aus Assets.xcassets)
Color.appPrimary        // Braun - Pub Theme (Light: #A0522D, Dark: #CD853F)
Color.appSecondary      // Gold - Bier Theme (Light: #FFD700, Dark: #E5C100)
Color.appAccent         // Orange - Highlight (Light: #F15A24, Dark: #FF7F50)
Color.appSuccess        // Grün - Positiv (Light: #06C14F, Dark: #32CD32)

// Background & Text (automatisch generiert)
Color.appBackground
Color.appBackgroundSecondary
Color.appTextPrimary
Color.appTextSecondary
Color.appTextTertiary

// Light/Dark Varianten (für manuelle Verwendung)
Color.appPrimaryLight / Color.appPrimaryDark
Color.appSecondaryLight / Color.appSecondaryDark
Color.appAccentLight / Color.appAccentDark
Color.appSuccessLight / Color.appSuccessDark

// Gradients
Color.gradientPrimary      // Braun Gradient
Color.gradientSecondary    // Gold Gradient
Color.gradientAccent       // Orange Gradient
Color.gradientSuccess      // Grün Gradient
Color.gradientPubTheme     // Primary zu Secondary
Color.gradientSunset       // Accent Variationen
```

**Verwendungsrichtlinien:**
- ✅ `.appPrimary`: Navigation bars, main buttons, logo
- ✅ `.appSecondary`: Pub cards, progress bars, headers, highlights
- ✅ `.appAccent`: Star ratings, top rank badges, CTA buttons
- ✅ `.appSuccess`: High ratings, favorite badges, positive feedback
- ✅ `.appBackground`: App background, windows
- ✅ `.appTextPrimary`: Main text, labels
- ✅ `.appTextSecondary`: Less prominent text
- ✅ `.appTextTertiary`: Even less prominent text

#### 2. **Spacing** (`AppSpacing.swift`)
```swift
// Base Spacing (4pt Grid System)
AppSpacing.xxxs  // 4pt
AppSpacing.xxs   // 8pt
AppSpacing.xs    // 12pt
AppSpacing.sm    // 16pt
AppSpacing.md    // 20pt (most common)
AppSpacing.lg    // 24pt
AppSpacing.xl    // 32pt
AppSpacing.xxl   // 40pt
AppSpacing.xxxl  // 48pt

// Semantic Spacing
AppSpacing.cardPadding      // 20pt - Card padding inside
AppSpacing.sectionSpacing  // 24pt - Section spacing between groups
AppSpacing.stackSpacing     // 16pt - Stack spacing for VStack/HStack
AppSpacing.listItemSpacing  // 12pt - List item spacing
AppSpacing.buttonPaddingH   // 20pt - Button padding horizontal
AppSpacing.buttonPaddingV   // 12pt - Button padding vertical
AppSpacing.screenPadding    // 24pt - Screen edge padding
```

**Verwendungsrichtlinien:**
- ✅ **VStack/HStack spacing**: `AppSpacing.stackSpacing` (16pt) oder `AppSpacing.md` (20pt)
- ✅ **Card padding**: `AppSpacing.cardPadding` (20pt)
- ✅ **Section spacing**: `AppSpacing.sectionSpacing` (24pt)
- ✅ **Screen edges**: `AppSpacing.screenPadding` (24pt)
- ✅ **List items**: `AppSpacing.listItemSpacing` (12pt)

#### 3. **Shadows** (`AppShadow`)
```swift
AppShadow.none   // No shadow (elevation 0)
AppShadow.sm     // Minimal shadow (elevation 1) - Subtle depth
AppShadow.md     // Small shadow (elevation 2) - Cards, buttons
AppShadow.lg     // Medium shadow (elevation 3) - Raised cards
AppShadow.xl     // Large shadow (elevation 4) - Modals, overlays
AppShadow.xxl    // Extra large shadow (elevation 5) - Floating elements

// Colored Shadows
AppShadow.primary   // Primary colored shadow (brown theme)
AppShadow.secondary // Secondary colored shadow (gold theme)
AppShadow.accent    // Accent colored shadow (orange theme)
AppShadow.success   // Success colored shadow (green theme)
```

**Verwendungsrichtlinien:**
- ✅ **Default Cards**: `AppShadow.sm` oder `AppShadow.md`
- ✅ **Elevated Cards**: `AppShadow.lg`
- ✅ **Buttons**: `AppShadow.md` oder colored shadows
- ✅ **Modals/Overlays**: `AppShadow.xl`
- ✅ **Floating Elements**: `AppShadow.xxl`

#### 4. **Corner Radius** (`AppCornerRadius`)
```swift
AppCornerRadius.xs     // 4pt - Minimal rounding
AppCornerRadius.sm     // 8pt - Small rounding
AppCornerRadius.md     // 12pt - Medium rounding (most common for cards)
AppCornerRadius.lg     // 16pt - Large rounding
AppCornerRadius.xl     // 20pt - Extra large rounding
AppCornerRadius.xxl    // 24pt - Maximum rounding
AppCornerRadius.circle // .infinity - Circle
```

**Verwendungsrichtlinien:**
- ✅ **Cards**: `AppCornerRadius.md` (12pt)
- ✅ **Buttons**: `AppCornerRadius.md` (12pt)
- ✅ **Small elements**: `AppCornerRadius.sm` (8pt)
- ✅ **Large elements**: `AppCornerRadius.lg` (16pt)

#### 5. **Cards** (`AppCard`)
```swift
// Card Styles
AppCard(style: .default)              // Standard Card mit Background
AppCard(style: .glassmorphism)       // Frosted Glass Effekt
AppCard(style: .elevated)             // Erhöhte Card mit größerem Shadow
AppCard(style: .outlined)            // Nur Umrandung
AppCard(style: .primary)             // Primary Gradient Card
AppCard(style: .secondary)           // Secondary Gradient Card
AppCard(style: .accent)              // Accent Gradient Card
AppCard(style: .gradient(custom))    // Custom Gradient

// View Extension
VStack { ... }
    .appCard(style: .glassmorphism, padding: AppSpacing.md, cornerRadius: AppCornerRadius.md)
```

**Verwendungsrichtlinien:**
- ✅ **Standard Cards**: `.default` oder `.glassmorphism`
- ✅ **Important Cards**: `.elevated` oder `.primary`
- ✅ **Outlined Cards**: `.outlined` für subtile Hervorhebung
- ✅ **Gradient Cards**: `.primary`, `.secondary`, `.accent` für wichtige Elemente

#### 6. **Buttons** (`AppButton`)
```swift
// Gradient Button Styles
Button("Action") { }
    .primaryGradientButton()        // Primary Theme (Braun)
    .secondaryGradientButton()      // Secondary Theme (Gold)
    .accentGradientButton()         // Accent Theme (Orange)
    .successGradientButton()        // Success Theme (Grün)
    .gradientButton(gradient: custom) // Custom Gradient

// Button Sizes
.primaryGradientButton(size: .small)   // Small button
.primaryGradientButton(size: .medium) // Medium button (default)
.primaryGradientButton(size: .large)   // Large button
```

**Verwendungsrichtlinien:**
- ✅ **Primary Actions**: `.primaryGradientButton()`
- ✅ **Secondary Actions**: `.secondaryGradientButton()`
- ✅ **CTA/Highlight**: `.accentGradientButton()`
- ✅ **Success/Positive**: `.successGradientButton()`
- ✅ **Standard Buttons**: `.buttonStyle(.bordered)` für weniger wichtige Aktionen

---

## 🎨 Design-Prinzipien

### Visuals
- **Glassmorphism**: Frosted glass Effekte für Cards und Overlays (`.glassmorphism` Style)
- **Material Design**: `.ultraThinMaterial` für Glassmorphism Cards
- **Gradients**: Für wichtige Elemente und Buttons (Primary, Secondary, Accent)
- **Shadows**: Konsistentes Shadow-System (elevation-based)

### Colors
- **Dynamische Akzentfarben**: macOS adaptive (automatisch Light/Dark Mode)
- **Dark Mode optimiert**: Alle Color Assets unterstützen Light/Dark Mode
- **Subtile Farbverläufe**: Für wichtige Elemente
- **Color Theming System**: Konsistente Verwendung der Theme-Farben

### Typography
- **SF Pro Display**: Für Headlines (system font)
- **Klare Text-Hierarchie**: 
  - `.title`, `.title2`, `.title3` für Headlines
  - `.headline` für wichtige Labels
  - `.body` für Standard-Text
  - `.caption`, `.caption2` für sekundäre Informationen
- **Monospaced Digits**: Für Zahlen (`.monospacedDigit()`)

### Interaction
- **Spring Animations**: Für Button-Interaktionen (bereits in Button Styles)
- **Smooth Transitions**: Für View-Wechsel
- **Hover States**: Für interaktive Elemente

---

## 📝 Umsetzungs-Checkliste

### Vor jeder Änderung:
- [ ] Design-System-Komponenten importieren: `import` nicht nötig (global verfügbar)
- [ ] Prüfen: Welche Komponenten werden verwendet?
- [ ] Prüfen: Welche Farben passen zum Kontext?
- [ ] Prüfen: Welche Spacing-Werte sind angemessen?
- [ ] Prüfen: Welcher Card-Style passt?
- [ ] Prüfen: Welcher Button-Style passt?

### Während der Umsetzung:
- [ ] **Farben**: Nur Design-System-Farben verwenden (keine hardcoded Colors)
- [ ] **Spacing**: Nur `AppSpacing`-Werte verwenden (keine Magic Numbers)
- [ ] **Shadows**: Nur `AppShadow`-Werte verwenden
- [ ] **Corner Radius**: Nur `AppCornerRadius`-Werte verwenden
- [ ] **Cards**: `AppCard` oder `.appCard()` Extension verwenden
- [ ] **Buttons**: Gradient-Button-Styles verwenden für primäre Aktionen
- [ ] **Text Colors**: `.appTextPrimary`, `.appTextSecondary`, `.appTextTertiary` verwenden

### Nach der Umsetzung:
- [ ] Dark Mode testen (alle Farben müssen funktionieren)
- [ ] Spacing konsistent prüfen
- [ ] Shadows konsistent prüfen
- [ ] Corner Radius konsistent prüfen
- [ ] Alle Buttons verwenden Design-System-Styles
- [ ] Alle Cards verwenden Design-System-Styles

---

## 🔄 Migration von altem Code

### Alte Patterns → Neue Patterns

```swift
// ❌ ALT
.padding(16)
.padding(.horizontal, 20)
.padding(.vertical, 12)

// ✅ NEU
.padding(AppSpacing.sm)
.padding(.horizontal, AppSpacing.md)
.padding(.vertical, AppSpacing.xs)
```

```swift
// ❌ ALT
.background(Color(nsColor: .controlBackgroundColor))
.clipShape(RoundedRectangle(cornerRadius: 12))
.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

// ✅ NEU
.appCard(style: .default)
// oder
AppCard(style: .glassmorphism) {
    // Content
}
```

```swift
// ❌ ALT
Button("Action") { }
    .buttonStyle(.borderedProminent)
    .tint(.blue)

// ✅ NEU
Button("Action") { }
    .primaryGradientButton()
// oder für Secondary/Accent/Success
```

```swift
// ❌ ALT
.foregroundStyle(.blue)
.foregroundStyle(.secondary)
.foregroundStyle(Color.gray)

// ✅ NEU
.foregroundStyle(Color.appPrimary)
.foregroundStyle(Color.appTextSecondary)
.foregroundStyle(Color.appTextTertiary)
```

```swift
// ❌ ALT
.shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
.shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)

// ✅ NEU
.shadow(AppShadow.md)
.shadow(AppShadow.lg)
```

```swift
// ❌ ALT
.clipShape(RoundedRectangle(cornerRadius: 12))
.clipShape(RoundedRectangle(cornerRadius: 8))

// ✅ NEU
.clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.md))
.clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.sm))
```

---

## 📊 SwiftCharts Integration

### Design-System-Farben in Charts verwenden:

```swift
Chart {
    ForEach(data) { item in
        BarMark(x: .value("Label", item.label), y: .value("Value", item.value))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.appPrimary, Color.appPrimaryLight],
                    startPoint: .bottom,
                    endPoint: .top
                )
            )
            .cornerRadius(AppCornerRadius.xs)
    }
}
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
```

**Chart Card Wrapper:**
```swift
AppCard(style: .glassmorphism) {
    // Chart hier
}
```

---

## 🎯 Beispiel: Komplette View-Modernisierung

### Vorher (Alt):
```swift
VStack(spacing: 16) {
    Text("Titel")
        .font(.title)
        .foregroundStyle(.primary)
    
    HStack(spacing: 12) {
        Button("Aktion") { }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
    }
    .padding()
    .background(Color(nsColor: .controlBackgroundColor))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
}
.padding(20)
```

### Nachher (Neu mit Design System):
```swift
VStack(spacing: AppSpacing.stackSpacing) {
    Text("Titel")
        .font(.title)
        .foregroundStyle(Color.appTextPrimary)
    
    HStack(spacing: AppSpacing.sm) {
        Button("Aktion") { }
            .primaryGradientButton()
    }
    .appCard(style: .glassmorphism)
}
.padding(AppSpacing.screenPadding)
```

---

## ⚠️ WICHTIGE REGELN

1. **KEINE Magic Numbers**: Alle Spacing-, Shadow- und Corner-Radius-Werte müssen aus dem Design System kommen
2. **KEINE hardcoded Colors**: Alle Farben müssen aus `AppColors` kommen
3. **KONSISTENZ**: Gleiche Elemente müssen immer gleich aussehen
4. **DARK MODE**: Alle Komponenten müssen in Light und Dark Mode funktionieren
5. **DESIGN SYSTEM FIRST**: Immer zuerst prüfen, ob eine Design-System-Komponente existiert, bevor man selbst etwas baut

---

## 📚 Referenz-Dateien

- `PubRanker/DesignSystem/AppColors.swift` - Alle Farben und Gradients
- `PubRanker/DesignSystem/AppSpacing.swift` - Spacing, Shadows, Corner Radius
- `PubRanker/DesignSystem/AppCard.swift` - Card-Komponenten
- `PubRanker/DesignSystem/AppButton.swift` - Button-Styles
- `PubRanker/Views/DesignSystemDemoView.swift` - Live-Beispiele aller Komponenten

---

## 🚀 Start-Prompt für AI-Assistenten

**Verwende diesen Prompt, wenn du Views modernisieren möchtest:**

```
Ich möchte die View [VIEW_NAME] mit dem PubRanker 2.0 Design System modernisieren.

Bitte:
1. Ersetze alle hardcoded Spacing-Werte durch AppSpacing-Werte
2. Ersetze alle hardcoded Colors durch AppColors (appPrimary, appSecondary, appAccent, appSuccess, appTextPrimary, etc.)
3. Ersetze alle manuellen Card-Styles durch AppCard-Komponenten
4. Ersetze alle primären Buttons durch Gradient-Button-Styles (.primaryGradientButton, etc.)
5. Ersetze alle hardcoded Shadows durch AppShadow-Werte
6. Ersetze alle hardcoded Corner Radius durch AppCornerRadius-Werte
7. Stelle sicher, dass alles in Light und Dark Mode funktioniert
8. Verwende die Design-System-Komponenten konsistent

Die View-Datei ist: [PATH_TO_VIEW]

Bitte zeige mir die komplette modernisierte Version.
```

---

**Version**: 2.0  
**Erstellt**: 30.11.2025  
**Status**: Ready for Implementation






