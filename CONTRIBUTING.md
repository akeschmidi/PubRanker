# Contributing zu PubRanker

Vielen Dank für Ihr Interesse, zu PubRanker beizutragen! 🎯

## Wie kann ich beitragen?

### Bug Reports 🐛

Wenn Sie einen Bug finden, erstellen Sie bitte ein Issue mit:
- Beschreibung des Problems
- Schritte zur Reproduktion
- Erwartetes vs. tatsächliches Verhalten
- Screenshots (falls relevant)
- System-Info (macOS/iOS Version, Xcode Version)

### Feature Requests 💡

Für neue Feature-Vorschläge:
- Beschreiben Sie das gewünschte Feature
- Erklären Sie den Use Case
- Skizzen/Mockups sind willkommen

### Pull Requests 🔧

1. **Fork & Clone**
   ```bash
   git clone https://github.com/akeschmidi/PubRanker.git
   cd PubRanker
   ```

2. **Branch erstellen**
   ```bash
   git checkout -b feature/your-feature-name
   # oder
   git checkout -b fix/bug-description
   ```

3. **Entwickeln**
   - Folgen Sie den Swift-Konventionen
   - Schreiben Sie klaren, dokumentierten Code
   - Testen Sie Ihre Änderungen gründlich

4. **Commit**
   ```bash
   git add .
   git commit -m "feat: Add team color customization"
   ```

5. **Push & PR**
   ```bash
   git push origin feature/your-feature-name
   ```
   Dann öffnen Sie einen Pull Request auf GitHub.

## Code-Stil

### Swift Conventions
- Verwenden Sie aussagekräftige Variablen- und Funktionsnamen
- Kommentieren Sie komplexe Logik
- Folgen Sie Swift API Design Guidelines

### SwiftUI Best Practices
- Halten Sie Views klein und fokussiert
- Extrahieren Sie wiederverwendbare Components
- Nutzen Sie `@Bindable`, `@Observable` für State Management

### Commit Messages
Folgen Sie dem [Conventional Commits](https://www.conventionalcommits.org/) Format:
- `feat:` Neue Features
- `fix:` Bug Fixes
- `docs:` Dokumentation
- `style:` Code-Formatierung
- `refactor:` Code-Refactoring
- `test:` Tests
- `chore:` Build-Prozess, Dependencies

Beispiele:
```
feat: Add PDF export for quiz results
fix: Resolve crash when deleting active round
docs: Update README with installation steps
```

## Projekt-Setup

1. Xcode 15.0+ installieren
2. Projekt öffnen: `open PubRanker.xcodeproj`
3. Dependencies werden automatisch aufgelöst
4. Build & Run: `Cmd + R`

## Testing

- Führen Sie Unit Tests aus: `Cmd + U`
- Testen Sie auf macOS und iOS/iPadOS
- Prüfen Sie verschiedene Szenarien (leere States, viele Teams, etc.)

## Review-Prozess

1. PR wird erstellt
2. Automatische Checks laufen (wenn konfiguriert)
3. Code Review durch Maintainer
4. Änderungen implementieren (falls notwendig)
5. Merge!

## Fragen?

Bei Fragen oder Unklarheiten:
- Öffnen Sie ein Discussion auf GitHub
- Kommentieren Sie im relevanten Issue

Vielen Dank für Ihren Beitrag! 🙏
