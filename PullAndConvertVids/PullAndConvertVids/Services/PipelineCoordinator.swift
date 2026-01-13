//
//  PipelineCoordinator.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

/// Coordinates download→convert pipeline jobs
@MainActor
final class PipelineCoordinator {
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
    }

    /// Executes a complete pipeline: download then convert
    func executePipeline(
        job: Job,
        downloadSettings: DownloadSettings,
        convertSettings: ConvertSettings
    ) async {
        // Phase 1: Download
        job.appendLog("=== Pipeline Phase 1: Download ===\n")
        job.status = .running
        try? modelContext.save()

        let downloadResult = await executeDownloadPhase(
            job: job,
            url: job.name,
            settings: downloadSettings
        )

        guard case .success(let downloadedPath) = downloadResult else {
            if case .failure(let error) = downloadResult {
                job.status = .failed
                job.errorMessage = "Download phase failed: \(error.localizedDescription)"
                job.completedAt = Date()
                try? modelContext.save()
            }
            return
        }

        // Phase 2: Convert
        job.appendLog("\n=== Pipeline Phase 2: Convert ===\n")
        job.progress = 0.5 // Mark download as complete

        let convertResult = await executeConvertPhase(
            job: job,
            inputPath: downloadedPath,
            settings: convertSettings
        )

        switch convertResult {
        case .success(let outputPath):
            job.status = .success
            job.outputPath = outputPath
            job.progress = 1.0
            job.completedAt = Date()
        case .failure(let error):
            job.status = .failed
            job.errorMessage = "Convert phase failed: \(error.localizedDescription)"
            job.completedAt = Date()
        }

        try? modelContext.save()
    }

    // MARK: - Phase Execution

    private func executeDownloadPhase(
        job: Job,
        url: String,
        settings: DownloadSettings
    ) async -> Result<String, Error> {
        await withCheckedContinuation { continuation in
            _ = pullVidsService.download(
                url: url,
                settings: settings,
                progressCallback: { progress in
                    Task { @MainActor in
                        // Scale progress: 0-50% for download phase
                        job.progress = progress.percentage / 200.0
                        job.progressText = "Downloading: \(progress.progressText)"
                        job.speed = progress.speed
                        job.eta = progress.eta
                        try? self.modelContext.save()
                    }
                },
                logCallback: { line in
                    Task { @MainActor in
                        job.appendLog(line)
                        try? self.modelContext.save()
                    }
                },
                completion: { result in
                    continuation.resume(returning: result)
                }
            )
        }
    }

    private func executeConvertPhase(
        job: Job,
        inputPath: String,
        settings: ConvertSettings
    ) async -> Result<String, Error> {
        await withCheckedContinuation { continuation in
            _ = convertVidService.convert(
                input: inputPath,
                settings: settings,
                progressCallback: { progress in
                    Task { @MainActor in
                        // Scale progress: 50-100% for convert phase
                        job.progress = 0.5 + (progress.percentage / 200.0)
                        job.progressText = "Converting: \(progress.progressText)"
                        job.eta = progress.eta.map { DateFormatters.formatETA(seconds: $0) }
                        try? self.modelContext.save()
                    }
                },
                logCallback: { line in
                    Task { @MainActor in
                        job.appendLog(line)
                        try? self.modelContext.save()
                    }
                },
                completion: { result in
                    continuation.resume(returning: result)
                }
            )
        }
    }
}
