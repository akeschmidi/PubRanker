#!/bin/bash

# Xcode Build Phase Script zum automatischen Erhöhen der Build-Version
# Wird nur bei Release-Builds (Archive) ausgeführt

# Prüfe ob es ein Release-Build ist
if [ "${CONFIGURATION}" != "Release" ]; then
    echo "Debug-Build erkannt - Version wird nicht erhöht"
    exit 0
fi

PROJECT_FILE="${PROJECT_DIR}/PubRanker.xcodeproj/project.pbxproj"

# Prüfe ob die Projektdatei existiert
if [ ! -f "$PROJECT_FILE" ]; then
    echo "Warnung: Projektdatei nicht gefunden: $PROJECT_FILE"
    exit 0
fi

# Lese die aktuelle Version aus der Projektdatei
CURRENT_VERSION=$(grep -m 1 "CURRENT_PROJECT_VERSION = " "$PROJECT_FILE" | sed 's/.*CURRENT_PROJECT_VERSION = \([0-9]*\);/\1/')

if [ -z "$CURRENT_VERSION" ]; then
    echo "Warnung: Konnte aktuelle Version nicht finden"
    exit 0
fi

# Erhöhe die Version um 1
NEW_VERSION=$((CURRENT_VERSION + 1))

# Ersetze alle Vorkommen von CURRENT_PROJECT_VERSION in der Projektdatei
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_VERSION;/g" "$PROJECT_FILE"
    echo "✓ Build-Version automatisch auf $NEW_VERSION erhöht"
fi

