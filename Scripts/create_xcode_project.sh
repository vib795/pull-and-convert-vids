#!/bin/bash

# Script to create the Xcode project structure
# This should be run after cloning the repository

set -e

echo "🔨 Creating Xcode Project"
echo "========================="

cd "$(dirname "$0")/.."

# Check if xcodebuild is available
if ! command -v xcodebuild &> /dev/null; then
    echo "❌ Error: Xcode is not installed"
    echo "   Please install Xcode from the Mac App Store"
    exit 1
fi

echo "✓ Xcode found"

# Create the project directory if it doesn't exist
mkdir -p PullAndConvertVids

cd PullAndConvertVids

# Check if project already exists
if [ -d "PullAndConvertVids.xcodeproj" ]; then
    echo "⚠️  Project already exists at PullAndConvertVids/PullAndConvertVids.xcodeproj"
    read -p "   Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "   Skipping project creation"
        exit 0
    fi
    rm -rf PullAndConvertVids.xcodeproj
fi

echo ""
echo "📝 Creating new Xcode project..."
echo ""
echo "⚠️  MANUAL STEP REQUIRED:"
echo "   Xcode project files are too complex to generate programmatically."
echo "   Please follow these steps:"
echo ""
echo "   1. Open Xcode"
echo "   2. File → New → Project"
echo "   3. Select 'macOS' → 'App'"
echo "   4. Set Project Name: PullAndConvertVids"
echo "   5. Set Organization: com.vib795"
echo "   6. Interface: SwiftUI"
echo "   7. Language: Swift"
echo "   8. Storage: SwiftData"
echo "   9. Uncheck 'Include Tests' (we have custom test targets)"
echo "   10. Save to: $(pwd)"
echo ""
echo "   After creating the project:"
echo ""
echo "   11. Delete the auto-generated 'PullAndConvertVids' group in the project navigator"
echo "   12. Right-click the project → 'Add Files to PullAndConvertVids...'"
echo "   13. Select the 'PullAndConvertVids' folder in Finder"
echo "   14. Check 'Create groups' and 'Add to targets: PullAndConvertVids'"
echo "   15. Click 'Add'"
echo ""
echo "   16. Add Test Targets:"
echo "       - File → New → Target → macOS Unit Testing Bundle"
echo "       - Name: PullAndConvertVidsTests"
echo "       - Add files from PullAndConvertVidsTests folder"
echo ""
echo "   17. Configure Build Settings:"
echo "       - Select target 'PullAndConvertVids'"
echo "       - General → Deployment Target: macOS 13.0"
echo "       - Signing & Capabilities → Signing: 'Sign to Run Locally'"
echo "       - Disable App Sandbox (for file system access)"
echo ""
echo "   18. Add Build Phase Script:"
echo "       - Select target → Build Phases → + → New Run Script Phase"
echo "       - Shell: /bin/bash"
echo "       - Script:"
echo '       "$ {PROJECT_DIR}/../Scripts/bundle_binaries.sh"'
echo ""
echo "   19. Build and Run (⌘R)"
echo ""
echo "📖 Or use the alternative SPM approach:"
echo "   Run: ./Scripts/create_spm_project.sh"
echo ""
