//
//  AppSettings.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID

    // Binary management
    var binarySource: String // "bundled", "system", "custom"
    var customPullVidsPath: String?
    var customConvertVidPath: String?

    // Default paths
    var defaultDownloadDirectory: String
    var defaultConvertOutputRule: String // "same-folder" or path

    // UI preferences
    var rememberLastUsedValues: Bool
    var defaultConcurrency: Int

    // Last used values (if rememberLastUsedValues is true)
    var lastDownloadQuality: String?
    var lastDownloadFormat: String?
    var lastConvertFormat: String?
    var lastConvertQuality: String?

    init(
        id: UUID = UUID(),
        binarySource: String = "bundled",
        customPullVidsPath: String? = nil,
        customConvertVidPath: String? = nil,
        defaultDownloadDirectory: String = Constants.defaultDownloadPath,
        defaultConvertOutputRule: String = "same-folder",
        rememberLastUsedValues: Bool = true,
        defaultConcurrency: Int = ProcessInfo.processInfo.activeProcessorCount
    ) {
        self.id = id
        self.binarySource = binarySource
        self.customPullVidsPath = customPullVidsPath
        self.customConvertVidPath = customConvertVidPath
        self.defaultDownloadDirectory = defaultDownloadDirectory
        self.defaultConvertOutputRule = defaultConvertOutputRule
        self.rememberLastUsedValues = rememberLastUsedValues
        self.defaultConcurrency = defaultConcurrency
    }

    static var `default`: AppSettings {
        AppSettings()
    }
}
