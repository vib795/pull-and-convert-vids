# Quick Start Guide

This guide helps you get the application running in minutes.

## Prerequisites

1. **macOS 13.0 (Ventura) or later**
2. **Xcode 15+ installed** from the Mac App Store
3. **Homebrew installed** (https://brew.sh)

## Installation Steps

### 1. Clone the Repository

```bash
git clone https://github.com/vib795/pull-and-convert-vids.git
cd pull-and-convert-vids
```

### 2. Install Dependencies

The app requires `ffmpeg` and `yt-dlp` to function:

```bash
./Scripts/install_dependencies.sh
```

This will install:
- `ffmpeg` (media processing)
- `yt-dlp` (video downloading)
- `pull-vids` and `convert-vid` (optional, via Homebrew)

### 3. Build CLI Tools (Optional)

**Option A: Use System Binaries** (Easiest)

If you installed `pull-vids` and `convert-vid` via Homebrew in step 2, you're done! The app will automatically detect them.

**Option B: Build from Source**

To bundle the CLI tools inside the app:

```bash
# Initialize submodules (downloads pull-vids and convert-vid source code)
git submodule update --init --recursive

# Build universal binaries (Apple Silicon + Intel)
./Scripts/build_tools.sh
```

This creates universal binaries in the `Build/` directory.

### 4. Open in Xcode

```bash
open PullAndConvertVids/PullAndConvertVids.xcodeproj
```

Xcode will open the project with all 38 Swift source files configured.

### 5. Build and Run

In Xcode:
1. Select the **PullAndConvertVids** scheme (top toolbar)
2. Choose **My Mac** as the run destination
3. Press **⌘R** (or Product → Run)

The app will build and launch!

## Troubleshooting

### "Submodule not found" warnings

This is normal if you're using Homebrew-installed binaries (Option A). The app will work fine.

To eliminate warnings:
```bash
git submodule update --init --recursive
```

### "Binary not found" in the app

The app looks for binaries in three locations:

1. **Bundled** (inside the app) - requires building from source
2. **System** (Homebrew) - `/opt/homebrew/bin/` or `/usr/local/bin/`
3. **Custom** - paths specified in Settings

**Solution**: Run `brew install vib795/tap/pull-vids vib795/tap/convert-vid`

### "ffmpeg not found" or "yt-dlp not found"

```bash
brew install ffmpeg yt-dlp
```

Verify installation:
```bash
ffmpeg -version
yt-dlp --version
```

### Xcode build errors

1. **Check Swift version**: Xcode 15+ with Swift 5.9+
2. **Clean build folder**: Product → Clean Build Folder (⇧⌘K)
3. **Verify deployment target**: Should be macOS 13.0 in project settings

### App crashes on launch

1. **Check Console.app** for crash logs
2. **Verify SwiftData**: The app uses SwiftData for persistence
3. **Reset app data**: Delete `~/Library/Application Support/PullAndConvertVids/`

## Verify Installation

Once the app launches:

1. Navigate to **Settings** → **Binary Management**
2. Click **Verify Binaries**
3. You should see:
   - ✓ pull-vids found
   - ✓ convert-vid found
   - ✓ ffmpeg found
   - ✓ yt-dlp found

If any are missing, follow the solutions above.

## Quick Test

### Test Download
1. Go to **Download** tab
2. Paste a YouTube URL: `https://www.youtube.com/watch?v=dQw4w9WgXcQ`
3. Click **Add to Queue**
4. Watch the **Queue** tab for progress

### Test Convert
1. Go to **Convert** tab
2. Drag & drop a video file
3. Select format (e.g., MP4)
4. Click **Start Conversion**

## Binary Source Modes

The app supports three modes (configurable in Settings):

### 1. Bundled (Default)
- Uses binaries inside the app bundle
- Requires building from source (Step 3, Option B)
- Location: `PullAndConvertVids.app/Contents/Resources/bin/`

### 2. System
- Uses Homebrew-installed binaries
- No build required
- Location: `/opt/homebrew/bin/` (Apple Silicon) or `/usr/local/bin/` (Intel)

### 3. Custom
- Specify exact paths to binaries
- Useful for testing or custom installations

**Recommendation**: Use **System** mode if you installed via Homebrew. It's simpler and updates automatically.

## Development Workflow

For developers:

```bash
# 1. Make code changes in Xcode
# 2. Build and test (⌘R)

# 3. If you modify CLI tools:
./Scripts/build_tools.sh

# 4. If you add new Swift files:
#    Xcode will prompt to add them to the target - click "Add to targets: PullAndConvertVids"

# 5. Run tests
cd PullAndConvertVids
xcodebuild test -scheme PullAndConvertVids -destination 'platform=macOS'
```

## Next Steps

- Read the full [README.md](README.md) for feature details
- Check [ARCHITECTURE.md](Docs/ARCHITECTURE.md) for code structure
- Review [BEHAVIOR_SPEC.md](BEHAVIOR_SPEC.md) for CLI tool reference

## Support

If you encounter issues:

1. Check **Diagnostics** tab in the app
2. Review command history for errors
3. File an issue on GitHub with logs

---

**Enjoy your new video downloader and converter!** 🎉
