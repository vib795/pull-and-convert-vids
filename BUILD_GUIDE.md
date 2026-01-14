# Build & Distribution Guide

## 📦 Building a DMG for Distribution

### Prerequisites

1. **macOS with Xcode 15+** installed from Mac App Store
2. **CLI tools** (pull-vids, convert-vid) available:
   ```bash
   brew install vib795/tap/pull-vids vib795/tap/convert-vid
   ```
3. **Dependencies**:
   ```bash
   brew install ffmpeg yt-dlp
   ```

---

## Method 1: Xcode GUI Build (Recommended - Easiest)

### Step 1: Build the App in Xcode

1. **Open the project:**
   ```bash
   open PullAndConvertVids/PullAndConvertVids.xcodeproj
   ```

2. **Select build destination:**
   - At the top of Xcode, click the destination dropdown
   - Select **"Any Mac (Apple Silicon, Intel)"**

3. **Build the Release version:**
   - Menu: **Product → Build** (⌘B)
   - Wait for build to complete (watch progress bar)

### Step 2: Package into DMG

```bash
# Simple packaging script (works without xcodebuild CLI)
./Scripts/package_dmg.sh
```

The DMG will be created at: `Build/Pull-and-Convert-Vids-1.0.0.dmg`

**That's it!** ✅

---

## Method 2: Command-Line Build (Advanced)

**Note:** Requires full Xcode installed (not just Command Line Tools)

### Quick Build

```bash
# One-command automated build
./Scripts/build_dmg.sh
```

The DMG will be created at: `Build/Pull-and-Convert-Vids-1.0.0.dmg`

### What the Script Does

1. ✅ Cleans previous builds
2. ✅ Builds Release version of the app
3. ✅ Creates an archive
4. ✅ Exports the app bundle
5. ✅ Packages everything in a DMG with Applications symlink
6. ✅ Compresses the DMG for distribution

### Build Output

```
Build/
├── Pull-and-Convert-Vids-1.0.0.dmg    ← Distributable DMG
├── PullAndConvertVids.xcarchive/       ← Archive
├── Export/                              ← Exported app
│   └── Pull and Convert Vids.app
└── DMG/                                 ← DMG contents
    ├── Pull and Convert Vids.app
    └── Applications → /Applications
```

---

## 🎨 Setting Up the App Icon

You have 3 icon variations provided:

1. **Primary macOS Icon** (Soft Gradient Depth) - Recommended for main app
2. **Minimal Flat Variation** - For documentation/web
3. **Monochrome Variation** (Menu Bar/Utility) - For menu bar apps

### Steps to Add Icon

#### Option 1: Using Xcode (Easiest)

1. **Prepare the icon:**
   - Save the **PRIMARY macOS ICON** as a PNG (1024×1024px recommended)
   - Name it `AppIcon.png`

2. **In Xcode:**
   - Open `PullAndConvertVids.xcodeproj`
   - In the navigator, select **Assets.xcassets**
   - Select **AppIcon**
   - Drag your `AppIcon.png` onto the **1024×1024** slot
   - Xcode will automatically generate all required sizes

#### Option 2: Using iconutil (Command Line)

1. **Create an iconset:**
   ```bash
   mkdir -p AppIcon.iconset

   # Generate all required sizes (use sips or ImageMagick)
   sips -z 16 16     AppIcon.png --out AppIcon.iconset/icon_16x16.png
   sips -z 32 32     AppIcon.png --out AppIcon.iconset/icon_16x16@2x.png
   sips -z 32 32     AppIcon.png --out AppIcon.iconset/icon_32x32.png
   sips -z 64 64     AppIcon.png --out AppIcon.iconset/icon_32x32@2x.png
   sips -z 128 128   AppIcon.png --out AppIcon.iconset/icon_128x128.png
   sips -z 256 256   AppIcon.png --out AppIcon.iconset/icon_128x128@2x.png
   sips -z 256 256   AppIcon.png --out AppIcon.iconset/icon_256x256.png
   sips -z 512 512   AppIcon.png --out AppIcon.iconset/icon_256x256@2x.png
   sips -z 512 512   AppIcon.png --out AppIcon.iconset/icon_512x512.png
   sips -z 1024 1024 AppIcon.png --out AppIcon.iconset/icon_512x512@2x.png

   # Convert to .icns
   iconutil -c icns AppIcon.iconset -o AppIcon.icns
   ```

2. **Add to Xcode:**
   - Place `AppIcon.icns` in your project
   - In **Info.plist**, set `CFBundleIconFile` to `AppIcon`

#### Option 3: Using Asset Catalog (Recommended)

1. Create all sizes and add to `Assets.xcassets/AppIcon.appiconset/`
2. Update `Contents.json` with proper mappings

---

## 🚢 Distribution Steps

### 1. Build the DMG
```bash
./Scripts/build_dmg.sh
```

### 2. Test the DMG
```bash
# Mount and test
open Build/Pull-and-Convert-Vids-1.0.0.dmg

# Try installing
# Drag app to Applications
# Launch and verify it works
```

### 3. Distribute

**Upload to:**
- GitHub Releases
- Your website
- App distribution platform

**DMG includes:**
- ✅ App bundle
- ✅ Applications folder symlink for easy drag-and-drop install
- ✅ Compressed for smaller download

---

## 🔧 Advanced Build Options

### Custom Version Number

Edit the script or pass as environment variable:
```bash
VERSION=1.1.0 ./Scripts/build_dmg.sh
```

### Code Signing (for App Store or notarization)

To properly sign your app:

1. **Get a Developer ID:**
   - Enroll in Apple Developer Program ($99/year)
   - Create Developer ID Application certificate

2. **Update build script:**
   ```bash
   CODE_SIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
   CODE_SIGNING_REQUIRED=YES
   CODE_SIGNING_ALLOWED=YES
   ```

3. **Notarize for Gatekeeper:**
   ```bash
   # Submit for notarization
   xcrun notarytool submit Build/Pull-and-Convert-Vids-1.0.0.dmg \
     --apple-id "your@email.com" \
     --team-id "TEAM_ID" \
     --password "app-specific-password"

   # Staple the notarization ticket
   xcrun stapler staple Build/Pull-and-Convert-Vids-1.0.0.dmg
   ```

---

## 📝 Notes

### Why No Code Signing by Default?

The default build script disables code signing for easier local development and testing. Users can run the app by:
1. Right-click → Open (first launch)
2. Or go to System Settings → Privacy & Security → Allow

### For Production Distribution

Consider:
- ✅ Code signing with Developer ID
- ✅ Notarization for Gatekeeper
- ✅ Hardened Runtime enabled
- ✅ Entitlements properly configured

---

## 🐛 Troubleshooting

### "App is damaged" message
- Cause: Gatekeeper blocking unsigned apps
- Fix: `xattr -cr "/Applications/Pull and Convert Vids.app"`

### "No developer certificate found"
- This is expected if you haven't enrolled in Apple Developer Program
- Script disables signing by default for this reason

### Build fails
- Ensure Xcode Command Line Tools installed: `xcode-select --install`
- Clean derived data: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Try building in Xcode first to catch any issues

---

## ✅ Quick Checklist

Before distributing:

- [ ] App icon is set (use PRIMARY macOS ICON)
- [ ] Version number updated in script and Info.plist
- [ ] All features tested in Release build
- [ ] README updated with installation instructions
- [ ] License file included
- [ ] CLI tools (pull-vids, convert-vid) documented as dependencies

---

Ready to ship! 🚀
