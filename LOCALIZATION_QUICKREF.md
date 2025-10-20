# 🌍 Lokalisierungs Quick Reference

Schnellübersicht für die Verwendung der Lokalisierung in PubRanker.

## 📱 Unterstützte Sprachen

| Flag | Sprache | Code |
|------|---------|------|
| 🇩🇪 | Deutsch | `de` |
| 🇬🇧 | Englisch | `en` |
| 🇪🇸 | Spanisch | `es` |
| 🇫🇷 | Französisch | `fr` |
| 🇮🇹 | Italienisch | `it` |

---

## 💻 Verwendung im Code

### Einfache Strings

```swift
// Navigation
Text(L10n.Navigation.save)      // "Speichern" / "Save" / "Guardar"
Button(L10n.Navigation.cancel)  // "Abbrechen" / "Cancel" / "Annuler"

// Quiz
Text(L10n.Quiz.title)           // "Quiz"
Text(L10n.Quiz.new)             // "Neues Quiz" / "New Quiz"

// Teams
Text(L10n.Team.title)           // "Teams" / "Équipes"
Text(L10n.Team.management)      // "Team-Verwaltung" / "Team Management"
```

### Formatierte Strings

```swift
// Mit Anzahl
Text(L10n.Team.count(12))       // "12 Teams"
Text(L10n.Round.number(3))      // "Runde 3" / "Round 3"

// Mit Platzhalter
let message = L10n.Team.Delete.message("Quiz Masters")
// "Quiz Masters wird aus dem Quiz entfernt."
// "Quiz Masters will be removed from the quiz."
```

---

## 🎯 Häufig verwendete Strings

### Navigation & Buttons
| Code | DE | EN | ES | FR | IT |
|------|----|----|----|----|-----|
| `L10n.Navigation.back` | Zurück | Back | Atrás | Retour | Indietro |
| `L10n.Navigation.save` | Speichern | Save | Guardar | Enregistrer | Salva |
| `L10n.Navigation.cancel` | Abbrechen | Cancel | Cancelar | Annuler | Annulla |
| `L10n.Navigation.delete` | Löschen | Delete | Eliminar | Supprimer | Elimina |
| `L10n.Navigation.add` | Hinzufügen | Add | Añadir | Ajouter | Aggiungi |

### Quiz
| Code | DE | EN | ES |
|------|----|----|-----|
| `L10n.Quiz.new` | Neues Quiz | New Quiz | Nuevo Quiz |
| `L10n.Quiz.teams` | Teams | Teams | Equipos |
| `L10n.Quiz.rounds` | Runden | Rounds | Rondas |

### Leaderboard
| Code | DE | EN | ES |
|------|----|----|-----|
| `L10n.Leaderboard.title` | Rangliste | Leaderboard | Clasificación |
| `L10n.Leaderboard.winner` | Gewinner | Winner | Ganador |
| `L10n.Leaderboard.podium` | Podium | Podium | Podio |

### Status
| Code | DE | EN | ES |
|------|----|----|-----|
| `L10n.Round.Status.active` | Aktiv | Active | Activa |
| `L10n.Round.Status.completed` | Abgeschlossen | Completed | Completada |
| `L10n.Round.Status.pending` | Ausstehend | Pending | Pendiente |

---

## 📋 Code-Snippets

### Alert mit Lokalisierung

```swift
.alert(L10n.Quiz.Delete.confirm, isPresented: $showAlert) {
    Button(L10n.Navigation.cancel, role: .cancel) { }
    Button(L10n.Navigation.delete, role: .destructive) {
        deleteQuiz()
    }
} message: {
    Text(L10n.Quiz.Delete.message)
}
```

### TextField mit Placeholder

```swift
TextField(L10n.Placeholder.quizName, text: $quizName)
TextField(L10n.Placeholder.teamName, text: $teamName)
TextField(L10n.Placeholder.points, text: $points)
```

### NavigationTitle

```swift
.navigationTitle(L10n.Quiz.title)
.navigationTitle(L10n.Leaderboard.title)
.navigationTitle(L10n.Team.management)
```

### Empty State

```swift
VStack {
    Text(L10n.Empty.noTeams)
        .font(.title2)
    Text(L10n.Empty.noTeamsMessage)
        .foregroundColor(.secondary)
    Button(L10n.Team.new) { }
}
```

### Error Messages

```swift
if quizName.isEmpty {
    Text(L10n.Error.nameRequired)
        .foregroundColor(.red)
}

if saveError {
    Text(L10n.Error.saveFailed)
}
```

---

## 🧪 Testing in verschiedenen Sprachen

### Xcode Scheme

```bash
1. Product → Scheme → Edit Scheme...
2. Run → Options → App Language
3. Sprache wählen
4. Run (⌘+R)
```

### Simulator

```bash
1. Settings → General → Language & Region
2. iPhone Language → Sprache wählen
3. App neu starten
```

### Command Line

```swift
// In Xcode Scheme → Arguments Passed On Launch:
-AppleLanguages (de)    // Deutsch
-AppleLanguages (en)    // Englisch
-AppleLanguages (es)    // Spanisch
-AppleLanguages (fr)    // Französisch
-AppleLanguages (it)    // Italienisch
```

---

## 🔍 String suchen

Wenn Sie nicht sicher sind welcher Key zu verwenden ist:

```bash
# Alle Keys anzeigen
cat PubRanker/de.lproj/Localizable.strings | grep "^\"" | cut -d'"' -f2

# Nach Kategorie suchen
grep "quiz\." PubRanker/de.lproj/Localizable.strings
grep "team\." PubRanker/de.lproj/Localizable.strings
grep "round\." PubRanker/de.lproj/Localizable.strings
```

---

## 📚 Dokumentation

- **Vollständige Anleitung**: `LOCALIZATION_GUIDE.md`
- **Xcode Setup**: `LOCALIZATION_XCODE_SETUP.md`
- **Alle Strings**: `PubRanker/*/Localizable.strings`

---

## ✅ Quick Checklist

Neue View mit Lokalisierung:

- [ ] Import SwiftUI
- [ ] Verwende `L10n.*` statt Hardcoded Strings
- [ ] Navigation Title lokalisiert
- [ ] Button Labels lokalisiert
- [ ] Placeholders lokalisiert
- [ ] Error Messages lokalisiert
- [ ] Test in mindestens 2 Sprachen

---

**Happy Coding! 🚀**
