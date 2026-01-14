#!/bin/bash
# Build script for creating a distributable DMG

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PROJECT_NAME="PullAndConvertVids"
APP_NAME="Pull and Convert Vids"
DMG_NAME="Pull-and-Convert-Vids"
VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Building $APP_NAME DMG"
echo "=========================="

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed${NC}"
    exit 1
fi

# Navigate to project directory
cd "$PROJECT_ROOT/$PROJECT_NAME"

# Clean previous builds
echo ""
echo "🧹 Cleaning previous builds..."
xcodebuild clean \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release

# Build the app
echo ""
echo "🔨 Building Release version..."
xcodebuild archive \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$PROJECT_NAME" \
    -configuration Release \
    -archivePath "$PROJECT_ROOT/Build/$PROJECT_NAME.xcarchive" \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Export the archive
echo ""
echo "📦 Exporting app..."
mkdir -p "$PROJECT_ROOT/Build/Export"

# Create export options plist
cat > "$PROJECT_ROOT/Build/ExportOptions.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>mac-application</string>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
    -archivePath "$PROJECT_ROOT/Build/$PROJECT_NAME.xcarchive" \
    -exportPath "$PROJECT_ROOT/Build/Export" \
    -exportOptionsPlist "$PROJECT_ROOT/Build/ExportOptions.plist"

# Create DMG directory structure
echo ""
echo "📂 Creating DMG structure..."
DMG_DIR="$PROJECT_ROOT/Build/DMG"
rm -rf "$DMG_DIR"
mkdir -p "$DMG_DIR"

# Copy app to DMG directory
cp -R "$PROJECT_ROOT/Build/Export/$APP_NAME.app" "$DMG_DIR/"

# Create Applications symlink
ln -s /Applications "$DMG_DIR/Applications"

# Create DMG
echo ""
echo "💿 Creating DMG..."
DMG_OUTPUT="$PROJECT_ROOT/Build/$DMG_NAME-$VERSION.dmg"
rm -f "$DMG_OUTPUT"

hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_OUTPUT"

# Summary
echo ""
echo -e "${GREEN}✅ Build Complete!${NC}"
echo "=================="
echo -e "DMG location: ${GREEN}$DMG_OUTPUT${NC}"
echo ""
echo "📊 DMG Details:"
ls -lh "$DMG_OUTPUT"
echo ""
echo "🎉 Ready to distribute!"
echo ""
echo "To install:"
echo "  1. Open $DMG_NAME-$VERSION.dmg"
echo "  2. Drag '$APP_NAME.app' to Applications folder"
echo "  3. Launch from Applications"
