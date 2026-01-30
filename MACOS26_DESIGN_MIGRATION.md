# macOS 26 (Tahoe) Design Migration

Diese Datei enthält alle Aufgaben für die Migration zum neuen macOS 26 "Liquid Glass" Design.

**Voraussetzung:** Xcode 26+ und Deployment Target macOS 26.0 / iOS 26.0

---

## Neue APIs in macOS 26 / iOS 26

### Glass Effect
- `.glassEffect()` - Fügt den charakteristischen Glas-Effekt hinzu
- `.glassEffect(.regular)` / `.glassEffect(.prominent)` - Verschiedene Intensitäten
- `.glassEffectUnpadded()` - Ohne automatisches Padding

### Weitere neue Modifier
- `.presentationSizing(.fitted)` - Sheets passen sich dem Inhalt an
- `.windowStyle(.plain)` - Fenster ohne Chrome
- `.containerBackground()` - Hintergrund für Container

---

## Migration Tasks

### Phase 1: Buttons & Controls

- [x] **PlanningSidebarView.swift** - Quiz Action Buttons mit `.glassEffect()`
  - ✅ Zeile ~130-175: `quizActionButtons(for:)` Funktion
  - ✅ Aktuell: `.successGradientButton()`, `.primaryGradientButton()`, `.destructiveGradientButton()`
  - ✅ Neu: Custom Buttons mit `.glassEffect()`

- [x] **AppButton.swift** - Neue Button-Styles mit Glass Effect
  - ✅ `glassButton()` Modifier erstellt (AppGlassEffect.swift)
  - ✅ Varianten: primary, secondary, destructive, success, accent

- [x] **CompactQuizHeader.swift** - Action Buttons (falls wieder aktiviert)
  - ✅ Zeile ~117-250: `actionButtons` Property aktualisiert

### Phase 2: Cards & Container

- [x] **AppCard.swift** - Glass Card Style hinzufügen
  - ✅ Neuer Style: `.glass` und `.glassProminent` neben `.glassmorphism`
  - ✅ Verwendet `.glassEffect()` statt manueller Blur-Effekte

- [x] **OverviewComponents.swift** - Statistik-Cards
  - ✅ `QuickStatsGrid`, `StatusCardsSection` - alle auf `.glass` umgestellt

- [x] **LeaderboardView.swift** - Podium und Team-Karten
  - ✅ Geprüft (keine Änderungen erforderlich)

- [x] **TeamManagementView.swift** - Team-Karten
  - ✅ 10 Buttons und 4 Cards aktualisiert

### Phase 3: Navigation & Sidebar

- [x] **PlanningSidebarView.swift** - Sidebar Background
  - ✅ `.background(.ultraThinMaterial)` → `.glassEffect()`

- [x] **SidebarView.swift** (GlobalTeamsManager) - Sidebar Design
  - ✅ Alle 4 Buttons auf Glass umgestellt

- [x] **ContentView.swift** - Haupt-Navigation
  - ✅ Geprüft (keine Änderungen erforderlich)

### Phase 4: Sheets & Modals

- [x] **EditQuizSheet.swift** - Sheet mit Glass Background
- [x] **NewQuizSheet** (in QuizListView.swift) - Wizard mit Glass Design (12 Buttons)
- [x] **TeamSetupWizard.swift** - Team Wizard (6 Buttons)
- [x] **EmailComposerView.swift** - E-Mail Sheet (2 Buttons)

### Phase 5: Spezielle Views

- [x] **PresentationModeView.swift** - Präsentationsmodus (keine Änderungen)
- [x] **LeaderboardImageGenerator.swift** - Export-Ansicht (keine Änderungen)
- [x] **ExecutionView.swift** - Quiz-Durchführung (26 Buttons, 1 Card)

---

## Implementierungs-Strategie

### Option A: Availability Check (Empfohlen für schrittweise Migration)

```swift
struct GlassEffectModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 26.0, iOS 26.0, *) {
            content.glassEffect()
        } else {
            content // Fallback für ältere Versionen
        }
    }
}

extension View {
    func adaptiveGlassEffect() -> some View {
        modifier(GlassEffectModifier())
    }
}
```

### Option B: Deployment Target erhöhen

Wenn nur macOS 26+ unterstützt werden soll:
1. Project Settings → Deployment Target → macOS 26.0
2. Direkt `.glassEffect()` verwenden ohne Availability Check

---

## Design Guidelines für Liquid Glass

### Farben
- Primärfarben bleiben gleich, werden aber durch Glass-Effekt gefiltert
- Weniger Opacity-Werte nötig (Glass macht das automatisch)
- Hintergründe sollten durchscheinen

### Abstände
- Glass-Effekt hat eingebautes Padding
- `.glassEffectUnpadded()` für manuelles Padding

### Schatten
- Weniger manuelle Schatten nötig
- Glass-Effekt hat eingebaute Tiefe

### Best Practices
- Nicht zu viele Glass-Elemente übereinander
- Kontrast für Text sicherstellen
- Accessibility beachten (Reduce Transparency)

---

## Referenzen

- [WWDC 2025: What's new in SwiftUI](https://developer.apple.com/videos/play/wwdc2025/...)
- [Human Interface Guidelines - Materials](https://developer.apple.com/design/human-interface-guidelines/materials)
- [SwiftUI Glass Effect Documentation](https://developer.apple.com/documentation/swiftui/view/glasseffect())

---

## Notizen

- Erstellt: 2026-01-28
- **Status: ✅ ABGESCHLOSSEN** (2026-01-28)
- Aktuelles Deployment Target: macOS 14.0 / iOS 17.0
- Implementierung: Mock-Implementierung mit Vorbereitung für macOS 26 APIs

## Migration Log

### 2026-01-28: Vollständige Migration durchgeführt

**✅ Alle 5 Phasen abgeschlossen:**

1. **Phase 1: Buttons & Controls**
   - ✅ PlanningSidebarView.swift - Alle Buttons auf Glass Design umgestellt
   - ✅ CompactQuizHeader.swift - Action Buttons aktualisiert
   - ✅ AppGlassEffect.swift - Neue Mock-Implementierung erstellt

2. **Phase 2: Cards & Container**
   - ✅ AppCard.swift - Neue `.glass` und `.glassProminent` Styles hinzugefügt
   - ✅ OverviewComponents.swift - Alle Cards auf Glass Style umgestellt
   - ✅ TeamManagementView.swift - Cards und Buttons aktualisiert
   - ✅ LeaderboardView.swift - Geprüft (keine Änderungen erforderlich)

3. **Phase 3: Navigation & Sidebar**
   - ✅ PlanningSidebarView.swift - Sidebar Background auf Glass Effect umgestellt
   - ✅ SidebarView.swift (GlobalTeamsManager) - Alle Buttons aktualisiert
   - ✅ ContentView.swift - Geprüft (keine Änderungen erforderlich)

4. **Phase 4: Sheets & Modals**
   - ✅ EditQuizSheet.swift - Buttons aktualisiert
   - ✅ QuizListView.swift (NewQuizSheet) - Alle Buttons auf Glass umgestellt
   - ✅ TeamSetupWizard.swift - Vollständig migriert
   - ✅ EmailComposerView.swift - Buttons aktualisiert

5. **Phase 5: Spezielle Views + Zusätzliche Komponenten**
   - ✅ ExecutionView.swift - Alle 26 Buttons und Cards aktualisiert
   - ✅ ScoreEntryView.swift - Buttons und Cards migriert
   - ✅ RoundManagementView.swift - Vollständig aktualisiert
   - ✅ Analysis/AnalysisView.swift - Migriert
   - ✅ GlobalTeamsManager (alle Views) - Vollständig umgestellt
   - ✅ Weitere 15+ Views aktualisiert

**Statistik:**
- Neue Dateien: 1 (AppGlassEffect.swift)
- Aktualisierte Dateien: 40+
- Button-Migrationen: 150+ Buttons von Gradient → Glass
- Card-Migrationen: 30+ Cards auf Glass Style umgestellt
- Keine Linter-Fehler

**Technische Details:**
- Mock-Implementation der `.glassEffect()` API erstellt
- Beide Button-Styles (Gradient & Glass) parallel verfügbar
- DesignSystemDemoView zeigt weiterhin beide Varianten
- Bereit für nahtlosen Wechsel zu echten macOS 26 APIs
