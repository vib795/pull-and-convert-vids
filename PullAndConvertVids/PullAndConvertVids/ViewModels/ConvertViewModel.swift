//
//  ConvertViewModel.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData
import UniformTypeIdentifiers

@MainActor
final class ConvertViewModel: ObservableObject {
    @Published var selectedFiles: [URL] = []
    @Published var settings: ConvertSettings = .default
    @Published var isProcessing: Bool = false
    @Published var errorMessage: String?
    @Published var outputLocationChoice: OutputLocation = .sameFolder

    private let modelContext: ModelContext
    private let jobManager: JobManager

    enum OutputLocation {
        case sameFolder
        case chooseFolder(String)

        var displayName: String {
            switch self {
            case .sameFolder:
                return "Same folder as input"
            case .chooseFolder(let path):
                return path
            }
        }
    }

    init(modelContext: ModelContext, jobManager: JobManager) {
        self.modelContext = modelContext
        self.jobManager = jobManager
    }

    // MARK: - Actions

    func addFiles() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = [
            UTType(filenameExtension: "mp4") ?? .movie,
            UTType(filenameExtension: "avi") ?? .movie,
            UTType(filenameExtension: "mov") ?? .movie,
            UTType(filenameExtension: "mkv") ?? .movie,
            UTType(filenameExtension: "webm") ?? .movie,
            UTType(filenameExtension: "flv") ?? .movie,
            UTType(filenameExtension: "m4v") ?? .movie
        ]
        panel.prompt = "Select Video Files"

        if panel.runModal() == .OK {
            selectedFiles.append(contentsOf: panel.urls)
        }
    }

    func addFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Folder"

        if panel.runModal() == .OK {
            if let url = panel.url {
                // Get all video files in the folder
                do {
                    let files = try PathHelpers.getVideoFiles(
                        in: url.path,
                        extensions: FileHelpers.videoExtensions
                    )
                    selectedFiles.append(contentsOf: files.map { URL(fileURLWithPath: $0) })
                } catch {
                    errorMessage = "Failed to read folder: \(error.localizedDescription)"
                }
            }
        }
    }

    func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                Task { @MainActor in
                    guard let url = url else { return }

                    if PathHelpers.isDirectory(at: url.path) {
                        // Add all video files from directory
                        do {
                            let files = try PathHelpers.getVideoFiles(
                                in: url.path,
                                extensions: FileHelpers.videoExtensions
                            )
                            self.selectedFiles.append(contentsOf: files.map { URL(fileURLWithPath: $0) })
                        } catch {
                            self.errorMessage = "Failed to read folder: \(error.localizedDescription)"
                        }
                    } else if FileHelpers.isVideoFile(url.path) {
                        self.selectedFiles.append(url)
                    }
                }
            }
        }
    }

    func removeFile(_ url: URL) {
        selectedFiles.removeAll { $0 == url }
    }

    func clearFiles() {
        selectedFiles.removeAll()
    }

    func startConversion() {
        guard !selectedFiles.isEmpty else {
            errorMessage = Constants.ErrorMessage.noInputFiles
            return
        }

        isProcessing = true
        errorMessage = nil

        // Update output path in settings
        switch outputLocationChoice {
        case .sameFolder:
            settings.outputPath = nil
        case .chooseFolder(let path):
            settings.outputPath = path
        }

        // Create jobs for each file
        for fileURL in selectedFiles {
            let job = Job(
                type: .convert,
                status: .queued,
                name: fileURL.lastPathComponent,
                inputPath: fileURL.path,
                convertSettings: settings
            )

            modelContext.insert(job)
        }

        do {
            try modelContext.save()

            // Clear selection
            selectedFiles.removeAll()
            isProcessing = false

            // Trigger job processing
            jobManager.processNext()
        } catch {
            errorMessage = "Failed to save jobs: \(error.localizedDescription)"
            isProcessing = false
        }
    }

    func selectOutputFolder() {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.prompt = "Select Output Folder"

        if panel.runModal() == .OK {
            if let url = panel.url {
                outputLocationChoice = .chooseFolder(url.path)
            }
        }
    }

    func setQualityPreset(_ quality: Constants.ConvertQuality) {
        settings.quality = quality.rawValue
    }

    func setConcurrency(_ value: Int) {
        settings.concurrency = max(1, min(value, 16))
    }

    var isValidInput: Bool {
        !selectedFiles.isEmpty
    }

    var fileCount: Int {
        selectedFiles.count
    }
}

import AppKit
