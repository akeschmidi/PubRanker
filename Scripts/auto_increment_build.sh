#!/bin/bash

# =============================================================================
# AUTO INCREMENT BUILD NUMBER
# =============================================================================
# Dieses Script erhöht automatisch die Build-Nummer bei jedem Archive-Build.
# Es verwendet Git Commit Count + Offset um sicherzustellen, dass die
# Build-Nummer IMMER höher ist als die vorherige.
#
# INSTALLATION:
# 1. Xcode → Target → Build Phases → + → New Run Script Phase
# 2. Script unter "Pre-actions" im Archive Scheme einfügen:
#    ${PROJECT_DIR}/Scripts/auto_increment_build.sh
#
# =============================================================================

set -e

# Konfiguration
# Offset um sicherzustellen, dass wir immer über der letzten App Store Version sind
# Aktuell höchste Version im App Store: 200
# Wir starten bei 200 + Git Commits seit diesem Commit
OFFSET=200

# Projektpfade
PROJECT_DIR="${PROJECT_DIR:-$(dirname "$0")/..}"
PROJECT_FILE="${PROJECT_DIR}/PubRanker.xcodeproj/project.pbxproj"
VERSION_FILE="${PROJECT_DIR}/.build_version"

echo "=============================================="
echo "🔧 Auto Increment Build Number"
echo "=============================================="

# Prüfe ob wir in einem Git Repository sind
if ! git -C "$PROJECT_DIR" rev-parse --git-dir > /dev/null 2>&1; then
    echo "⚠️  Kein Git Repository - verwende Fallback"
    # Fallback: Timestamp-basierte Version
    NEW_VERSION=$(date +%Y%m%d%H%M)
else
    # Git Commit Count als Basis
    GIT_COMMIT_COUNT=$(git -C "$PROJECT_DIR" rev-list --count HEAD 2>/dev/null || echo "0")
    
    # Berechne neue Version: Offset + Git Commits
    NEW_VERSION=$((OFFSET + GIT_COMMIT_COUNT))
    
    echo "📊 Git Commits: $GIT_COMMIT_COUNT"
    echo "📊 Offset: $OFFSET"
fi

# Lese letzte gespeicherte Version (falls vorhanden)
if [ -f "$VERSION_FILE" ]; then
    LAST_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "0")
else
    LAST_VERSION=0
fi

# Stelle sicher, dass neue Version IMMER höher ist
if [ "$NEW_VERSION" -le "$LAST_VERSION" ]; then
    NEW_VERSION=$((LAST_VERSION + 1))
    echo "⚠️  Version angepasst um Duplikate zu vermeiden"
fi

echo "📦 Neue Build-Nummer: $NEW_VERSION"

# Prüfe ob Projektdatei existiert
if [ ! -f "$PROJECT_FILE" ]; then
    echo "❌ Projektdatei nicht gefunden: $PROJECT_FILE"
    exit 1
fi

# Lese aktuelle Version aus Projektdatei
CURRENT_VERSION=$(grep -m 1 "CURRENT_PROJECT_VERSION = " "$PROJECT_FILE" | sed 's/.*CURRENT_PROJECT_VERSION = \([0-9]*\);/\1/' || echo "0")
echo "📋 Aktuelle Version in Projekt: $CURRENT_VERSION"

# Nur aktualisieren wenn neue Version höher ist
if [ "$NEW_VERSION" -gt "$CURRENT_VERSION" ]; then
    # Ersetze Version in Projektdatei
    sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_VERSION;/g" "$PROJECT_FILE"
    
    # Speichere Version für nächstes Mal
    echo "$NEW_VERSION" > "$VERSION_FILE"
    
    echo "✅ Build-Nummer aktualisiert: $CURRENT_VERSION → $NEW_VERSION"
else
    echo "ℹ️  Version bereits aktuell oder höher"
fi

echo "=============================================="
