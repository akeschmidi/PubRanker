# Color Assets Setup für PubRanker 2.0

## Schritt 1: Color Assets in Xcode erstellen

Öffne `Assets.xcassets` in Xcode und erstelle folgende **Color Sets**:

### AppPrimary
- **Any Appearance**: #A0522D (RGB: 160, 82, 45)
- **Dark Appearance**: #CD853F (RGB: 205, 133, 63)

### AppSecondary
- **Any Appearance**: #FFD700 (RGB: 255, 215, 0)
- **Dark Appearance**: #E5C100 (RGB: 229, 193, 0)

### AppAccent
- **Any Appearance**: #F15A24 (RGB: 241, 90, 36)
- **Dark Appearance**: #FF7F50 (RGB: 255, 127, 80)

### AppSuccess
- **Any Appearance**: #06C14F (RGB: 6, 193, 79)
- **Dark Appearance**: #32CD32 (RGB: 50, 205, 50)

### AppBackground
- **Any Appearance**: #F0F0F0 (RGB: 240, 240, 240)
- **Dark Appearance**: #1C1C1E (RGB: 28, 28, 30)

### AppBackgroundSecondary
- **Any Appearance**: #E8E8E8 (RGB: 232, 232, 232)
- **Dark Appearance**: #2C2C2E (RGB: 44, 44, 46)

### AppTextPrimary
- **Any Appearance**: #000000 (RGB: 0, 0, 0)
- **Dark Appearance**: #FFFFFF (RGB: 255, 255, 255)

### AppTextSecondary
- **Any Appearance**: #666666 (RGB: 102, 102, 102)
- **Dark Appearance**: #EBEBF5 (RGB: 235, 235, 245) @ 60% Opacity

### AppTextTertiary
- **Any Appearance**: #999999 (RGB: 153, 153, 153)
- **Dark Appearance**: #EBEBF5 (RGB: 235, 235, 245) @ 30% Opacity

## Schritt 2: Anleitung in Xcode

1. Öffne `Assets.xcassets`
2. Klicke auf das `+` Symbol unten links
3. Wähle "New Color Set"
4. Benenne es (z.B. "AppPrimary")
5. Wähle "Appearances" → "Any, Dark"
6. Setze die Farben für Light und Dark Mode

## Alternative: Direkte Verwendung

Falls du die Assets noch nicht erstellt hast, kannst du die direkten Varianten verwenden:

```swift
// Statt .appPrimary
.foregroundStyle(colorScheme == .dark ? .appPrimaryLight : .appPrimaryDark)
```

## Schritt 3: Testen

Nach dem Erstellen der Color Assets, teste in deiner App:

```swift
struct ColorTestView: View {
    var body: some View {
        VStack(spacing: 20) {
            Rectangle().fill(.appPrimary).frame(height: 50)
            Rectangle().fill(.appSecondary).frame(height: 50)
            Rectangle().fill(.appAccent).frame(height: 50)
            Rectangle().fill(.appSuccess).frame(height: 50)
        }
        .padding()
    }
}
```

Wechsle zwischen Light/Dark Mode um die Farben zu testen!
