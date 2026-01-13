# Repository Structure

This document outlines the complete file structure for the pull-and-convert-vids macOS application.

```
pull-and-convert-vids/
├── README.md                           # User and developer documentation
├── LICENSE                             # MIT License
├── BEHAVIOR_SPEC.md                    # CLI tools behavior specification
├── REPOSITORY_STRUCTURE.md             # This file
├── .gitignore                          # Git ignore patterns
├── .gitmodules                         # Git submodules (optional)
│
├── PullAndConvertVids/                 # Xcode project root
│   ├── PullAndConvertVids.xcodeproj/   # Xcode project file
│   │
│   ├── PullAndConvertVids/             # Main app target
│   │   ├── App/
│   │   │   ├── PullAndConvertVidsApp.swift          # App entry point
│   │   │   ├── AppDelegate.swift                    # App delegate for lifecycle
│   │   │   └── Info.plist                           # App configuration
│   │   │
│   │   ├── Models/
│   │   │   ├── Job.swift                            # SwiftData job model
│   │   │   ├── JobType.swift                        # Download/Convert enum
│   │   │   ├── JobStatus.swift                      # Status enum
│   │   │   ├── DownloadSettings.swift               # Download configuration
│   │   │   ├── ConvertSettings.swift                # Conversion configuration
│   │   │   ├── AppSettings.swift                    # App-wide settings
│   │   │   ├── CommandRecord.swift                  # Diagnostics command log
│   │   │   └── BinaryInfo.swift                     # Binary detection info
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── DownloadViewModel.swift              # Download screen logic
│   │   │   ├── ConvertViewModel.swift               # Convert screen logic
│   │   │   ├── QueueViewModel.swift                 # Queue management logic
│   │   │   ├── HistoryViewModel.swift               # History screen logic
│   │   │   ├── SettingsViewModel.swift              # Settings screen logic
│   │   │   └── DiagnosticsViewModel.swift           # Diagnostics screen logic
│   │   │
│   │   ├── Views/
│   │   │   ├── ContentView.swift                    # Main sidebar navigation
│   │   │   ├── Download/
│   │   │   │   ├── DownloadView.swift               # Download screen
│   │   │   │   ├── URLInputView.swift               # Multi-line URL input
│   │   │   │   ├── QualityPickerView.swift          # Quality selector
│   │   │   │   ├── CookieAuthView.swift             # Cookie auth section
│   │   │   │   └── PipelineToggleView.swift         # Auto-convert toggle
│   │   │   ├── Convert/
│   │   │   │   ├── ConvertView.swift                # Convert screen
│   │   │   │   ├── FileDropZoneView.swift           # Drag & drop area
│   │   │   │   ├── FormatPickerView.swift           # Format selector
│   │   │   │   └── ConcurrencySliderView.swift      # Concurrency control
│   │   │   ├── Queue/
│   │   │   │   ├── QueueView.swift                  # Queue list screen
│   │   │   │   ├── QueueItemRow.swift               # Single queue item
│   │   │   │   └── JobProgressView.swift            # Progress indicator
│   │   │   ├── History/
│   │   │   │   ├── HistoryView.swift                # History screen
│   │   │   │   ├── HistoryItemRow.swift             # History item row
│   │   │   │   └── HistoryFilterView.swift          # Filter controls
│   │   │   ├── Settings/
│   │   │   │   ├── SettingsView.swift               # Settings screen
│   │   │   │   ├── BinaryManagementView.swift       # Binary paths config
│   │   │   │   ├── DependencyStatusView.swift       # Dependency checker
│   │   │   │   └── OutputDefaultsView.swift         # Default paths
│   │   │   ├── Diagnostics/
│   │   │   │   ├── DiagnosticsView.swift            # Diagnostics screen
│   │   │   │   ├── BinaryInfoView.swift             # Detected binaries
│   │   │   │   └── CommandLogView.swift             # Command history
│   │   │   └── Components/
│   │   │       ├── EmptyStateView.swift             # Empty state placeholder
│   │   │       ├── ErrorView.swift                  # Error display
│   │   │       ├── LogViewerView.swift              # Log viewer modal
│   │   │       └── ActionButtonsView.swift          # Reusable action buttons
│   │   │
│   │   ├── Services/
│   │   │   ├── ProcessRunner.swift                  # Process execution with streaming
│   │   │   ├── PullVidsService.swift                # pull-vids CLI wrapper
│   │   │   ├── ConvertVidService.swift              # convert-vid CLI wrapper
│   │   │   ├── BinaryLocator.swift                  # Binary path resolution
│   │   │   ├── DependencyChecker.swift              # Check ffmpeg/yt-dlp
│   │   │   ├── ProgressParser.swift                 # Parse progress from output
│   │   │   ├── JobManager.swift                     # Job queue orchestration
│   │   │   └── PipelineCoordinator.swift            # Download→Convert pipeline
│   │   │
│   │   ├── Utilities/
│   │   │   ├── PathHelpers.swift                    # Path expansion & validation
│   │   │   ├── ArgumentBuilder.swift                # CLI argument construction
│   │   │   ├── FileHelpers.swift                    # File operations
│   │   │   ├── DateFormatters.swift                 # Date formatting
│   │   │   └── Constants.swift                      # App-wide constants
│   │   │
│   │   └── Resources/
│   │       ├── Assets.xcassets/                     # App icons, images
│   │       │   ├── AppIcon.appiconset/
│   │       │   └── Colors.colorset/
│   │       └── Localizable.strings                  # Localization (optional)
│   │
│   ├── PullAndConvertVidsTests/        # Unit tests
│   │   ├── ArgumentBuilderTests.swift               # Argument builder tests
│   │   ├── PathHelpersTests.swift                   # Path utilities tests
│   │   ├── ProgressParserTests.swift                # Progress parsing tests
│   │   ├── JobManagerTests.swift                    # Job state tests
│   │   ├── MockProcessRunner.swift                  # Mock for testing
│   │   └── TestHelpers.swift                        # Test utilities
│   │
│   └── PullAndConvertVidsUITests/      # UI tests (optional)
│       └── DownloadFlowTests.swift                  # Basic UI flow tests
│
├── Tools/                              # Go CLI tools (submodules or vendored)
│   ├── pull-vids/                      # Git submodule or vendored code
│   │   ├── main.go
│   │   ├── go.mod
│   │   ├── go.sum
│   │   └── ...
│   │
│   └── convert-video-formats/          # Git submodule or vendored code
│       ├── main.go
│       ├── go.mod
│       ├── go.sum
│       └── ...
│
├── Scripts/                            # Build and utility scripts
│   ├── build_tools.sh                  # Build Go binaries (universal if possible)
│   ├── bundle_binaries.sh              # Copy binaries to app bundle
│   ├── install_dependencies.sh         # Install ffmpeg/yt-dlp via Homebrew
│   └── setup_submodules.sh             # Initialize git submodules
│
├── CI/                                 # Continuous Integration
│   └── .github/
│       └── workflows/
│           ├── build.yml               # Build workflow
│           ├── test.yml                # Test workflow
│           └── release.yml             # Release workflow (optional)
│
└── Docs/                               # Additional documentation
    ├── SETUP.md                        # Development setup guide
    ├── ARCHITECTURE.md                 # Architecture overview
    ├── CODE_SIGNING.md                 # Code signing & notarization
    └── TROUBLESHOOTING.md              # Common issues and solutions
```

## Directory Descriptions

### `/PullAndConvertVids/PullAndConvertVids/`

**Main application source code organized by architectural layers:**

- **App/**: Application lifecycle and entry point
- **Models/**: SwiftData models and data structures
- **ViewModels/**: MVVM view models with business logic
- **Views/**: SwiftUI views organized by feature
- **Services/**: Core services for CLI interaction and job management
- **Utilities/**: Helper functions and extensions
- **Resources/**: Assets, icons, and localization files

### `/Tools/`

**Go CLI tool source code:**

Two options for managing these:

**Option A: Git Submodules (Recommended)**
```bash
git submodule add https://github.com/vib795/pull-vids.git Tools/pull-vids
git submodule add https://github.com/vib795/convert-video-formats.git Tools/convert-video-formats
```

**Option B: Vendored Code**
- Copy source code directly into the repository
- Easier for contributors but harder to sync with upstream

### `/Scripts/`

**Build automation scripts:**

- `build_tools.sh`: Compiles Go binaries for Apple Silicon and Intel
- `bundle_binaries.sh`: Copies compiled binaries to Xcode Resources
- `install_dependencies.sh`: Installs runtime dependencies (ffmpeg, yt-dlp)
- `setup_submodules.sh`: Initializes and updates git submodules

### `/CI/.github/workflows/`

**GitHub Actions workflows:**

- `build.yml`: Automated builds on push/PR
- `test.yml`: Run unit tests
- `release.yml`: Create release artifacts (DMG, notarized app)

### `/Docs/`

**Extended documentation:**

- `SETUP.md`: Step-by-step development environment setup
- `ARCHITECTURE.md`: High-level architecture and design decisions
- `CODE_SIGNING.md`: Code signing and notarization guide
- `TROUBLESHOOTING.md`: Common problems and solutions

## App Bundle Structure (Runtime)

When built and bundled, the application structure looks like:

```
PullAndConvertVids.app/
├── Contents/
│   ├── Info.plist
│   ├── MacOS/
│   │   └── PullAndConvertVids           # Main executable
│   ├── Resources/
│   │   ├── Assets.car                   # Compiled assets
│   │   ├── bin/
│   │   │   ├── pull-vids                # Bundled CLI binary
│   │   │   └── convert-vid              # Bundled CLI binary
│   │   └── ...
│   └── _CodeSignature/                  # Code signature (if signed)
```

## Binary Building Strategy

### Universal Binary Approach

**Goal:** Support both Apple Silicon (arm64) and Intel (amd64) Macs.

**Option A: Separate Binaries**
```bash
# Build for Apple Silicon
GOOS=darwin GOARCH=arm64 go build -o pull-vids-arm64

# Build for Intel
GOOS=darwin GOARCH=amd64 go build -o pull-vids-amd64

# Detect architecture at runtime and use appropriate binary
```

**Option B: Universal Binary (via lipo)**
```bash
# Build both architectures
GOOS=darwin GOARCH=arm64 go build -o pull-vids-arm64
GOOS=darwin GOARCH=amd64 go build -o pull-vids-amd64

# Combine into universal binary
lipo -create -output pull-vids pull-vids-arm64 pull-vids-amd64
```

**Recommendation:** Use Option B (universal binary) for simplicity.

## File Locations (Settings)

### User Data Storage

**SwiftData Database:**
- Location: `~/Library/Application Support/PullAndConvertVids/`
- Stores: Jobs, settings, command history

**User Defaults:**
- Binary paths
- Last used directories
- Window state

### Binary Resolution Order

1. **Bundled**: `PullAndConvertVids.app/Contents/Resources/bin/`
2. **Custom**: User-specified paths from Settings
3. **System**: Homebrew paths (`/opt/homebrew/bin/` or `/usr/local/bin/`)
4. **PATH**: System PATH environment variable

## Git Configuration

### `.gitignore`

```gitignore
# Xcode
*.xcodeproj/xcuserdata/
*.xcodeproj/project.xcworkspace/xcuserdata/
*.xcworkspace/xcuserdata/
DerivedData/
*.hmap
*.ipa
*.dSYM.zip
*.dSYM

# Swift Package Manager
.swiftpm/
.build/

# Go
Tools/*/bin/
Tools/*/pkg/
*.exe
*.exe~
*.dll
*.so
*.dylib

# Compiled binaries
Scripts/*.o
Scripts/*.a
Scripts/*.test
Scripts/*.out

# OS files
.DS_Store
Thumbs.db

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# Build artifacts
build/
*.app
*.dmg
*.pkg
```

### `.gitmodules` (if using submodules)

```gitmodules
[submodule "Tools/pull-vids"]
    path = Tools/pull-vids
    url = https://github.com/vib795/pull-vids.git
    branch = main
[submodule "Tools/convert-video-formats"]
    path = Tools/convert-video-formats
    url = https://github.com/vib795/convert-video-formats.git
    branch = main
```

## Xcode Project Configuration

### Target Settings

**General:**
- **Product Name:** PullAndConvertVids
- **Bundle Identifier:** com.vib795.PullAndConvertVids
- **Version:** 1.0.0
- **Build:** 1
- **Deployment Target:** macOS 13.0+
- **Category:** Utilities

**Signing & Capabilities:**
- **Team:** None (for local development)
- **Signing Certificate:** Sign to Run Locally
- **Hardened Runtime:** Enabled (required for notarization)
- **App Sandbox:** Disabled (for file system access)

**Build Settings:**
- **Swift Language Version:** Swift 5
- **Enable Hardened Runtime:** YES
- **Code Signing Identity:** "-" (local development)

**Build Phases:**
- **Run Script Phase:** Copy bundled binaries to Resources/bin/
  ```bash
  "${PROJECT_DIR}/../Scripts/bundle_binaries.sh"
  ```

### SwiftData Configuration

**ModelContainer** configured in `PullAndConvertVidsApp.swift`:
```swift
@main
struct PullAndConvertVidsApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            modelContainer = try ModelContainer(for: Job.self, AppSettings.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}
```

## Development Workflow

### Initial Setup

1. Clone repository:
   ```bash
   git clone https://github.com/vib795/pull-and-convert-vids.git
   cd pull-and-convert-vids
   ```

2. Initialize submodules (if using):
   ```bash
   ./Scripts/setup_submodules.sh
   ```

3. Install dependencies:
   ```bash
   ./Scripts/install_dependencies.sh
   ```

4. Build Go binaries:
   ```bash
   ./Scripts/build_tools.sh
   ```

5. Open Xcode project:
   ```bash
   open PullAndConvertVids/PullAndConvertVids.xcodeproj
   ```

6. Build and run in Xcode (⌘R)

### Building for Distribution

1. Build Go binaries for release:
   ```bash
   ./Scripts/build_tools.sh --release
   ```

2. Archive in Xcode:
   - Product → Archive
   - Distribute App → Copy App

3. Create DMG (optional):
   ```bash
   hdiutil create -volname "Pull and Convert Vids" -srcfolder PullAndConvertVids.app -ov -format UDZO PullAndConvertVids.dmg
   ```

4. Notarize (if code signed):
   ```bash
   xcrun notarytool submit PullAndConvertVids.dmg --apple-id "..." --password "..." --team-id "..."
   ```

## Testing Strategy

### Unit Tests

**Coverage:**
- Argument builders for both CLI tools
- Path expansion and validation
- Progress parsing logic
- Job state transitions
- Binary path resolution

**Mock Strategy:**
- `MockProcessRunner` protocol conformance
- Simulated stdout/stderr streams
- Predefined exit codes

### UI Tests (Optional)

**Basic Flows:**
- Navigate between screens
- Add URL to download queue
- Add file to convert queue
- Verify job appears in queue

### Manual Testing

**Test Cases:**
- Download video with various quality settings
- Download audio-only
- Convert single file
- Convert folder (batch)
- Pipeline: download → auto-convert
- Binary detection and verification
- Error scenarios (missing dependencies, invalid URLs)

---

This structure provides a clean, maintainable codebase with clear separation of concerns and production-ready build automation.
