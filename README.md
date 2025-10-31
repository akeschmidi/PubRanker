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

PubRanker ist dein zentraler Hub als QuizMaster - mit drei klaren Phasen:

### 🎯 Die drei Workflow-Phasen

1. **📅 Planen** - Quiz vorbereiten
   - Quiz erstellen mit allen Details
   - Teams und Runden konfigurieren
   - Übersicht über die Vorbereitung
   
2. **▶️ Durchführen** - Live-Quiz Management
   - Echtzeit-Rangliste
   - Schnelle Punkteeingabe
   - Fortschrittsanzeige und Status-Tracking
   
3. **📊 Auswerten** - Ergebnisse analysieren
   - Siegertreppchen für Top 3
   - Detaillierte Statistiken
   - Export als JSON/CSV

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

### Als QuizMaster - Der komplette Workflow

#### 1️⃣ Planung (vor dem Quiz)
1. Wechsle zur Phase **"Planen"**
2. Erstelle ein neues Quiz mit Name, Ort und Datum
3. Füge alle teilnehmenden Teams hinzu
4. Definiere die Runden mit maximalen Punktzahlen
5. Klicke **"Quiz starten"** wenn alles bereit ist

#### 2️⃣ Durchführung (während des Quiz)
1. Die App wechselt automatisch zur Phase **"Durchführen"**
2. Gib Punkte für jede Runde ein
3. Beobachte die Live-Rangliste in Echtzeit
4. Schließe Runden ab wenn fertig
5. Klicke **"Quiz beenden"** am Ende

#### 3️⃣ Auswertung (nach dem Quiz)
1. Betrachte das Siegertreppchen
2. Prüfe detaillierte Statistiken
3. Exportiere Ergebnisse als JSON oder CSV
4. Teile die Ergebnisse mit den Teilnehmern

Siehe **[QUIZMASTER_HUB.md](QUIZMASTER_HUB.md)** für die vollständige Dokumentation.

## Projekt-Struktur

```
PubRanker/
├── App/
│   ├── PubRankerApp.swift          # App Entry Point
│   └── ContentView.swift           # Haupt-Navigation mit 3 Phasen
├── Models/
│   ├── Quiz.swift                  # Quiz-Datenmodell
│   ├── Team.swift                  # Team-Datenmodell
│   └── Round.swift                 # Runden-Datenmodell
├── Views/
│   ├── PlanningView.swift          # 📅 Planungsphase
│   ├── ExecutionView.swift         # ▶️ Durchführungsphase
│   ├── AnalysisView.swift          # 📊 Auswertungsphase
│   ├── TeamManagementView.swift    # Team-Verwaltung
│   ├── RoundManagementView.swift   # Runden-Verwaltung
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

### Version 2.0 ✅ (Aktuell)
- [x] QuizMaster Hub mit 3 Phasen
- [x] Planungsphase mit Setup-Workflow
- [x] Durchführungsphase mit Live-Features
- [x] Auswertungsphase mit Statistiken
- [x] Siegertreppchen und Podium
- [x] Export als JSON/CSV
- [x] SwiftData Persistenz
- [x] iCloud Backup & Sync

### Version 2.1 (Geplant)
- [ ] iPadOS-Optimierungen
- [ ] PDF-Export mit Custom Design
- [ ] Team-Avatars/Icons
- [ ] Dark Mode Verbesserungen

### Version 3.0 (Vision)
- [ ] Apple Watch Companion
- [ ] Erweiterte Analytics
- [ ] Custom Themes
- [ ] Multiplayer-Sync

## Danksagungen

- Inspiriert von der lebendigen Pub Quiz-Community
- Built with ❤️ für QuizMaster überall

---

**PubRanker** - Making Pub Quiz scoring easy and fun! 🍺🎯
