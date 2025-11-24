# Versionsverwaltung

## Automatisches Erhöhen der Build-Version

Es gibt zwei Möglichkeiten, die Build-Version automatisch zu erhöhen:

### Option 1: Manuelles Skript (Empfohlen)

Vor jedem App Store Upload das Skript ausführen:

```bash
./increment_version.sh
```

Das Skript:
- Liest die aktuelle Version aus der Projektdatei
- Erhöht sie automatisch um 1
- Aktualisiert beide Build-Konfigurationen (Debug & Release)

**Vorteil:** Du hast volle Kontrolle, wann die Version erhöht wird.

### Option 2: Automatisch bei jedem Release-Build

Füge das Build Phase Script zu deinem Xcode-Projekt hinzu:

1. Öffne das Projekt in Xcode
2. Wähle das Target "PubRanker"
3. Gehe zu "Build Phases"
4. Klicke auf "+" und wähle "New Run Script Phase"
5. Verschiebe die Phase NACH "Copy Bundle Resources"
6. Füge folgendes Script ein:

```bash
"${PROJECT_DIR}/increment_version_build_phase.sh"
```

**Vorteil:** Die Version wird automatisch bei jedem Archive-Build erhöht.

**Hinweis:** Bei Option 2 wird die Version bei jedem Release-Build erhöht, auch wenn du nicht hochlädst. Option 1 gibt dir mehr Kontrolle.

## Aktuelle Version prüfen

Die aktuelle Build-Version findest du in:
- `PubRanker.xcodeproj/project.pbxproj` (Zeile mit `CURRENT_PROJECT_VERSION`)
- Oder in Xcode: Target → General → Version

## Marketing Version

Die Marketing Version (z.B. 1.7) wird separat verwaltet und sollte manuell in Xcode geändert werden, wenn du eine neue Hauptversion veröffentlichst.

