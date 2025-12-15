# PubRanker iPad-Migration

Dieses Dokument beschreibt alle notwendigen Schritte, um PubRanker als universelle App auch auf dem iPad lauffähig zu machen.

---

## 📋 Übersicht

| Aspekt | Aktueller Stand | Ziel |
|--------|-----------------|------|
| **Plattform** | macOS only | macOS + iPadOS (Universal) |
| **Deployment Target** | macOS 14.0+ | macOS 14.0+ / iPadOS 17.0+ |
| **UI Framework** | SwiftUI + AppKit | SwiftUI (plattformübergreifend) |
| **Architektur** | MVVM | MVVM (unverändert) |

---

## 🔧 Phase 1: Xcode Projekt-Konfiguration

### 1.1 Target-Einstellungen
- [ ] **Neues Target hinzufügen** oder bestehendes Target erweitern
  - `Project` → `Targets` → `PubRanker` → `Supported Destinations`
  - iPad hinzufügen
- [ ] **Deployment Target setzen**: iPadOS 17.0 (für SwiftData-Kompatibilität)
- [ ] **Bundle Identifier**: Gleicher Identifier für Universal App

### 1.2 Capabilities (Entitlements)
- [ ] **iCloud** für iPadOS aktivieren (CloudKit Database)
- [ ] **App Groups** prüfen (falls für Datenaustausch benötigt)
- [ ] Separates Entitlements-File für iOS erstellen falls nötig

### 1.3 Info.plist für iOS
```xml
<key>UIRequiresFullScreen</key>
<false/>
<key>UISupportedInterfaceOrientations~ipad</key>
<array>
    <string>UIInterfaceOrientationLandscapeLeft</string>
    <string>UIInterfaceOrientationLandscapeRight</string>
    <string>UIInterfaceOrientationPortrait</string>
    <string>UIInterfaceOrientationPortraitUpsideDown</string>
</array>
<key>UILaunchScreen</key>
<dict/>
```

---

## 🎨 Phase 2: AppKit → UIKit Migration

### 2.1 Zu ersetzende AppKit-Imports

| Datei | Aktuell | Änderung |
|-------|---------|----------|
| `PubRankerApp.swift` | `import AppKit` | Conditional Import |
| `ContentView.swift` | `import AppKit` | Conditional Import |

**Lösung: Conditional Compilation**

```swift
#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
```

### 2.2 WindowAccessor entfernen/ersetzen

**Aktueller Code (nur macOS):**
```swift
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView { ... }
    func updateNSView(_ nsView: NSView, context: Context) {}
}
```

**Neuer Code (plattformübergreifend):**
```swift
#if os(macOS)
struct WindowAccessor: NSViewRepresentable {
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            if let window = view.window {
                window.titlebarAppearsTransparent = true
                window.titleVisibility = .hidden
                window.styleMask.insert(.fullSizeContentView)
                window.tabbingMode = .disallowed
            }
        }
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
}
#endif
```

### 2.3 PubRankerApp.swift anpassen

```swift
@main
struct PubRankerApp: App {
    @State private var viewModel = QuizViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(viewModel)
                #if os(macOS)
                .background(WindowAccessor())
                #endif
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowToolbarStyle(.unifiedCompact(showsTitle: false))
        #endif
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
```

---

## 📱 Phase 3: UI-Anpassungen

### 3.1 Layout-Constraints anpassen

**Aktuell in ContentView.swift:**
```swift
.frame(minWidth: 1000, minHeight: 100)
```

**Neu (adaptiv):**
```swift
#if os(macOS)
.frame(minWidth: 1000, minHeight: 600)
#else
.frame(minWidth: 320, minHeight: 480)
#endif
```

### 3.2 NavigationSplitView-Anpassungen

Die App verwendet bereits `NavigationSplitView`, was gut ist. Anpassungen:

| View | Aktuelle Breite | iPad-Anpassung |
|------|-----------------|----------------|
| `PlanningView` | min: 320, ideal: 380, max: 500 | ✅ Passt |
| `GlobalTeamsManagerView` | Standard | ✅ Passt |
| `ExecutionView` | Sidebar + Detail | Breitenprüfung bei 1200px → anpassen |

**ExecutionView Anpassung:**
```swift
// Aktuell:
if geometry.size.width > 1200 {
    // Live Leaderboard Sidebar
}

// Neu:
#if os(macOS)
if geometry.size.width > 1200 {
    // Live Leaderboard Sidebar
}
#else
if geometry.size.width > 900 && horizontalSizeClass == .regular {
    // Live Leaderboard Sidebar auf iPad
}
#endif
```

### 3.3 Size Classes verwenden

```swift
@Environment(\.horizontalSizeClass) private var horizontalSizeClass
@Environment(\.verticalSizeClass) private var verticalSizeClass

var isCompact: Bool {
    horizontalSizeClass == .compact
}
```

### 3.4 Grid-Layouts anpassen

**Aktuell (ExecutionView):**
```swift
LazyVGrid(columns: [
    GridItem(.flexible(), spacing: AppSpacing.xs),
    GridItem(.flexible(), spacing: AppSpacing.xs),
    GridItem(.flexible(), spacing: AppSpacing.xs)
], spacing: AppSpacing.xs)
```

**Neu (adaptiv):**
```swift
private var gridColumns: [GridItem] {
    #if os(macOS)
    return [
        GridItem(.flexible(), spacing: AppSpacing.xs),
        GridItem(.flexible(), spacing: AppSpacing.xs),
        GridItem(.flexible(), spacing: AppSpacing.xs)
    ]
    #else
    if horizontalSizeClass == .compact {
        return [GridItem(.flexible())]
    } else {
        return [
            GridItem(.flexible(), spacing: AppSpacing.xs),
            GridItem(.flexible(), spacing: AppSpacing.xs)
        ]
    }
    #endif
}
```

---

## 🎨 Phase 4: Design System Anpassungen

### 4.1 AppSpacing.swift erweitern

```swift
struct AppSpacing {
    // ... bestehende Werte ...
    
    // MARK: - Platform-spezifische Werte
    
    #if os(iOS)
    /// Screen edge padding - größer auf iPad für Touch
    static let screenPaddingAdaptive: CGFloat = 32
    
    /// Touch target minimum (44pt für iOS HIG)
    static let touchTarget: CGFloat = 44
    #else
    static let screenPaddingAdaptive: CGFloat = 24
    static let touchTarget: CGFloat = 28
    #endif
}
```

### 4.2 AppColors.swift NSColor → UIColor

```swift
#if canImport(AppKit)
import AppKit
typealias PlatformColor = NSColor
#elseif canImport(UIKit)
import UIKit
typealias PlatformColor = UIColor
#endif

extension Color {
    init(platformColor: PlatformColor) {
        #if canImport(AppKit)
        self.init(nsColor: platformColor)
        #else
        self.init(uiColor: platformColor)
        #endif
    }
}
```

### 4.3 cardStyle() Modifier anpassen

```swift
extension View {
    func cardStyle(
        background: Color = Color(platformColor: .controlBackgroundColor),
        padding: CGFloat = AppSpacing.cardPadding,
        cornerRadius: CGFloat = 12,
        shadow: Shadow = AppShadow.md
    ) -> some View {
        // ...
    }
}
```

**Problem:** `.controlBackgroundColor` existiert nicht auf iOS.

**Lösung:**
```swift
extension PlatformColor {
    static var adaptiveControlBackground: PlatformColor {
        #if canImport(AppKit)
        return .controlBackgroundColor
        #else
        return .secondarySystemGroupedBackground
        #endif
    }
}
```

---

## ⌨️ Phase 5: Eingabe-Anpassungen

### 5.1 Keyboard Shortcuts → iPad Keyboard

Die App verwendet `keyboardShortcut()` - das funktioniert auch auf iPad mit externer Tastatur.

```swift
.keyboardShortcut("p", modifiers: .command)  // ✅ Funktioniert
.keyboardShortcut(.return, modifiers: .command)  // ✅ Funktioniert
```

### 5.2 TextField-Anpassungen

**Aktuell (Score-Eingabe):**
```swift
TextField("0", text: $scoreBinding)
    .textFieldStyle(.plain)
    .font(.system(size: 32, weight: .bold, design: .rounded))
```

**Anpassung für iPad:**
```swift
TextField("0", text: $scoreBinding)
    #if os(iOS)
    .keyboardType(.numberPad)
    #endif
    .textFieldStyle(.plain)
    .font(.system(size: 32, weight: .bold, design: .rounded))
```

### 5.3 Touch Targets vergrößern

```swift
// Mindestgröße für Touch: 44x44pt
.frame(minWidth: AppSpacing.touchTarget, minHeight: AppSpacing.touchTarget)
```

---

## 🪟 Phase 6: Präsentationsmodus

### 6.1 PresentationWindowController ersetzen

**Aktueller Ansatz (macOS):**
- Separates NSWindow für Präsentation
- `PresentationWindowController.swift` mit AppKit

**iPad-Alternative:**
- Nutzung von AirPlay/External Display API
- SwiftUI-basierte Präsentation mit `WindowGroup`

```swift
#if os(iOS)
struct PresentationSceneDelegate: UIWindowSceneDelegate {
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        guard session.role == .windowExternalDisplayNonInteractive else { return }
        // Externe Anzeige Setup
    }
}
#endif
```

### 6.2 Alternative: In-App Vollbild

```swift
@State private var isPresentationMode = false

var body: some View {
    if isPresentationMode {
        PresentationModeView(quiz: selectedQuiz)
            .statusBarHidden(true)
            .persistentSystemOverlays(.hidden)
    } else {
        // Normale View
    }
}
```

---

## 📧 Phase 7: EmailService Anpassung

### 7.1 Aktueller Stand (macOS)

```swift
// Verwendet NSSharingService oder mailto:
```

### 7.2 iOS-Implementierung

```swift
#if os(iOS)
import MessageUI

struct MailView: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    let emailData: EmailData
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients(emailData.recipients)
        vc.setSubject(emailData.subject)
        vc.setMessageBody(emailData.body, isHTML: false)
        return vc
    }
    
    // Coordinator implementation...
}
#endif
```

---

## 💾 Phase 8: Datenpersistenz

### 8.1 SwiftData / CloudKit

**Gut:** SwiftData funktioniert identisch auf beiden Plattformen.

**Zu prüfen:**
- [ ] CloudKit Container-Identifier sind korrekt
- [ ] iCloud-Capability für iOS-Target aktiviert
- [ ] Sync-Verhalten bei unterschiedlichen Netzwerkbedingungen testen

### 8.2 ModelContainer-Konfiguration

Der aktuelle Code funktioniert bereits plattformübergreifend:
```swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([Quiz.self, Team.self, Round.self])
    // ... Configuration
}()
```

---

## 🧪 Phase 9: Testing

### 9.1 Geräte-Matrix

| Gerät | Auflösung | Size Class | Priorität |
|-------|-----------|------------|-----------|
| iPad Pro 12.9" | 2048 x 2732 | Regular/Regular | Hoch |
| iPad Pro 11" | 1668 x 2388 | Regular/Regular | Hoch |
| iPad Air | 1640 x 2360 | Regular/Regular | Mittel |
| iPad mini | 1488 x 2266 | Compact/Regular* | Mittel |
| iPad (10. Gen) | 1640 x 2360 | Regular/Regular | Mittel |

*iPad mini kann in Compact Size Class wechseln bei Split View

### 9.2 Test-Szenarien

- [ ] **Orientierung:** Portrait, Landscape, Rotation während Nutzung
- [ ] **Multitasking:** Split View, Slide Over
- [ ] **Tastatur:** Software-Tastatur, Magic Keyboard, Smart Keyboard
- [ ] **Pencil:** Drag & Drop, Handschrift in Textfeldern
- [ ] **Stage Manager:** Multiple Fenster (iPadOS 16+)
- [ ] **External Display:** Präsentationsmodus via HDMI/AirPlay
- [ ] **Dark Mode / Light Mode**
- [ ] **Dynamic Type:** Schriftgrößen-Anpassungen

---

## 📁 Datei-Änderungen Übersicht

### Neue Dateien
- [ ] `PubRanker/iOS/` Ordner für iOS-spezifische Views (falls nötig)
- [ ] `PubRanker.entitlements.ios` (falls separate Entitlements)

### Zu ändernde Dateien

| Datei | Änderung | Aufwand |
|-------|----------|---------|
| `PubRankerApp.swift` | Conditional Compilation | Klein |
| `ContentView.swift` | AppKit Import entfernen, Constraints | Klein |
| `ExecutionView.swift` | Grid-Layouts, Size Classes | Mittel |
| `AppSpacing.swift` | Platform-spezifische Werte | Klein |
| `AppColors.swift` | NSColor → PlatformColor | Klein |
| `DesignSystem/AppCard.swift` | Background Color | Klein |
| `Services/EmailService.swift` | MFMailComposeViewController | Mittel |
| `Helpers/PresentationWindowController.swift` | iOS-Alternative | Groß |

---

## 🚀 Migrations-Reihenfolge (empfohlen)

### Sprint 1: Basis-Lauffähigkeit
1. Xcode Target-Konfiguration
2. AppKit-Imports durch Conditional Compilation ersetzen
3. WindowAccessor platform-spezifisch machen
4. PubRankerApp.swift anpassen
5. Basis-Test auf iPad Simulator

### Sprint 2: UI-Anpassungen
1. Layout-Constraints adaptiv machen
2. Grid-Layouts für iPad optimieren
3. Size Classes implementieren
4. Touch Targets vergrößern

### Sprint 3: Features
1. EmailService für iOS implementieren
2. Präsentationsmodus für iPad anpassen
3. Keyboard-Eingabe optimieren

### Sprint 4: Polish & Testing
1. Umfassende Tests auf allen iPad-Modellen
2. Multitasking-Unterstützung validieren
3. Performance-Optimierung
4. Accessibility-Tests

---

## ⚠️ Bekannte Herausforderungen

### 1. Präsentations-Fenster
Das separate Präsentationsfenster auf macOS hat auf iPad keine direkte Entsprechung. Alternativen:
- Vollbild-Modus in der App
- AirPlay für externe Displays
- Picture-in-Picture (falls sinnvoll)

### 2. Feste Mindestbreiten
Einige Sheets haben feste Mindestbreiten (z.B. 900px), die auf iPad angepasst werden müssen:
```swift
.sheet(...) {
    EditRoundsSheet(...)
        .frame(minWidth: 900, minHeight: 700) // ⚠️ Zu breit für iPad Portrait
}
```

### 3. Email-Composer
MFMailComposeViewController ist auf iOS required, aber nicht auf allen Geräten verfügbar (kein Mail-Account). Fallback implementieren.

---

## 📊 Geschätzter Aufwand

| Phase | Aufwand | Zeit |
|-------|---------|------|
| Phase 1: Xcode-Konfiguration | Klein | 1-2 Stunden |
| Phase 2: AppKit Migration | Mittel | 4-6 Stunden |
| Phase 3: UI-Anpassungen | Groß | 8-12 Stunden |
| Phase 4: Design System | Klein | 2-3 Stunden |
| Phase 5: Eingabe | Klein | 2-3 Stunden |
| Phase 6: Präsentationsmodus | Groß | 6-8 Stunden |
| Phase 7: EmailService | Mittel | 3-4 Stunden |
| Phase 8: Datenpersistenz | Klein | 1-2 Stunden |
| Phase 9: Testing | Mittel | 6-8 Stunden |
| **Gesamt** | | **~35-50 Stunden** |

---

## ✅ Checkliste vor App Store Submission

- [ ] Alle iPad-Modelle in Simulator getestet
- [ ] Echtes iPad-Gerät getestet
- [ ] Multitasking funktioniert
- [ ] Orientierungswechsel flüssig
- [ ] Dark Mode / Light Mode korrekt
- [ ] Dynamic Type unterstützt
- [ ] VoiceOver funktioniert
- [ ] CloudKit Sync zwischen Mac und iPad getestet
- [ ] App Store Screenshots für iPad erstellt (2048x2732, 2388x1668)
- [ ] Privacy Policy aktualisiert (falls nötig)
- [ ] Marketing-Text für iPad-Features

---

*Erstellt: Dezember 2025*
*Version: 1.0*
