//
//  CommandRecord.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class CommandRecord {
    var id: UUID
    var timestamp: Date
    var command: String // Full command string (may be redacted)
    var exitCode: Int?
    var duration: TimeInterval?
    var jobID: UUID? // Associated job ID

    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        command: String,
        exitCode: Int? = nil,
        duration: TimeInterval? = nil,
        jobID: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.command = command
        self.exitCode = exitCode
        self.duration = duration
        self.jobID = jobID
    }

    var formattedTimestamp: String {
        DateFormatters.fullDate.string(from: timestamp)
    }

    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        return DateFormatters.formatDuration(seconds: duration)
    }

    var statusIcon: String {
        if let exitCode = exitCode {
            return exitCode == 0 ? "✓" : "✗"
        }
        return "•"
    }
}
