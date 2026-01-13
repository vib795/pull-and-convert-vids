//
//  DateFormatters.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

enum DateFormatters {
    /// Shared date formatter for timestamps
    static let timestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    /// Shared date formatter for full dates
    static let fullDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        return formatter
    }()

    /// Shared date formatter for relative dates (e.g., "2 hours ago")
    static let relative: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter
    }()

    /// Formats duration in seconds to human-readable string (e.g., "1h 23m 45s")
    static func formatDuration(seconds: TimeInterval) -> String {
        let hours = Int(seconds) / 3600
        let minutes = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60

        if hours > 0 {
            return String(format: "%dh %dm %ds", hours, minutes, secs)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, secs)
        } else {
            return String(format: "%ds", secs)
        }
    }

    /// Formats time remaining (ETA) from seconds
    static func formatETA(seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "< 1 min"
        }

        let minutes = Int(seconds) / 60
        let hours = minutes / 60

        if hours > 0 {
            let remainingMinutes = minutes % 60
            return String(format: "%dh %dm", hours, remainingMinutes)
        } else {
            return String(format: "%d min", minutes)
        }
    }
}
