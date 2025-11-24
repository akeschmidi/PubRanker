#!/bin/bash

# Skript zum automatischen Erhöhen der Build-Version
# Verwendung: ./increment_version.sh

PROJECT_FILE="PubRanker.xcodeproj/project.pbxproj"

# Prüfe ob die Projektdatei existiert
if [ ! -f "$PROJECT_FILE" ]; then
    echo "Fehler: Projektdatei nicht gefunden: $PROJECT_FILE"
    exit 1
fi

# Lese die aktuelle Version aus der Projektdatei
CURRENT_VERSION=$(grep -m 1 "CURRENT_PROJECT_VERSION = " "$PROJECT_FILE" | sed 's/.*CURRENT_PROJECT_VERSION = \([0-9]*\);/\1/')

if [ -z "$CURRENT_VERSION" ]; then
    echo "Fehler: Konnte aktuelle Version nicht finden"
    exit 1
fi

# Erhöhe die Version um 1
NEW_VERSION=$((CURRENT_VERSION + 1))

echo "Aktuelle Version: $CURRENT_VERSION"
echo "Neue Version: $NEW_VERSION"

# Ersetze alle Vorkommen von CURRENT_PROJECT_VERSION in der Projektdatei
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_VERSION;/g" "$PROJECT_FILE"
else
    # Linux
    sed -i "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_VERSION;/g" "$PROJECT_FILE"
fi

echo "✓ Build-Version erfolgreich auf $NEW_VERSION erhöht!"
echo ""
echo "Du kannst jetzt die App bauen und hochladen."

