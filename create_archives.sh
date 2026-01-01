#!/bin/bash

# PubRanker - Archive Creation Script
# Erstellt Archives für macOS und iPadOS

set -e  # Exit bei Fehler

echo "🚀 PubRanker Archive Creation"
echo "=============================="
echo ""

# Farben für Output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projekt-Infos
PROJECT="PubRanker.xcodeproj"
SCHEME="PubRanker"
ARCHIVE_PATH="$HOME/Desktop/PubRanker-Archives"

# Version aus Info.plist auslesen (falls vorhanden)
VERSION=$(defaults read "$(pwd)/PubRanker/Info.plist" CFBundleShortVersionString 2>/dev/null || echo "3.0")
BUILD=$(defaults read "$(pwd)/PubRanker/Info.plist" CFBundleVersion 2>/dev/null || echo "$(date +%s)")

echo "📦 Version: $VERSION"
echo "🔢 Build: $BUILD"
echo ""

# Erstelle Archive-Ordner
mkdir -p "$ARCHIVE_PATH"

echo "${BLUE}[1/3] Clean Build Folder...${NC}"
xcodebuild clean -project "$PROJECT" -scheme "$SCHEME" > /dev/null 2>&1
echo "✅ Clean abgeschlossen"
echo ""

# Funktion zum Erstellen eines Archives
create_archive() {
    local platform=$1
    local destination=$2
    local archive_name=$3

    echo "${BLUE}[Archive] $archive_name wird erstellt...${NC}"

    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -destination "$destination" \
        -archivePath "$ARCHIVE_PATH/$archive_name.xcarchive" \
        -configuration Release \
        CODE_SIGN_STYLE=Automatic \
        | xcpretty || xcodebuild archive \
            -project "$PROJECT" \
            -scheme "$SCHEME" \
            -destination "$destination" \
            -archivePath "$ARCHIVE_PATH/$archive_name.xcarchive" \
            -configuration Release \
            CODE_SIGN_STYLE=Automatic

    if [ $? -eq 0 ]; then
        echo "${GREEN}✅ $archive_name Archive erfolgreich erstellt${NC}"
    else
        echo "❌ Fehler beim Erstellen von $archive_name Archive"
        return 1
    fi
}

# macOS Archive erstellen
echo "${BLUE}[2/3] macOS Archive erstellen...${NC}"
create_archive "macOS" "generic/platform=macOS" "PubRanker-macOS-v$VERSION"
echo ""

# iPadOS Archive erstellen
echo "${BLUE}[3/3] iPadOS Archive erstellen...${NC}"
create_archive "iOS" "generic/platform=iOS" "PubRanker-iOS-v$VERSION"
echo ""

# Zusammenfassung
echo "=============================="
echo "${GREEN}🎉 Fertig!${NC}"
echo ""
echo "📁 Archives gespeichert in:"
echo "   $ARCHIVE_PATH"
echo ""
echo "📦 Erstellt:"
echo "   ✅ PubRanker-macOS-v$VERSION.xcarchive"
echo "   ✅ PubRanker-iOS-v$VERSION.xcarchive"
echo ""
echo "🚀 Nächste Schritte:"
echo "   1. Xcode → Window → Organizer (⇧⌘2)"
echo "   2. Archives auswählen"
echo "   3. 'Distribute App' → App Store Connect"
echo ""
echo "💡 Oder öffne Organizer direkt:"
echo "   open -a Xcode $ARCHIVE_PATH"
echo ""
