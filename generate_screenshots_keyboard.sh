#!/bin/bash

# PubRanker - Screenshot-Erstellung mit Keyboard-Shortcuts
# Verwendet Keyboard-Shortcuts für zuverlässigere Navigation

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Konfiguration
APP_NAME="PubRanker"
SCREENSHOT_DIR="screenshots/appstore"
SCREENSHOT_WIDTH=2880
SCREENSHOT_HEIGHT=1800

# Erstelle Screenshot-Verzeichnis
mkdir -p "$SCREENSHOT_DIR"

echo -e "${BLUE}📸 PubRanker - Screenshot-Generator (Keyboard-Modus)${NC}"
echo "======================================================"
echo ""

# 1. App bauen (optional)
read -p "App neu bauen? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
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
else
    APP_PATH="./build/Build/Products/Release/PubRanker.app"
    if [ ! -d "$APP_PATH" ]; then
        APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/PubRanker-*/Build/Products/Release/PubRanker.app"
        APP_PATH=$(ls -d $APP_PATH 2>/dev/null | head -1)
    fi
fi

if [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ App nicht gefunden!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ App gefunden: $APP_PATH${NC}"
echo ""

# 2. Alte App-Instanzen beenden
echo -e "${YELLOW}🛑 Beende alte App-Instanzen...${NC}"
killall "$APP_NAME" 2>/dev/null || true
sleep 2

# 3. App starten
echo -e "${YELLOW}🚀 Starte App...${NC}"
open "$APP_PATH"
sleep 5

echo -e "${GREEN}✅ App läuft${NC}"
echo ""

# Funktion zum Finden des App-Fensters
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

# Screenshot-Funktion - nur App-Fenster
take_screenshot() {
    local filename=$1
    local description=$2
    local keyboard_hint=$3
    
    echo -e "${BLUE}📸 Screenshot: $description${NC}"
    if [ -n "$keyboard_hint" ]; then
        echo -e "${YELLOW}   💡 Tipp: $keyboard_hint${NC}"
    fi
    echo -e "${YELLOW}   → Drücken Sie ENTER wenn die Ansicht bereit ist...${NC}"
    read -r
    
    # Aktiviere App-Fenster
    osascript <<EOF > /dev/null 2>&1
tell application "$APP_NAME"
    activate
end tell
EOF
    sleep 0.5
    
    # Hole Fenster-Bounds
    local bounds=$(get_app_window_bounds)
    if [ -z "$bounds" ]; then
        echo -e "${YELLOW}⚠️  Konnte Fenster-Bounds nicht ermitteln${NC}"
        screencapture -x "$SCREENSHOT_DIR/$filename.png"
    else
        IFS=',' read -r x y width height <<< "$bounds"
        screencapture -x -R "$x,$y,$width,$height" "$SCREENSHOT_DIR/$filename.png"
    fi
    
    # Konvertiere zu exakter Größe
    if command -v sips &> /dev/null; then
        sips -z $SCREENSHOT_HEIGHT $SCREENSHOT_WIDTH "$SCREENSHOT_DIR/$filename.png" \
             --out "$SCREENSHOT_DIR/${filename}_${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}.png" > /dev/null 2>&1
        
        if [ -f "$SCREENSHOT_DIR/${filename}_${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}.png" ]; then
            rm "$SCREENSHOT_DIR/$filename.png"
            mv "$SCREENSHOT_DIR/${filename}_${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT}.png" \
               "$SCREENSHOT_DIR/$filename.png"
            echo -e "${GREEN}✅ Erstellt: $filename.png (${SCREENSHOT_WIDTH}x${SCREENSHOT_HEIGHT})${NC}"
        else
            echo -e "${YELLOW}⚠️  Erstellt (Original-Größe): $filename.png${NC}"
        fi
    fi
    
    echo ""
}

# Keyboard-Shortcut senden
send_key() {
    local key=$1
    osascript <<EOF > /dev/null 2>&1
tell application "System Events"
    tell process "$APP_NAME"
        keystroke "$key"
    end tell
end tell
EOF
    sleep 0.5
}

# 4. Interaktive Screenshot-Erstellung
echo -e "${BLUE}📱 Bereit für Screenshot-Erstellung${NC}"
echo ""
echo -e "${YELLOW}Anleitung:${NC}"
echo "1. Navigieren Sie mit den Tabs oben in der App"
echo "2. Oder verwenden Sie die Segmented Control (Picker)"
echo "3. Drücken Sie ENTER wenn die Ansicht bereit ist"
echo ""
echo -e "${YELLOW}Drücken Sie ENTER um zu beginnen...${NC}"
read -r

# Screenshot 1: Leaderboard (Auswerten)
take_screenshot "01_leaderboard" "Leaderboard mit Podium" "Klicken Sie auf 'Auswerten' Tab"

# Screenshot 2: Team Management
take_screenshot "02_team_management" "Team Management" "Klicken Sie auf 'Teams' Tab"

# Screenshot 3: Quiz Planning
take_screenshot "03_quiz_planning" "Quiz Planning" "Klicken Sie auf 'Planen' Tab"

# Screenshot 4: Score Entry
take_screenshot "04_score_entry" "Score Entry" "Klicken Sie auf 'Durchführen' Tab"

# Screenshot 5: Rounds Overview
take_screenshot "05_rounds_overview" "Rounds Overview" "Gehen Sie zurück zu 'Planen' und zeigen Sie Runden"

# Zusammenfassung
echo ""
echo -e "${GREEN}✅ Screenshot-Erstellung abgeschlossen!${NC}"
echo ""
echo -e "${BLUE}📁 Screenshots gespeichert in: $SCREENSHOT_DIR${NC}"
echo ""
ls -lh "$SCREENSHOT_DIR"/*.png 2>/dev/null | awk '{print "  - " $9 " (" $5 ")"}' || echo "  (keine Screenshots gefunden)"
echo ""

# App beenden (optional)
read -p "App beenden? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    killall "$APP_NAME" 2>/dev/null || true
    echo -e "${GREEN}✅ App beendet${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Fertig!${NC}"













