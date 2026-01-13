//
//  Job.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class Job {
    var id: UUID
    var typeRaw: String // JobType stored as String
    var statusRaw: String // JobStatus stored as String

    var name: String // Display name (URL or filename)
    var inputPath: String? // For convert jobs: input file path
    var outputPath: String? // Resulting file path(s)
    var progress: Double // 0.0 to 1.0
    var progressText: String? // Human-readable progress (e.g., "45.2% of 123MB")
    var speed: String? // Download/convert speed
    var eta: String? // Estimated time remaining

    var logs: String // Captured stdout/stderr
    var errorMessage: String? // Error description if failed

    var createdAt: Date
    var startedAt: Date?
    var completedAt: Date?

    // Settings snapshot (encoded as JSON)
    var downloadSettingsJSON: Data?
    var convertSettingsJSON: Data?

    // Pipeline-specific
    var isPipelineChild: Bool // If this is the convert step of a pipeline
    var pipelineParentID: UUID? // Parent download job ID

    // Computed properties
    var type: JobType {
        get { JobType(rawValue: typeRaw) ?? .download }
        set { typeRaw = newValue.rawValue }
    }

    var status: JobStatus {
        get { JobStatus(rawValue: statusRaw) ?? .queued }
        set { statusRaw = newValue.rawValue }
    }

    var downloadSettings: DownloadSettings? {
        get {
            guard let data = downloadSettingsJSON else { return nil }
            return try? JSONDecoder().decode(DownloadSettings.self, from: data)
        }
        set {
            downloadSettingsJSON = try? JSONEncoder().encode(newValue)
        }
    }

    var convertSettings: ConvertSettings? {
        get {
            guard let data = convertSettingsJSON else { return nil }
            return try? JSONDecoder().decode(ConvertSettings.self, from: data)
        }
        set {
            convertSettingsJSON = try? JSONEncoder().encode(newValue)
        }
    }

    var duration: TimeInterval? {
        guard let start = startedAt, let end = completedAt else { return nil }
        return end.timeIntervalSince(start)
    }

    init(
        id: UUID = UUID(),
        type: JobType,
        status: JobStatus = .queued,
        name: String,
        inputPath: String? = nil,
        outputPath: String? = nil,
        downloadSettings: DownloadSettings? = nil,
        convertSettings: ConvertSettings? = nil,
        isPipelineChild: Bool = false,
        pipelineParentID: UUID? = nil
    ) {
        self.id = id
        self.typeRaw = type.rawValue
        self.statusRaw = status.rawValue
        self.name = name
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.progress = 0.0
        self.progressText = nil
        self.speed = nil
        self.eta = nil
        self.logs = ""
        self.errorMessage = nil
        self.createdAt = Date()
        self.startedAt = nil
        self.completedAt = nil
        self.downloadSettingsJSON = try? JSONEncoder().encode(downloadSettings)
        self.convertSettingsJSON = try? JSONEncoder().encode(convertSettings)
        self.isPipelineChild = isPipelineChild
        self.pipelineParentID = pipelineParentID
    }

    func appendLog(_ text: String) {
        logs += text
        // Trim logs if they get too large
        if logs.count > 100_000 {
            let startIndex = logs.index(logs.endIndex, offsetBy: -80_000)
            logs = String(logs[startIndex...])
        }
    }
}

// MARK: - Job Extensions
extension Job {
    var displayName: String {
        return name
    }

    var statusIcon: String {
        return status.icon
    }

    var statusColor: Color {
        return status.color
    }

    var formattedCreatedAt: String {
        DateFormatters.timestamp.string(from: createdAt)
    }

    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        return DateFormatters.formatDuration(seconds: duration)
    }

    func canRetry() -> Bool {
        return status == .failed || status == .canceled
    }

    func canCancel() -> Bool {
        return status == .queued || status == .running
    }
}

import SwiftUI
