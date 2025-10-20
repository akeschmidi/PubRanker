# 🎯 Xcode Lokalisierungs-Setup

Diese Anleitung zeigt, wie Sie die Lokalisierungsdateien in Xcode korrekt einbinden.

## ✅ Bereits erstellt

Die folgenden Lokalisierungsdateien wurden bereits erstellt:

```
PubRanker/
├── de.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── en.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── es.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── fr.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── it.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
└── Localization/
    └── LocalizationManager.swift
```

---

## 🔧 Schritt 1: Lokalisierung in Xcode aktivieren

### 1.1 Projekt-Einstellungen öffnen

1. **Xcode öffnen**: `PubRanker.xcodeproj`
2. Navigator: Projekt **PubRanker** auswählen (ganz oben)
3. Im Hauptfenster: Projekt **PubRanker** (nicht Target) auswählen
4. **Info** Tab öffnen

### 1.2 Sprachen hinzufügen

Im **Localizations** Bereich:

1. Klicken Sie auf das **+** Zeichen
2. Fügen Sie diese Sprachen hinzu:
   - **English** (en)
   - **Spanish** (es)
   - **French** (fr)
   - **Italian** (it)
3. **Deutsch (de)** sollte bereits als Development Language vorhanden sein

Nach dem Hinzufügen sollten Sie sehen:
```
✅ German (de) - Development Language
✅ English (en)
✅ Spanish (es)
✅ French (fr)
✅ Italian (it)
```

---

## 📁 Schritt 2: Dateien zum Projekt hinzufügen

### 2.1 LocalizationManager.swift hinzufügen

Falls noch nicht im Projekt:

1. **File** → **Add Files to "PubRanker"...**
2. Navigieren Sie zu: `PubRanker/Localization/LocalizationManager.swift`
3. ✅ **Copy items if needed** aktivieren
4. ✅ **Add to targets: PubRanker** aktivieren
5. **Add** klicken

### 2.2 Localizable.strings Dateien hinzufügen

**Option A: Automatische Erkennung (Empfohlen)**

Xcode sollte die `.lproj` Ordner automatisch erkennen:

1. **Project Navigator** öffnen (⌘+1)
2. Rechtsklick auf **PubRanker** Ordner
3. **Add Files to "PubRanker"...**
4. Ordner auswählen: `de.lproj`, `en.lproj`, `es.lproj`, `fr.lproj`, `it.lproj`
5. ✅ **Create groups** aktivieren
6. ✅ **Add to targets: PubRanker** aktivieren
7. **Add** klicken

**Option B: Manuell**

1. **File** → **New** → **File...**
2. **Strings File** wählen
3. Name: `Localizable`
4. **Create** klicken
5. Im **File Inspector** (⌘+⌥+1):
   - Klicken Sie auf **Localize...**
   - Wählen Sie alle Sprachen aus
6. Ersetzen Sie den Inhalt mit den bereits erstellten Dateien

---

## 🎯 Schritt 3: Verifizierung

### 3.1 Prüfen Sie die Projektstruktur

Im **Project Navigator** sollten Sie sehen:

```
PubRanker/
├── 📁 Models/
├── 📁 ViewModels/
├── 📁 Views/
├── 📁 Localization/
│   └── LocalizationManager.swift
├── 📁 de.lproj/
│   ├── Localizable.strings
│   └── InfoPlist.strings
├── 📁 en.lproj/
├── 📁 es.lproj/
├── 📁 fr.lproj/
└── 📁 it.lproj/
```

### 3.2 Target Membership prüfen

Wählen Sie eine `.strings` Datei aus und prüfen Sie im **File Inspector**:

✅ Target Membership: **PubRanker** muss aktiviert sein

### 3.3 Lokalisierung testen

**Methode 1: Scheme ändern**

1. **Product** → **Scheme** → **Edit Scheme...** (⌘+<)
2. **Run** → **Options** Tab
3. **App Language** → Sprache wählen (z.B. English)
4. **Apply** → **Close**
5. **Build & Run** (⌘+R)

**Methode 2: Simulator Einstellungen**

1. Simulator starten
2. **Settings** → **General** → **Language & Region**
3. **iPhone Language** → Sprache wählen
4. App neu starten

---

## 💻 Schritt 4: Code anpassen (Optional)

### 4.1 L10n Manager verwenden

Aktualisieren Sie Ihre Views um die Lokalisierung zu nutzen:

**Vorher:**
```swift
Text("Quiz")
Button("New Quiz") { }
```

**Nachher:**
```swift
import SwiftUI

Text(L10n.Quiz.title)
Button(L10n.Quiz.new) { }
```

### 4.2 Beispiel: QuizListView

```swift
import SwiftUI

struct QuizListView: View {
    @StateObject private var viewModel = QuizViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.quizzes) { quiz in
                    NavigationLink(destination: QuizDetailView(quiz: quiz)) {
                        VStack(alignment: .leading) {
                            Text(quiz.name)
                                .font(.headline)
                            Text(L10n.Team.count(quiz.teams.count))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(L10n.Quiz.title)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(L10n.Quiz.new) {
                        viewModel.createNewQuiz()
                    }
                }
            }
        }
    }
}
```

---

## 🧪 Schritt 5: Testing

### Test-Plan

| Sprache | Test | Erwartetes Ergebnis |
|---------|------|---------------------|
| 🇩🇪 Deutsch | App starten | "Quiz", "Neues Quiz" |
| 🇬🇧 English | App starten | "Quiz", "New Quiz" |
| 🇪🇸 Spanish | App starten | "Quiz", "Nuevo Quiz" |
| 🇫🇷 French | App starten | "Quiz", "Nouveau Quiz" |
| 🇮🇹 Italian | App starten | "Quiz", "Nuovo Quiz" |

### Automatisierter Test

```swift
import XCTest

class LocalizationTests: XCTestCase {
    func testGermanLocalization() {
        XCTAssertEqual(L10n.Quiz.title, "Quiz")
        XCTAssertEqual(L10n.Quiz.new, "Neues Quiz")
    }
    
    func testEnglishLocalization() {
        // Set language to English
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
        
        XCTAssertEqual(NSLocalizedString("quiz.title", comment: ""), "Quiz")
        XCTAssertEqual(NSLocalizedString("quiz.new", comment: ""), "New Quiz")
    }
}
```

---

## 🐛 Troubleshooting

### Problem: Strings werden nicht übersetzt

**Lösung 1: Clean Build**
```bash
Product → Clean Build Folder (⌘+Shift+K)
Product → Build (⌘+B)
```

**Lösung 2: Derived Data löschen**
```bash
Xcode → Settings → Locations → Derived Data
→ Pfeil-Symbol klicken → Ordner im Finder löschen
```

**Lösung 3: .strings Dateien prüfen**
```bash
# In Terminal:
plutil -lint PubRanker/de.lproj/Localizable.strings
plutil -lint PubRanker/en.lproj/Localizable.strings
```

### Problem: Sprache ändert sich nicht

**Lösung:**
1. App komplett beenden (nicht nur Home)
2. Simulator/Device neu starten
3. App erneut installieren

### Problem: "Key not found" Fehler

**Prüfen Sie:**
- ✅ Key existiert in allen `.strings` Dateien
- ✅ Keine Tippfehler im Key
- ✅ Comment vorhanden
- ✅ Semikolon am Ende der Zeile

**Beispiel:**
```strings
// ✅ Korrekt
"quiz.title" = "Quiz";

// ❌ Fehlt Semikolon
"quiz.title" = "Quiz"

// ❌ Tippfehler im Key
"quiz.titel" = "Quiz";
```

### Problem: L10n Manager nicht gefunden

**Lösung:**
1. Prüfen Sie Target Membership von `LocalizationManager.swift`
2. **Project Navigator** → `LocalizationManager.swift` auswählen
3. **File Inspector** (⌘+⌥+1) → Target Membership
4. ✅ **PubRanker** aktivieren
5. Clean & Build

---

## 📊 Build Settings prüfen

### Development Language

1. Projekt auswählen
2. **Info** Tab
3. **Localizations** → Development Language sollte **German (de)** sein

### Known Regions

In `Info.plist` sollten alle Regionen aufgelistet sein:
```xml
<key>CFBundleLocalizations</key>
<array>
    <string>de</string>
    <string>en</string>
    <string>es</string>
    <string>fr</string>
    <string>it</string>
</array>
```

---

## ✅ Checkliste

Nach dem Setup:

- [ ] Alle 5 Sprachen in Project Info → Localizations sichtbar
- [ ] `LocalizationManager.swift` zu Target hinzugefügt
- [ ] Alle `.lproj` Ordner im Project Navigator sichtbar
- [ ] `.strings` Dateien haben Target Membership
- [ ] Build erfolgreich (⌘+B)
- [ ] App startet in allen 5 Sprachen
- [ ] Strings werden korrekt übersetzt angezeigt
- [ ] Keine "Key not found" Warnungen in Console

---

## 🎓 Weitere Schritte

Nach erfolgreichem Setup:

1. **Code migrieren**: Ersetzen Sie hardcoded Strings mit `L10n.*`
2. **Testing**: Testen Sie alle Screens in allen Sprachen
3. **Screenshots**: Erstellen Sie lokalisierte Screenshots für App Store
4. **App Store**: Fügen Sie Übersetzungen in App Store Connect hinzu

Siehe `LOCALIZATION_GUIDE.md` für Details zur Verwendung im Code.

---

**Bei Fragen:** [Issues auf GitHub](https://github.com/akeschmidi/PubRanker/issues)

**Happy Localizing! 🌍**
