//
//  DownloadSettings.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

struct DownloadSettings: Codable, Equatable {
    var quality: String // best, 1080p, 720p, etc.
    var outputDirectory: String
    var isAudioOnly: Bool
    var audioFormat: String? // mp3, m4a, opus, wav
    var videoFormat: String? // mp4, mkv, webm
    var isPlaylist: Bool
    var cookieAuth: CookieAuth?

    // Pipeline settings
    var autoConvert: Bool
    var autoConvertSettings: ConvertSettings?

    init(
        quality: String = "best",
        outputDirectory: String = Constants.defaultDownloadPath,
        isAudioOnly: Bool = false,
        audioFormat: String? = "mp3",
        videoFormat: String? = "mp4",
        isPlaylist: Bool = false,
        cookieAuth: CookieAuth? = nil,
        autoConvert: Bool = false,
        autoConvertSettings: ConvertSettings? = nil
    ) {
        self.quality = quality
        self.outputDirectory = outputDirectory
        self.isAudioOnly = isAudioOnly
        self.audioFormat = audioFormat
        self.videoFormat = videoFormat
        self.isPlaylist = isPlaylist
        self.cookieAuth = cookieAuth
        self.autoConvert = autoConvert
        self.autoConvertSettings = autoConvertSettings
    }

    static var `default`: DownloadSettings {
        DownloadSettings()
    }
}

enum CookieAuth: Codable, Equatable {
    case fromBrowser(String) // Browser name
    case fromFile(String) // Cookie file path

    var displayName: String {
        switch self {
        case .fromBrowser(let browser):
            return "Browser: \(browser)"
        case .fromFile(let path):
            return "File: \(FileHelpers.getFilenameWithExtension(path))"
        }
    }
}
