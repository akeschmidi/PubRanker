# 📋 App Store Connect Checkliste

## ✅ Vor dem Upload

### 1. App-Informationen bereit?
- [ ] App Name: `PubRanker - Pub Quiz Manager`
- [ ] Bundle ID: `com.akeschmidi.PubRanker`
- [ ] Version: `1.0.0`
- [ ] Build Number: `1`

### 2. Xcode Archive erstellt?
- [ ] Product → Archive ausgeführt
- [ ] Archive erfolgreich erstellt
- [ ] Im Organizer sichtbar

### 3. Marketing-Materialien bereit?
- [ ] Screenshots (3-5 Stück, 2880x1800 Pixel)
- [ ] App Icon wird automatisch aus Assets verwendet
- [ ] Beschreibungstexte kopiert aus `AppStore-Kopiervorlagen.txt`
- [ ] Keywords bereit

---

## 📱 App Store Connect Schritte

### Schritt 1: Neue App anlegen

1. Gehen Sie zu [App Store Connect](https://appstoreconnect.apple.com)
2. **Meine Apps** → **+** → **Neue App**
3. Ausfüllen:
   - **Plattform**: macOS
   - **Name**: `PubRanker - Pub Quiz Manager`
   - **Primäre Sprache**: Deutsch
   - **Bundle ID**: `com.akeschmidi.PubRanker`
   - **SKU**: `pubranker-001` (Ihre Wahl)
   - **Benutzerzugriff**: Vollständiger Zugriff

### Schritt 2: App-Informationen

**Allgemein → App-Informationen**

- **Name**: `PubRanker - Pub Quiz Manager`
- **Untertitel**: `Quiz-Punkte einfach verwalten`
- **Kategorien**:
  - Primär: Produktivität
  - Sekundär: Unterhaltung

**Datenschutz**

- **Datenschutz-URL**: (Optional) `https://github.com/akeschmidi/PubRanker`
- **Datenschutzangaben**: 
  - Sammeln Sie Daten? → **Nein**
  - Alle Daten bleiben lokal auf dem Gerät

### Schritt 3: Preise und Verfügbarkeit

- **Preis**: 
  - Empfohlen: **€4,99** oder **€9,99**
  - Alternative: **Kostenlos**
- **Verfügbarkeit**: Alle Länder

### Schritt 4: Version vorbereiten

**1.0 - Vorbereitung für Einreichung**

#### Screenshots
- Laden Sie 3-5 Screenshots hoch (2880 x 1800 Pixel)
- Reihenfolge wie in `AppStore-Marketing.md` beschrieben

#### App-Vorschau (Optional)
- Kann später hinzugefügt werden
- Videogröße: 1920 x 1080 oder 2880 x 1800

#### Werbematerial-Text (Promotional Text)
```
Neu: Geteilte Plätze! Teams mit gleicher Punktzahl teilen sich den Rang. Perfekt für faire Quiz-Veranstaltungen. Jetzt mit Auto-Save für alle Punkteingaben!
```

#### Beschreibung
Kopieren aus: `AppStore-Kopiervorlagen.txt` → Abschnitt 5

#### Keywords
```
pub quiz,trivia,quiz manager,punkteverwaltung,quiz veranstalter,pub night,rangliste,team quiz,quiz app,scoreboard
```

#### Support-URL
```
https://github.com/akeschmidi/PubRanker
```

#### Marketing-URL (Optional)
```
https://github.com/akeschmidi/PubRanker
```

#### Neuerungen in dieser Version
Kopieren aus: `AppStore-Kopiervorlagen.txt` → Abschnitt 6

### Schritt 5: Build auswählen

1. **Build** → **+** (Plus-Symbol)
2. Warten Sie, bis Ihr Upload verarbeitet wurde (5-15 Minuten)
3. Build auswählen aus der Liste
4. Exportvorschriften-Compliance beantworten:
   - **Verwendet Verschlüsselung?**: Nein
   - (SwiftData nutzt lokale Verschlüsselung, aber keine Export-relevante)

### Schritt 6: Altersfreigabe

- **Altersfreigabe**: 4+
- Alle Fragen mit "Nein" beantworten
- (Keine Gewalt, keine anstößigen Inhalte, etc.)

### Schritt 7: Überprüfungsinformationen

- **Kontaktinformationen**: Ihre E-Mail und Telefon
- **Notizen für Prüfung** (optional):
```
PubRanker ist eine Offline-App für Pub Quiz Veranstalter.
Alle Daten werden lokal mit SwiftData gespeichert.
Keine Anmeldung erforderlich.

Testhinweise:
1. Erstellen Sie ein Quiz
2. Fügen Sie Teams über den Wizard hinzu
3. Erstellen Sie Runden
4. Geben Sie Punkte ein
5. Sehen Sie die Rangliste

Die App funktioniert komplett offline.
```

### Schritt 8: Versionsfreigabe

- **Automatisch freigeben**: Ja (empfohlen)
- **Phasenweise Freigabe**: Optional

### Schritt 9: Zur Überprüfung einreichen

**Finale Checkliste:**
- [ ] Alle Felder ausgefüllt
- [ ] Screenshots hochgeladen
- [ ] Build ausgewählt
- [ ] Beschreibung korrekt
- [ ] Keywords eingetragen
- [ ] Preis festgelegt

**→ Klick auf "Zur Überprüfung einreichen"**

---

## ⏱️ Zeitplan

| Phase | Dauer | Status |
|-------|-------|--------|
| Upload Processing | 5-15 Min | 🟡 Warten |
| In Überprüfung | 1-3 Tage | 🟡 Warten |
| Überprüfung | 1-2 Tage | 🟡 Apple prüft |
| Im App Store | Sofort | ✅ Live! |

**Gesamt: 2-5 Tage typischerweise**

---

## 🚨 Häufige Ablehnungsgründe

### 1. Fehlende Funktionalität
**Problem**: App ist zu einfach oder nicht funktional genug
**Lösung**: PubRanker hat umfangreiche Features ✅

### 2. Fehlende Metadaten
**Problem**: Screenshots fehlen oder Beschreibung unvollständig
**Lösung**: Alle Texte aus Kopiervorlagen verwenden ✅

### 3. Privacy-Probleme
**Problem**: Unklare Datenschutzrichtlinien
**Lösung**: Alle Daten lokal, keine Collection ✅

### 4. Crash beim Start
**Problem**: App startet nicht
**Lösung**: Vor Upload testen! ✅

### 5. Fehlende Sandbox-Entitlements
**Problem**: App Sandbox fehlt
**Lösung**: Bereits implementiert! ✅

---

## 📊 Nach der Freigabe

### Sofort:
- [ ] App im Store überprüfen
- [ ] Link teilen auf Social Media
- [ ] Screenshot machen vom Live-Store-Eintrag

### Diese Woche:
- [ ] Freunde/Familie bitten um Reviews
- [ ] Social Media Posts veröffentlichen
- [ ] App-Website aktualisieren (falls vorhanden)

### Laufend:
- [ ] Rezensionen überwachen und beantworten
- [ ] Feedback sammeln für Updates
- [ ] Downloads und Statistiken verfolgen

---

## 💡 Optimierungs-Tipps

### Keywords optimieren
- Nach 2-3 Wochen überprüfen
- In App Store Connect → App Analytics
- Schlecht performende Keywords austauschen

### Screenshots aktualisieren
- Basierend auf Benutzer-Feedback
- Beste Features in den Vordergrund
- A/B Testing über phasenweise Freigabe

### Beschreibung verbessern
- Top-Rezensionen einarbeiten
- Häufige Fragen beantworten
- Neue Features hervorheben

### Preisoptierung
- Einführungspreis eventuell senken
- Nach Launch-Phase anpassen
- Saisonale Aktionen erwägen

---

## 📞 Support bei Problemen

### Apple Developer Support
- https://developer.apple.com/support/
- Telefon: Über Developer Portal
- Forum: https://developer.apple.com/forums/

### Häufige Probleme & Lösungen

**"Build wird nicht angezeigt"**
→ Warten Sie 15-30 Minuten nach Upload

**"Sandbox-Fehler"**
→ Entitlements-Datei prüfen (bereits implementiert ✅)

**"Missing Compliance"**
→ Export Compliance in Build ausfüllen

**"Rejected - 2.1 Performance"**
→ Mehr Features zeigen in Screenshots

---

## 🎉 Erfolg!

Wenn Ihre App genehmigt wurde:

1. **Gratulation!** 🎊
2. Teilen Sie den Link überall
3. Bitten Sie um ehrliche Reviews
4. Planen Sie Updates
5. Genießen Sie den Erfolg!

**App Store Link Format:**
```
https://apps.apple.com/de/app/pubranker/id[IHRE-APP-ID]
```

---

**Viel Erfolg mit PubRanker! 🚀**
