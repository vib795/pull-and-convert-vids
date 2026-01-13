#!/bin/bash
# Install runtime dependencies (ffmpeg, yt-dlp) via Homebrew

set -e

echo "📦 Installing Dependencies"
echo "========================="

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "❌ Homebrew is not installed."
    echo "   Install from: https://brew.sh"
    exit 1
fi

echo "✓ Homebrew found"

# Install ffmpeg
echo ""
echo "Installing ffmpeg..."
if command -v ffmpeg &> /dev/null; then
    echo "✓ ffmpeg already installed: $(ffmpeg -version | head -n1)"
else
    brew install ffmpeg
    echo "✓ ffmpeg installed"
fi

# Install yt-dlp
echo ""
echo "Installing yt-dlp..."
if command -v yt-dlp &> /dev/null; then
    echo "✓ yt-dlp already installed: $(yt-dlp --version)"
else
    brew install yt-dlp
    echo "✓ yt-dlp installed"
fi

# Optional: Install the CLI tools themselves
echo ""
read -p "Install pull-vids and convert-vid via Homebrew? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    brew tap vib795/tap
    brew install vib795/tap/pull-vids
    brew install vib795/tap/convert-vid
    echo "✓ CLI tools installed"
fi

echo ""
echo "✅ Dependencies installed!"
