# 🌍 Lokalisierungs-Guide für PubRanker

PubRanker unterstützt mehrere Sprachen für eine weltweite Nutzung.

## 📋 Unterstützte Sprachen

| Sprache | Code | Status |
|---------|------|--------|
| 🇩🇪 Deutsch | `de` | ✅ Vollständig |
| 🇬🇧 Englisch | `en` | ✅ Vollständig |
| 🇪🇸 Spanisch | `es` | ✅ Vollständig |
| 🇫🇷 Französisch | `fr` | ✅ Vollständig |
| 🇮🇹 Italienisch | `it` | ✅ Vollständig |

---

## 📁 Dateistruktur

```
PubRanker/
├── de.lproj/
│   └── Localizable.strings
├── en.lproj/
│   └── Localizable.strings
├── es.lproj/
│   └── Localizable.strings
├── fr.lproj/
│   └── Localizable.strings
├── it.lproj/
│   └── Localizable.strings
└── Localization/
    └── LocalizationManager.swift
```

---

## 💻 Verwendung im Code

### Methode 1: L10n Manager (Empfohlen)

```swift
import SwiftUI

struct QuizListView: View {
    var body: some View {
        NavigationView {
            List {
                // Verwenden Sie L10n für typsichere Lokalisierung
                Text(L10n.Quiz.title)
                Button(L10n.Quiz.new) {
                    // Neues Quiz erstellen
                }
            }
            .navigationTitle(L10n.Leaderboard.title)
        }
    }
}
```

### Methode 2: Direkt mit NSLocalizedString

```swift
Text(NSLocalizedString("quiz.title", comment: "Quiz title"))
```

### Methode 3: String Extension

```swift
Text("quiz.title".localized())
```

### Methode 4: LocalizedStringKey (SwiftUI)

```swift
Text("quiz.title") // SwiftUI lokalisiert automatisch
```

---

## 📝 String-Kategorien

### Navigation
```swift
L10n.Navigation.back        // "Zurück" / "Back" / "Atrás"
L10n.Navigation.save        // "Speichern" / "Save" / "Guardar"
L10n.Navigation.cancel      // "Abbrechen" / "Cancel" / "Annuler"
```

### Quiz
```swift
L10n.Quiz.title            // "Quiz"
L10n.Quiz.new              // "Neues Quiz" / "New Quiz"
L10n.Quiz.Delete.confirm   // Bestätigungsdialog
```

### Teams
```swift
L10n.Team.title            // "Teams" / "Équipes"
L10n.Team.wizard           // "Team-Wizard"
L10n.Team.count(12)        // "12 Teams"
L10n.Team.Delete.message("Quiz Masters") // Formatierter String
```

### Runden
```swift
L10n.Round.title           // "Runden" / "Rounds" / "Manches"
L10n.Round.number(3)       // "Runde 3" / "Round 3"
L10n.Round.Status.active   // "Aktiv" / "Active"
```

### Leaderboard
```swift
L10n.Leaderboard.title     // "Rangliste" / "Leaderboard"
L10n.Leaderboard.podium    // "Podium" / "Podio"
```

### Scores
```swift
L10n.Score.title           // "Punkteeingabe" / "Score Entry"
L10n.Score.autoSaveEnabled // "Auto-Speichern aktiviert"
```

---

## 🎯 Beispiele

### Quiz-Erstellung Dialog

```swift
struct NewQuizView: View {
    @State private var quizName = ""
    @State private var location = ""
    
    var body: some View {
        Form {
            Section(header: Text(L10n.Quiz.name)) {
                TextField(L10n.Placeholder.quizName, text: $quizName)
            }
            
            Section(header: Text(L10n.Quiz.location)) {
                TextField(L10n.Placeholder.location, text: $location)
            }
            
            Section {
                Button(L10n.Navigation.save) {
                    saveQuiz()
                }
                .disabled(quizName.isEmpty)
            }
        }
        .navigationTitle(L10n.Quiz.new)
    }
}
```

### Löschen-Bestätigung

```swift
.alert(L10n.Team.Delete.confirm, isPresented: $showDeleteAlert) {
    Button(L10n.Navigation.cancel, role: .cancel) { }
    Button(L10n.Navigation.delete, role: .destructive) {
        deleteTeam()
    }
} message: {
    Text(L10n.Team.Delete.message(team.name))
}
```

### Formatierte Strings

```swift
// Mit Platzhaltern
let teamCount = L10n.Team.count(teams.count)  // "12 Teams"
let roundNumber = L10n.Round.number(3)         // "Runde 3"

// In der UI
Text(teamCount)
Text(roundNumber)
```

### Empty States

```swift
struct EmptyQuizzesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(L10n.Empty.noQuizzes)
                .font(.title2)
                .bold()
            
            Text(L10n.Empty.noQuizzesMessage)
                .foregroundColor(.secondary)
            
            Button(L10n.Quiz.new) {
                createQuiz()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

---

## 🔧 Xcode Konfiguration

### 1. Lokalierung im Projekt aktivieren

1. **Projekt auswählen** in Navigator
2. **Info** Tab öffnen
3. **Localizations** → **+** klicken
4. Sprachen hinzufügen: `en`, `es`, `fr`, `it`

### 2. Localizable.strings zum Projekt hinzufügen

```bash
# In Xcode:
# 1. File → New → File...
# 2. Strings File wählen
# 3. Name: "Localizable"
# 4. Im Inspector: "Localize..." Button
# 5. Alle Sprachen auswählen
```

### 3. LocalizationManager.swift hinzufügen

Die Datei `LocalizationManager.swift` muss zum Xcode Target hinzugefügt werden:

1. Rechtsklick auf `Localization/LocalizationManager.swift`
2. **Target Membership** → `PubRanker` aktivieren

---

## 🧪 Testing

### Test in verschiedenen Sprachen

#### Im Simulator:
1. **Settings** → **General** → **Language & Region**
2. **iPhone Language** → Sprache wählen
3. App neu starten

#### In Xcode Scheme:
1. **Product** → **Scheme** → **Edit Scheme**
2. **Run** → **Options**
3. **App Language** → Sprache wählen
4. App starten

### Test mit Arguments

```swift
// In Scheme: Run → Arguments → Arguments Passed On Launch
-AppleLanguages (de)    // Deutsch
-AppleLanguages (en)    // Englisch
-AppleLanguages (es)    // Spanisch
```

---

## ➕ Neue Sprache hinzufügen

### Schritt 1: Neue .lproj Ordner erstellen

```bash
mkdir PubRanker/zh-Hans.lproj  # Chinesisch (vereinfacht)
```

### Schritt 2: Localizable.strings erstellen

```bash
# Kopiere eine existierende Datei als Template
cp PubRanker/en.lproj/Localizable.strings \
   PubRanker/zh-Hans.lproj/Localizable.strings
```

### Schritt 3: Übersetzen

Öffnen Sie `zh-Hans.lproj/Localizable.strings` und übersetzen Sie alle Strings:

```strings
/* Beispiel */
"quiz.title" = "测验";
"quiz.new" = "新测验";
```

### Schritt 4: Xcode aktualisieren

1. Projekt auswählen
2. **Info** → **Localizations** → **+**
3. Neue Sprache hinzufügen

---

## 🔍 Best Practices

### DO ✅

```swift
// Typsicher mit L10n Manager
Text(L10n.Quiz.title)

// Comments für Kontext
NSLocalizedString("quiz.title", comment: "Title of quiz screen")

// Formatierung für Plurale
L10n.Team.count(teams.count)

// Platzhalter für Variablen
L10n.Team.Delete.message(team.name)
```

### DON'T ❌

```swift
// Hardcoded Strings
Text("Quiz")  // ❌

// Keine Comments
NSLocalizedString("quiz.title", comment: "")  // ❌

// String-Interpolation in Keys
Text("round.\(number)")  // ❌

// Englische Strings als Fallback
Text(title ?? "Quiz")  // ❌ Immer lokalisieren
```

---

## 📊 Plurals & Formatierung

### Plurale (mit .stringsdict)

Für korrekte Pluralformen erstellen Sie eine `.stringsdict` Datei:

```xml
<!-- de.lproj/Localizable.stringsdict -->
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>team.count</key>
    <dict>
        <key>NSStringLocalizedFormatKey</key>
        <string>%#@teams@</string>
        <key>teams</key>
        <dict>
            <key>NSStringFormatSpecTypeKey</key>
            <string>NSStringPluralRuleType</string>
            <key>NSStringFormatValueTypeKey</key>
            <string>d</string>
            <key>one</key>
            <string>%d Team</string>
            <key>other</key>
            <string>%d Teams</string>
        </dict>
    </dict>
</dict>
</plist>
```

### Zahlenformatierung

```swift
// Automatische Lokalisierung von Zahlen
let formatter = NumberFormatter()
formatter.numberStyle = .decimal
let formattedNumber = formatter.string(from: NSNumber(value: 1234.56))
// Deutsch: "1.234,56"
// Englisch: "1,234.56"
```

### Datumsformatierung

```swift
let formatter = DateFormatter()
formatter.dateStyle = .medium
formatter.timeStyle = .short
let formattedDate = formatter.string(from: Date())
// Deutsch: "20. Okt. 2025, 20:00"
// Englisch: "Oct 20, 2025, 8:00 PM"
```

---

## 🛠️ Tools

### 1. Lokalisierung exportieren

```bash
# In Xcode:
# Product → Export Localizations...
# XLIFF-Dateien für Übersetzer erstellen
```

### 2. String-Extraktion

```bash
# Finde alle verwendeten Strings
find . -name "*.swift" -print0 | \
  xargs -0 grep -h "NSLocalizedString"
```

### 3. Validation

```bash
# Prüfe auf fehlende Übersetzungen
plutil -lint PubRanker/de.lproj/Localizable.strings
```

---

## 📱 App Store Lokalisierung

Für den App Store müssen Sie auch folgende Elemente lokalisieren:

### 1. App Name
```
// de.lproj/InfoPlist.strings
"CFBundleDisplayName" = "PubRanker";
"CFBundleName" = "PubRanker";
```

### 2. App Store Metadaten
- App-Beschreibung (siehe `AppStore-Marketing.md`)
- Screenshots mit lokalisierten UI-Elementen
- Keywords für jede Sprache

---

## 🌐 Sprach-Fallback

Wenn eine Übersetzung fehlt, verwendet iOS automatisch:

1. Requested Language (z.B. Französisch)
2. Development Language (Deutsch)
3. English (falls vorhanden)
4. String Key als Fallback

---

## 📚 Weitere Ressourcen

- [Apple Localization Guide](https://developer.apple.com/localization/)
- [NSLocalizedString Documentation](https://developer.apple.com/documentation/foundation/nslocalizedstring)
- [String Catalogs in Xcode 15+](https://developer.apple.com/videos/play/wwdc2023/10155/)

---

## ✅ Checkliste: Neue Strings hinzufügen

- [ ] String in allen 5 `.strings` Dateien hinzufügen
- [ ] Key in `LocalizationManager.swift` hinzufügen
- [ ] Comment für Kontext schreiben
- [ ] In allen Sprachen testen
- [ ] SwiftLint-Checks bestehen
- [ ] Build erfolgreich

---

**Viel Erfolg mit der mehrsprachigen App! 🌍**
