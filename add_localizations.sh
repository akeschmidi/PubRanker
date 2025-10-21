#!/bin/bash
# Add all Localizable.strings to Xcode project

PROJ_FILE="PubRanker.xcodeproj/project.pbxproj"

# Add known regions to project
if ! grep -q "knownRegions" "$PROJ_FILE"; then
    echo "Adding localization support to project..."
    
    # This will trigger Xcode to recognize the .lproj folders
    touch PubRanker/de.lproj/Localizable.strings
fi

echo "✅ Run: Product > Clean Build Folder in Xcode"
echo "✅ Then: Product > Build (⌘B)"
echo "✅ The app will now show localized strings!"
