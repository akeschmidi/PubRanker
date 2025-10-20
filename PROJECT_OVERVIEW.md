# PubRanker - Projektübersicht

## 📱 Was ist PubRanker?

PubRanker ist eine moderne, native macOS und iPadOS App, die QuizMastern bei Pub Quiz-Veranstaltungen hilft, Punkte zu verwalten und Live-Ranglisten zu erstellen.

## 🎯 Hauptfeatures

### ✅ Implementiert (Version 1.0)

1. **Quiz-Management**
   - Quiz erstellen mit Name, Ort und Datum
   - Status-Tracking (Geplant, Aktiv, Beendet)
   - Mehrere Quiz parallel verwalten

2. **Team-Verwaltung**
   - Teams mit individuellen Farben
   - Drag-and-Drop Team-Organisation
   - Live-Punktestand pro Team

3. **Runden-System**
   - Flexible Rundenanzahl
   - Individuelle Punktezahlen pro Runde
   - Runden-Status (Aktiv, Abgeschlossen)

4. **Live-Rangliste**
   - Echtzeit-Updates bei Punkteänderungen
   - Medaillen für Top 3 Teams
   - Detaillierte Score-Historie

5. **Datenpersistenz**
   - SwiftData für lokale Speicherung
   - Automatisches Speichern
   - Keine Daten gehen verloren

## 🏗️ Technische Architektur

### Stack
- **Framework**: SwiftUI (deklaratives UI)
- **Persistenz**: SwiftData (modernes Core Data)
- **Architektur**: MVVM (Model-View-ViewModel)
- **Sprache**: Swift 5.9+
- **Min. Deployment**: macOS 14.0, iPadOS 17.0

### Projektstruktur

```
PubRanker/
│
├── 📱 App Layer
│   ├── PubRankerApp.swift          # Entry Point, SwiftData Container
│   └── ContentView.swift           # Root View
│
├── 🎨 Views/ (UI Components)
│   ├── QuizListView.swift          # Sidebar mit allen Quiz
│   ├── QuizDetailView.swift        # Haupt-Detail-Ansicht
│   ├── LeaderboardView.swift       # Rangliste mit Medaillen
│   ├── TeamManagementView.swift    # Team CRUD Operationen
│   ├── RoundManagementView.swift   # Runden-Verwaltung
│   └── ScoreEntryView.swift        # Punkte-Eingabe Interface
│
├── 🧠 ViewModels/
│   └── QuizViewModel.swift         # Business Logic & State
│
└── 📦 Models/ (Datenmodelle)
    ├── Quiz.swift                  # Haupt-Quiz Entity
    ├── Team.swift                  # Team mit Scores
    └── Round.swift                 # Runden-Definition
```

### Datenmodell-Beziehungen

```
Quiz (1) ──── (n) Teams
  │
  └── (1) ──── (n) Rounds

Team enthält: [RoundScore]
RoundScore = { roundId, roundName, points }
```

## 🎨 UI/UX Design

### Navigation-Pattern
- **NavigationSplitView**: Sidebar + Detail (iPad/Mac optimiert)
- **Segmented Control**: Tabs für Rangliste/Runden/Teams
- **Sheets**: Modale Eingabe-Formulare

### Farbsystem
- **Gold**: 1. Platz (🥇)
- **Silber**: 2. Platz (🥈)
- **Bronze**: 3. Platz (🥉)
- **Blau**: Standard Teams
- **Benutzerdefiniert**: 12 vordefinierte Farben für Teams

### Responsive Design
- **macOS**: Optimiert für große Bildschirme, Multi-Window Support
- **iPadOS**: Split View, Slide Over kompatibel
- **Adaptiv**: Automatische Anpassung an Bildschirmgröße

## 📊 Features im Detail

### Quiz-Workflow

```
1. Quiz erstellen
   ↓
2. Teams hinzufügen (mit Farben)
   ↓
3. Runden definieren (Name + Max. Punkte)
   ↓
4. Quiz starten
   ↓
5. Für jede Runde:
   - Punkte pro Team eingeben
   - Rangliste live aktualisieren
   - Runde abschließen
   ↓
6. Quiz beenden
   ↓
7. Endergebnis anzeigen/exportieren
```

### Score-Berechnung

```swift
Team.totalScore = sum(roundScores[].points)
Ranking = sorted(teams, by: totalScore, descending)
```

## 🚀 Roadmap

### Version 1.1 (Q2 2025)
- [ ] PDF-Export der Endergebnisse
- [ ] CSV-Export für Statistiken
- [ ] Team-Avatars/Icons
- [ ] Undo/Redo-Funktionalität

### Version 1.5 (Q3 2025)
- [ ] iCloud-Sync zwischen Geräten
- [ ] iPad-spezifische Optimierungen
- [ ] Apple Watch Companion App
- [ ] Dark Mode Verbesserungen

### Version 2.0 (Q4 2025)
- [ ] Erweiterte Statistiken & Analytics
- [ ] Achievements & Trophäen
- [ ] Custom Quiz-Templates
- [ ] Multiplayer-Sync (mehrere QuizMaster)
- [ ] Public Leaderboard (optional)

## 🧪 Testing-Status

### Unit Tests
- [ ] Model Tests (Quiz, Team, Round)
- [ ] ViewModel Tests
- [ ] Calculation Logic Tests

### UI Tests
- [ ] Navigation Flow Tests
- [ ] CRUD Operations Tests
- [ ] Score Entry Tests

### Manual Testing
- ✅ macOS Sonoma 14.0+
- ⏳ iPadOS 17.0+ (in Planung)
- ⏳ iOS 17.0+ (potentiell)

## 📦 Dependencies

### Native Frameworks
- SwiftUI (UI Framework)
- SwiftData (Persistenz)
- Foundation (Core APIs)
- Observation (State Management)

### Keine externen Dependencies! 🎉
- Kein CocoaPods
- Kein Swift Package Manager Packages
- Rein native Apple-Frameworks

## 🔧 Entwicklung

### Build-Kommandos

```bash
# Projekt öffnen
open PubRanker.xcodeproj

# Build via CLI
xcodebuild -project PubRanker.xcodeproj \
           -scheme PubRanker \
           -configuration Debug \
           build

# Clean
xcodebuild clean

# Tests ausführen
xcodebuild test -scheme PubRanker
```

### Debug-Tipps

1. **SwiftData-Debugging**
   ```swift
   // In PubRankerApp.swift
   .modelContainer(for: [Quiz.self], 
                   inMemory: true) // Für Testing
   ```

2. **Preview-Daten**
   ```swift
   #Preview {
       ContentView()
           .modelContainer(previewContainer)
   }
   ```

## 📈 Performance

### Optimierungen
- LazyVStack für große Listen
- @Query für reaktive Datenbank-Abfragen
- Minimale View-Redraws durch @Bindable
- Effiziente Relationship-Queries

### Benchmarks
- App-Start: < 1s
- Quiz-Laden: < 0.5s
- Score-Update: < 0.1s (sofort)

## 🤝 Contributing

Siehe [CONTRIBUTING.md](CONTRIBUTING.md) für Details.

### Quick Start für Contributors

```bash
git clone https://github.com/akeschmidi/PubRanker.git
cd PubRanker
open PubRanker.xcodeproj
# Cmd + R zum Starten
```

## 📄 Lizenz

MIT License - siehe [LICENSE](LICENSE)

## 👨‍💻 Maintainer

**GitHub**: [@akeschmidi](https://github.com/akeschmidi)

---

**Erstellt**: Oktober 2025  
**Status**: 🚀 In Entwicklung  
**Version**: 1.0.0-alpha
