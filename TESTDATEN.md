# Testdaten für PubRanker

## Übersicht

Das Projekt enthält jetzt ein umfassendes Testdaten-System, mit dem du realistische PubQuiz-Szenarien für Tests und Entwicklung erstellen kannst.

## Verwendung

### 1. Debug-Menü öffnen

In **DEBUG-Builds** erscheint oben rechts in der App ein Käfer-Symbol (🐞) neben dem Hilfe-Button. Klicke darauf, um das Debug-Menü zu öffnen.

### 2. Testdaten laden

Das Debug-Menü bietet drei Optionen:

#### Quick Demo
- **Was wird geladen**: 1 aktives Quiz mit 24 Teams und 8 Runden
- **Status**: 4 Runden bereits abgeschlossen, 4 noch offen
- **Verwendung**: Perfekt zum schnellen Testen der Durchführungs- und Auswertungsfunktionen

#### Vollständiges Demo
- **Was wird geladen**: 7 verschiedene Quizze
  - 1 aktives Quiz (Winterquiz 2024) - 24 Teams
  - 1 abgeschlossenes Quiz (Oktoberquiz 2024) - 10 Teams
  - 5 geplante Quizze in verschiedenen Planungsstadien:
    - Valentinsquiz 2025 (in 2 Monaten) - 18 bestätigte Teams
    - Frühlingsquiz 2025 (in 3 Monaten) - 8 bestätigte Teams
    - Osterquiz 2025 (in 4 Monaten) - 5 bestätigte Teams
    - Sommerquiz 2025 (in 6 Monaten) - 3 bestätigte Teams
    - Herbstquiz 2025 (in 9 Monaten) - noch keine Teams
- **Verwendung**: Ideal zum Testen aller App-Bereiche, Planungsfunktionen und verschiedener Quiz-Stati

#### Nur Globale Teams
- **Was wird geladen**: 35 Teams ohne Quiz-Zuordnung
- **Verwendung**: Zum Testen der globalen Team-Verwaltung

### 3. Daten löschen

Die Option "Alle Daten löschen" entfernt alle Quizze und Teams aus der Datenbank.

## Realistische Testdaten

### Team-Namen
Die Testdaten verwenden 35 kreative, authentische PubQuiz-Team-Namen wie:
- "Quiz in My Pants"
- "The Quizzard of Oz"
- "Let's Get Quizzical"
- "Agatha Quiztie"
- "E=MC Hammered"
- "Sherlock Homies"
- "Les Quizerables"
- "Trivia Newton John"
- "Netflix and Skill"
- "Ctrl Alt Elite"
- "Quiz Khalifa"
- ... und 24 weitere!

### Runden-Kategorien
- Allgemeinwissen (10 Punkte)
- Musik & Charts (10 Punkte)
- Film & TV (10 Punkte)
- Bilderrunde (15 Punkte)
- Sport & Spiele (10 Punkte)
- Geschichte (10 Punkte)
- Soundrunde (15 Punkte)
- Jokerrunde (20 Punkte)

### Score-Generierung
Die Scores werden intelligent generiert mit:
- **Verschiedene Team-Archetypen**: Excellent, Good, Average, Struggling, Wildcard
- **Realistische Variation**: Unterschiedliche Performance je nach Rundentyp
- **Spannende Ranglisten**: Enge Rennen und klare Führungen

## Für Entwickler

### Testdaten programmatisch erstellen

```swift
import SwiftData

// Quick Demo
let quiz = SampleData.setupQuickDemo(in: modelContext)

// Vollständiges Demo
SampleData.setupFullDemo(in: modelContext)

// Nur Teams
let teams = SampleData.createGlobalTeams(in: modelContext)

// Eigenes Quiz erstellen
let customQuiz = SampleData.createSampleQuiz(in: modelContext)
```

### Preview Container

Für SwiftUI Previews steht ein vorkonfigurierter Container zur Verfügung:

```swift
#Preview {
    MyView()
        .modelContainer(SampleData.previewContainer)
}
```

## Dateien

- `PubRanker/Helpers/SampleData.swift` - Testdaten-Generator
- `PubRanker/Views/DebugDataView.swift` - Debug-Menü UI

## Hinweise

- Das Debug-Menü ist **nur in DEBUG-Builds** sichtbar
- In Release-Builds wird das Käfer-Symbol nicht angezeigt
- Testdaten können beliebig oft geladen werden
- Beim erneuten Laden werden die alten Daten nicht automatisch gelöscht
