# PubRanker 🎯

Eine moderne macOS und iPadOS App für QuizMaster, um Punkte bei Pub Quiz-Veranstaltungen zu verwalten und Ranglisten zu erstellen.

## Status

![Build & Test](https://github.com/akeschmidi/PubRanker/actions/workflows/build.yml/badge.svg)
![SwiftLint](https://github.com/akeschmidi/PubRanker/actions/workflows/swiftlint.yml/badge.svg)
![Release](https://github.com/akeschmidi/PubRanker/actions/workflows/release.yml/badge.svg)
![Platform](https://img.shields.io/badge/platform-macOS-blue)
![Swift](https://img.shields.io/badge/swift-5.9-orange)
![License](https://img.shields.io/github/license/akeschmidi/PubRanker)

## Überblick

PubRanker hilft QuizMastern dabei, Pub Quiz-Veranstaltungen effizient zu organisieren:
- **Punkteverwaltung**: Erfassen Sie Punkte für jede Runde und jedes Team
- **Automatische Ranglisten**: Echtzeit-Updates der Teamrankings
- **Mehrere Runden**: Unterstützung für Quiz mit mehreren Runden
- **Team-Management**: Einfaches Hinzufügen und Verwalten von Teams
- **Übersichtliche Darstellung**: Klare Visualisierung der aktuellen Standings

## Features

### Kernfunktionen
- ✅ Team-Verwaltung (Hinzufügen, Bearbeiten, Löschen)
- ✅ Runden-basierte Punktevergabe
- ✅ Automatische Ranglistenberechnung
- ✅ Live-Aktualisierung der Rankings
- ✅ Historie der Punktestände
- ✅ Export der Ergebnisse
- ✅ **iCloud Backup & Sync** - Automatische Synchronisation über alle Geräte

### Geplante Features
- 🎨 Customizable Themes
- 📊 Statistiken und Analysen
- 🏆 Achievements und Trophäen
- 📤 PDF-Export der Endergebnisse

## Technologie-Stack

- **Framework**: SwiftUI
- **Plattformen**: macOS 14.0+, iPadOS 17.0+
- **Sprache**: Swift 5.9+
- **Datenpersistenz**: SwiftData mit iCloud CloudKit Sync
- **UI-Framework**: SwiftUI mit modernem Design
- **Cloud**: iCloud CloudKit für automatisches Backup

## Installation

### Voraussetzungen
- Xcode 15.0 oder höher
- macOS Sonoma 14.0+ für macOS-Entwicklung
- iOS 17.0+ SDK für iPadOS-Entwicklung

### Projekt einrichten

```bash
# Repository klonen
git clone https://github.com/akeschmidi/PubRanker.git
cd PubRanker

# Xcode-Projekt öffnen
open PubRanker.xcodeproj
```

### iCloud Setup

Für die Aktivierung von iCloud Backup und Sync, siehe detaillierte Anleitung:
📄 **[ICLOUD_SETUP.md](ICLOUD_SETUP.md)**

## Verwendung

### Als QuizMaster

1. **Neues Quiz starten**: Tippen Sie auf "Neues Quiz"
2. **Teams hinzufügen**: Fügen Sie alle teilnehmenden Teams hinzu
3. **Runden erstellen**: Definieren Sie die Quiz-Runden
4. **Punkte vergeben**: Geben Sie nach jeder Runde die Punktzahlen ein
5. **Rangliste anzeigen**: Sehen Sie die aktuelle Rangliste in Echtzeit

### Typischer Workflow

```
Quiz erstellen → Teams hinzufügen → Runde 1 → Punkte vergeben → 
Runde 2 → Punkte vergeben → ... → Endergebnis anzeigen → Exportieren
```

## Projekt-Struktur

```
PubRanker/
├── App/
│   ├── PubRankerApp.swift          # App Entry Point
│   └── ContentView.swift           # Haupt-View
├── Models/
│   ├── Quiz.swift                  # Quiz-Datenmodell
│   ├── Team.swift                  # Team-Datenmodell
│   └── Round.swift                 # Runden-Datenmodell
├── Views/
│   ├── QuizListView.swift          # Quiz-Übersicht
│   ├── TeamManagementView.swift    # Team-Verwaltung
│   ├── ScoreEntryView.swift        # Punkteeingabe
│   └── LeaderboardView.swift       # Rangliste
├── ViewModels/
│   └── QuizViewModel.swift         # Business Logic
└── Resources/
    ├── Assets.xcassets             # App Icons & Images
    └── Localizable.strings         # Übersetzungen
```

## Entwicklung

### Code-Stil
- Verwenden Sie Swift-Konventionen
- SwiftUI-Views sollten klein und wiederverwendbar sein
- Nutzen Sie MVVM-Pattern für bessere Testbarkeit

### Testing
```bash
# Unit Tests ausführen
cmd+U in Xcode

# UI Tests ausführen
cmd+U im UI Test Target
```

## Beitragen

Wir freuen uns über Beiträge! Bitte beachten Sie:

1. Forken Sie das Repository
2. Erstellen Sie einen Feature-Branch (`git checkout -b feature/AmazingFeature`)
3. Committen Sie Ihre Änderungen (`git commit -m 'Add some AmazingFeature'`)
4. Pushen Sie zum Branch (`git push origin feature/AmazingFeature`)
5. Öffnen Sie einen Pull Request

## Lizenz

Dieses Projekt ist unter der MIT-Lizenz lizenziert - siehe [LICENSE](LICENSE) Datei für Details.

## Kontakt

GitHub: [@akeschmidi](https://github.com/akeschmidi)

## Roadmap

### Version 1.0 (MVP)
- [x] Projekt-Setup
- [ ] Basis-Datenmodelle
- [ ] Team-Management UI
- [ ] Punkteeingabe
- [ ] Ranglisten-Anzeige

### Version 1.1
- [ ] iPadOS-Optimierung
- [ ] Persistenz mit SwiftData
- [ ] Export-Funktionalität

### Version 2.0
- [ ] iCloud-Sync
- [ ] Erweiterte Statistiken
- [ ] Custom Themes

## Danksagungen

- Inspiriert von der lebendigen Pub Quiz-Community
- Built with ❤️ für QuizMaster überall

---

**PubRanker** - Making Pub Quiz scoring easy and fun! 🍺🎯
