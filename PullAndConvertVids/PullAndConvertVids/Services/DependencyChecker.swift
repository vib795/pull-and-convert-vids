//
//  DependencyChecker.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Checks for required dependencies (ffmpeg, yt-dlp)
final class DependencyChecker {

    /// Checks all dependencies and returns their status
    static func checkAll() async -> [BinaryInfo] {
        async let ffmpeg = checkFFmpeg()
        async let ytdlp = checkYtDlp()

        return await [ffmpeg, ytdlp]
    }

    /// Checks ffmpeg availability
    static func checkFFmpeg() async -> BinaryInfo {
        return await checkBinary(
            name: "ffmpeg",
            versionArgs: ArgumentBuilder.ffmpegVersionArgs
        )
    }

    /// Checks yt-dlp availability
    static func checkYtDlp() async -> BinaryInfo {
        return await checkBinary(
            name: "yt-dlp",
            versionArgs: ArgumentBuilder.ytdlpVersionArgs
        )
    }

    /// Generic binary checker
    private static func checkBinary(name: String, versionArgs: [String]) async -> BinaryInfo {
        guard let path = BinaryLocator.locateAny(name) else {
            return .notFound(name: name, error: "\(name) not found in PATH or Homebrew paths")
        }

        guard BinaryLocator.isExecutable(path) else {
            return .notFound(name: name, error: "\(name) found but not executable")
        }

        let version = await BinaryLocator.getVersion(
            binary: path,
            versionArgs: versionArgs
        )

        return .found(name: name, path: path, version: version)
    }

    /// Generates installation instructions for missing dependencies
    static func installInstructions(for binaryName: String) -> String {
        switch binaryName.lowercased() {
        case "ffmpeg":
            return """
            Install ffmpeg using Homebrew:

            brew install ffmpeg

            Or download from: https://ffmpeg.org/download.html
            """
        case "yt-dlp":
            return """
            Install yt-dlp using Homebrew:

            brew install yt-dlp

            Or using pip:

            python3 -m pip install -U yt-dlp

            Or download from: https://github.com/yt-dlp/yt-dlp/releases
            """
        default:
            return "Installation instructions not available."
        }
    }

    /// Checks if all required dependencies for download are available
    static func canDownload() async -> (canRun: Bool, missingDeps: [String]) {
        let deps = await checkAll()
        let missing = deps.filter { !$0.isAvailable }.map { $0.name }
        return (missing.isEmpty, missing)
    }

    /// Checks if all required dependencies for conversion are available
    static func canConvert() async -> (canRun: Bool, missingDeps: [String]) {
        let ffmpeg = await checkFFmpeg()
        if ffmpeg.isAvailable {
            return (true, [])
        } else {
            return (false, ["ffmpeg"])
        }
    }
}
