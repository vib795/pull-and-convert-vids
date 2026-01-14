#!/bin/bash
# Simple DMG packaging script (works without xcodebuild)
# Packages an already-built app into a DMG

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
APP_BUNDLE_NAME="PullAndConvertVids"  # The actual .app bundle name
APP_DISPLAY_NAME="Pull and Convert Vids"  # The display name users see
DMG_NAME="Pull-and-Convert-Vids"
VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "💿 Creating DMG for $APP_DISPLAY_NAME"
echo "=============================="

# Find the built app
APP_PATH=""

# Check common build locations
if [ -d "$PROJECT_ROOT/PullAndConvertVids/build/Release/$APP_BUNDLE_NAME.app" ]; then
    APP_PATH="$PROJECT_ROOT/PullAndConvertVids/build/Release/$APP_BUNDLE_NAME.app"
elif [ -d "$PROJECT_ROOT/Build/Products/Release/$APP_BUNDLE_NAME.app" ]; then
    APP_PATH="$PROJECT_ROOT/Build/Products/Release/$APP_BUNDLE_NAME.app"
else
    # Search in DerivedData (where Xcode ⌘B builds to)
    echo "🔍 Searching in Xcode DerivedData..."
    APP_PATH=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "$APP_BUNDLE_NAME.app" -path "*/Build/Products/Release/*" -print -quit 2>/dev/null)

    # If not found in Release, try Debug
    if [ -z "$APP_PATH" ]; then
        APP_PATH=$(find "$HOME/Library/Developer/Xcode/DerivedData" -name "$APP_BUNDLE_NAME.app" -path "*/Build/Products/Debug/*" -print -quit 2>/dev/null)
        if [ -n "$APP_PATH" ]; then
            echo -e "${YELLOW}⚠ Found Debug build (use Release for distribution)${NC}"
        fi
    fi
fi

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
    echo -e "${RED}❌ Could not find built app${NC}"
    echo ""
    echo "Please build the app first in Xcode:"
    echo "  1. Open PullAndConvertVids.xcodeproj"
    echo "  2. Select 'Any Mac' as destination"
    echo "  3. Product → Build (⌘B)"
    echo ""
    echo "Or specify the app path:"
    echo "  APP_PATH=\"/path/to/app\" $0"
    exit 1
fi

echo -e "${GREEN}✓ Found app:${NC} $APP_PATH"

# Create DMG directory structure
echo ""
echo "📂 Creating DMG structure..."
DMG_DIR="$PROJECT_ROOT/Build/DMG"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
echo "  → Copying app..."
cp -R "$APP_PATH" "$DMG_DIR/"

# Create Applications symlink
echo "  → Creating Applications symlink..."
ln -s /Applications "$DMG_DIR/Applications"

# Optional: Add background image or .DS_Store for custom DMG appearance
# (You can add this later if you want custom DMG styling)

# Create DMG
echo ""
echo "💿 Creating DMG..."
DMG_OUTPUT="$PROJECT_ROOT/Build/$DMG_NAME-$VERSION.dmg"
rm -f "$DMG_OUTPUT"

hdiutil create \
    -volname "$APP_DISPLAY_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_OUTPUT"

# Clean up temp directory
rm -rf "$DMG_DIR"

# Summary
echo ""
echo -e "${GREEN}✅ DMG Created Successfully!${NC}"
echo "=============================="
echo ""
echo "📍 Location: $DMG_OUTPUT"
echo ""
ls -lh "$DMG_OUTPUT"
echo ""
echo "🎉 Ready to distribute!"
echo ""
echo "To test:"
echo "  open $DMG_OUTPUT"
echo ""
echo "To install:"
echo "  1. Open the DMG"
echo "  2. Drag '$APP_DISPLAY_NAME.app' to Applications folder"
echo "  3. Launch from Applications"
