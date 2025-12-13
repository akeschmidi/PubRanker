#!/bin/bash

# ============================================================
# PubRanker mit spezifischer Sprache starten
# ============================================================
# Verwendung: ./start_with_language.sh de
#             ./start_with_language.sh en
#             ./start_with_language.sh fr
# ============================================================

BUNDLE_ID="com.akeschmidi.PubRanker"
APP_NAME="PubRanker"

# Sprach-Mapping
case "$1" in
    de|de-DE)   LANG="de" ;;
    en|en-US)   LANG="en" ;;
    en-GB)      LANG="en-GB" ;;
    fr|fr-FR)   LANG="fr" ;;
    es|es-ES)   LANG="es" ;;
    it)         LANG="it" ;;
    nl|nl-NL)   LANG="nl" ;;
    pl)         LANG="pl" ;;
    pt|pt-BR)   LANG="pt-BR" ;;
    ru)         LANG="ru" ;;
    sv)         LANG="sv" ;;
    da)         LANG="da" ;;
    ja)         LANG="ja" ;;
    ko)         LANG="ko" ;;
    zh|zh-Hans) LANG="zh-Hans" ;;
    reset)
        echo "Setze Sprache auf Systemstandard zurück..."
        defaults delete "$BUNDLE_ID" AppleLanguages 2>/dev/null
        echo "✓ Sprache zurückgesetzt. Starte App neu..."
        osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
        sleep 1
        open -a "$APP_NAME"
        exit 0
        ;;
    *)
        echo "PubRanker Sprach-Starter"
        echo ""
        echo "Verwendung: $0 <sprache>"
        echo ""
        echo "Verfügbare Sprachen:"
        echo "  de, en, en-GB, fr, es, it, nl, pl, pt-BR, ru, sv, da, ja, ko, zh-Hans"
        echo ""
        echo "Beispiele:"
        echo "  $0 de        # Deutsch"
        echo "  $0 en        # Englisch"
        echo "  $0 fr        # Französisch"
        echo "  $0 reset     # Zurück zur Systemsprache"
        exit 1
        ;;
esac

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Starte PubRanker mit Sprache: $LANG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# App beenden
echo "→ Beende App..."
osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
sleep 2

# Sprache setzen via defaults (zuverlässiger als -AppleLanguages)
echo "→ Setze Sprache..."
defaults write "$BUNDLE_ID" AppleLanguages -array "$LANG"

# App starten
echo "→ Starte App..."
open -a "$APP_NAME"

echo ""
echo "✓ App läuft jetzt mit Sprache: $LANG"
echo ""
echo "Tipp: Nach den Screenshots '$0 reset' ausführen"
echo "      um zur Systemsprache zurückzukehren."
