//
//  JobManager.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

/// Manages job execution and queue
@MainActor
final class JobManager: ObservableObject {
    @Published var runningJobs: [UUID: ProcessHandle] = [:]
    @Published var activeJobCount: Int = 0

    private let modelContext: ModelContext
    private let pullVidsService: PullVidsService
    private let convertVidService: ConvertVidService
    private let pipelineCoordinator: PipelineCoordinator

    private let maxConcurrentJobs: Int

    init(
        modelContext: ModelContext,
        pullVidsService: PullVidsService,
        convertVidService: ConvertVidService,
        maxConcurrentJobs: Int = Constants.maxConcurrentJobs
    ) {
        self.modelContext = modelContext
        self.pullVidsService = pullVidsService
        self.convertVidService = convertVidService
        self.maxConcurrentJobs = maxConcurrentJobs
        self.pipelineCoordinator = PipelineCoordinator(
            modelContext: modelContext,
            pullVidsService: pullVidsService,
            convertVidService: convertVidService
        )
    }

    // MARK: - Queue Management

    /// Processes next queued job if capacity allows
    func processNext() {
        guard activeJobCount < maxConcurrentJobs else { return }

        // Fetch next queued job
        let queuedStatus = JobStatus.queued.rawValue
        let descriptor = FetchDescriptor<Job>(
            predicate: #Predicate { $0.statusRaw == queuedStatus },
            sortBy: [SortDescriptor(\.createdAt)]
        )

        guard let job = try? modelContext.fetch(descriptor).first else { return }

        startJob(job)
    }

    /// Starts executing a job
    private func startJob(_ job: Job) {
        job.status = .running
        job.startedAt = Date()
        job.progress = 0.0

        try? modelContext.save()

        activeJobCount += 1

        switch job.type {
        case .download:
            executeDownloadJob(job)
        case .convert:
            executeConvertJob(job)
        case .pipeline:
            executePipelineJob(job)
        }
    }

    // MARK: - Job Execution

    private func executeDownloadJob(_ job: Job) {
        guard let settings = job.downloadSettings else {
            failJob(job, error: "Missing download settings")
            return
        }

        let handle = pullVidsService.download(
            url: job.name,
            settings: settings,
            progressCallback: { [weak self] progress in
                Task { @MainActor in
                    job.progress = progress.percentage / 100.0
                    job.progressText = progress.progressText
                    job.speed = progress.speed
                    job.eta = progress.eta
                    try? self?.modelContext.save()
                }
            },
            logCallback: { [weak self] line in
                Task { @MainActor in
                    job.appendLog(line)
                    try? self?.modelContext.save()
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    self?.handleDownloadCompletion(job: job, result: result)
                }
            }
        )

        if let handle = handle {
            runningJobs[job.id] = handle
        }
    }

    private func executeConvertJob(_ job: Job) {
        guard let settings = job.convertSettings,
              let inputPath = job.inputPath else {
            failJob(job, error: "Missing convert settings or input path")
            return
        }

        let handle = convertVidService.convert(
            input: inputPath,
            settings: settings,
            progressCallback: { [weak self] progress in
                Task { @MainActor in
                    job.progress = progress.percentage / 100.0
                    job.progressText = progress.progressText
                    job.eta = progress.eta.map { DateFormatters.formatETA(seconds: $0) }
                    try? self?.modelContext.save()
                }
            },
            logCallback: { [weak self] line in
                Task { @MainActor in
                    job.appendLog(line)
                    try? self?.modelContext.save()
                }
            },
            completion: { [weak self] result in
                Task { @MainActor in
                    self?.handleConvertCompletion(job: job, result: result)
                }
            }
        )

        if let handle = handle {
            runningJobs[job.id] = handle
        }
    }

    private func executePipelineJob(_ job: Job) {
        guard let downloadSettings = job.downloadSettings,
              let convertSettings = job.convertSettings else {
            failJob(job, error: "Missing pipeline settings")
            return
        }

        Task {
            await pipelineCoordinator.executePipeline(
                job: job,
                downloadSettings: downloadSettings,
                convertSettings: convertSettings
            )
            completeJob(job)
        }
    }

    // MARK: - Completion Handlers

    private func handleDownloadCompletion(job: Job, result: Result<String, Error>) {
        switch result {
        case .success(let outputPath):
            job.outputPath = outputPath
            job.progress = 1.0

            // Check if this is part of a pipeline
            if let settings = job.downloadSettings, settings.autoConvert {
                // Enqueue conversion job
                enqueuePipelineConversion(for: job)
            } else {
                completeJob(job)
            }

        case .failure(let error):
            failJob(job, error: error.localizedDescription)
        }

        runningJobs.removeValue(forKey: job.id)
        activeJobCount -= 1
        processNext()
    }

    private func handleConvertCompletion(job: Job, result: Result<String, Error>) {
        switch result {
        case .success(let outputPath):
            job.outputPath = outputPath
            job.progress = 1.0
            completeJob(job)

        case .failure(let error):
            failJob(job, error: error.localizedDescription)
        }

        runningJobs.removeValue(forKey: job.id)
        activeJobCount -= 1
        processNext()
    }

    // MARK: - Job State Changes

    private func completeJob(_ job: Job) {
        job.status = .success
        job.completedAt = Date()
        job.progress = 1.0
        try? modelContext.save()
    }

    private func failJob(_ job: Job, error: String) {
        job.status = .failed
        job.completedAt = Date()
        job.errorMessage = error
        try? modelContext.save()
    }

    func cancelJob(_ job: Job) {
        if let handle = runningJobs[job.id] {
            handle.cancel()
            runningJobs.removeValue(forKey: job.id)
            activeJobCount -= 1
        }

        job.status = .canceled
        job.completedAt = Date()
        try? modelContext.save()

        processNext()
    }

    func retryJob(_ job: Job) {
        job.status = .queued
        job.startedAt = nil
        job.completedAt = nil
        job.progress = 0.0
        job.progressText = nil
        job.speed = nil
        job.eta = nil
        job.errorMessage = nil
        job.logs = ""

        try? modelContext.save()

        processNext()
    }

    // MARK: - Pipeline Support

    private func enqueuePipelineConversion(for downloadJob: Job) {
        guard let downloadSettings = downloadJob.downloadSettings,
              let convertSettings = downloadSettings.autoConvertSettings,
              let inputPath = downloadJob.outputPath else {
            return
        }

        let convertJob = Job(
            type: .convert,
            status: .queued,
            name: FileHelpers.getFilenameWithExtension(inputPath),
            inputPath: inputPath,
            convertSettings: convertSettings,
            isPipelineChild: true,
            pipelineParentID: downloadJob.id
        )

        modelContext.insert(convertJob)
        try? modelContext.save()

        processNext()
    }

    // MARK: - Bulk Operations

    func cancelAll() {
        let runningJobIds = Array(runningJobs.keys)
        for jobId in runningJobIds {
            if let job = try? modelContext.fetch(FetchDescriptor<Job>(
                predicate: #Predicate { $0.id == jobId }
            )).first {
                cancelJob(job)
            }
        }
    }

    func retryFailed() {
        let failedStatus = JobStatus.failed.rawValue
        let descriptor = FetchDescriptor<Job>(
            predicate: #Predicate { $0.statusRaw == failedStatus }
        )

        if let jobs = try? modelContext.fetch(descriptor) {
            for job in jobs {
                retryJob(job)
            }
        }
    }

    func clearCompleted() {
        let successStatus = JobStatus.success.rawValue
        let canceledStatus = JobStatus.canceled.rawValue
        let descriptor = FetchDescriptor<Job>(
            predicate: #Predicate {
                $0.statusRaw == successStatus ||
                $0.statusRaw == canceledStatus
            }
        )

        if let jobs = try? modelContext.fetch(descriptor) {
            for job in jobs {
                modelContext.delete(job)
            }
            try? modelContext.save()
        }
    }
}
