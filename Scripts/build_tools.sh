#!/bin/bash
# Build script for Go CLI tools (pull-vids and convert-vid)
# Creates universal binaries for macOS (Apple Silicon + Intel)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TOOLS_DIR="$PROJECT_ROOT/Tools"
BUILD_OUTPUT="$PROJECT_ROOT/Build"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🔨 Building Go CLI Tools"
echo "======================="

# Check if Go is installed
if ! command -v go &> /dev/null; then
    echo -e "${RED}❌ Go is not installed. Please install Go 1.18 or later.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Go found: $(go version)${NC}"

# Create build output directory
mkdir -p "$BUILD_OUTPUT"

# Build pull-vids
echo ""
echo "📦 Building pull-vids..."
if [ -d "$TOOLS_DIR/pull-vids" ]; then
    cd "$TOOLS_DIR/pull-vids"

    # Build for Apple Silicon (arm64)
    echo "  → Building for Apple Silicon (arm64)..."
    GOOS=darwin GOARCH=arm64 go build -o "$BUILD_OUTPUT/pull-vids-arm64" -ldflags="-s -w" .

    # Build for Intel (amd64)
    echo "  → Building for Intel (amd64)..."
    GOOS=darwin GOARCH=amd64 go build -o "$BUILD_OUTPUT/pull-vids-amd64" -ldflags="-s -w" .

    # Create universal binary
    echo "  → Creating universal binary..."
    lipo -create -output "$BUILD_OUTPUT/pull-vids" \
        "$BUILD_OUTPUT/pull-vids-arm64" \
        "$BUILD_OUTPUT/pull-vids-amd64"

    # Clean up architecture-specific binaries
    rm "$BUILD_OUTPUT/pull-vids-arm64" "$BUILD_OUTPUT/pull-vids-amd64"

    # Make executable
    chmod +x "$BUILD_OUTPUT/pull-vids"

    echo -e "${GREEN}  ✓ pull-vids built successfully${NC}"
else
    echo -e "${YELLOW}  ⚠ pull-vids source not found at $TOOLS_DIR/pull-vids${NC}"
    echo "    Run: ./Scripts/setup_submodules.sh"
fi

# Build convert-vid
echo ""
echo "📦 Building convert-vid..."
if [ -d "$TOOLS_DIR/convert-video-formats" ]; then
    cd "$TOOLS_DIR/convert-video-formats"

    # Build for Apple Silicon (arm64)
    echo "  → Building for Apple Silicon (arm64)..."
    GOOS=darwin GOARCH=arm64 go build -o "$BUILD_OUTPUT/convert-vid-arm64" -ldflags="-s -w" .

    # Build for Intel (amd64)
    echo "  → Building for Intel (amd64)..."
    GOOS=darwin GOARCH=amd64 go build -o "$BUILD_OUTPUT/convert-vid-amd64" -ldflags="-s -w" .

    # Create universal binary
    echo "  → Creating universal binary..."
    lipo -create -output "$BUILD_OUTPUT/convert-vid" \
        "$BUILD_OUTPUT/convert-vid-arm64" \
        "$BUILD_OUTPUT/convert-vid-amd64"

    # Clean up architecture-specific binaries
    rm "$BUILD_OUTPUT/convert-vid-arm64" "$BUILD_OUTPUT/convert-vid-amd64"

    # Make executable
    chmod +x "$BUILD_OUTPUT/convert-vid"

    echo -e "${GREEN}  ✓ convert-vid built successfully${NC}"
else
    echo -e "${YELLOW}  ⚠ convert-vid source not found at $TOOLS_DIR/convert-video-formats${NC}"
    echo "    Run: ./Scripts/setup_submodules.sh"
fi

# Summary
echo ""
echo "✅ Build Complete!"
echo "=================="
echo "Binaries location: $BUILD_OUTPUT"
echo ""
ls -lh "$BUILD_OUTPUT"

# Verify binaries
echo ""
echo "🔍 Verifying binaries..."
if [ -f "$BUILD_OUTPUT/pull-vids" ]; then
    echo -e "${GREEN}✓ pull-vids${NC}"
    file "$BUILD_OUTPUT/pull-vids"
fi

if [ -f "$BUILD_OUTPUT/convert-vid" ]; then
    echo -e "${GREEN}✓ convert-vid${NC}"
    file "$BUILD_OUTPUT/convert-vid"
fi

echo ""
echo "💡 Next step: Run ./Scripts/bundle_binaries.sh to copy to Xcode project"
