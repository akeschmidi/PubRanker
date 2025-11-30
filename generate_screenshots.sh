#!/bin/bash

# PubRanker - Automatisierte Screenshot-Erstellung für App Store
# Erstellt Screenshots in 2880x1800 Pixel für macOS App Store

set -e  # Exit on error

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfiguration
APP_NAME="PubRanker"
BUNDLE_ID="com.akeschmidi.PubRanker"
SCREENSHOT_DIR="screenshots/appstore"
SCREENSHOT_WIDTH=2880
SCREENSHOT_HEIGHT=1800
SCREENSHOT_DELAY=3  # Sekunden warten nach UI-Änderungen

# Erstelle Screenshot-Verzeichnis
mkdir -p "$SCREENSHOT_DIR"

echo -e "${BLUE}📸 PubRanker Screenshot-Generator${NC}"
echo "=================================="
echo ""

# 1. App bauen
echo -e "${YELLOW}🔨 Baue App...${NC}"
xcodebuild -project PubRanker.xcodeproj \
           -scheme PubRanker \
           -configuration Release \
           -derivedDataPath ./build \
           build

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Build fehlgeschlagen!${NC}"
    exit 1
fi

APP_PATH="./build/Build/Products/Release/PubRanker.app"
if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ App nicht gefunden in $APP_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Build erfolgreich${NC}"
echo ""

# 2. Alte App-Instanzen beenden
echo -e "${YELLOW}🛑 Beende alte App-Instanzen...${NC}"
killall "$APP_NAME" 2>/dev/null || true
sleep 2

# 3. App starten
echo -e "${YELLOW}🚀 Starte App...${NC}"
open "$APP_PATH"
sleep 5  # Warten bis App vollständig geladen ist

# Prüfe ob App läuft
if ! pgrep -f "$APP_NAME" > /dev/null; then
    echo -e "${RED}❌ App konnte nicht gestartet werden!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App läuft${NC}"
echo ""

# 4. Warte auf vollständiges Laden
echo -e "${YELLOW}⏳ Warte auf vollständiges Laden der App...${NC}"
sleep 3

# 5. Funktion zum Finden des App-Fensters
get_app_window_id() {
    osascript <<EOF 2>/dev/null
tell application "System Events"
    tell process "$APP_NAME"
        set frontWindow to window 1
        return id of frontWindow
    end tell
end tell
EOF
}

get_app_window_bounds() {
    osascript <<EOF 2>/dev/null
tell application "System Events"
    tell process "$APP_NAME"
        set frontWindow to window 1
        set windowPosition to position of frontWindow
        set windowSize to size of frontWindow
        return (item 1 of windowPosition) & "," & (item 2 of windowPosition) & "," & (item 1 of windowSize) & "," & (item 2 of windowSize)
    end tell
end tell
EOF
}

# 6. Screenshot-Funktion - nur App-Fenster
take_screenshot() {
    local filename=$1
    local description=$2
    
    echo -e "${BLUE}📸 Erstelle Screenshot: $description${NC}"
    
    # Aktiviere App-Fenster zuerst
    osascript <<EOF > /dev/null 2>&1
tell application "$APP_NAME"
    activate
end tell
EOF
    sleep 1
    
    # Hole Fenster-Bounds
    local bounds=$(get_app_window_bounds)
    if [ -z "$bounds" ]; then
        echo -e "${YELLOW}⚠️  Konnte Fenster-Bounds nicht ermitteln, verwende gesamten Bildschirm${NC}"
        screencapture -x "$SCREENSHOT_DIR/$filename.png"
    else
        # Parse bounds: x,y,width,height
        IFS=',' read -r x y width height <<< "$bounds"
        
        # Screenshot des App-Fensters mit Bereich
        screencapture -x -R "$x,$y,$width,$height" "$SCREENSHOT_DIR/$filename.png"
    fi
    
    # Konvertiere zu exakter Größe mit sips (macOS Tool)
    if command -v sips &> /dev/null; then
        sips -z $SCREENSHOT_HEIGHT $SCREENSHOT_WIDTH "$SCREENSHOT_DIR/$filename.png" \
             --out "$SCREENSHOT_DIR/${filename}_${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}.png" > /dev/null 2>&1
        
        # Lösche Original falls Konvertierung erfolgreich
        if [ -f "$SCREENSHOT_DIR/${filename}_${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}.png" ]; then
            rm "$SCREENSHOT_DIR/$filename.png"
            mv "$SCREENSHOT_DIR/${filename}_${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}.png" \
               "$SCREENSHOT_DIR/$filename.png"
            echo -e "${GREEN}✅ Screenshot erstellt: $filename.png (${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT})${NC}"
        else
            echo -e "${YELLOW}⚠️  Screenshot erstellt (Original-Größe): $filename.png${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  'sips' nicht gefunden. Screenshot in Original-Größe: $filename.png${NC}"
    fi
    
    sleep $SCREENSHOT_DELAY
}

# 7. Navigation-Funktion mit verbesserter AppleScript-Logik
navigate_to_tab() {
    local tab_name=$1
    local tab_index=$2
    
    echo -e "${YELLOW}   → Navigiere zu: $tab_name${NC}"
    
    # Aktiviere App zuerst
    osascript <<EOF > /dev/null 2>&1
tell application "$APP_NAME"
    activate
end tell
EOF
    sleep 1
    
    # Versuche verschiedene Methoden, um zum Tab zu navigieren
    # Methode 1: Über Segmented Control (Picker)
    osascript <<EOF > /dev/null 2>&1
tell application "System Events"
    tell process "$APP_NAME"
        set frontWindow to window 1
        
        -- Versuche Segmented Control zu finden
        try
            set pickerGroups to groups of frontWindow whose class is splitter group
            repeat with pickerGroup in pickerGroups
                try
                    set pickers to picker buttons of pickerGroup
                    if (count of pickers) > 0 then
                        -- Versuche Tab über Index zu klicken (falls tab_index gesetzt)
                        if "$tab_index" != "" then
                            click picker button $tab_index of pickerGroup
                        else
                            -- Versuche Tab über Name zu finden
                            repeat with picker in pickers
                                try
                                    set pickerTitle to title of picker
                                    if pickerTitle contains "$tab_name" then
                                        click picker
                                        exit repeat
                                    end if
                                end try
                            end repeat
                        end if
                        exit repeat
                    end if
                end try
            end repeat
        end try
        
        -- Methode 2: Versuche über Radio Buttons
        try
            set radioGroups to radio groups of frontWindow
            repeat with radioGroup in radioGroups
                try
                    set radioButtons to radio buttons of radioGroup
                    repeat with radioButton in radioButtons
                        try
                            set buttonTitle to title of radioButton
                            if buttonTitle contains "$tab_name" then
                                click radioButton
                                exit repeat
                            end if
                        end try
                    end repeat
                end try
            end repeat
        end try
        
        -- Methode 3: Versuche über Buttons
        try
            set allButtons to buttons of frontWindow
            repeat with aButton in allButtons
                try
                    set buttonTitle to title of aButton
                    if buttonTitle contains "$tab_name" then
                        click aButton
                        exit repeat
                    end if
                end try
            end repeat
        end try
    end tell
end tell
EOF
    
    # Warte auf UI-Update
    sleep 2
}

# 8. Erstelle Screenshots mit verbesserter Navigation
echo -e "${YELLOW}📱 Erstelle Screenshots...${NC}"
echo ""
echo -e "${YELLOW}⚠️  Hinweis: UI-Automation kann bei SwiftUI-Apps unzuverlässig sein.${NC}"
echo -e "${YELLOW}   Falls die Navigation nicht funktioniert, verwenden Sie das manuelle Skript.${NC}"
echo ""

# Screenshot 1: Auswerten (Leaderboard)
echo -e "${BLUE}→ Screenshot 1: Leaderboard (Hauptfeature)${NC}"
navigate_to_tab "Auswerten" "4"
take_screenshot "01_leaderboard" "Leaderboard mit Podium"

# Screenshot 2: Teams
echo -e "${BLUE}→ Screenshot 2: Team Management${NC}"
navigate_to_tab "Teams" "1"
take_screenshot "02_team_management" "Team Management"

# Screenshot 3: Planen
echo -e "${BLUE}→ Screenshot 3: Quiz Planning${NC}"
navigate_to_tab "Planen" "2"
take_screenshot "03_quiz_planning" "Quiz Planning"

# Screenshot 4: Durchführen
echo -e "${BLUE}→ Screenshot 4: Score Entry${NC}"
navigate_to_tab "Durchführen" "3"
take_screenshot "04_score_entry" "Score Entry"

# Screenshot 5: Zurück zu Planen für Rounds Overview
echo -e "${BLUE}→ Screenshot 5: Rounds Overview${NC}"
navigate_to_tab "Planen" "2"
sleep 2
take_screenshot "05_rounds_overview" "Rounds Overview"

# 7. Zusammenfassung
echo ""
echo -e "${GREEN}✅ Screenshot-Erstellung abgeschlossen!${NC}"
echo ""
echo -e "${BLUE}📁 Screenshots gespeichert in: $SCREENSHOT_DIR${NC}"
echo ""
echo "Erstellte Screenshots:"
ls -lh "$SCREENSHOT_DIR"/*.png 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}'
echo ""
echo -e "${YELLOW}💡 Hinweis:${NC}"
echo "  - Screenshots sollten 2880x1800 Pixel sein"
echo "  - Prüfe die Screenshots manuell und passe bei Bedarf an"
echo "  - Für bessere Automatisierung könnten UI-Tests verwendet werden"
echo ""

# 8. App beenden (optional)
read -p "App beenden? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    killall "$APP_NAME" 2>/dev/null || true
    echo -e "${GREEN}✅ App beendet${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Fertig!${NC}"

