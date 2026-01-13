# Development Setup Guide

This guide walks through setting up the development environment for Pull and Convert Vids.

## Prerequisites

### Required Software

1. **Xcode 15.0 or later**
   ```bash
   # Install from Mac App Store, then:
   xcode-select --install
   ```

2. **Homebrew**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

3. **Go 1.18 or later**
   ```bash
   brew install go
   ```

4. **Runtime Dependencies**
   ```bash
   brew install ffmpeg yt-dlp
   ```

## Initial Setup

### 1. Clone Repository

```bash
git clone https://github.com/vib795/pull-and-convert-vids.git
cd pull-and-convert-vids
```

### 2. Initialize Submodules

The project uses git submodules for the CLI tools:

```bash
git submodule update --init --recursive
```

Or use the helper script:

```bash
./Scripts/setup_submodules.sh
```

This will clone:
- `Tools/pull-vids` - Video downloader CLI
- `Tools/convert-video-formats` - Video converter CLI

### 3. Build CLI Tools

```bash
./Scripts/build_tools.sh
```

This script will:
- Build both Go CLI tools for Apple Silicon (arm64) and Intel (amd64)
- Create universal binaries using `lipo`
- Output binaries to `Build/` directory

Expected output:
```
🔨 Building Go CLI Tools
=======================
✓ Go found: go version go1.21.x darwin/arm64

📦 Building pull-vids...
  → Building for Apple Silicon (arm64)...
  → Building for Intel (amd64)...
  → Creating universal binary...
  ✓ pull-vids built successfully

📦 Building convert-vid...
  → Building for Apple Silicon (arm64)...
  → Building for Intel (amd64)...
  → Creating universal binary...
  ✓ convert-vid built successfully
```

### 4. Open Xcode Project

```bash
open PullAndConvertVids/PullAndConvertVids.xcodeproj
```

### 5. Build and Run

In Xcode:
- Select the **PullAndConvertVids** scheme
- Choose your Mac as the destination
- Press ⌘R to build and run

## Xcode Project Configuration

### Build Phases

The project includes a custom build phase script that bundles the Go binaries into the app:

**Script:** `"${PROJECT_DIR}/../Scripts/bundle_binaries.sh"`

This runs automatically during the build process and copies binaries to:
```
PullAndConvertVids.app/Contents/Resources/bin/
```

### Build Settings

- **Product Name:** PullAndConvertVids
- **Bundle Identifier:** com.vib795.PullAndConvertVids
- **Deployment Target:** macOS 13.0
- **Swift Version:** Swift 5
- **Signing:** Sign to Run Locally (for development)

### SwiftData Configuration

The app uses SwiftData for persistent storage. The model container is configured in `PullAndConvertVidsApp.swift`:

```swift
let schema = Schema([
    Job.self,
    AppSettings.self,
    CommandRecord.self
])
```

Database location: `~/Library/Application Support/PullAndConvertVids/`

## Running Tests

### Unit Tests

```bash
cd PullAndConvertVids
xcodebuild test -scheme PullAndConvertVids -destination 'platform=macOS'
```

Or in Xcode:
- Press ⌘U to run all tests
- Press ⌘5 to open the Test Navigator

### Test Coverage

Current test coverage includes:
- Argument builder logic
- Path utilities
- File helpers
- Progress parsing (basic)

## Debugging

### Enable Verbose Logging

Set environment variable in Xcode scheme:
```
VERBOSE_LOGGING=1
```

### View Database

Use a SQLite viewer to inspect the SwiftData database:
```bash
# Database location
cd ~/Library/Application\ Support/PullAndConvertVids/
ls -la
```

### Check Bundled Binaries

Verify binaries are correctly bundled:
```bash
cd PullAndConvertVids/DerivedData/Build/Products/Debug
ls -la PullAndConvertVids.app/Contents/Resources/bin/
```

## Common Issues

### "Binary not found" when running app

**Cause:** CLI tools not built or not bundled

**Solution:**
```bash
# Rebuild binaries
./Scripts/build_tools.sh

# Clean and rebuild in Xcode
# Product → Clean Build Folder (⌘⇧K)
# Product → Build (⌘B)
```

### Submodules not initialized

**Symptom:** Empty `Tools/` directories

**Solution:**
```bash
git submodule update --init --recursive
```

### Build fails with "lipo: can't open input file"

**Cause:** One or both architecture builds failed

**Solution:**
- Check Go version: `go version`
- Ensure you have macOS SDK: `xcode-select --install`
- Try building manually:
  ```bash
  cd Tools/pull-vids
  GOOS=darwin GOARCH=arm64 go build -o ../../Build/test-arm64
  GOOS=darwin GOARCH=amd64 go build -o ../../Build/test-amd64
  ```

### FFmpeg/yt-dlp not found at runtime

**Solution:**
```bash
brew install ffmpeg yt-dlp

# Verify installation
which ffmpeg
which yt-dlp
```

## Development Workflow

### 1. Feature Development

```bash
# Create feature branch
git checkout -b feature/your-feature

# Make changes
# ...

# Run tests
xcodebuild test -scheme PullAndConvertVids -destination 'platform=macOS'

# Commit
git commit -m "Add your feature"

# Push
git push origin feature/your-feature
```

### 2. Updating CLI Tools

If the upstream CLI tools have updates:

```bash
# Update submodules
git submodule update --remote

# Rebuild binaries
./Scripts/build_tools.sh

# Test in app
# ...

# Commit submodule updates
git add Tools/
git commit -m "Update CLI tools"
```

### 3. Making a Release

```bash
# 1. Update version in Info.plist
# 2. Build for release
cd PullAndConvertVids
xcodebuild -scheme PullAndConvertVids \
  -configuration Release \
  -derivedDataPath DerivedData \
  build

# 3. Create DMG (optional)
hdiutil create -volname "Pull and Convert Vids" \
  -srcfolder DerivedData/Build/Products/Release/PullAndConvertVids.app \
  -ov -format UDZO PullAndConvertVids.dmg

# 4. Tag release
git tag v1.0.0
git push origin v1.0.0
```

## Additional Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [Xcode Build Settings Reference](https://developer.apple.com/documentation/xcode/build-settings-reference)
- [Go Documentation](https://go.dev/doc/)

## Getting Help

- **Issues:** https://github.com/vib795/pull-and-convert-vids/issues
- **Discussions:** https://github.com/vib795/pull-and-convert-vids/discussions
