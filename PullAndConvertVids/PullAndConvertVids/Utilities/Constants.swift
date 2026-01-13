//
//  Constants.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

enum Constants {
    // MARK: - App Info
    static let appName = "Pull and Convert Vids"
    static let bundleIdentifier = "com.vib795.PullAndConvertVids"
    static let version = "1.0.0"

    // MARK: - Binary Names
    static let pullVidsBinaryName = "pull-vids"
    static let convertVidBinaryName = "convert-vid"

    // MARK: - Default Paths
    static let defaultDownloadPath = "~/Downloads/pull-vids"
    static let defaultConvertPath = "same-folder" // Special value

    // MARK: - Homebrew Paths
    static let homebrewAppleSiliconPath = "/opt/homebrew/bin"
    static let homebrewIntelPath = "/usr/local/bin"

    // MARK: - Dependencies
    static let ffmpegBinaryName = "ffmpeg"
    static let ytdlpBinaryName = "yt-dlp"

    // MARK: - Quality Presets (pull-vids)
    enum DownloadQuality: String, CaseIterable, Identifiable {
        case best = "best"
        case uhd4k = "2160p"
        case qhd2k = "1440p"
        case fullHD = "1080p"
        case hd = "720p"
        case sd = "480p"
        case low = "360p"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .best: return "Best"
            case .uhd4k: return "4K (2160p)"
            case .qhd2k: return "2K (1440p)"
            case .fullHD: return "Full HD (1080p)"
            case .hd: return "HD (720p)"
            case .sd: return "SD (480p)"
            case .low: return "Low (360p)"
            }
        }
    }

    // MARK: - Video Formats (pull-vids)
    enum VideoFormat: String, CaseIterable, Identifiable {
        case mp4 = "mp4"
        case mkv = "mkv"
        case webm = "webm"

        var id: String { rawValue }
    }

    // MARK: - Audio Formats (pull-vids)
    enum AudioFormat: String, CaseIterable, Identifiable {
        case mp3 = "mp3"
        case m4a = "m4a"
        case opus = "opus"
        case wav = "wav"

        var id: String { rawValue }
    }

    // MARK: - Convert Quality Presets
    enum ConvertQuality: String, CaseIterable, Identifiable {
        case high = "high"
        case medium = "medium"
        case low = "low"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .high: return "High (CRF 18)"
            case .medium: return "Medium (CRF 23)"
            case .low: return "Low (CRF 28)"
            }
        }

        var description: String {
            switch self {
            case .high: return "Best quality, largest file size, slowest encoding"
            case .medium: return "Balanced quality/size/speed (recommended)"
            case .low: return "Fastest encoding, smallest files"
            }
        }
    }

    // MARK: - Convert Formats
    enum ConvertFormat: String, CaseIterable, Identifiable {
        case mp4 = "mp4"
        case avi = "avi"
        case mov = "mov"
        case mkv = "mkv"
        case webm = "webm"
        case flv = "flv"

        var id: String { rawValue }
    }

    // MARK: - Supported Browsers for Cookie Extraction
    enum Browser: String, CaseIterable, Identifiable {
        case firefox = "firefox"
        case chrome = "chrome"
        case safari = "safari"
        case edge = "edge"
        case chromium = "chromium"
        case brave = "brave"
        case opera = "opera"
        case vivaldi = "vivaldi"

        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .firefox: return "Firefox"
            case .chrome: return "Chrome"
            case .safari: return "Safari"
            case .edge: return "Edge"
            case .chromium: return "Chromium"
            case .brave: return "Brave"
            case .opera: return "Opera"
            case .vivaldi: return "Vivaldi"
            }
        }

        var requiresFullDiskAccess: Bool {
            self == .safari
        }
    }

    // MARK: - Error Messages
    enum ErrorMessage {
        static let ffmpegNotFound = "ffmpeg not found. Please install: brew install ffmpeg"
        static let ytdlpNotFound = "yt-dlp not found. Please install: brew install yt-dlp"
        static let pullVidsNotFound = "pull-vids binary not found"
        static let convertVidNotFound = "convert-vid binary not found"
        static let invalidURL = "Invalid URL. Must start with http:// or https://"
        static let outputExists = "Output file already exists. Enable 'Overwrite' to replace it."
        static let noInputFiles = "No input files selected"
        static let botDetection = "YouTube bot detection. Try using cookie authentication."
    }

    // MARK: - UI Constants
    static let maxConcurrentJobs = 10
    static let logViewerMaxLines = 1000
    static let commandHistoryMaxCount = 20
    static let progressUpdateInterval: TimeInterval = 0.1

    // MARK: - Keyboard Shortcuts
    static let downloadShortcut = "⌘D"
    static let convertShortcut = "⌘K"
    static let queueShortcut = "⌘Q"
    static let historyShortcut = "⌘H"
    static let settingsShortcut = "⌘,"
}
