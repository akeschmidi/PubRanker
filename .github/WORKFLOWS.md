# GitHub Workflows für PubRanker

Dieses Projekt verwendet GitHub Actions für CI/CD (Continuous Integration/Continuous Deployment).

## 🔄 Verfügbare Workflows

### 1. Build & Test (`build.yml`)

**Trigger:** Push/PR auf `main` oder `develop`

**Was macht er:**
- Checkout des Codes
- Setup von Xcode 15.4
- Clean Build
- Build der macOS App (Debug)
- Erfolgsmeldung

**Status:** 
[![Build & Test](https://github.com/akeschmidi/PubRanker/actions/workflows/build.yml/badge.svg)](https://github.com/akeschmidi/PubRanker/actions/workflows/build.yml)

---

### 2. SwiftLint (`swiftlint.yml`)

**Trigger:** Push/PR auf `main` oder `develop`

**Was macht er:**
- Installation von SwiftLint via Homebrew
- Code-Qualität Analyse
- Reporting von Warnings/Errors

**Status:**
[![SwiftLint](https://github.com/akeschmidi/PubRanker/actions/workflows/swiftlint.yml/badge.svg)](https://github.com/akeschmidi/PubRanker/actions/workflows/swiftlint.yml)

**Konfiguration:** `.swiftlint.yml` im Root-Verzeichnis

---

### 3. PR Checks (`pr-check.yml`)

**Trigger:** Pull Request auf `main`

**Was macht er:**
- Build-Check
- SwiftLint-Check
- Listet geänderte Dateien
- Kommentiert PR mit Ergebnissen
- Erstellt Check-Summary

**Features:**
- ✅ Automatische PR-Kommentare
- 📊 Übersichtliche Tabelle mit Status
- 🔗 Link zu Workflow-Details

---

### 4. Release (`release.yml`)

**Trigger:** Git Tags mit Format `v*` (z.B. `v1.0.0`)

**Was macht er:**
- Extrahiert Version aus Tag
- Build Release-Konfiguration
- Erstellt Archive (optional)
- Generiert Release Notes
- Erstellt GitHub Release

**Verwendung:**
```bash
# Version taggen und pushen
git tag v1.0.0
git push origin v1.0.0

# Workflow startet automatisch
```

**Status:**
[![Release](https://github.com/akeschmidi/PubRanker/actions/workflows/release.yml/badge.svg)](https://github.com/akeschmidi/PubRanker/actions/workflows/release.yml)

---

## 🛠️ Lokale Entwicklung

### SwiftLint lokal ausführen

```bash
# Installation (einmalig)
brew install swiftlint

# SwiftLint ausführen
swiftlint

# Auto-Fix für einfache Probleme
swiftlint --fix

# Nur Warnings
swiftlint --strict
```

### Build lokal ausführen

```bash
# Debug Build
xcodebuild build \
  -project PubRanker.xcodeproj \
  -scheme PubRanker \
  -destination 'platform=macOS'

# Release Build
xcodebuild build \
  -project PubRanker.xcodeproj \
  -scheme PubRanker \
  -destination 'platform=macOS' \
  -configuration Release
```

---

## 📝 SwiftLint Konfiguration

Die SwiftLint-Regeln sind in `.swiftlint.yml` definiert:

**Aktivierte Regeln:**
- ✅ Code-Style Checks
- ✅ Best Practices
- ✅ Performance Optimierungen
- ✅ Naming Conventions
- ✅ Custom Rules

**Deaktivierte Regeln:**
- ❌ `trailing_whitespace` - Zu strikt
- ❌ `todo` - TODOs sind OK
- ❌ `line_length` - Manchmal sind lange Zeilen OK

**Limits:**
- Line Length: 120 (warning), 200 (error)
- File Length: 500 (warning), 1000 (error)
- Function Body: 50 (warning), 100 (error)
- Type Body: 300 (warning), 500 (error)

---

## 🤖 Dependabot

Automatische Updates für GitHub Actions:

**Konfiguration:** `.github/dependabot.yml`

**Features:**
- 🔄 Wöchentliche Checks (Montags, 09:00)
- 📦 Automatische PRs für Updates
- 🏷️ Auto-Labeling: `dependencies`, `github-actions`
- 👤 Auto-Assignment

---

## 🔐 Secrets & Permissions

### Benötigte Secrets

Aktuell keine Secrets erforderlich. Der `GITHUB_TOKEN` wird automatisch bereitgestellt.

### Zukünftige Secrets (für App Store Upload)

Wenn Sie automatische App Store Uploads einrichten möchten:

- `APPLE_ID` - Ihre Apple ID
- `APPLE_APP_SPECIFIC_PASSWORD` - App-spezifisches Passwort
- `APPLE_TEAM_ID` - Ihre Team ID
- `CERTIFICATES_P12` - Code Signing Certificate
- `CERTIFICATES_PASSWORD` - Certificate Passwort
- `PROVISIONING_PROFILE` - Provisioning Profile

---

## 📊 Workflow Status Dashboard

Fügen Sie diese Badges zu Ihrer README.md hinzu:

```markdown
![Build](https://github.com/akeschmidi/PubRanker/actions/workflows/build.yml/badge.svg)
![SwiftLint](https://github.com/akeschmidi/PubRanker/actions/workflows/swiftlint.yml/badge.svg)
![Release](https://github.com/akeschmidi/PubRanker/actions/workflows/release.yml/badge.svg)
```

---

## 🐛 Troubleshooting

### Build schlägt fehl

**Problem:** Xcode Version nicht kompatibel
```yaml
# Ändern Sie in workflow.yml:
xcode-version: '15.4'  # Ihre Xcode Version
```

**Problem:** Code Signing Fehler
```bash
# Lösung: Code Signing deaktiviert in Workflows
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
```

### SwiftLint Fehler

**Problem:** Zu viele Warnings
```yaml
# In .swiftlint.yml Regel deaktivieren:
disabled_rules:
  - rule_name
```

**Problem:** SwiftLint nicht gefunden
```bash
# Installation prüfen:
brew install swiftlint
which swiftlint
```

### Release Workflow startet nicht

**Problem:** Tag Format falsch
```bash
# Korrekt:
git tag v1.0.0

# Falsch:
git tag 1.0.0
```

---

## 📚 Weitere Ressourcen

- [GitHub Actions Dokumentation](https://docs.github.com/en/actions)
- [SwiftLint Regeln](https://realm.github.io/SwiftLint/rule-directory.html)
- [Xcodebuild Kommandos](https://developer.apple.com/library/archive/technotes/tn2339/_index.html)
- [GitHub Actions für iOS/macOS](https://github.com/marketplace?type=actions&query=xcode)

---

## 🎯 Best Practices

1. **Immer PR-Checks bestehen** bevor Sie mergen
2. **SwiftLint Warnings beheben** vor dem Commit
3. **Semantic Versioning** für Tags verwenden (`v1.0.0`)
4. **Release Notes** aussagekräftig schreiben
5. **Workflow-Logs prüfen** bei Fehlern

---

**Letzte Aktualisierung:** 20. Oktober 2025
