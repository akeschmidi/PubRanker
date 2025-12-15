# CloudKit Dashboard - Detaillierte Anleitung

## 🎯 Was ist das CloudKit Dashboard?

Das **CloudKit Dashboard** ist ein Web-Interface von Apple, mit dem du die Daten in deiner CloudKit-Datenbank verwalten und einsehen kannst. Es ist kostenlos und Teil des Apple Developer Programms.

**URL**: [https://icloud.developer.apple.com/](https://icloud.developer.apple.com/)

## 📋 Voraussetzungen

1. **Apple Developer Account** (kostenpflichtig, ~99€/Jahr)
2. **App ID** mit iCloud Capability aktiviert
3. **CloudKit Container** für deine App

## 🚀 Schritt 1: CloudKit Dashboard öffnen

1. Gehe zu: [https://icloud.developer.apple.com/](https://icloud.developer.apple.com/)
2. Melde dich mit deiner **Apple Developer Account** an
3. Du siehst eine Liste aller deiner Apps mit CloudKit

## 🔍 Schritt 2: Deinen Container finden

1. Suche nach **"PubRanker"** oder deiner App
2. Klicke auf den **Container** (z.B. `iCloud.com.akeschmidi.PubRanker`)
3. Du landest im **Dashboard** deines Containers

### Container-Struktur

Ein CloudKit Container hat **3 Datenbanken**:

1. **Private Database** - Nur für den angemeldeten User (deine Quiz-Daten)
2. **Public Database** - Öffentlich zugänglich (für Analytics)
3. **Shared Database** - Geteilt zwischen Usern (nicht verwendet)

Für Analytics nutzen wir die **Public Database**.

## 📊 Schritt 3: Record Types erstellen

Record Types sind wie "Tabellen" in einer Datenbank. Wir brauchen 2:

### Record Type 1: `AppAnalytics`

1. Im Dashboard: Klicke auf **"Schema"** (linke Sidebar)
2. Klicke auf **"Record Types"**
3. Klicke auf **"+"** (neuer Record Type)
4. Name: `AppAnalytics`
5. Klicke auf **"Create"**

#### Felder hinzufügen:

Klicke auf **"Add Field"** für jedes Feld:

| Feldname | Typ | Beschreibung |
|----------|-----|--------------|
| `timestamp` | **Date/Time** | Wann wurden die Daten gesendet |
| `totalQuizzes` | **Int(64)** | Anzahl Quiz gesamt |
| `totalTeams` | **Int(64)** | Anzahl Teams gesamt |
| `totalRounds` | **Int(64)** | Anzahl Runden gesamt |
| `totalPoints` | **Int(64)** | Anzahl Punkte gesamt |
| `appVersion` | **String** | App-Version (z.B. "1.0") |
| `platform` | **String** | Plattform (z.B. "macOS") |
| `anonymousUserId` | **String** | Anonyme User-ID (keine persönlichen Daten) |

**Wichtig**: Nach jedem Feld auf **"Save"** klicken!

### Record Type 2: `AppEvents`

1. Wieder **"+"** klicken
2. Name: `AppEvents`
3. **"Create"** klicken

#### Felder hinzufügen:

| Feldname | Typ | Beschreibung |
|----------|-----|--------------|
| `eventType` | **String** | Event-Typ (z.B. "quiz_created") |
| `timestamp` | **Date/Time** | Wann wurde das Event ausgelöst |
| `anonymousUserId` | **String** | Anonyme User-ID |
| `appVersion` | **String** | App-Version |

## 🔐 Schritt 4: Public Database Berechtigungen

Damit die App Daten in die Public Database schreiben kann:

1. Im Dashboard: Klicke auf **"Security Roles"** (linke Sidebar)
2. Du siehst eine Liste von Rollen
3. Suche nach **"World"** (öffentlicher Zugriff)
4. Falls nicht vorhanden: Klicke **"+"** → Name: `World`

### Berechtigungen für `AppAnalytics`:

1. Klicke auf die Rolle **"World"**
2. Unter **"Record Types"**:
   - Finde `AppAnalytics`
   - Setze **"Create"** auf ✅ (erlaubt)
   - Setze **"Read"** auf ✅ (erlaubt)
   - Setze **"Update"** auf ❌ (nicht nötig)
   - Setze **"Delete"** auf ❌ (nicht nötig)

### Berechtigungen für `AppEvents`:

1. Gleiche Rolle **"World"**
2. Unter **"Record Types"**:
   - Finde `AppEvents`
   - Setze **"Create"** auf ✅
   - Setze **"Read"** auf ✅
   - Setze **"Update"** auf ❌
   - Setze **"Delete"** auf ❌

3. Klicke **"Save"**

## 📈 Schritt 5: Daten ansehen

### Option A: Im CloudKit Dashboard

1. Klicke auf **"Data"** (linke Sidebar)
2. Wähle **"Public Database"** (Dropdown oben)
3. Wähle **"AppAnalytics"** oder **"AppEvents"** aus dem Dropdown
4. Du siehst alle gesendeten Daten!

**Filter verwenden**:
- Klicke auf **"Query"** → **"Add Filter"**
- Beispiel: `timestamp > 2025-01-01` (nur Daten ab 2025)

**Exportieren**:
- Klicke auf **"Export"** → Wähle Format (JSON/CSV)
- Daten werden heruntergeladen

### Option B: Query im Dashboard

1. Klicke auf **"Data"** → **"Query"**
2. Wähle Record Type: `AppAnalytics`
3. Klicke **"Run Query"**
4. Du siehst alle Einträge

**Erweiterte Queries**:
```
// Alle Quiz-Statistiken der letzten 7 Tage
timestamp > DATE_SUB(NOW(), INTERVAL 7 DAY)

// Nur Daten von Version 1.0
appVersion = "1.0"

// Sortiert nach Punkten (höchste zuerst)
SORT BY totalPoints DESC
```

## 📊 Schritt 6: Dashboard-Ansichten erstellen

### Einfache Statistik-Ansicht

1. Im Dashboard: **"Data"** → **"Query"**
2. Record Type: `AppAnalytics`
3. Klicke **"Run Query"**
4. Du siehst eine Tabelle mit allen Daten

**Aggregationen** (Summen, Durchschnitte):

CloudKit Dashboard unterstützt keine direkten Aggregationen, aber du kannst:

1. **Exportieren** → JSON/CSV
2. In Excel/Numbers öffnen
3. Pivot-Tabellen erstellen

### Beispiel-Aggregationen:

**Gesamt Quiz aller User:**
- Exportiere alle `AppAnalytics` Records
- Summiere `totalQuizzes` Spalte

**Durchschnittliche Punkte pro User:**
- Exportiere alle Records
- Berechne: `SUM(totalPoints) / COUNT(Records)`

## 🔄 Schritt 7: Automatische Updates

Die App sendet automatisch Daten, wenn:
- Ein Quiz erstellt wird
- Ein Quiz abgeschlossen wird
- (Optional) Täglich um Mitternacht

**Im Dashboard prüfen**:
1. **"Data"** → **"Public Database"** → **"AppAnalytics"**
2. Neue Einträge erscheinen automatisch (kein Refresh nötig)
3. Klicke **"Refresh"** um sicherzugehen

## 🛠️ Schritt 8: Troubleshooting

### Problem: "No records found"

**Mögliche Ursachen**:
1. App hat noch keine Daten gesendet
   - ✅ Prüfe: Wurde ein Quiz erstellt?
   - ✅ Prüfe: Ist die App mit Internet verbunden?
   
2. Berechtigungen falsch
   - ✅ Prüfe: Ist "World" Rolle erstellt?
   - ✅ Prüfe: Sind Create/Read erlaubt?

3. Record Type nicht erstellt
   - ✅ Prüfe: Existiert `AppAnalytics` Record Type?
   - ✅ Prüfe: Sind alle Felder korrekt?

### Problem: "Permission denied"

**Lösung**:
1. Gehe zu **"Security Roles"**
2. Prüfe **"World"** Rolle
3. Stelle sicher, dass **"Create"** erlaubt ist

### Problem: "Field not found"

**Lösung**:
1. Gehe zu **"Schema"** → **"Record Types"**
2. Wähle `AppAnalytics`
3. Prüfe, ob alle Felder existieren
4. Falls nicht: Füge fehlende Felder hinzu

## 📱 Schritt 9: Daten in eigener App anzeigen

Du kannst auch eine separate Dashboard-App erstellen, die die Public Database liest:

```swift
import CloudKit

let container = CKContainer(identifier: "iCloud.com.akeschmidi.PubRanker")
let publicDatabase = container.publicCloudDatabase

// Query für alle Analytics
let query = CKQuery(recordType: "AppAnalytics", predicate: NSPredicate(value: true))
query.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]

publicDatabase.perform(query) { records, error in
    if let records = records {
        for record in records {
            let totalQuizzes = record["totalQuizzes"] as? Int ?? 0
            let totalTeams = record["totalTeams"] as? Int ?? 0
            // ... verarbeite Daten
        }
    }
}
```

## 🎨 Schritt 10: Visuelles Dashboard (Web)

Für ein schönes Web-Dashboard kannst du:

1. **CloudKit JS** verwenden (offiziell von Apple)
2. Oder die Daten exportieren und in einem Tool visualisieren:
   - **Google Data Studio**
   - **Tableau**
   - **Excel/Numbers** mit Charts

### Beispiel: Einfaches HTML Dashboard

```html
<!DOCTYPE html>
<html>
<head>
    <title>PubRanker Analytics</title>
    <script src="https://cdn.apple-cloudkit.com/ck/2/cloudkit.js"></script>
</head>
<body>
    <h1>📊 PubRanker Analytics</h1>
    <div id="stats"></div>
    
    <script>
        CloudKit.configure({
            containers: [{
                identifier: 'iCloud.com.akeschmidi.PubRanker',
                environment: 'production'
            }]
        });
        
        const container = CloudKit.getDefaultContainer();
        const publicDB = container.publicCloudDatabase;
        
        // Query ausführen
        const query = {
            recordType: 'AppAnalytics',
            sortBy: [{ fieldName: 'timestamp', direction: 'DESCENDING' }],
            resultsLimit: 100
        };
        
        publicDB.performQuery(query).then(response => {
            const records = response.records;
            let totalQuizzes = 0;
            let totalTeams = 0;
            let totalRounds = 0;
            let totalPoints = 0;
            
            records.forEach(record => {
                totalQuizzes += record.fields.totalQuizzes.value || 0;
                totalTeams += record.fields.totalTeams.value || 0;
                totalRounds += record.fields.totalRounds.value || 0;
                totalPoints += record.fields.totalPoints.value || 0;
            });
            
            document.getElementById('stats').innerHTML = `
                <h2>Gesamt-Statistiken</h2>
                <p>Quiz: ${totalQuizzes}</p>
                <p>Teams: ${totalTeams}</p>
                <p>Runden: ${totalRounds}</p>
                <p>Punkte: ${totalPoints}</p>
            `;
        });
    </script>
</body>
</html>
```

## ✅ Checkliste

- [ ] CloudKit Dashboard geöffnet
- [ ] Container gefunden
- [ ] Record Type `AppAnalytics` erstellt
- [ ] Record Type `AppEvents` erstellt
- [ ] Alle Felder hinzugefügt
- [ ] "World" Rolle erstellt
- [ ] Berechtigungen gesetzt (Create + Read)
- [ ] App getestet (Quiz erstellt)
- [ ] Daten im Dashboard sichtbar
- [ ] Export funktioniert

## 🔗 Nützliche Links

- **CloudKit Dashboard**: [https://icloud.developer.apple.com/](https://icloud.developer.apple.com/)
- **CloudKit Dokumentation**: [https://developer.apple.com/documentation/cloudkit](https://developer.apple.com/documentation/cloudkit)
- **CloudKit JS**: [https://developer.apple.com/documentation/cloudkitjs](https://developer.apple.com/documentation/cloudkitjs)

## 💡 Tipps

1. **Testen in Development**: Nutze zuerst die Development-Umgebung im Dashboard
2. **Daten bereinigen**: Alte Test-Daten können gelöscht werden (Data → Delete)
3. **Monitoring**: Prüfe regelmäßig, ob Daten ankommen
4. **Backup**: Exportiere regelmäßig die Daten als Backup

---

**Fragen?** Die CloudKit Dokumentation ist sehr umfangreich: [Apple Developer Documentation](https://developer.apple.com/documentation/cloudkit)




