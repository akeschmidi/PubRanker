# Versionsverwaltung

## ⚠️ WICHTIG: Build-Nummer vs. Marketing-Version

| Feld | In Xcode | Info.plist Key | Beispiel | Regel |
|------|----------|----------------|----------|-------|
| **Build-Nummer** | Build | `CFBundleVersion` | `201` | Muss bei JEDEM Upload höher sein |
| **Marketing-Version** | Version | `CFBundleShortVersionString` | `2.2` | Kann gleich bleiben bei Bug-Fixes |

---

## 🚀 Empfohlene Methode: Fastlane (Automatisch)

### Bei jedem Release:

```bash
cd PubRanker
fastlane bump_build
```

Oder direkt Release erstellen und hochladen:

```bash
fastlane release
```

### Wie es funktioniert:
1. Liest Git Commit Count
2. Addiert Offset (200) um über App Store Version zu bleiben
3. Setzt IMMER eine höhere Nummer

---

## 🛠 Alternative: Manuelles Script

```bash
./Scripts/auto_increment_build.sh
```

Oder das ältere Script:

```bash
./increment_version.sh
```

---

## ⚙️ Xcode Build Phase (Automatisch bei Archive)

### Einrichtung:

1. **Xcode öffnen** → Target "PubRanker"
2. **Edit Scheme...** (⌘<)
3. Links: **Archive** → **Pre-actions**
4. **+** → "New Run Script Action"
5. **Shell:** `/bin/bash`
6. **Script einfügen:**

```bash
"${PROJECT_DIR}/Scripts/auto_increment_build.sh"
```

7. **"Provide build settings from":** PubRanker

### Ergebnis:
- Bei jedem **Archive** (Release-Build) wird die Build-Nummer automatisch erhöht
- Debug-Builds bleiben unberührt

---

## 📊 Aktuelle Werte

| Wert | Aktuell |
|------|---------|
| Marketing-Version | 2.2 |
| Build-Nummer | 201+ |
| Letzte App Store Version | 200 |

### Prüfen:

```bash
# In project.pbxproj
grep "CURRENT_PROJECT_VERSION" PubRanker.xcodeproj/project.pbxproj

# Oder in Xcode:
# Target → General → Identity → Build
```

---

## 🔢 Build-Nummer Strategie

### Git-basiert (Empfohlen):
```
Build-Nummer = 200 (Offset) + Git Commit Count
```

**Vorteile:**
- ✅ Immer eindeutig
- ✅ Immer aufsteigend
- ✅ Kann nicht versehentlich zurückgesetzt werden
- ✅ Reproduzierbar auf jedem System

### Fallback (wenn kein Git):
```
Build-Nummer = YYYYMMDDHHMM (Timestamp)
```

---

## ❌ Häufige Fehler vermeiden

### Fehler: "CFBundleVersion must be higher"
```
This bundle is invalid. The value for key CFBundleVersion [1] 
must contain a higher version than that of the previously uploaded version [200].
```

**Ursache:** Build-Nummer wurde zurückgesetzt oder nicht erhöht.

**Lösung:**
```bash
fastlane bump_build
# Oder manuell in project.pbxproj:
# CURRENT_PROJECT_VERSION = 201; (oder höher)
```

### Prävention:
1. **Nie** CURRENT_PROJECT_VERSION manuell auf niedrigen Wert setzen
2. **Immer** Fastlane oder Script vor Upload verwenden
3. **Xcode Build Phase** für automatisches Inkrement einrichten

---

## 📝 Workflow für App Store Release

### Empfohlener Ablauf:

```bash
# 1. Änderungen committen
git add .
git commit -m "Release 2.2"

# 2. Build-Nummer erhöhen + Archive erstellen + hochladen
fastlane release

# 3. In App Store Connect: Review einreichen
```

### Alternativer Ablauf (manuell):

```bash
# 1. Build-Nummer erhöhen
./Scripts/auto_increment_build.sh

# 2. In Xcode: Product → Archive

# 3. In Organizer: Distribute App → App Store Connect
```

---

## 🔄 Marketing-Version ändern

Die Marketing-Version (2.2 → 2.3) wird **manuell** geändert:

### In Xcode:
1. Target → General → Identity → Version
2. Neuen Wert eingeben (z.B. "2.3")

### Per Script:
```bash
# Alle Vorkommen ersetzen
sed -i '' 's/MARKETING_VERSION = 2.2;/MARKETING_VERSION = 2.3;/g' \
    PubRanker.xcodeproj/project.pbxproj
```

### Wann erhöhen?
- **Major (1.0 → 2.0):** Große Änderungen, neues Design
- **Minor (2.2 → 2.3):** Neue Features
- **Keine Erhöhung:** Bug-Fixes (nur Build-Nummer erhöhen)

---

*Zuletzt aktualisiert: Dezember 2024*
