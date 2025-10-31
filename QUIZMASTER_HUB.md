# QuizMaster Hub - Neue App-Struktur

## Übersicht

Die PubRanker App wurde komplett umstrukturiert, um als zentraler Hub für QuizMaster zu dienen. Die App ist jetzt in **drei Hauptphasen** organisiert, die den natürlichen Workflow eines Quiz widerspiegeln.

## 🎯 Die drei Workflow-Phasen

### 1. **Planen** 📅
*Quiz vorbereiten und konfigurieren*

**Funktionen:**
- Neues Quiz erstellen mit Name, Ort und Datum
- Teams hinzufügen und verwalten
- Runden definieren mit maximalen Punktzahlen
- Übersicht über die Vorbereitung
- Status-Check: Zeigt an, ob Quiz startbereit ist

**Navigation:**
- Sidebar: Liste aller geplanten Quiz
- Detail: Konfigurations-Interface für ausgewähltes Quiz
- Quick-Actions: Direkt Teams und Runden hinzufügen

**Workflow:**
```
Quiz erstellen → Teams hinzufügen → Runden definieren → Quiz starten
```

---

### 2. **Durchführen** ▶️
*Live-Quiz Management*

**Funktionen:**
- Live-Anzeige aller aktiven Quiz
- Echtzeit-Rangliste
- Schnelle Punkteeingabe
- Fortschrittsanzeige (Runden-Status)
- Runden-Übersicht mit Status
- Quiz beenden

**Live-Features:**
- 🔴 Live-Indikator für aktive Quiz
- Aktuelle Runde wird hervorgehoben
- Progress-Bar zeigt Fortschritt
- Schnellzugriff auf Punkteeingabe

**Tabs:**
- **Rangliste**: Aktuelle Platzierungen in Echtzeit
- **Punkte eingeben**: Scores für aktuelle Runde
- **Übersicht**: Runden-Status und Statistiken

---

### 3. **Auswerten** 📊
*Ergebnisse analysieren und exportieren*

**Funktionen:**
- Siegertreppchen (Top 3 Podium)
- Vollständige Ergebnistabelle
- Detaillierte Statistiken
- Runden-für-Runden Analyse
- Export als JSON oder CSV
- Teilen und archivieren

**Statistiken:**
- Teilnehmerzahl
- Höchste Punktzahl
- Durchschnittswerte
- Gesamt- und Max-Punkte
- Pro-Runden-Analyse mit Top-Scorer

**Export-Optionen:**
- **JSON**: Vollständige Daten-Export
- **CSV**: Tabellen für Excel/Numbers
- Direktes Teilen via macOS Share-Sheet

---

## 🎨 UI/UX Design

### Hauptnavigation
- **Zentraler Header** mit drei Phasen-Tabs
- **Segmented Control** für schnellen Phasenwechsel
- **Visuell unterschiedliche Icons** für jede Phase:
  - Planen: `calendar.badge.plus`
  - Durchführen: `play.circle.fill`
  - Auswerten: `chart.bar.fill`

### Navigation Pattern
- **NavigationSplitView** für alle Phasen
- **Sidebar**: Filterte Quiz-Listen pro Phase
- **Detail**: Phasen-spezifische Ansicht

### Visuelle Highlights
- **Live-Indicator**: Pulsierender grüner Punkt
- **Fortschrittsbalken**: Zeigt Quiz-Completion
- **Siegertreppchen**: Podium mit 1./2./3. Platz
- **Farbcodierte Stats**: Orange, Blau, Grün für verschiedene Metriken

---

## 🔄 Quiz-Lifecycle

```
┌─────────────────────────────────────────────────┐
│              PLANUNG                            │
│  • Quiz erstellen                               │
│  • Teams & Runden konfigurieren                 │
│  • Status: !isActive && !isCompleted           │
└──────────────────┬──────────────────────────────┘
                   │ "Quiz starten" →
                   ↓
┌─────────────────────────────────────────────────┐
│           DURCHFÜHRUNG                          │
│  • Live-Punkte eingeben                         │
│  • Rangliste in Echtzeit                        │
│  • Status: isActive && !isCompleted            │
└──────────────────┬──────────────────────────────┘
                   │ "Quiz beenden" →
                   ↓
┌─────────────────────────────────────────────────┐
│            AUSWERTUNG                           │
│  • Ergebnisse analysieren                       │
│  • Statistiken anzeigen                         │
│  • Export & Archiv                              │
│  • Status: !isActive && isCompleted            │
└─────────────────────────────────────────────────┘
```

---

## 💡 Neue Features im Detail

### Intelligente Filter
- **Planungsphase**: Zeigt nur geplante Quiz (`!isActive && !isCompleted`)
- **Durchführungsphase**: Zeigt nur aktive Quiz (`isActive && !isCompleted`)
- **Auswertungsphase**: Zeigt nur abgeschlossene Quiz (`isCompleted`)

### Kontextbezogene Actions
Jede Phase hat ihre eigenen relevanten Aktionen:
- **Planen**: "Neues Quiz", "Teams/Runden hinzufügen", "Starten"
- **Durchführen**: "Punkte eingeben", "Runde abschließen", "Beenden"
- **Auswerten**: "Export JSON/CSV", "Teilen", "Im Finder zeigen"

### Statistik-Dashboard (Auswerten)
- **Übersichtskarten**: Teilnehmer, Runden, Höchstwerte
- **Siegertreppchen**: Visuelles Podium für Top 3
- **Runden-Breakdown**: Detaillierte Analyse pro Runde
- **Durchschnittswerte**: Team- und Runden-Statistiken

---

## 🛠 Technische Architektur

### Neue Dateien
```
PubRanker/Views/
├── ContentView.swift        # Hauptnavigation mit drei Phasen
├── PlanningView.swift       # Planungsphase
├── ExecutionView.swift      # Durchführungsphase
└── AnalysisView.swift       # Auswertungsphase
```

### SwiftData Queries
Jede Phase nutzt optimierte Queries:

```swift
// PlanningView
@Query(filter: #Predicate<Quiz> { !$0.isActive && !$0.isCompleted })
private var plannedQuizzes: [Quiz]

// ExecutionView  
@Query(filter: #Predicate<Quiz> { $0.isActive && !$0.isCompleted })
private var activeQuizzes: [Quiz]

// AnalysisView
@Query(filter: #Predicate<Quiz> { $0.isCompleted })
private var completedQuizzes: [Quiz]
```

### State Management
- **Quiz.isActive**: Markiert aktives Quiz
- **Quiz.isCompleted**: Markiert abgeschlossenes Quiz
- **Quiz.progress**: Berechnet automatisch Fortschritt (0.0 - 1.0)

---

## 📱 Keyboard Shortcuts

### Global
- `⌘N` - Neues Quiz erstellen
- `?` - Hilfe anzeigen

### Durchführung
- `⌘S` - Quiz starten (in Planung)
- `⌘E` - Quiz beenden (in Durchführung)

---

## 🎯 Verwendung

### Als QuizMaster - Kompletter Workflow

#### 1. Vorbereitung (Planen)
1. Wähle Phase **"Planen"**
2. Klicke **"+ Neues Quiz"**
3. Fülle Name, Ort, Datum aus
4. Klicke **"Teams hinzufügen"** → Füge alle Teilnehmer hinzu
5. Klicke **"Runden definieren"** → Erstelle Runden mit Punktzahlen
6. Klicke **"Quiz starten"** → Wechselt automatisch zur Durchführung

#### 2. Live-Quiz (Durchführen)
1. App zeigt automatisch aktives Quiz
2. Wähle Tab **"Punkte eingeben"**
3. Gib Punkte für aktuelle Runde ein
4. Schließe Runde ab
5. Wiederhole für alle Runden
6. Prüfe **"Rangliste"** für Live-Standings
7. Klicke **"Beenden"** → Wechselt zur Auswertung

#### 3. Nachbereitung (Auswerten)
1. Sieh dir **Siegertreppchen** an
2. Prüfe **Statistiken**
3. Analysiere **Runden-Details**
4. Exportiere als **JSON** oder **CSV**
5. Teile Ergebnisse mit Teilnehmern

---

## 🎨 Visuelle Identität

### Farbschema pro Phase
- **Planen**: Blau/Cyan (Vorbereitung)
- **Durchführen**: Grün/Rot (Aktiv/Live)
- **Auswerten**: Orange/Gelb (Erfolg/Trophäe)

### Icons
- Planen: `calendar.badge.plus`
- Durchführen: `play.circle.fill`, Live-Dot 🔴
- Auswerten: `trophy.fill`, `chart.bar.fill`

---

## 🚀 Vorteile der neuen Struktur

### Für den QuizMaster
✅ **Klarer Workflow**: Drei logische Schritte
✅ **Fokus**: Nur relevante Quiz pro Phase
✅ **Schnelligkeit**: Weniger Klicks, direktere Navigation
✅ **Übersicht**: Bessere Orientierung im Quiz-Lifecycle
✅ **Live-Feedback**: Echtzeit-Updates während Durchführung

### Technisch
✅ **Performance**: Optimierte Queries pro Phase
✅ **Skalierbar**: Einfach erweiterbar
✅ **Wartbar**: Klare Trennung der Verantwortlichkeiten
✅ **Testbar**: Isolierte Komponenten

---

## 📋 Migration von alter Struktur

### Was hat sich geändert?
- **Alte Struktur**: Eine große QuizListView mit allen Quiz
- **Neue Struktur**: Drei spezialisierte Views mit gefilterten Listen

### Datenkompatibilität
✅ Alle bestehenden Quiz bleiben erhalten
✅ Keine Datenbank-Migration nötig
✅ Quiz werden automatisch der richtigen Phase zugeordnet

---

## 🎓 Best Practices

### Workflow-Empfehlung
1. **Plane** mehrere Quiz im Voraus
2. **Starte** ein Quiz wenn bereit
3. **Führe durch** mit Live-Updates
4. **Werte aus** nach Abschluss
5. **Archiviere** oder exportiere für Rekorde

### Tipps
- Nutze die **Keyboard Shortcuts** für schnellere Bedienung
- **Export** Ergebnisse regelmäßig als Backup
- Prüfe **Statistiken** für bessere zukünftige Planung
- Nutze **Siegertreppchen** für feierliche Verkündung

---

**Erstellt**: 31.10.2025  
**Version**: 2.0.0  
**Autor**: PubRanker Team
