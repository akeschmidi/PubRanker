#!/bin/bash

# Quick Screenshot-Konvertierung zu App Store Format
# Verwendung: ./convert_screenshot.sh input.png [output.png]

if [ $# -eq 0 ]; then
    echo "Verwendung: $0 <input.png> [output.png]"
    echo ""
    echo "Konvertiert einen Screenshot zu 2880x1800 Pixel (App Store Format)"
    echo ""
    echo "Beispiele:"
    echo "  $0 screenshot.png"
    echo "  $0 screenshot.png appstore_screenshot.png"
    exit 1
fi

INPUT="$1"
OUTPUT="${2:-${INPUT%.png}_2880x1800.png}"

if [ ! -f "$INPUT" ]; then
    echo "❌ Fehler: Datei '$INPUT' nicht gefunden!"
    exit 1
fi

if ! command -v sips &> /dev/null; then
    echo "❌ Fehler: 'sips' nicht gefunden (macOS Standard-Tool)"
    exit 1
fi

echo "🔄 Konvertiere $INPUT..."
echo "   → Ziel: $OUTPUT (2880x1800 Pixel)"

sips -z 1800 2880 "$INPUT" --out "$OUTPUT" > /dev/null 2>&1

if [ $? -eq 0 ] && [ -f "$OUTPUT" ]; then
    echo "✅ Erfolgreich konvertiert!"
    echo "   Größe: $(ls -lh "$OUTPUT" | awk '{print $5}')"
else
    echo "❌ Fehler bei der Konvertierung!"
    exit 1
fi













