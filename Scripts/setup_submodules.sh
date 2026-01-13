#!/bin/bash
# Initialize git submodules for CLI tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "🔗 Setting up Git Submodules"
echo "============================"

cd "$PROJECT_ROOT"

# Initialize and update submodules
if [ -f ".gitmodules" ]; then
    echo "📥 Initializing submodules..."
    git submodule init
    git submodule update

    echo "✅ Submodules initialized!"
else
    echo "⚠ No .gitmodules file found."
    echo "   Add submodules manually:"
    echo ""
    echo "   git submodule add https://github.com/vib795/pull-vids.git Tools/pull-vids"
    echo "   git submodule add https://github.com/vib795/convert-video-formats.git Tools/convert-video-formats"
fi

echo ""
echo "💡 Next step: Run ./Scripts/build_tools.sh to build binaries"
