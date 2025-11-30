# 📸 Automatisierte Screenshot-Erstellung für App Store

Dieses Skript erstellt automatisch Screenshots für den macOS App Store in der erforderlichen Größe von **2880x1800 Pixel**.

## 🚀 Schnellstart

### Option 1: Automatisiertes Skript (mit UI-Automation)

```bash
./generate_screenshots.sh
```

Das Skript:
1. Baut die App im Release-Modus
2. Startet die App
3. Versucht automatisch durch verschiedene Views zu navigieren
4. Erstellt Screenshots in der richtigen Größe
5. Speichert sie in `screenshots/appstore/`

**Hinweis:** UI-Automation mit AppleScript funktioniert bei SwiftUI-Apps manchmal nicht zuverlässig.

### Option 2: Manuelles Skript (empfohlen)

```bash
./generate_screenshots_manual.sh
```

Das Skript:
1. Baut die App (optional)
2. Startet die App
3. **Wartet auf Ihre manuelle Navigation** zu den gewünschten Views
4. Erstellt Screenshots **nur vom App-Fenster** (nicht den ganzen Desktop)
5. Konvertiert automatisch zu 2880x1800 Pixel

**Empfohlen für zuverlässigste Ergebnisse!**

### Option 2b: Keyboard-basiertes Skript

```bash
./generate_screenshots_keyboard.sh
```

Ähnlich wie das manuelle Skript, aber mit zusätzlichen Hinweisen für die Navigation.

### Option 3: Schnelle Konvertierung vorhandener Screenshots

```bash
./convert_screenshot.sh screenshot.png
```

Konvertiert einen vorhandenen Screenshot zu 2880x1800 Pixel.

## 📋 Voraussetzungen

- macOS mit Xcode installiert
- App muss kompilierbar sein
- Terminal-Zugriff auf `screencapture` und `sips` (beide sind macOS-Standard-Tools)

## 📁 Screenshot-Reihenfolge

Die Screenshots werden in dieser Reihenfolge erstellt (entspricht App Store Marketing):

1. **01_leaderboard.png** - Leaderboard mit Podium (Hauptfeature)
2. **02_team_management.png** - Team Management (Benutzerfreundlichkeit)
3. **03_quiz_planning.png** - Quiz Planning (Organisation)
4. **04_score_entry.png** - Score Entry (Funktionalität)
5. **05_rounds_overview.png** - Rounds Overview (Gesamtbild)

## ⚙️ Konfiguration

Sie können die Konfiguration im Skript anpassen:

```bash
SCREENSHOT_DIR="screenshots/appstore"      # Ausgabe-Verzeichnis
SCREENSHOT_WIDTH=2880                      # Breite in Pixel
SCREENSHOT_HEIGHT=1800                     # Höhe in Pixel
SCREENSHOT_DELAY=3                         # Wartezeit zwischen Screenshots (Sekunden)
```

## 🎯 Manuelle Anpassung

Da UI-Automation mit AppleScript bei SwiftUI-Apps manchmal unzuverlässig ist, sollten Sie:

1. **Das Skript ausführen** - Es erstellt die Screenshots der aktuellen Ansicht
2. **Manuell navigieren** - Öffnen Sie die App und navigieren Sie zu den gewünschten Views
3. **Screenshots prüfen** - Kontrollieren Sie die erstellten Screenshots
4. **Bei Bedarf wiederholen** - Führen Sie das Skript erneut aus oder erstellen Sie Screenshots manuell

## 📐 Screenshot-Größen für App Store

- **macOS App Store**: 2880 x 1800 Pixel (16:10)
- **Format**: PNG
- **Anzahl**: 3-5 Screenshots empfohlen

## 🔧 Manuelle Screenshot-Erstellung

Falls das automatisierte Skript nicht zuverlässig funktioniert:

### Option 1: Mit Terminal

```bash
# Screenshot des gesamten Bildschirms
screencapture -x screenshot.png

# Screenshot in bestimmter Größe konvertieren
sips -z 1800 2880 screenshot.png --out screenshot_2880x1800.png
```

### Option 2: Mit macOS Screenshot-Tool

1. Drücken Sie `Cmd + Shift + 4`
2. Wählen Sie den App-Fenster-Bereich aus
3. Speichern Sie den Screenshot
4. Konvertieren Sie mit `sips`:

```bash
sips -z 1800 2880 ~/Desktop/Screenshot.png --out screenshot_2880x1800.png
```

### Option 3: Mit Preview.app

1. Öffnen Sie den Screenshot in Preview
2. `Tools` → `Adjust Size...`
3. Setzen Sie:
   - Width: 2880
   - Height: 1800
   - Units: pixels
4. Speichern Sie als PNG

## 🎨 Screenshot-Tipps

### Best Practices

- **Zeigen Sie die wichtigsten Features** in den ersten Screenshots
- **Verwenden Sie echte Daten** - keine leeren States
- **Konsistente UI** - Alle Screenshots sollten den gleichen Stil haben
- **Gute Beleuchtung** - Dark Mode oder Light Mode konsistent
- **Keine persönlichen Daten** - Verwenden Sie Demo-Daten

### Empfohlene Screenshot-Inhalte

1. **Leaderboard** - Zeigt das Hauptfeature mit Podium
2. **Team Management** - Zeigt Benutzerfreundlichkeit
3. **Score Entry** - Zeigt Funktionalität
4. **Planning View** - Zeigt Organisation
5. **Quiz Overview** - Zeigt Gesamtbild

## 🐛 Fehlerbehebung

### Problem: Ganzes Desktop wird aufgenommen statt nur App-Fenster
**✅ Behoben!** Die Skripte erfassen jetzt automatisch nur das App-Fenster. Falls es dennoch auftritt:
- Stellen Sie sicher, dass die App im Vordergrund ist
- Prüfen Sie, ob Terminal Zugriff auf Accessibility-Features hat:
  - System Preferences → Security & Privacy → Privacy → Accessibility
  - Fügen Sie Terminal hinzu, falls nicht vorhanden

### Problem: App wechselt die View nicht / Alle Screenshots sind gleich
**Lösung:** Verwenden Sie das **manuelle Skript** (`generate_screenshots_manual.sh`):
- Das Skript wartet auf Ihre manuelle Navigation
- Sie klicken selbst auf die Tabs in der App
- Dann drücken Sie ENTER für den Screenshot

### Problem: App startet nicht
- Prüfen Sie, ob die App erfolgreich gebaut wurde
- Prüfen Sie die Berechtigungen (System Preferences → Security)

### Problem: Screenshots sind falsch dimensioniert
- Prüfen Sie, ob `sips` verfügbar ist: `which sips`
- Manuelle Konvertierung mit `sips -z 1800 2880 input.png --out output.png`

### Problem: UI-Automation funktioniert nicht
- AppleScript hat bei SwiftUI-Apps manchmal Probleme
- **Lösung:** Verwenden Sie das manuelle Skript (`generate_screenshots_manual.sh`)
- Navigieren Sie manuell zu den gewünschten Views
- Das Skript macht dann Screenshots der aktuellen Ansicht

### Problem: App wird nicht gefunden
- Prüfen Sie den Build-Pfad im Skript
- Führen Sie `xcodebuild` manuell aus und prüfen Sie den Output-Pfad

## 🔄 Alternative: UI-Tests für Screenshots

Für zuverlässigere Automatisierung können Sie UI-Tests verwenden:

1. Erstellen Sie UI-Tests in Xcode
2. Verwenden Sie `XCUIScreenshot` in den Tests
3. Führen Sie die Tests aus und speichern Sie Screenshots

Beispiel:

```swift
func testScreenshotLeaderboard() {
    let app = XCUIApplication()
    app.launch()
    
    // Navigiere zur Leaderboard-Ansicht
    app.buttons["Auswerten"].tap()
    
    // Warte auf UI-Update
    sleep(2)
    
    // Screenshot erstellen
    let screenshot = app.screenshot()
    let attachment = XCTAttachment(screenshot: screenshot)
    attachment.name = "Leaderboard"
    attachment.lifetime = .keepAlways
    add(attachment)
}
```

## 📚 Weitere Ressourcen

- [App Store Connect Screenshot-Anforderungen](https://developer.apple.com/app-store/app-store-connect/)
- [macOS Screenshot-Tools](https://support.apple.com/en-us/HT201361)
- [sips Command Reference](https://ss64.com/osx/sips.html)

## ✅ Checkliste vor App Store Upload

- [ ] Alle Screenshots sind 2880x1800 Pixel
- [ ] Screenshots zeigen die wichtigsten Features
- [ ] Keine persönlichen oder sensiblen Daten sichtbar
- [ ] Konsistente UI (alle Light Mode oder alle Dark Mode)
- [ ] Screenshots sind in der richtigen Reihenfolge
- [ ] Dateinamen sind aussagekräftig

---

**Viel Erfolg mit Ihren Screenshots! 🚀**

