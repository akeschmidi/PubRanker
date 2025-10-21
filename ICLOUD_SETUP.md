# iCloud Backup Setup für PubRanker

## 🎯 Übersicht

PubRanker nutzt **iCloud** mit **CloudKit**, um automatisch alle Quiz-Daten über alle Geräte des Users zu synchronisieren. Die Daten werden sicher in der privaten iCloud-Datenbank des Users gespeichert.

## ✅ Was bereits implementiert ist

1. **Entitlements konfiguriert** (`PubRanker.entitlements`)
   - CloudKit aktiviert
   - iCloud Container konfiguriert
   
2. **SwiftData mit CloudKit** (`PubRankerApp.swift`)
   - ModelContainer nutzt `.automatic` CloudKit Database
   - Alle Modelle (Quiz, Team, Round) werden automatisch synchronisiert

## 🔧 Erforderliche manuelle Schritte in Xcode

### Schritt 1: iCloud Capability aktivieren

1. Öffne das Projekt in Xcode
2. Wähle das **PubRanker** Target
3. Gehe zum Tab **"Signing & Capabilities"**
4. Klicke auf **"+ Capability"**
5. Wähle **"iCloud"** aus der Liste

### Schritt 2: CloudKit konfigurieren

Im iCloud Bereich:
1. ✅ Aktiviere **"CloudKit"**
2. Der Container `iCloud.com.akeschmidi.PubRanker` wird automatisch erstellt
3. (Optional) Überprüfe im CloudKit Dashboard: [https://icloud.developer.apple.com/](https://icloud.developer.apple.com/)

### Schritt 3: App ID und Provisioning Profile

**Wichtig:** iCloud erfordert ein explizites App ID (keine Wildcard).

1. Gehe zu [Apple Developer Portal](https://developer.apple.com/account/)
2. Stelle sicher, dass die App ID `com.akeschmidi.PubRanker` registriert ist
3. Aktiviere **iCloud** für diese App ID
4. Erstelle/aktualisiere das Provisioning Profile
5. Lade das neue Profile in Xcode herunter

## 📱 Wie es funktioniert

### Automatische Synchronisation

- **Speichern**: Jede Änderung an Quiz, Team oder Round wird lokal gespeichert und automatisch zu iCloud hochgeladen
- **Synchronisieren**: Änderungen von anderen Geräten werden automatisch heruntergeladen
- **Konfliktlösung**: SwiftData + CloudKit löst Konflikte automatisch

### Was wird synchronisiert?

Alle App-Daten:
- ✅ Alle Quizze (Name, Venue, Datum)
- ✅ Teams (Name, Farbe, Scores)
- ✅ Runden (Name, Punkte, Status)
- ✅ Gesamte Historie

### Datenbank-Typ

Die App verwendet `.automatic`, was bedeutet:
- **macOS**: Private CloudKit Database
- **iOS/iPadOS**: Private CloudKit Database
- Keine Shared Database (jeder User hat seine eigenen Daten)

## 🧪 Testing

### iCloud Sync testen

1. **Simulatoren**: 
   - Melde dich mit der gleichen Apple ID an
   - Stelle sicher, dass iCloud Drive aktiviert ist

2. **Echte Geräte**:
   - Installiere die App auf zwei Geräten
   - Melde dich mit der gleichen Apple ID an
   - Erstelle ein Quiz auf Gerät 1
   - Warte 2-3 Sekunden
   - Öffne die App auf Gerät 2 → Das Quiz sollte erscheinen

### Troubleshooting

**Problem: Daten werden nicht synchronisiert**
- ✅ iCloud Drive in iOS/macOS Einstellungen aktiviert?
- ✅ Korrekt mit Apple ID angemeldet?
- ✅ Internetverbindung vorhanden?
- ✅ iCloud Capability in Xcode aktiviert?
- ✅ Provisioning Profile aktuell?

**Problem: "CloudKit account not available"**
- Simulator: Settings → Apple ID → iCloud → iCloud Drive ON
- Gerät: Einstellungen → [Dein Name] → iCloud → iCloud Drive ON

## 🚀 Deployment

### App Store Submission

Beim Upload zur Review:
1. App Store Connect prüft automatisch die iCloud Entitlements
2. CloudKit Container wird automatisch provisioniert
3. Keine zusätzlichen Schritte erforderlich

### Privacy

iCloud ist DSGVO-konform:
- Daten bleiben in der privaten iCloud des Users
- Keine Server-seitige Verarbeitung durch uns
- User hat volle Kontrolle über seine Daten

## 📊 Daten-Migration

Bei existierenden App-Installationen:
- Lokale Daten bleiben erhalten
- Beim ersten Start mit iCloud werden lokale Daten hochgeladen
- Danach: Sync zwischen allen Geräten

## 🔒 Sicherheit

- ✅ Ende-zu-Ende verschlüsselt (Apple's iCloud Encryption)
- ✅ Nur der User kann auf seine Daten zugreifen
- ✅ Keine Third-Party Server
- ✅ Sandbox-konform

## 📝 Nächste Schritte

1. [x] Code implementiert
2. [ ] iCloud Capability in Xcode aktivieren
3. [ ] App auf Testgerät installieren
4. [ ] Sync zwischen zwei Geräten testen
5. [ ] Archive erstellen und zu App Store Connect hochladen
6. [ ] Submit zur Review

---

**Hinweis**: Nach dem Aktivieren der iCloud Capability in Xcode werden automatisch die entsprechenden Einträge im Xcode-Projekt gesetzt. Die Entitlements-Datei haben wir bereits vorbereitet.
