# GitHub Push Anleitung

## Schritt 1: Repository auf GitHub erstellen (✅ Bereits erledigt!)

Das Repository ist bereits verfügbar unter:
**https://github.com/akeschmidi/PubRanker**

## Schritt 2: Git initialisieren und Code pushen

Führen Sie folgende Befehle im Terminal aus:

```bash
# Ins Projekt-Verzeichnis wechseln
cd /Users/stefanschwinghammer/work/PubRanker

# Git Repository initialisieren
git init

# Alle Dateien zum Staging hinzufügen
git add .

# Initial Commit erstellen
git commit -m "Initial commit: Complete PubRanker iOS/macOS app

- SwiftUI-basierte App für Pub Quiz Score-Management
- SwiftData für Persistenz
- Support für macOS 14.0+ und iPadOS 17.0+
- Features: Team-Management, Runden-Verwaltung, Live-Rangliste
- MVVM-Architektur mit modernem SwiftUI"

# Main Branch setzen
git branch -M main

# Remote Repository hinzufügen
git remote add origin https://github.com/akeschmidi/PubRanker.git

# Code zu GitHub pushen
git push -u origin main
```

## Schritt 3: Verifizieren

Besuchen Sie https://github.com/akeschmidi/PubRanker und überprüfen Sie:
- ✅ README.md wird korrekt angezeigt
- ✅ Alle Source-Dateien sind vorhanden
- ✅ .gitignore funktioniert (keine xcuserdata Dateien)
- ✅ LICENSE ist sichtbar

## Optionale Schritte

### Branch Protection einrichten
1. Gehen Sie zu Repository Settings → Branches
2. Fügen Sie Branch Protection Rule für `main` hinzu
3. Aktivieren Sie "Require pull request reviews before merging"

### GitHub Topics hinzufügen
Fügen Sie Topics hinzu für bessere Auffindbarkeit:
- `swift`
- `swiftui`
- `macos`
- `ipados`
- `pub-quiz`
- `score-tracking`
- `swiftdata`

### GitHub Actions (Optional)
Erstellen Sie `.github/workflows/build.yml` für automatische Builds:

```yaml
name: Build

on: [push, pull_request]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build
        run: xcodebuild -project PubRanker.xcodeproj -scheme PubRanker build
```

## Troubleshooting

### Fehler: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/akeschmidi/PubRanker.git
```

### Fehler: "Updates were rejected"
```bash
git pull origin main --rebase
git push -u origin main
```

### Authentifizierung
Falls GitHub nach Credentials fragt:
1. Verwenden Sie einen Personal Access Token (PAT)
2. Generieren Sie unter: https://github.com/settings/tokens
3. Wählen Sie Scope: `repo`
4. Verwenden Sie den Token als Passwort

## Nächste Schritte nach dem Push

1. **README Badge hinzufügen** (optional)
   - Build Status
   - License Badge
   - Platform Badges

2. **Issues und Projects einrichten**
   - Erstellen Sie GitHub Issues für geplante Features
   - Nutzen Sie Projects für Roadmap-Planung

3. **Release erstellen**
   ```bash
   git tag -a v1.0.0 -m "Release v1.0.0 - Initial Release"
   git push origin v1.0.0
   ```

4. **Wiki erstellen** (optional)
   - Detaillierte Dokumentation
   - Screenshots
   - Video-Tutorials

Viel Erfolg mit PubRanker! 🎯🍺
