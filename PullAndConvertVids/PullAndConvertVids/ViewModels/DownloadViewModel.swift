//
//  DownloadViewModel.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@MainActor
final class DownloadViewModel: ObservableObject {
    @Published var urlText: String = ""
    @Published var settings: DownloadSettings = .default
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?

    // Cookie auth UI state
    @Published var cookieAuthEnabled: Bool = false
    @Published var cookieAuthMethod: CookieAuthMethod = .browser
    @Published var selectedBrowser: String = Constants.Browser.firefox.rawValue
    @Published var cookieFilePath: String = ""

    private let modelContext: ModelContext
    private let jobManager: JobManager

    enum CookieAuthMethod {
        case browser
        case file
    }

    init(modelContext: ModelContext, jobManager: JobManager) {
        self.modelContext = modelContext
        self.jobManager = jobManager
    }

    // MARK: - Actions

    func addToQueue() {
        let urls = FileHelpers.parseURLs(from: urlText)

        guard !urls.isEmpty else {
            errorMessage = "Please enter at least one valid URL"
            return
        }

        isProcessing = true
        errorMessage = nil

        // Update settings with cookie auth
        updateCookieAuth()

        // Create jobs for each URL
        for url in urls {
            let job = Job(
                type: .download,
                status: .queued,
                name: url,
                downloadSettings: settings
            )

            modelContext.insert(job)
        }

        do {
            try modelContext.save()

            // Clear input
            urlText = ""
            isProcessing = false

            // Trigger job processing
            jobManager.processNext()
        } catch {
            errorMessage = "Failed to save jobs: \(error.localizedDescription)"
            isProcessing = false
        }
    }

    func importURLsFromFile(url: URL) {
        do {
            let urls = try FileHelpers.readURLsFromFile(url.path)
            urlText = urls.joined(separator: "\n")
        } catch {
            errorMessage = "Failed to read file: \(error.localizedDescription)"
        }
    }

    func setQualityPreset(_ quality: Constants.DownloadQuality) {
        settings.quality = quality.rawValue
    }

    func toggleAudioOnly() {
        settings.isAudioOnly.toggle()
    }

    func togglePlaylist() {
        settings.isPlaylist.toggle()
    }

    func toggleAutoConvert() {
        settings.autoConvert.toggle()
        if settings.autoConvert && settings.autoConvertSettings == nil {
            settings.autoConvertSettings = .default
        }
    }

    func selectOutputDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Output Directory"

        if panel.runModal() == .OK {
            if let url = panel.url {
                settings.outputDirectory = url.path
            }
        }
    }

    func selectCookieFile() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.text]
        panel.prompt = "Select Cookie File"

        if panel.runModal() == .OK {
            if let url = panel.url {
                cookieFilePath = url.path
            }
        }
    }

    // MARK: - Private Methods

    private func updateCookieAuth() {
        if cookieAuthEnabled {
            switch cookieAuthMethod {
            case .browser:
                settings.cookieAuth = .fromBrowser(selectedBrowser)
            case .file:
                if !cookieFilePath.isEmpty {
                    settings.cookieAuth = .fromFile(cookieFilePath)
                } else {
                    settings.cookieAuth = nil
                }
            }
        } else {
            settings.cookieAuth = nil
        }
    }

    var isValidInput: Bool {
        !FileHelpers.parseURLs(from: urlText).isEmpty
    }

    var urlCount: Int {
        FileHelpers.parseURLs(from: urlText).count
    }
}

import AppKit
