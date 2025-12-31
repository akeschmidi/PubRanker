#!/usr/bin/env bash

# ============================================================
# PubRanker Screenshot Generator
# ============================================================

# Konfiguration
APP_NAME="PubRanker"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCREENSHOT_DIR="${SCRIPT_DIR}/screenshots"

# Alle unterstützten Sprachen (App Store Code : System Code)
LANG_CODES=(
    "de-DE:de"
    "en-US:en"
    "en-GB:en-GB"
    "fr-FR:fr"
    "es-ES:es"
    "it:it"
    "nl-NL:nl"
    "pl:pl"
    "pt-BR:pt-BR"
    "ru:ru"
    "sv:sv"
    "da:da"
    "ja:ja"
    "ko:ko"
    "zh-Hans:zh-Hans"
)

# Screenshot Namen
SCREENSHOTS=(
    "01_leaderboard"
    "02_team_management"
    "03_quiz_planning"
    "04_score_entry"
    "05_rounds_overview"
    "06_email"
)

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     PubRanker Screenshot Generator         ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Ordner erstellen
create_dirs() {
    echo -e "${BLUE}Erstelle Ordnerstruktur...${NC}"
    for entry in "${LANG_CODES[@]}"; do
        app_store_code="${entry%%:*}"
        mkdir -p "${SCREENSHOT_DIR}/${app_store_code}"
        echo -e "${GREEN}✓ ${SCREENSHOT_DIR}/${app_store_code}${NC}"
    done
    echo -e "${GREEN}Fertig!${NC}"
}

# App mit Sprache starten
start_app() {
    local app_store_code="$1"
    local system_code="$2"
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}Starte App: ${app_store_code} (${system_code})${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # App beenden
    osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
    sleep 1
    
    # App mit Sprache starten
    open -a "$APP_NAME" --args -AppleLanguages "($system_code)"
    sleep 3
    
    echo ""
    echo -e "${GREEN}App läuft mit Sprache: ${app_store_code}${NC}"
    echo ""
    echo -e "Screenshots speichern in: ${BLUE}${SCREENSHOT_DIR}/${app_store_code}/${NC}"
    echo ""
    echo "Empfohlene Screenshots:"
    for s in "${SCREENSHOTS[@]}"; do
        echo "  - ${s}.png"
    done
    echo ""
}

# Screenshot machen
take_screenshot() {
    local lang="$1"
    local name="$2"
    local output="${SCREENSHOT_DIR}/${lang}/${name}.png"
    
    mkdir -p "${SCREENSHOT_DIR}/${lang}"
    screencapture -w "$output"
    
    if [ -f "$output" ]; then
        echo -e "${GREEN}✓ Gespeichert: ${output}${NC}"
    fi
}

# Interaktiver Modus
interactive() {
    local entry="$1"
    local app_store_code="${entry%%:*}"
    local system_code="${entry##*:}"
    
    start_app "$app_store_code" "$system_code"
    
    for screenshot in "${SCREENSHOTS[@]}"; do
        echo -e "${BLUE}Screenshot: ${screenshot}${NC}"
        echo "Drücke ENTER wenn bereit (s=skip, q=quit)"
        read -r input
        
        case "$input" in
            q) return ;;
            s) continue ;;
            *) take_screenshot "$app_store_code" "$screenshot" ;;
        esac
    done
}

# Menü anzeigen
show_menu() {
    echo ""
    echo -e "${BLUE}Wähle eine Option:${NC}"
    echo ""
    echo "  1) App in einer Sprache starten"
    echo "  2) Ordnerstruktur erstellen"
    echo "  3) Screenshots für eine Sprache (interaktiv)"
    echo "  q) Beenden"
    echo ""
    read -p "Auswahl: " choice
    
    case $choice in
        1)
            echo ""
            echo "Wähle Sprache:"
            select entry in "${LANG_CODES[@]}" "Zurück"; do
                if [ "$entry" = "Zurück" ]; then
                    show_menu
                    return
                elif [ -n "$entry" ]; then
                    app_store_code="${entry%%:*}"
                    system_code="${entry##*:}"
                    start_app "$app_store_code" "$system_code"
                    echo "Drücke ENTER um fortzufahren..."
                    read
                    show_menu
                    return
                fi
            done
            ;;
        2)
            create_dirs
            show_menu
            ;;
        3)
            echo ""
            echo "Wähle Sprache:"
            select entry in "${LANG_CODES[@]}" "Zurück"; do
                if [ "$entry" = "Zurück" ]; then
                    show_menu
                    return
                elif [ -n "$entry" ]; then
                    interactive "$entry"
                    show_menu
                    return
                fi
            done
            ;;
        q|Q)
            echo -e "${GREEN}Auf Wiedersehen!${NC}"
            exit 0
            ;;
        *)
            show_menu
            ;;
    esac
}

# Argumente
case "$1" in
    --create-dirs)
        create_dirs
        ;;
    --lang)
        for entry in "${LANG_CODES[@]}"; do
            if [[ "$entry" == "$2:"* ]]; then
                app_store_code="${entry%%:*}"
                system_code="${entry##*:}"
                start_app "$app_store_code" "$system_code"
                exit 0
            fi
        done
        echo "Sprache nicht gefunden: $2"
        exit 1
        ;;
    *)
        show_menu
        ;;
esac




