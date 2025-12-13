# CloudKit Analytics Dashboard Setup

## 🎯 Übersicht

PubRanker nutzt **CloudKit Public Database** für anonymisierte Nutzungsstatistiken. Diese können über das CloudKit Dashboard oder ein eigenes Web-Dashboard abgerufen werden.

## ✅ Was wird implementiert

1. **Anonymisierte Statistiken** in CloudKit Public Database
   - Anzahl Quiz, Teams, Runden, Punkte
   - Events (Quiz erstellt, Team erstellt, etc.)
   - App-Version und Plattform
   - Anonyme User-ID (keine persönlichen Daten)

2. **Automatisches Tracking** bei wichtigen Aktionen
   - Quiz erstellt → Event + Statistiken
   - Team erstellt → Event
   - Punkte eingegeben → Event
   - Quiz abgeschlossen → Event + Statistiken

## 🔧 Setup in Xcode

### Schritt 1: CloudKit Public Database aktivieren

1. Öffne das Projekt in Xcode
2. Gehe zu **Signing & Capabilities**
3. Stelle sicher, dass **iCloud** aktiviert ist
4. Im CloudKit Dashboard: [https://icloud.developer.apple.com/](https://icloud.developer.apple.com/)
   - Wähle deinen Container: `iCloud.com.akeschmidi.PubRanker`
   - Gehe zu **Schema** → **Record Types**
   - Erstelle zwei neue Record Types:

#### Record Type 1: `AppAnalytics`
```
Fields:
- timestamp (Date/Time)
- totalQuizzes (Int64)
- totalTeams (Int64)
- totalRounds (Int64)
- totalPoints (Int64)
- appVersion (String)
- platform (String)
- anonymousUserId (String)
```

#### Record Type 2: `AppEvents`
```
Fields:
- eventType (String)
- timestamp (Date/Time)
- anonymousUserId (String)
- appVersion (String)
```

### Schritt 2: Public Database konfigurieren

1. Im CloudKit Dashboard → **Security Roles**
2. Erstelle eine Rolle für **World** (öffentlicher Zugriff)
3. Setze **Read** Berechtigung für beide Record Types

## 📊 Dashboard-Zugriff

### Option 1: CloudKit Dashboard (Einfach)

1. Gehe zu [CloudKit Dashboard](https://icloud.developer.apple.com/)
2. Wähle deinen Container
3. Gehe zu **Data** → **Public Database**
4. Filtere nach `AppAnalytics` oder `AppEvents`
5. Exportiere Daten als JSON/CSV

### Option 2: Eigenes Web-Dashboard (Erweitert)

Erstelle eine einfache Web-App, die die CloudKit Public Database liest:

```javascript
// Beispiel mit CloudKit JS
const container = new CloudKit.Container({
    containerIdentifier: 'iCloud.com.akeschmidi.PubRanker',
    environment: 'production'
});

// Query für Statistiken
const query = {
    recordType: 'AppAnalytics',
    sortBy: [{ fieldName: 'timestamp', direction: 'DESCENDING' }],
    resultsLimit: 100
};

container.publicCloudDatabase.performQuery(query)
    .then(response => {
        // Verarbeite Statistiken
        console.log(response.records);
    });
```

### Option 3: macOS Dashboard App

Erstelle eine separate macOS App, die die CloudKit Public Database liest und ein Dashboard anzeigt.

## 🔒 Datenschutz

- ✅ **Anonymisiert**: Keine persönlichen Daten
- ✅ **Opt-in**: Kann in App-Einstellungen deaktiviert werden
- ✅ **Transparent**: User sieht, was gesendet wird
- ✅ **DSGVO-konform**: Keine personenbezogenen Daten

## 📈 Statistiken die gesammelt werden

### Aggregierte Statistiken (AppAnalytics)
- Gesamtanzahl Quiz
- Gesamtanzahl Teams
- Gesamtanzahl Runden
- Gesamtanzahl Punkte
- App-Version
- Plattform (macOS/iOS)

### Events (AppEvents)
- `quiz_created` - Quiz wurde erstellt
- `team_created` - Team wurde erstellt
- `round_created` - Runde wurde erstellt
- `score_entered` - Punkte wurden eingegeben
- `quiz_started` - Quiz wurde gestartet
- `quiz_completed` - Quiz wurde abgeschlossen

## 🚀 Verwendung

Die Analytics werden automatisch gesendet, wenn:
- Ein Quiz erstellt wird
- Ein Team erstellt wird
- Punkte eingegeben werden
- Ein Quiz abgeschlossen wird

Optional: Tägliche Zusammenfassung senden (kann in App-Einstellungen aktiviert werden).

## 📝 Code-Integration

Die Analytics werden automatisch in folgenden Funktionen getrackt:
- `QuizViewModel.createQuiz()`
- `QuizViewModel.addTeam()`
- `QuizViewModel.updateScore()`
- `QuizViewModel.completeQuiz()`

## 🔍 Dashboard-Beispiele

### Einfache Statistik-Ansicht
```
📊 PubRanker Analytics

Gesamt Quiz: 1,234
Gesamt Teams: 5,678
Gesamt Runden: 9,012
Gesamt Punkte: 123,456

Events heute:
- Quiz erstellt: 12
- Teams erstellt: 45
- Quiz abgeschlossen: 8
```

### Erweiterte Ansicht
- Zeitreihen-Diagramme
- Nutzung nach App-Version
- Plattform-Verteilung
- Events pro Tag/Woche/Monat



