//
//  ArgumentBuilder.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Builds command-line arguments for pull-vids and convert-vid CLIs
enum ArgumentBuilder {

    // MARK: - pull-vids Arguments

    /// Builds arguments for pull-vids command
    /// - Parameters:
    ///   - url: The video URL to download
    ///   - settings: Download configuration settings
    /// - Returns: Array of command-line arguments
    static func buildPullVidsArguments(url: String, settings: DownloadSettings) -> [String] {
        var args: [String] = []

        // Quality
        args.append("-q")
        args.append(settings.quality)

        // Output directory
        args.append("-o")
        args.append(PathHelpers.expandPath(settings.outputDirectory))

        // Audio-only mode
        if settings.isAudioOnly {
            args.append("-a")

            // Audio format (only if audio-only)
            if let audioFormat = settings.audioFormat, audioFormat != "mp3" {
                args.append("-f")
                args.append(audioFormat)
            }
        } else {
            // Video format (only if not audio-only)
            if let videoFormat = settings.videoFormat, videoFormat != "mp4" {
                args.append("-f")
                args.append(videoFormat)
            }
        }

        // Playlist mode
        if settings.isPlaylist {
            args.append("-p")
        }

        // Cookie authentication
        if let cookieAuth = settings.cookieAuth {
            switch cookieAuth {
            case .fromBrowser(let browser):
                args.append("--cookies-from-browser")
                args.append(browser)
            case .fromFile(let path):
                args.append("--cookies")
                args.append(PathHelpers.expandPath(path))
            }
        }

        // No banner for cleaner output
        args.append("--no-banner")

        // Finally, add the URL
        args.append(url)

        return args
    }

    // MARK: - convert-vid Arguments

    /// Builds arguments for convert-vid command
    /// - Parameters:
    ///   - input: Input file or directory path
    ///   - settings: Conversion configuration settings
    /// - Returns: Array of command-line arguments
    static func buildConvertVidArguments(input: String, settings: ConvertSettings) -> [String] {
        var args: [String] = ["convert"]

        // Input (required)
        args.append("--input")
        args.append(PathHelpers.expandPath(input))

        // Format
        args.append("-f")
        args.append(settings.format)

        // Quality preset
        args.append("-q")
        args.append(settings.quality)

        // Output path (if specified)
        if let output = settings.outputPath {
            let expandedOutput = PathHelpers.expandPath(output)

            // If output is a directory, construct full output file path
            if PathHelpers.isDirectory(at: expandedOutput) {
                // Get input filename without extension
                let inputURL = URL(fileURLWithPath: PathHelpers.expandPath(input))
                let inputName = inputURL.deletingPathExtension().lastPathComponent

                // Construct output file path with new extension
                let outputFileName = "\(inputName).\(settings.format)"
                let outputFilePath = URL(fileURLWithPath: expandedOutput).appendingPathComponent(outputFileName).path

                args.append("-o")
                args.append(outputFilePath)
            } else {
                // Output is a file path, use as-is
                args.append("-o")
                args.append(expandedOutput)
            }
        }

        // Overwrite flag
        if settings.overwrite {
            args.append("--overwrite")
        }

        // Concurrency (only for batch/directory processing)
        if PathHelpers.isDirectory(at: input) {
            args.append("-c")
            args.append(String(settings.concurrency))
        }

        return args
    }

    // MARK: - Version Check Arguments

    /// Builds arguments to check pull-vids version
    static var pullVidsVersionArgs: [String] {
        ["--version"]
    }

    /// Builds arguments to check convert-vid version
    static var convertVidVersionArgs: [String] {
        ["version"]
    }

    // MARK: - Dependency Check Arguments

    /// Builds arguments to check ffmpeg version
    static var ffmpegVersionArgs: [String] {
        ["-version"]
    }

    /// Builds arguments to check yt-dlp version
    static var ytdlpVersionArgs: [String] {
        ["--version"]
    }

    // MARK: - Command String Generation (for display/diagnostics)

    /// Generates a human-readable command string for display
    /// - Parameters:
    ///   - binary: Binary name
    ///   - args: Command-line arguments
    ///   - redactSensitive: Whether to redact sensitive arguments like cookie paths
    /// - Returns: Formatted command string
    static func formatCommand(binary: String, args: [String], redactSensitive: Bool = true) -> String {
        var formattedArgs = args

        if redactSensitive {
            formattedArgs = redactSensitiveArguments(args)
        }

        // Quote arguments that contain spaces
        let quotedArgs = formattedArgs.map { arg -> String in
            if arg.contains(" ") {
                return "\"\(arg)\""
            }
            return arg
        }

        return "\(binary) \(quotedArgs.joined(separator: " "))"
    }

    /// Redacts sensitive arguments (cookie file paths, URLs with tokens)
    private static func redactSensitiveArguments(_ args: [String]) -> [String] {
        var result: [String] = []
        var i = 0

        while i < args.count {
            let arg = args[i]

            // Check if next argument should be redacted
            if arg == "--cookies" || arg == "--cookies-from-browser" {
                result.append(arg)
                if i + 1 < args.count {
                    if arg == "--cookies" {
                        result.append("[REDACTED_COOKIE_FILE]")
                    } else {
                        result.append(args[i + 1]) // Browser name is safe
                    }
                    i += 2
                    continue
                }
            }

            // Redact URLs with tokens/auth
            if arg.contains("token=") || arg.contains("auth=") || arg.contains("key=") {
                result.append("[REDACTED_URL]")
            } else {
                result.append(arg)
            }

            i += 1
        }

        return result
    }
}
