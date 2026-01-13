# Quick Setup Guide

## Problem: CLI Tools Not Found

If you see "pull-vids binary not found" and "convert-vid binary not found" in the Diagnostics section, you need to install or build the CLI tools.

## Solution 1: Build from Source (Recommended for Development)

```bash
# Navigate to project directory
cd ~/pull-and-convert-vids

# Clone the CLI tool repositories
git submodule update --init --recursive

# Install Go if needed
brew install go

# Build the binaries
./Scripts/build_tools.sh

# The binaries will be created in the Build/ directory
# They should be automatically found by the app
```

## Solution 2: Use Custom Paths in Settings

If you already have the binaries built or installed elsewhere:

1. In the app, go to **Settings** → **Binary Management**
2. Change "CLI Source" to **"Custom Paths"**
3. Click **"Choose..."** next to each binary and select the files:
   - **pull-vids**: Point to your pull-vids binary
   - **convert-vid**: Point to your convert-vid binary
4. Click **"Verify Binaries"** to confirm they work

## Solution 3: Install via Homebrew (if available)

```bash
# If a Homebrew tap exists for these tools:
brew tap vib795/tap
brew install pull-vids convert-vid
```

## Verifying the Fix

After completing any of the above solutions:

1. Go to **Diagnostics** in the app
2. Click **"Refresh"**
3. You should now see green checkmarks for:
   - ✓ pull-vids (with version info)
   - ✓ convert-vid (with version info)
   - ✓ ffmpeg (already working)
   - ✓ yt-dlp (already working)

## Testing Downloads

Once the binaries are found:

1. Go to **Download** section
2. Enter a test URL (e.g., a YouTube video)
3. Click **"Add to Queue"**
4. Go to **Queue** to see the download progress

---

**Note**: The app now searches in multiple locations including:
- `~/pull-and-convert-vids/Build/` (project build directory)
- `~/go/bin/` (Go default install location)
- `/opt/homebrew/bin/` (Homebrew on Apple Silicon)
- `/usr/local/bin/` (Homebrew on Intel)
- System PATH

If you've built or installed the binaries anywhere, the app should find them automatically!
