//
//  ConvertSettings.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

struct ConvertSettings: Codable, Equatable {
    var format: String // mp4, avi, mov, mkv, webm, flv
    var quality: String // high, medium, low
    var outputPath: String? // nil = same folder, or specific path
    var overwrite: Bool
    var concurrency: Int
    var keepOriginal: Bool // Always true (input files never deleted)

    init(
        format: String = "mp4",
        quality: String = "medium",
        outputPath: String? = nil,
        overwrite: Bool = false,
        concurrency: Int = ProcessInfo.processInfo.activeProcessorCount,
        keepOriginal: Bool = true
    ) {
        self.format = format
        self.quality = quality
        self.outputPath = outputPath
        self.overwrite = overwrite
        self.concurrency = max(1, min(concurrency, 16)) // Clamp between 1-16
        self.keepOriginal = keepOriginal
    }

    static var `default`: ConvertSettings {
        ConvertSettings()
    }

    var outputLocationDescription: String {
        if outputPath == nil {
            return "Same folder as input"
        } else {
            return outputPath!
        }
    }
}
