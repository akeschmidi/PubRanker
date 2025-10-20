# 🚀 GitHub Workflows Setup-Guide

Dieses Dokument erklärt die GitHub Actions Workflows für PubRanker und wie Sie diese verwenden.

## 📋 Inhaltsverzeichnis

1. [Übersicht](#übersicht)
2. [Verfügbare Workflows](#verfügbare-workflows)
3. [Erste Schritte](#erste-schritte)
4. [Verwendung](#verwendung)
5. [Troubleshooting](#troubleshooting)

---

## 📊 Übersicht

PubRanker verwendet GitHub Actions für:

- ✅ **Automatisches Build-Testing** bei jedem Push
- 🔍 **Code-Qualitätsprüfung** mit SwiftLint
- 🤖 **Pull Request Checks** mit automatischen Kommentaren
- 📦 **Release-Automation** bei Git Tags
- 🔄 **Dependency Updates** via Dependabot

---

## 🔄 Verfügbare Workflows

### 1. Build & Test (`build.yml`)

**Wann läuft er:** Bei Push/PR auf `main` oder `develop`

**Was passiert:**
```
✓ Code wird ausgecheckt
✓ Xcode 15.4 wird eingerichtet
✓ Build wird ausgeführt (Debug)
✓ Erfolgsmeldung oder Fehlerreport
```

**Badge:**
```markdown
![Build](https://github.com/akeschmidi/PubRanker/actions/workflows/build.yml/badge.svg)
```

---

### 2. SwiftLint (`swiftlint.yml`)

**Wann läuft er:** Bei Push/PR auf `main` oder `develop`

**Was passiert:**
```
✓ SwiftLint wird installiert
✓ Code wird analysiert
✓ Warnings/Errors werden gemeldet
```

**Konfiguration:** `.swiftlint.yml`

**Lokal ausführen:**
```bash
brew install swiftlint
swiftlint lint
```

---

### 3. PR Checks (`pr-check.yml`)

**Wann läuft er:** Bei Pull Requests auf `main`

**Was passiert:**
```
✓ Build-Check
✓ SwiftLint-Check
✓ Änderungsliste
✓ Automatischer PR-Kommentar mit Ergebnissen
```

**Beispiel PR-Kommentar:**
```
🤖 PR Check Results

| Check | Status |
|-------|--------|
| Build | ✅ |
| SwiftLint | ✅ |

Workflow run: [View Details](...)
```

---

### 4. Release (`release.yml`)

**Wann läuft er:** Bei Git Tags im Format `v*.*.*`

**Was passiert:**
```
✓ Version wird extrahiert
✓ Release-Build wird erstellt
✓ GitHub Release wird angelegt
✓ Release Notes werden generiert
```

**Verwendung:**
```bash
# Version taggen
git tag v1.0.0
git commit -m "Release v1.0.0"
git push origin v1.0.0

# Workflow startet automatisch
# Release erscheint unter: github.com/USER/REPO/releases
```

---

### 5. Dependabot (`.github/dependabot.yml`)

**Wann läuft er:** Automatisch jeden Montag um 09:00

**Was passiert:**
```
✓ Prüft auf Updates für GitHub Actions
✓ Erstellt automatische PRs
✓ Labeled PRs mit "dependencies"
```

---

## 🎯 Erste Schritte

### 1. Repository Setup

Die Workflows sind bereits im `.github/workflows/` Ordner vorhanden. Sie werden automatisch aktiv sobald Sie pushen.

### 2. Badges zur README hinzufügen

Kopieren Sie diese Badges in Ihre `README.md`:

```markdown
![Build & Test](https://github.com/akeschmidi/PubRanker/actions/workflows/build.yml/badge.svg)
![SwiftLint](https://github.com/akeschmidi/PubRanker/actions/workflows/swiftlint.yml/badge.svg)
![Release](https://github.com/akeschmidi/PubRanker/actions/workflows/release.yml/badge.svg)
```

### 3. SwiftLint Lokal Installieren

```bash
# Installation
brew install swiftlint

# Ausführen
swiftlint

# Auto-Fix
swiftlint --fix
```

---

## 💻 Verwendung

### Normaler Development-Workflow

```bash
# 1. Feature-Branch erstellen
git checkout -b feature/mein-feature

# 2. Änderungen machen
# ... code changes ...

# 3. Lokal testen
swiftlint
xcodebuild build -project PubRanker.xcodeproj -scheme PubRanker

# 4. Commit und Push
git add .
git commit -m "Add: Mein neues Feature"
git push origin feature/mein-feature

# 5. Pull Request erstellen
# → GitHub Actions läuft automatisch
# → PR-Check kommentiert Ergebnisse
```

### Release erstellen

```bash
# 1. Stelle sicher main ist aktuell
git checkout main
git pull

# 2. Version taggen
git tag v1.0.0

# 3. Tag pushen
git push origin v1.0.0

# 4. Workflow erstellt automatisch GitHub Release
# Überprüfen unter: github.com/USER/REPO/releases
```

---

## 🔧 Konfiguration

### SwiftLint Regeln anpassen

Editieren Sie `.swiftlint.yml`:

```yaml
# Regel deaktivieren
disabled_rules:
  - line_length
  
# Limit anpassen
line_length:
  warning: 150
  error: 200
```

### Workflow anpassen

Editieren Sie `.github/workflows/*.yml`:

```yaml
# Xcode Version ändern
- name: Setup Xcode
  uses: maxim-lobanov/setup-xcode@v1
  with:
    xcode-version: '15.4'  # ← Hier ändern
```

### Branch-Schutz aktivieren

In GitHub: **Settings → Branches → Add rule**

Empfohlene Einstellungen:
- ✅ Require pull request reviews before merging
- ✅ Require status checks to pass before merging
  - ✅ Build and Test
  - ✅ SwiftLint Code Quality
- ✅ Require branches to be up to date before merging

---

## 🐛 Troubleshooting

### Build schlägt fehl

**Problem:** "xcodebuild: error: Unable to find a destination"

**Lösung:**
```yaml
# In workflow.yml die destination anpassen:
-destination 'platform=macOS,arch=x86_64'  # Für Intel
-destination 'platform=macOS,arch=arm64'   # Für Apple Silicon
```

---

**Problem:** Code Signing Fehler

**Lösung:** In den Workflows ist Code Signing bereits deaktiviert:
```yaml
CODE_SIGN_IDENTITY=""
CODE_SIGNING_REQUIRED=NO
CODE_SIGNING_ALLOWED=NO
```

---

### SwiftLint Fehler

**Problem:** Zu viele Warnings

**Lösung 1 - Regel deaktivieren:**
```yaml
# In .swiftlint.yml
disabled_rules:
  - trailing_whitespace
```

**Lösung 2 - Auto-Fix:**
```bash
swiftlint --fix
```

---

**Problem:** SwiftLint findet Dateien nicht

**Lösung:**
```yaml
# In .swiftlint.yml Pfade anpassen:
included:
  - PubRanker
  - PubRankerTests
```

---

### Release Workflow

**Problem:** Release wird nicht erstellt

**Prüfen Sie:**
- ✅ Tag Format: Muss `v*` sein (z.B. `v1.0.0`)
- ✅ Tag ist gepusht: `git push origin v1.0.0`
- ✅ Workflow-Logs prüfen: Actions Tab in GitHub

---

**Problem:** GITHUB_TOKEN Fehler

**Lösung:** Der Token wird automatisch bereitgestellt. Prüfen Sie:
- Repository Settings → Actions → General
- Workflow permissions → "Read and write permissions"

---

### Dependabot

**Problem:** Keine PRs werden erstellt

**Prüfen Sie:**
- ✅ `.github/dependabot.yml` ist committed
- ✅ GitHub hat Dependabot aktiviert (Settings → Code security)
- ✅ Warten Sie bis Montag 09:00 (scheduled time)

---

## 📚 Weitere Ressourcen

### Dokumentation
- [GitHub Actions Workflows](.github/WORKFLOWS.md)
- [Badges Guide](.github/BADGES.md)
- [SwiftLint Rules](https://realm.github.io/SwiftLint/rule-directory.html)

### Templates
- [Bug Report](.github/ISSUE_TEMPLATE/bug_report.md)
- [Feature Request](.github/ISSUE_TEMPLATE/feature_request.md)
- [Pull Request Template](.github/PULL_REQUEST_TEMPLATE.md)

### Links
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [SwiftLint GitHub](https://github.com/realm/SwiftLint)
- [Dependabot Docs](https://docs.github.com/en/code-security/dependabot)

---

## ✅ Best Practices

### Commits

```bash
# Gute Commit-Messages
✅ "Add: Team-Wizard Feature"
✅ "Fix: Crash beim Löschen von Teams"
✅ "Refactor: QuizViewModel Code vereinfacht"

# Schlechte Commit-Messages
❌ "changes"
❌ "fix"
❌ "wip"
```

### Pull Requests

- ✅ Beschreibende Titel
- ✅ PR Template ausfüllen
- ✅ Alle Checks müssen grün sein
- ✅ Code Review einholen
- ✅ Squash & Merge verwenden

### Releases

- ✅ Semantic Versioning: `v1.0.0`
- ✅ Aussagekräftige Release Notes
- ✅ Changelog aktualisieren
- ✅ Nach Release testen

---

## 🎯 Zusammenfassung

**Bei jedem Push/PR:**
1. Build läuft automatisch
2. SwiftLint prüft Code
3. PR-Check kommentiert Ergebnisse

**Bei Release (Tag):**
1. Release-Build wird erstellt
2. GitHub Release wird angelegt
3. Assets werden hochgeladen

**Wöchentlich:**
1. Dependabot prüft Updates
2. Automatische PRs für Actions-Updates

---

**Viel Erfolg mit PubRanker! 🚀**

Bei Fragen: [Issues](https://github.com/akeschmidi/PubRanker/issues)
