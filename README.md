# Pull and Convert Vids

A modern, production-quality macOS application for downloading videos from 1000+ sites and converting video formats, built with SwiftUI and powered by the battle-tested [pull-vids](https://github.com/vib795/pull-vids) and [convert-vid](https://github.com/vib795/convert-video-formats) CLI tools.

![Platform](https://img.shields.io/badge/platform-macOS%2013.0%2B-blue)
![Swift](https://img.shields.io/badge/Swift-5.9%2B-orange)
![License](https://img.shields.io/badge/license-MIT-green)

## Features

### 🎬 Video Downloading (via pull-vids)
- **1000+ supported websites**: YouTube, Vimeo, TikTok, Instagram, Twitter, Twitch, and more
- **Quality selection**: Best, 4K (2160p), 2K (1440p), Full HD (1080p), HD (720p), SD (480p), 360p
- **Audio extraction**: Download audio-only in MP3, M4A, Opus, or WAV
- **Playlist support**: Download entire YouTube playlists and channels
- **Cookie authentication**: Bypass bot detection with browser cookie extraction (Firefox, Chrome, Safari, Edge, Brave, etc.)
- **Real-time progress**: Live download speed, ETA, and percentage tracking

### 🔄 Video Conversion (via convert-vid)
- **Multiple formats**: Convert to/from MP4, AVI, MOV, MKV, WebM, FLV
- **Quality presets**: High (CRF 18), Medium (CRF 23), Low (CRF 28)
- **Batch processing**: Convert multiple files or entire folders concurrently
- **Smart concurrency**: Automatic CPU core detection with manual override (1-16 threads)
- **Drag & drop**: Simple file and folder import
- **Non-destructive**: Original files are never modified

### ⚡ Pipeline Workflow
- **One-click automation**: Auto-convert downloads to your preferred format
- **Configurable**: Set target format, quality, and output location per download
- **Background processing**: Jobs run asynchronously without blocking the UI

### 🎯 Modern macOS UI
- **Native SwiftUI**: Clean, responsive interface with sidebar navigation
- **Queue management**: View active jobs with live progress and controls
- **History tracking**: Search and filter completed jobs by status/type
- **Settings & Diagnostics**: Binary management, dependency checking, command history
- **Keyboard shortcuts**: ⌘D (Download), ⌘K (Convert), ⌘Q (Queue), ⌘H (History), ⌘, (Settings)
- **Empty states**: Polished placeholders with actionable guidance

## Screenshots

> TODO: Add screenshots

## Requirements

- **macOS 13.0 (Ventura) or later**
- **Required dependencies** (auto-detected by the app):
  - `ffmpeg` - Media processing ([install via Homebrew](https://formulae.brew.sh/formula/ffmpeg))
  - `yt-dlp` - Video downloading backend ([install via Homebrew](https://formulae.brew.sh/formula/yt-dlp))

## Installation

### Option 1: Download Release (Coming Soon)
Download the latest `.dmg` from the [Releases](https://github.com/vib795/pull-and-convert-vids/releases) page.

### Option 2: Build from Source

#### Prerequisites
```bash
# Install Xcode 15+ from the Mac App Store
xcode-select --install

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Go (for building CLI tools)
brew install go

# Install dependencies
brew install ffmpeg yt-dlp
```

#### Build Steps
```bash
# 1. Clone the repository
git clone https://github.com/vib795/pull-and-convert-vids.git
cd pull-and-convert-vids

# 2. Initialize submodules
git submodule update --init --recursive

# 3. Install dependencies (optional if already installed)
./Scripts/install_dependencies.sh

# 4. Build Go CLI tools
./Scripts/build_tools.sh

# 5. Open in Xcode
open PullAndConvertVids/PullAndConvertVids.xcodeproj

# 6. Build and run (⌘R)
```

The build scripts will:
- Compile `pull-vids` and `convert-vid` as universal binaries (Apple Silicon + Intel)
- Bundle them inside the app at `PullAndConvertVids.app/Contents/Resources/bin/`

## Usage

### Downloading Videos

1. Navigate to **Download** screen
2. Paste one or more URLs (one per line)
3. Select quality and format options
4. (Optional) Enable cookie authentication for YouTube bot detection
5. (Optional) Enable "Auto-convert after download" for one-click pipeline
6. Click **Add to Queue**

**Supported Sites**: YouTube, Vimeo, TikTok, Instagram, Facebook, Twitter/X, Twitch, Reddit, Dailymotion, and [1000+ more](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md).

### Converting Videos

1. Navigate to **Convert** screen
2. Drag & drop video files or click **Add Files/Add Folder**
3. Select output format (MP4, AVI, MOV, MKV, WebM, FLV)
4. Choose quality preset (High, Medium, Low)
5. Configure output location and concurrency
6. Click **Start Conversion**

### Cookie Authentication (YouTube Bot Detection)

If you encounter "Sign in to confirm you're not a bot" errors:

1. In the **Download** screen, expand **Cookie Authentication**
2. Choose method:
   - **Browser**: Select your browser (Firefox, Chrome, etc.)
   - **File**: Use a Netscape-format cookie file
3. **For Safari users**: Grant Full Disk Access to Terminal/app in System Settings → Privacy & Security

## Binary Management

The app supports three binary source modes (configurable in **Settings**):

1. **Bundled** (default): Uses binaries inside the app bundle
2. **System**: Uses Homebrew-installed binaries (`/opt/homebrew/bin` or `/usr/local/bin`)
3. **Custom**: Specify custom paths to `pull-vids` and `convert-vid`

Click **Verify Binaries** in Settings to check status and versions.

## Architecture

### Tech Stack
- **Swift 5.9+ / SwiftUI**: Modern, declarative UI
- **SwiftData**: Persistent storage for jobs and settings
- **MVVM + async/await**: Clean separation of concerns
- **Process API**: Streams stdout/stderr in real-time
- **Go CLI tools**: Robust, battle-tested backends

### Repository Structure
```
pull-and-convert-vids/
├── PullAndConvertVids/           # Xcode project
│   ├── App/                      # App entry point
│   ├── Models/                   # SwiftData models
│   ├── ViewModels/               # Business logic
│   ├── Views/                    # SwiftUI views
│   ├── Services/                 # CLI wrappers, job management
│   └── Utilities/                # Helpers and extensions
├── Tools/                        # Git submodules
│   ├── pull-vids/                # Video downloader CLI
│   └── convert-video-formats/    # Video converter CLI
├── Scripts/                      # Build automation
├── CI/.github/workflows/         # GitHub Actions
└── Docs/                         # Documentation
```

### Key Design Patterns
- **ProcessRunner**: Abstract interface with real/mock implementations for testing
- **JobManager**: Orchestrates queue, limits concurrency, manages lifecycle
- **PipelineCoordinator**: Chains download → convert operations
- **BinaryLocator**: Resolves binary paths (bundled, system, custom)
- **ProgressParser**: Extracts progress info from CLI output

## Development

### Running Tests
```bash
cd PullAndConvertVids
xcodebuild test -scheme PullAndConvertVids -destination 'platform=macOS'
```

### Xcode Build Phase Scripts
The project includes a build phase script that automatically bundles Go binaries:
```bash
"${PROJECT_DIR}/../Scripts/bundle_binaries.sh"
```

### CI/CD
GitHub Actions workflows automatically:
- Build Go binaries for both architectures
- Build and test the macOS app
- Upload artifacts for each commit

## Troubleshooting

### "Binary not found" errors
- **Solution**: Run `./Scripts/build_tools.sh` to build CLI tools
- **Alternative**: Install via Homebrew: `brew install vib795/tap/pull-vids vib795/tap/convert-vid`
- **Check**: Verify in Settings → Binary Management

### "ffmpeg not found" or "yt-dlp not found"
- **Solution**: `brew install ffmpeg yt-dlp`
- **Check**: Run `ffmpeg -version` and `yt-dlp --version` in Terminal

### Safari cookie extraction fails
- **Solution**: Grant Full Disk Access to Terminal (or the app) in System Settings → Privacy & Security → Full Disk Access

### Slow downloads
- **Cause**: Website throttling (normal behavior)
- **Solution**: Consider using cookie authentication or VPN

### Output file already exists
- **Solution**: Enable "Overwrite existing files" in Convert settings

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Related Projects

- **pull-vids**: https://github.com/vib795/pull-vids (CLI video downloader)
- **convert-video-formats**: https://github.com/vib795/convert-video-formats (CLI video converter)
- **Homebrew Tap**: https://github.com/vib795/homebrew-tap (Formulae for both tools)

## License

MIT License - see [LICENSE](LICENSE) for details.

## Credits

- Built with ❤️ using SwiftUI and Go
- Powered by [yt-dlp](https://github.com/yt-dlp/yt-dlp) and [FFmpeg](https://ffmpeg.org)
- CLI tools: [pull-vids](https://github.com/vib795/pull-vids) & [convert-vid](https://github.com/vib795/convert-video-formats)

## Disclaimer

This tool is for personal use only. Respect copyright laws and terms of service of the websites you download from. The developers are not responsible for any misuse of this software.
