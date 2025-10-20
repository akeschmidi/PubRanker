# PubRanker Setup-Anleitung

## Projekt öffnen

1. **Xcode öffnen**
   ```bash
   open PubRanker.xcodeproj
   ```

2. **Projekt bauen**
   - In Xcode: `Cmd + B`
   - Oder über Terminal:
     ```bash
     xcodebuild -project PubRanker.xcodeproj -scheme PubRanker build
     ```

3. **App ausführen**
   - In Xcode: `Cmd + R`
   - Wählen Sie als Target entweder "My Mac" oder einen iOS-Simulator

## Projektstruktur

```
PubRanker/
├── PubRankerApp.swift          # App Entry Point mit SwiftData Container
├── ContentView.swift           # Haupt-View, lädt QuizListView
│
├── Models/
│   ├── Quiz.swift             # Quiz-Datenmodell mit Teams & Runden
│   ├── Team.swift             # Team-Datenmodell mit Scores
│   └── Round.swift            # Runden-Datenmodell
│
├── ViewModels/
│   └── QuizViewModel.swift    # Business Logic für Quiz-Management
│
└── Views/
    ├── QuizListView.swift     # Übersicht aller Quiz
    ├── QuizDetailView.swift   # Detail-Ansicht eines Quiz
    ├── LeaderboardView.swift  # Rangliste der Teams
    ├── TeamManagementView.swift    # Teams verwalten
    ├── RoundManagementView.swift   # Runden verwalten
    └── ScoreEntryView.swift        # Punkte eingeben
```

## Features

### Implementiert
✅ Quiz erstellen und verwalten
✅ Teams hinzufügen mit Farben
✅ Runden erstellen und verwalten
✅ Punkte pro Runde vergeben
✅ Automatische Ranglisten-Berechnung
✅ Quiz-Status (Geplant, Aktiv, Beendet)
✅ SwiftData-Persistenz
✅ macOS und iPadOS Support

### Nächste Schritte
- [ ] App Icons & Branding hinzufügen
- [ ] Export-Funktionen (PDF, CSV)
- [ ] iCloud-Sync implementieren
- [ ] Dark Mode optimieren
- [ ] iPad-spezifische Layouts
- [ ] Statistiken & Analysen
- [ ] Undo/Redo-Funktionalität

## Entwicklung

### Requirements
- macOS Sonoma 14.0+
- Xcode 15.0+
- Swift 5.9+

### Build-Konfigurationen
- **Debug**: Entwicklung mit vollständigem Debug-Info
- **Release**: Optimierte Produktion-Version

### Bundle Identifier
`com.akeschmidi.PubRanker`

## Architektur

### SwiftData Models
Die App verwendet SwiftData für die Datenpersistenz:
- `@Model` Makros für Quiz, Team, Round
- Automatische Relationship-Verwaltung
- Cascade Delete für abhängige Objekte

### MVVM Pattern
- **Models**: Datenmodelle mit SwiftData
- **Views**: SwiftUI-Views für UI
- **ViewModels**: Business Logic und State Management

### Navigation
- `NavigationSplitView` für Sidebar + Detail
- Tab-basierte Navigation im Detail-View
- Sheets für Eingabe-Formulare

## Troubleshooting

### Xcode öffnet nicht
```bash
xed /Users/stefanschwinghammer/work/PubRanker
```

### Build-Fehler
1. Clean Build Folder: `Cmd + Shift + K`
2. Derived Data löschen:
   ```bash
   rm -rf ~/Library/Developer/Xcode/DerivedData
   ```

### SwiftData-Fehler
Falls Datenbank-Probleme auftreten:
- App deinstallieren
- Container-Verzeichnis löschen
- Neu bauen und starten

## Git-Befehle

```bash
# Initial Commit
git add .
git commit -m "Initial PubRanker implementation with SwiftUI and SwiftData"

# Zu GitHub pushen
git remote add origin https://github.com/akeschmidi/PubRanker.git
git branch -M main
git push -u origin main
```

## Lizenz

MIT License - siehe LICENSE Datei
