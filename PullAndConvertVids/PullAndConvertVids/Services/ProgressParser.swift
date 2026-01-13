//
//  ProgressParser.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Parses progress information from CLI output
enum ProgressParser {

    // MARK: - pull-vids Progress Parsing

    /// Parses download progress from pull-vids/yt-dlp output
    /// Example: "[download]  45.2% of 123.45MiB at 1.23MiB/s ETA 00:45"
    static func parseDownloadProgress(_ line: String) -> DownloadProgress? {
        // Check if line contains [download]
        guard line.contains("[download]") else { return nil }

        var progress = DownloadProgress()

        // Extract percentage
        if let percentMatch = line.range(of: #"\d+\.?\d*%"#, options: .regularExpression) {
            let percentString = String(line[percentMatch]).replacingOccurrences(of: "%", with: "")
            progress.percentage = Double(percentString) ?? 0
        }

        // Extract speed (e.g., "1.23MiB/s" or "123.45KiB/s")
        if let speedMatch = line.range(of: #"\d+\.?\d*(MiB|KiB|GiB)/s"#, options: .regularExpression) {
            progress.speed = String(line[speedMatch])
        }

        // Extract ETA (e.g., "00:45" or "01:23:45")
        if let etaMatch = line.range(of: #"ETA\s+(\d{2}:\d{2}(:\d{2})?)"#, options: .regularExpression) {
            let etaString = String(line[etaMatch]).replacingOccurrences(of: "ETA", with: "").trimmingCharacters(in: .whitespaces)
            progress.eta = etaString
        }

        // Extract file size (e.g., "of 123.45MiB")
        if let sizeMatch = line.range(of: #"of\s+\d+\.?\d*(MiB|KiB|GiB)"#, options: .regularExpression) {
            let sizeString = String(line[sizeMatch]).replacingOccurrences(of: "of", with: "").trimmingCharacters(in: .whitespaces)
            progress.totalSize = sizeString
        }

        return progress
    }

    // MARK: - convert-vid Progress Parsing

    /// Parses conversion progress from convert-vid/ffmpeg output
    /// Example: "time=00:01:23.45"
    static func parseConversionProgress(_ line: String, totalDuration: TimeInterval?) -> ConversionProgress? {
        // Extract time= progress
        guard let timeMatch = line.range(of: #"time=(\d{2}):(\d{2}):(\d{2}\.\d{2})"#, options: .regularExpression) else {
            return nil
        }

        let timeString = String(line[timeMatch]).replacingOccurrences(of: "time=", with: "")

        guard let elapsedSeconds = parseTimeString(timeString) else {
            return nil
        }

        var progress = ConversionProgress()
        progress.elapsedTime = elapsedSeconds

        // Calculate percentage if total duration is known
        if let total = totalDuration, total > 0 {
            progress.percentage = min(100.0, (elapsedSeconds / total) * 100.0)

            // Estimate remaining time
            if progress.percentage > 0 {
                let remainingPercentage = 100.0 - progress.percentage
                let timePerPercent = elapsedSeconds / progress.percentage
                progress.eta = timePerPercent * remainingPercentage
            }
        }

        return progress
    }

    /// Parses time string in format HH:MM:SS.ss to seconds
    private static func parseTimeString(_ timeString: String) -> TimeInterval? {
        let components = timeString.split(separator: ":")
        guard components.count == 3 else { return nil }

        guard let hours = Double(components[0]),
              let minutes = Double(components[1]),
              let seconds = Double(components[2]) else {
            return nil
        }

        return hours * 3600 + minutes * 60 + seconds
    }

    // MARK: - Error Detection

    /// Checks if line contains an error message
    static func isError(_ line: String) -> Bool {
        let errorKeywords = [
            "error:",
            "ERROR:",
            "failed",
            "FAILED",
            "not found",
            "unable to",
            "cannot",
            "permission denied"
        ]

        let lowerLine = line.lowercased()
        return errorKeywords.contains { lowerLine.contains($0.lowercased()) }
    }

    /// Extracts error message from line
    static func extractErrorMessage(_ line: String) -> String {
        // Remove common prefixes
        var cleaned = line
            .replacingOccurrences(of: "ERROR:", with: "")
            .replacingOccurrences(of: "error:", with: "")
            .trimmingCharacters(in: .whitespaces)

        return cleaned
    }
}

// MARK: - Progress Structs

struct DownloadProgress {
    var percentage: Double = 0
    var speed: String?
    var eta: String?
    var totalSize: String?

    var progressText: String {
        var parts: [String] = [String(format: "%.1f%%", percentage)]
        if let size = totalSize {
            parts.append("of \(size)")
        }
        if let speed = speed {
            parts.append("at \(speed)")
        }
        if let eta = eta {
            parts.append("ETA \(eta)")
        }
        return parts.joined(separator: " ")
    }
}

struct ConversionProgress {
    var percentage: Double = 0
    var elapsedTime: TimeInterval = 0
    var eta: TimeInterval?

    var progressText: String {
        var parts: [String] = []

        if percentage > 0 {
            parts.append(String(format: "%.1f%%", percentage))
        }

        parts.append("elapsed: \(DateFormatters.formatDuration(seconds: elapsedTime))")

        if let eta = eta {
            parts.append("ETA: \(DateFormatters.formatETA(seconds: eta))")
        }

        return parts.joined(separator: " • ")
    }
}
