#!/bin/bash

# Dateipfade
VIEW_FILE="PubRanker/Views/PresentationModeView.swift"
HELPER_FILE="PubRanker/Helpers/PresentationWindowController.swift"

# Prüfe ob die Dateien existieren
if [ -f "$VIEW_FILE" ] && [ -f "$HELPER_FILE" ]; then
    echo "Dateien gefunden:"
    echo "  - $VIEW_FILE"
    echo "  - $HELPER_FILE"
    
    # Öffne die Dateien in Xcode, um sie zum Projekt hinzuzufügen
    osascript << 'APPLESCRIPT'
    tell application "Xcode"
        activate
        delay 1
    end tell
    
    tell application "System Events"
        tell process "Xcode"
            -- Warte bis Xcode bereit ist
            delay 2
            
            -- Drücke Cmd+Option+A um "Add Files to Project" zu öffnen
            keystroke "a" using {command down, option down}
            delay 1
        end tell
    end tell
APPLESCRIPT
    
    echo ""
    echo "Bitte füge die folgenden Dateien manuell in Xcode hinzu:"
    echo "1. Klicke mit rechts auf den 'Views' Ordner → Add Files to 'PubRanker'"
    echo "2. Wähle: PubRanker/Views/PresentationModeView.swift"
    echo "3. Klicke mit rechts auf den 'Helpers' Ordner → Add Files to 'PubRanker'"
    echo "4. Wähle: PubRanker/Helpers/PresentationWindowController.swift"
else
    echo "Fehler: Dateien nicht gefunden!"
    exit 1
fi
