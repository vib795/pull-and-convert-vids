#!/bin/bash
# Bundle binaries into Xcode project Resources
# This script is called during Xcode build phase

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BUILD_OUTPUT="$PROJECT_ROOT/Build"

# Xcode build environment
if [ -n "$BUILT_PRODUCTS_DIR" ]; then
    # Running from Xcode build phase
    RESOURCES_DIR="$BUILT_PRODUCTS_DIR/$PRODUCT_NAME.app/Contents/Resources"
else
    # Running manually - use default location
    RESOURCES_DIR="$PROJECT_ROOT/PullAndConvertVids/Build/Release/PullAndConvertVids.app/Contents/Resources"
fi

BIN_DIR="$RESOURCES_DIR/bin"

echo "📦 Bundling CLI Binaries"
echo "======================="
echo "Source: $BUILD_OUTPUT"
echo "Target: $BIN_DIR"
echo ""

# Create bin directory in Resources
mkdir -p "$BIN_DIR"

# Copy binaries
if [ -f "$BUILD_OUTPUT/pull-vids" ]; then
    cp "$BUILD_OUTPUT/pull-vids" "$BIN_DIR/"
    chmod +x "$BIN_DIR/pull-vids"
    echo "✓ Copied pull-vids"
else
    echo "⚠ pull-vids not found (run build_tools.sh first)"
fi

if [ -f "$BUILD_OUTPUT/convert-vid" ]; then
    cp "$BUILD_OUTPUT/convert-vid" "$BIN_DIR/"
    chmod +x "$BIN_DIR/convert-vid"
    echo "✓ Copied convert-vid"
else
    echo "⚠ convert-vid not found (run build_tools.sh first)"
fi

echo ""
echo "✅ Bundle Complete!"
