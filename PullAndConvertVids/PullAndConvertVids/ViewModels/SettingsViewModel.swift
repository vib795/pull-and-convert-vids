//
//  SettingsViewModel.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var pullVidsInfo: BinaryInfo?
    @Published var convertVidInfo: BinaryInfo?
    @Published var dependencyInfo: [BinaryInfo] = []
    @Published var isVerifying: Bool = false
    @Published var verificationMessage: String?

    private let modelContext: ModelContext
    private let pullVidsService: PullVidsService
    private let convertVidService: ConvertVidService

    init(
        modelContext: ModelContext,
        pullVidsService: PullVidsService,
        convertVidService: ConvertVidService
    ) {
        self.modelContext = modelContext
        self.pullVidsService = pullVidsService
        self.convertVidService = convertVidService

        // Load or create settings
        let descriptor = FetchDescriptor<AppSettings>()
        if let existing = try? modelContext.fetch(descriptor).first {
            self.settings = existing
        } else {
            let newSettings = AppSettings.default
            modelContext.insert(newSettings)
            try? modelContext.save()
            self.settings = newSettings
        }
    }

    // MARK: - Binary Source

    func setBinarySource(_ source: String) {
        settings.binarySource = source
        saveSettings()
    }

    func selectCustomPullVidsBinary() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select pull-vids Binary"

        if panel.runModal() == .OK {
            if let url = panel.url {
                settings.customPullVidsPath = url.path
                saveSettings()
            }
        }
    }

    func selectCustomConvertVidBinary() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = false
        panel.prompt = "Select convert-vid Binary"

        if panel.runModal() == .OK {
            if let url = panel.url {
                settings.customConvertVidPath = url.path
                saveSettings()
            }
        }
    }

    // MARK: - Verification

    func verifyBinaries() {
        isVerifying = true
        verificationMessage = nil

        Task {
            // Verify pull-vids
            pullVidsInfo = await pullVidsService.verify()

            // Verify convert-vid
            convertVidInfo = await convertVidService.verify()

            // Check dependencies
            dependencyInfo = await DependencyChecker.checkAll()

            // Generate message
            var messages: [String] = []

            if let info = pullVidsInfo, info.isAvailable {
                messages.append("✓ pull-vids: \(info.displayStatus)")
            } else {
                messages.append("✗ pull-vids: Not found")
            }

            if let info = convertVidInfo, info.isAvailable {
                messages.append("✓ convert-vid: \(info.displayStatus)")
            } else {
                messages.append("✗ convert-vid: Not found")
            }

            for dep in dependencyInfo {
                if dep.isAvailable {
                    messages.append("✓ \(dep.name): \(dep.displayStatus)")
                } else {
                    messages.append("✗ \(dep.name): Not found")
                }
            }

            verificationMessage = messages.joined(separator: "\n")
            isVerifying = false
        }
    }

    // MARK: - Default Paths

    func selectDefaultDownloadDirectory() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Default Download Directory"

        if panel.runModal() == .OK {
            if let url = panel.url {
                settings.defaultDownloadDirectory = url.path
                saveSettings()
            }
        }
    }

    // MARK: - Save

    func saveSettings() {
        try? modelContext.save()
    }

    // MARK: - Computed Properties

    var binarySourceDescription: String {
        switch settings.binarySource {
        case "bundled":
            return "Use binaries bundled inside the app"
        case "system":
            return "Use binaries installed via Homebrew or in PATH"
        case "custom":
            return "Use custom binary paths specified below"
        default:
            return settings.binarySource
        }
    }

    var allBinariesAvailable: Bool {
        (pullVidsInfo?.isAvailable ?? false) && (convertVidInfo?.isAvailable ?? false)
    }

    var allDependenciesAvailable: Bool {
        dependencyInfo.allSatisfy { $0.isAvailable }
    }
}

import AppKit
