# Architecture Overview

This document provides a high-level overview of the Pull and Convert Vids architecture.

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        SwiftUI Views                        │
│  (Download, Convert, Queue, History, Settings, Diagnostics) │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                        ViewModels                           │
│        (Business Logic, UI State, User Actions)             │
└───────────────────────────┬─────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────┐
│                        Services                             │
│  ┌────────────────┐  ┌────────────────┐  ┌──────────────┐  │
│  │  PullVidsService│  │ConvertVidService│  │ JobManager   │  │
│  └────────┬───────┘  └────────┬───────┘  └──────┬───────┘  │
│           │                    │                  │          │
│           └────────────────────┼──────────────────┘          │
│                                │                             │
│  ┌────────────────────────────▼──────────────────────────┐  │
│  │            ProcessRunner (with streaming)             │  │
│  └────────────────────────────┬──────────────────────────┘  │
└───────────────────────────────┼─────────────────────────────┘
                                │
                    ┌───────────▼───────────┐
                    │    Process API        │
                    │  (stdout/stderr)      │
                    └───────────┬───────────┘
                                │
        ┌───────────────────────┴───────────────────────┐
        │                                               │
┌───────▼───────┐                             ┌─────────▼────────┐
│   pull-vids   │                             │   convert-vid    │
│  (Go binary)  │                             │    (Go binary)   │
└───────────────┘                             └──────────────────┘
```

## Layer Breakdown

### 1. Views (SwiftUI)

**Responsibility:** User interface and presentation logic

**Components:**
- **DownloadView**: URL input, quality selection, cookie auth
- **ConvertView**: File picker, format/quality selection
- **QueueView**: Active jobs with progress indicators
- **HistoryView**: Completed jobs with filtering
- **SettingsView**: Binary management, dependencies
- **DiagnosticsView**: System info, binary versions, command history

**Key Patterns:**
- Declarative UI with SwiftUI
- @StateObject for ViewModel ownership
- @ObservedObject for reactive updates
- @Query for SwiftData queries

### 2. ViewModels (MVVM)

**Responsibility:** Business logic, state management, user action handling

**Components:**
- **DownloadViewModel**: Manages download form state and validation
- **ConvertViewModel**: Manages file selection and conversion settings
- **QueueViewModel**: Provides queue operations and filtering
- **HistoryViewModel**: Provides history queries and bulk actions
- **SettingsViewModel**: Manages app settings and binary verification
- **DiagnosticsViewModel**: Collects system diagnostics

**Key Patterns:**
- MVVM pattern
- ObservableObject protocol
- @Published properties for reactive state
- Async/await for asynchronous operations
- @MainActor for UI thread safety

### 3. Services

#### ProcessRunner

**Core service for executing external processes with streaming output.**

```swift
protocol ProcessRunnerProtocol {
    func run(
        binary: String,
        arguments: [String],
        outputHandler: @escaping (String) -> Void,
        errorHandler: @escaping (String) -> Void,
        completionHandler: @escaping (Int32) -> Void
    ) -> ProcessHandle
}
```

**Features:**
- Real-time stdout/stderr streaming
- Line-by-line output parsing
- Cancellation support via ProcessHandle
- Testable via protocol abstraction

#### PullVidsService

**Wraps pull-vids CLI for video downloading.**

```swift
func download(
    url: String,
    settings: DownloadSettings,
    progressCallback: @escaping (DownloadProgress) -> Void,
    logCallback: @escaping (String) -> Void,
    completion: @escaping (Result<String, Error>) -> Void
) -> ProcessHandle?
```

**Responsibilities:**
- Build command-line arguments from DownloadSettings
- Parse progress from yt-dlp output
- Extract output file paths from logs
- Handle errors and exit codes

#### ConvertVidService

**Wraps convert-vid CLI for video conversion.**

```swift
func convert(
    input: String,
    settings: ConvertSettings,
    progressCallback: @escaping (ConversionProgress) -> Void,
    logCallback: @escaping (String) -> Void,
    completion: @escaping (Result<String, Error>) -> Void
) -> ProcessHandle?
```

**Responsibilities:**
- Build command-line arguments from ConvertSettings
- Parse ffmpeg progress from stderr
- Extract video duration for ETA calculation
- Handle batch processing

#### JobManager

**Orchestrates job queue and execution.**

```swift
@MainActor
class JobManager: ObservableObject {
    @Published var runningJobs: [UUID: ProcessHandle]
    @Published var activeJobCount: Int

    func processNext()
    func cancelJob(_ job: Job)
    func retryJob(_ job: Job)
}
```

**Responsibilities:**
- Enforce concurrency limits (default: 10)
- Start queued jobs automatically
- Track running processes
- Handle job lifecycle (queued → running → success/failed/canceled)
- Coordinate with PipelineCoordinator for chained operations

#### PipelineCoordinator

**Chains download → convert operations.**

```swift
@MainActor
func executePipeline(
    job: Job,
    downloadSettings: DownloadSettings,
    convertSettings: ConvertSettings
) async
```

**Responsibilities:**
- Execute download phase (0-50% progress)
- Execute convert phase (50-100% progress)
- Handle failures at each phase
- Update single job with combined progress

### 4. Utilities

#### ArgumentBuilder

**Builds command-line arguments for both CLIs.**

```swift
static func buildPullVidsArguments(url: String, settings: DownloadSettings) -> [String]
static func buildConvertVidArguments(input: String, settings: ConvertSettings) -> [String]
```

**Features:**
- Type-safe argument construction
- Proper path escaping
- Sensitive data redaction for diagnostics

#### BinaryLocator

**Resolves binary paths from multiple sources.**

```swift
enum BinarySource {
    case bundled
    case system
    case custom(String)
}

static func locate(_ name: String, source: BinarySource) -> String?
```

**Search Order:**
1. App bundle: `Resources/bin/`
2. Homebrew Apple Silicon: `/opt/homebrew/bin/`
3. Homebrew Intel: `/usr/local/bin/`
4. PATH environment variable
5. Custom user-specified paths

#### ProgressParser

**Extracts progress info from CLI output.**

```swift
static func parseDownloadProgress(_ line: String) -> DownloadProgress?
static func parseConversionProgress(_ line: String, totalDuration: TimeInterval?) -> ConversionProgress?
```

**Parsing Logic:**
- **Download:** Regex for `[download] XX.X%` patterns
- **Convert:** Regex for `time=HH:MM:SS.ss` from ffmpeg

### 5. Models (SwiftData)

#### Job

**Represents a download or convert job.**

```swift
@Model
class Job {
    var type: JobType // download, convert, pipeline
    var status: JobStatus // queued, running, success, failed, canceled
    var progress: Double // 0.0 to 1.0
    var logs: String
    var downloadSettings: DownloadSettings?
    var convertSettings: ConvertSettings?
    // ...
}
```

**Persistence:** SwiftData (SQLite)
**Location:** `~/Library/Application Support/PullAndConvertVids/`

#### AppSettings

**Persistent app configuration.**

```swift
@Model
class AppSettings {
    var binarySource: String // "bundled", "system", "custom"
    var customPullVidsPath: String?
    var customConvertVidPath: String?
    var defaultDownloadDirectory: String
    var rememberLastUsedValues: Bool
    // ...
}
```

#### CommandRecord

**Diagnostics history.**

```swift
@Model
class CommandRecord {
    var timestamp: Date
    var command: String // Redacted for security
    var exitCode: Int?
    var duration: TimeInterval?
    var jobID: UUID?
}
```

**Retention:** Last 20 commands

## Data Flow Examples

### Example 1: Download Job

```
User enters URL → DownloadViewModel validates input
                 → JobManager.enqueue(Job)
                 → SwiftData saves Job
                 → JobManager.processNext()
                 → PullVidsService.download()
                 → ProcessRunner.run()
                 → parse progress → update Job.progress
                 → completion → Job.status = .success
                 → SwiftData saves Job
```

### Example 2: Pipeline Job

```
User enables "Auto-convert" → DownloadViewModel saves settings
                            → Job created with pipeline type
                            → JobManager → PipelineCoordinator
                            → Phase 1: Download (0-50%)
                            → Phase 2: Convert (50-100%)
                            → Job.status = .success
```

## Concurrency Model

- **Main Actor:** All ViewModels and JobManager run on @MainActor
- **Background Tasks:** ProcessRunner callbacks use Task for async work
- **Thread Safety:** SwiftData handles synchronization
- **Cancellation:** Cooperative via ProcessHandle.cancel()

## Testing Strategy

### Unit Tests

- **ArgumentBuilder:** Test argument construction logic
- **PathHelpers:** Test path expansion and validation
- **FileHelpers:** Test URL parsing and file type detection
- **ProgressParser:** Test regex patterns (mocked output)

### Integration Tests

- **MockProcessRunner:** Simulates CLI output for testing ViewModels
- **Job State Transitions:** Test queued → running → success flow

### Manual Tests

- Download various URLs (YouTube, Vimeo, etc.)
- Convert different formats and qualities
- Test pipeline workflow
- Verify binary detection
- Test error scenarios (missing dependencies, invalid URLs)

## Security Considerations

### Sandboxing

**Current:** Disabled (not App Store distribution)
**Reason:** Requires access to arbitrary file paths for input/output

**If Enabling:**
- Use security-scoped bookmarks for user-selected folders
- Request appropriate entitlements

### Cookie Handling

- Cookie files are never copied
- Paths passed directly to CLI
- Sensitive args redacted in diagnostics
- Browser cookie extraction handled by CLI (not app)

### Process Execution

- No shell interpretation (uses Process.arguments)
- Paths always passed as separate arguments (no injection risk)
- Exit codes validated
- Stderr captured for error messages

## Performance Optimizations

1. **Streaming Output:** Parse logs incrementally (no buffering)
2. **Concurrent Jobs:** Run up to 10 jobs simultaneously
3. **Background Threads:** ProcessRunner uses async Tasks
4. **SwiftData Batching:** Batch saves to reduce I/O
5. **Progress Throttling:** Update UI at fixed intervals (0.1s)

## Future Enhancements

- [ ] Queue persistence across app restarts
- [ ] Scheduled downloads
- [ ] Browser extension integration
- [ ] Export/import settings
- [ ] Cloud sync (iCloud)
- [ ] Dark mode optimization
- [ ] Localization (i18n)
- [ ] Advanced filtering (regex, date ranges)
- [ ] Notification system (completion alerts)
- [ ] Preset management (save/load configurations)
