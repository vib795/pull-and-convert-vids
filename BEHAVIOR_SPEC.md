# CLI Tools Behavior Specification

This document summarizes the exact behavior, flags, and capabilities of the two Go CLI tools that this macOS application wraps.

## 1. pull-vids CLI Tool

**Repository**: https://github.com/vib795/pull-vids
**Binary Name**: `pull-vids`
**Version**: 0.2.1
**Purpose**: Universal video downloader supporting 1000+ websites via yt-dlp backend

### Command-Line Flags

| Flag | Short | Type | Default | Description |
|------|-------|------|---------|-------------|
| `--output` | `-o` | string | `~/Downloads/pull-vids` | Destination directory for downloads |
| `--quality` | `-q` | string | `best` | Resolution/quality selection |
| `--audio-only` | `-a` | boolean | `false` | Extract audio only |
| `--playlist` | `-p` | boolean | `false` | Download entire playlists/channels |
| `--format` | `-f` | string | auto | Output format specification |
| `--cookies` | | string | | Path to Netscape-format cookie file |
| `--cookies-from-browser` | | string | | Extract cookies from browser |
| `--version` | `-v` | boolean | | Display version information |
| `--no-banner` | | boolean | `false` | Suppress banner display |

### Quality Options

**Presets:**
- `best` (default) - Maps to `bestvideo+bestaudio/best`
- `high`
- `medium`
- `low`

**Specific Resolutions:**
- `2160p` (4K)
- `1440p` (2K)
- `1080p` (Full HD)
- `720p` (HD)
- `480p` (SD)
- `360p`

### Audio-Only Mode

Activated with `-a` or `--audio-only` flag.

**Supported Audio Formats:**
- `mp3` (default)
- `m4a`
- `opus`
- `wav`

**Audio Extraction Settings:**
- Default bitrate: 192K
- Uses yt-dlp's `-x --audio-format [format] --audio-quality 192K`

### Video Output Formats

- `mp4` (default)
- `mkv`
- `webm`

### Playlist & Channel Support

Activated with `-p` or `--playlist` flag.

**Supported:**
- YouTube playlists
- YouTube channels
- Other platform playlists (where yt-dlp supports them)

### Cookie Authentication

**Method 1: Cookie File**
```bash
pull-vids --cookies youtube-cookies.txt "URL"
```
Requires Netscape-format cookie file exported via browser extension.

**Method 2: Browser Cookie Extraction**
```bash
pull-vids --cookies-from-browser [browser] "URL"
```

**Supported Browsers:**
- `firefox`
- `chrome`
- `safari`
- `edge`
- `chromium`
- `brave`
- `opera`
- `vivaldi`

**Safari Cookie Extraction Note:**
Requires Full Disk Access permission for the Terminal or application running the CLI.

### Progress Output

**Format:**
- Uses yt-dlp's `--newline` and `--progress` flags
- Outputs to stdout with `[download]` prefix lines
- Progress lines contain: percentage, speed, ETA

**Example Output:**
```
[download]  45.2% of 123.45MiB at 1.23MiB/s ETA 00:45
```

**Parsing Strategy:**
- Real-time progress bars with 100-point scale
- Extracts percentage, speed, and ETA from `[download]` lines
- Colored output (green for success, red for errors)

### Dependencies

**Required:**
- `yt-dlp` - Core download engine
- `ffmpeg` - Media processing and format conversion

### Error Scenarios

| Error | Cause | Solution |
|-------|-------|----------|
| "ffmpeg not found" | FFmpeg not in PATH | Install FFmpeg |
| "yt-dlp not found" | yt-dlp not in PATH | Install yt-dlp |
| "No video formats found" | Region-locked content | Use VPN or cookie auth |
| "Sign in to confirm you're not a bot" | YouTube bot detection | Use cookie authentication |

### Supported Sites

1000+ websites including:
- YouTube (videos, playlists, channels)
- Vimeo
- TikTok
- Instagram
- Facebook
- Twitter/X
- Twitch
- Reddit
- Dailymotion

**Cannot Download:**
- Netflix
- Amazon Prime Video
- Disney+
- Hulu
- HBO Max
- Apple TV+
(DRM-protected content)

### Example Commands

```bash
# Basic download
pull-vids "https://www.youtube.com/watch?v=VIDEO_ID"

# Specify quality
pull-vids -q 720p "https://vimeo.com/123456789"

# Custom output directory
pull-vids -o ~/Videos "https://www.youtube.com/watch?v=VIDEO_ID"

# Audio extraction
pull-vids -a "https://www.youtube.com/watch?v=VIDEO_ID"
pull-vids -a -f mp3 "https://www.youtube.com/watch?v=VIDEO_ID"

# Playlist download
pull-vids -p "https://www.youtube.com/playlist?list=PLAYLIST_ID"

# With cookie authentication
pull-vids --cookies-from-browser firefox "https://www.youtube.com/watch?v=VIDEO_ID"
```

---

## 2. convert-vid CLI Tool

**Repository**: https://github.com/vib795/convert-video-formats
**Binary Name**: `convert-vid`
**Version**: 1.0.5
**Purpose**: Video format converter with batch processing support via ffmpeg backend

### Command-Line Flags

| Flag | Short | Type | Default | Description |
|------|-------|------|---------|-------------|
| `--input` | `-i` | string | **Required** | Path to video file or directory |
| `--format` | `-f` | string | `mp4` | Target output format |
| `--output` | `-o` | string | auto | Output file path or directory |
| `--quality` | `-q` | string | `medium` | Quality preset (high/medium/low) |
| `--concurrent` | `-c` | integer | `runtime.NumCPU()` | Worker threads for batch processing |
| `--overwrite` | | boolean | `false` | Force overwrite existing files |
| `--help` | `-h` | | | Display help information |

**Additional Commands:**
```bash
convert-vid version  # Display version number
```

### Supported Input Formats

- `mp4` (MPEG-4)
- `avi` (Audio Video Interleave)
- `mov` (QuickTime)
- `mkv` (Matroska)
- `webm` (WebM)
- `flv` (Flash Video)
- `m4v` (MPEG-4 Video)
- `mpg` / `mpeg` (MPEG)
- `wmv` (Windows Media Video)

### Supported Output Formats

- `mp4`
- `avi`
- `mov`
- `mkv`
- `webm`
- `flv`

Format validation is case-insensitive.

### Quality Presets

Uses H.264 CRF (Constant Rate Factor) encoding:

| Preset | CRF Value | FFmpeg Preset | Characteristics |
|--------|-----------|---------------|-----------------|
| `high` | 18 | slow | Best quality, largest file size, slowest |
| `medium` | 23 | medium | Balanced quality/size/speed (default) |
| `low` | 28 | fast | Fastest encoding, smallest files |

**CRF Scale:** Lower values (0-51) = better quality; 18 is visually lossless.

### Batch/Folder Processing

**Features:**
- Process entire directories by specifying directory path as input
- Automatically identifies video files using supported extensions
- Worker pool pattern for concurrent processing
- Default concurrency: number of CPU cores

**Example:**
```bash
convert-vid convert ./videos -f mp4 -o ./converted_videos -c 4
```

### Concurrency Options

**Default:** `runtime.NumCPU()` (all available CPU cores)
**Customization:** Use `-c` or `--concurrent` flag

**Example:**
```bash
convert-vid convert videos/ -f mp4 -c 4  # Use 4 workers
```

**Implementation:**
- Worker pool pattern with goroutines
- `sync.WaitGroup` for synchronization
- Buffered channels for task distribution

### Overwrite Behavior

**Default (without --overwrite):**
- Checks if output file exists
- Skips conversion and returns error: "output file already exists"
- Uses FFmpeg `-n` flag (no overwrite)

**With --overwrite flag:**
- Forces overwrite of existing files
- Uses FFmpeg `-y` flag (force overwrite)
- No backup of original output file

**Input File Handling:**
- Original input files are **NEVER** modified or deleted
- Input files remain untouched after conversion
- No automatic backup functionality

### Progress Output Format

**Output Channels:**
- **stderr**: FFmpeg progress data via `-progress pipe:2`
- **stdout**: Tool messages and completion status

**Single File Conversion:**
- Progress bar displays real-time conversion progress
- Parses stderr using regex: `time=(\d{2}):(\d{2}):(\d{2}\.\d{2})`
- Extracts elapsed encoding time
- Fallback: Spinner animation if duration unavailable

**Batch Processing:**
- Shows count of completed files vs total
- Displays aggregated success/failure counts

**Example Progress Line:**
```
time=00:01:23.45
```

### Dependencies

**Required:**
- `ffmpeg` - Must be installed and available in system PATH

**Installation:**
- macOS: `brew install ffmpeg`
- Ubuntu/Debian: `sudo apt install ffmpeg`

### Path Handling

**Features:**
- Supports tilde (`~`) expansion
- Handles paths with spaces (must use quotes)
- Auto-generates output paths with "_converted" suffix if not specified

**Output Path Generation:**
If `-o` not specified: `[filename]_converted.[format]`

**Example:**
```
input: video.avi
output: video_converted.mp4
```

### Example Commands

```bash
# Basic single file conversion
convert-vid convert video.avi -f mp4

# High quality conversion with custom output
convert-vid convert input.mov -f mp4 -q high -o output.mp4

# Batch conversion with 4 workers
convert-vid convert ./videos -f mp4 -o ./converted -c 4

# Overwrite existing files
convert-vid convert video.mkv -f mp4 -o output.mp4 --overwrite

# Paths with spaces (use quotes)
convert-vid convert --input "My Videos/lecture.webm" -f mp4

# Check version
convert-vid version
```

---

## 3. Integration Notes for macOS Application

### Binary Naming (Homebrew Standard)

**Installed Command Names:**
- `pull-vids` (not pull_vids or pullvids)
- `convert-vid` (not convert_vid or convertvid)

**Installation Paths:**
- Homebrew Apple Silicon: `/opt/homebrew/bin/`
- Homebrew Intel: `/usr/local/bin/`

### Dependency Management

**pull-vids requires:**
1. `yt-dlp`
2. `ffmpeg`

**convert-vid requires:**
1. `ffmpeg`

**Installation via Homebrew:**
```bash
brew install ffmpeg
brew install yt-dlp
brew install vib795/tap/pull-vids
brew install vib795/tap/convert-vid
```

### Version Detection Commands

**pull-vids:**
```bash
pull-vids --version
# Expected output: "pull-vids" in output
```

**convert-vid:**
```bash
convert-vid version
# Expected output: version number (e.g., "dev" or "1.0.5")
```

### Bundling Strategy for macOS App

**Bundle Locations:**
```
PullAndConvertVids.app/Contents/Resources/bin/pull-vids
PullAndConvertVids.app/Contents/Resources/bin/convert-vid
```

**Build Requirements:**
- Build Go binaries for both Apple Silicon (arm64) and Intel (amd64)
- Option A: Include both architectures and select at runtime
- Option B: Create universal binary via `lipo`

**Binary Detection Order:**
1. Bundled binaries (inside .app bundle)
2. Custom paths (from Settings)
3. System PATH (Homebrew installation)

### Command Construction Examples

**pull-vids:**
```bash
pull-vids --newline --progress -q 720p -o "/Users/name/Downloads" --cookies-from-browser firefox "https://youtube.com/watch?v=VIDEO_ID"
```

**convert-vid:**
```bash
convert-vid convert --input "/Users/name/video.avi" --format mp4 --quality high --output "/Users/name/output.mp4" --overwrite
```

### Path Escaping

**Both CLIs handle paths properly when passed as separate arguments.**

**Safe (recommended for Process):**
```swift
let args = ["convert", "--input", "/path with spaces/video.avi", "-f", "mp4"]
```

**Unsafe (shell escaping):**
```bash
# Don't do this - use separate arguments instead
convert-vid convert --input "/path with spaces/video.avi" -f mp4
```

---

## 4. UI Mapping Summary

### Download Screen (pull-vids)

**Required Fields:**
- URL(s) input (text field or multi-line)

**Optional Fields:**
- Output directory picker (default: `~/Downloads/pull-vids`)
- Mode selector: Video / Audio-only
- Quality selector: best, 2160p, 1440p, 1080p, 720p, 480p, 360p
- Playlist toggle (for playlists/channels)
- Format selector (for video: mp4/mkv/webm; for audio: mp3/m4a/opus/wav)

**Advanced/Collapsible:**
- Cookie authentication:
  - Radio: Use cookies from browser / Use cookies file
  - Browser dropdown: firefox, chrome, safari, edge, chromium, brave, opera, vivaldi
  - File picker (for cookie file path)
  - Warning for Safari (Full Disk Access required)

### Convert Screen (convert-vid)

**Required Fields:**
- Input file(s) or folder (drag/drop or picker)

**Optional Fields:**
- Target format dropdown: mp4, avi, mov, mkv, webm, flv (default: mp4)
- Quality preset: high, medium, low (default: medium)
- Output location:
  - Same folder (default)
  - Choose folder
- Overwrite toggle (default: off)
- Concurrency slider (for batch): 1 to max CPU cores (default: all cores)

### Pipeline Feature

**In Download Screen:**
- Toggle: "Auto-convert after download"
- If enabled:
  - Target format selector
  - Quality preset selector
  - Overwrite toggle
  - Destination rule: same folder / choose folder

### Settings Screen

**Binary Management:**
- CLI Source selector: Bundled / System PATH / Custom
- Custom path fields:
  - pull-vids path
  - convert-vid path
- Verify button (runs `--version` commands)

**Dependency Status:**
- yt-dlp status (required for pull-vids)
- ffmpeg status (required for both)
- Install instructions (Homebrew commands)

**Output Defaults:**
- Default download folder
- Default conversion folder behavior
- Default concurrency
- Remember last used values toggle

### Diagnostics Screen

**Display:**
- Detected binary paths
- Binary versions
- Dependency status
- Last 20 commands executed (redact sensitive args like cookie paths)

---

## 5. Error Handling Reference

### pull-vids Errors

| Error Pattern | Detection | UI Action |
|---------------|-----------|-----------|
| "ffmpeg not found" | stderr | Show "Install ffmpeg" button |
| "yt-dlp not found" | stderr | Show "Install yt-dlp" button |
| "Sign in to confirm" | stderr | Suggest cookie authentication |
| "No video formats found" | stderr | Show error with copy/retry options |
| Non-zero exit code | exit status | Mark job failed, show logs |

### convert-vid Errors

| Error Pattern | Detection | UI Action |
|---------------|-----------|-----------|
| "ffmpeg not found" | stderr | Show "Install ffmpeg" button |
| "output file already exists" | stderr | Suggest enabling overwrite |
| "unsupported format" | stderr | Show supported formats list |
| Non-zero exit code | exit status | Mark job failed, show logs |

---

## 6. Performance Characteristics

### pull-vids

**Single Download:**
- Speed limited by source website and network
- Progress reported in real-time via stdout parsing
- CPU usage: low (yt-dlp handles download)

**Playlist Download:**
- Sequential processing (one video at a time)
- Total time: sum of individual downloads

### convert-vid

**Single Conversion:**
- CPU-intensive (ffmpeg encoding)
- Progress reported via stderr time extraction
- Quality impact:
  - high (CRF 18): ~2-3x slower than medium
  - medium (CRF 23): baseline
  - low (CRF 28): ~1.5x faster than medium

**Batch Conversion:**
- Parallel processing (worker pool)
- CPU usage scales with concurrency setting
- Optimal concurrency: number of CPU cores

---

This specification is the source of truth for implementing the macOS GUI application.
