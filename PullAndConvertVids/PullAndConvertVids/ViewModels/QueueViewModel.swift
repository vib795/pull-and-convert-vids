//
//  QueueViewModel.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@MainActor
final class QueueViewModel: ObservableObject {
    @Published var selectedJobs: Set<UUID> = []
    @Published var searchText: String = ""

    private let modelContext: ModelContext
    private let jobManager: JobManager

    init(modelContext: ModelContext, jobManager: JobManager) {
        self.modelContext = modelContext
        self.jobManager = jobManager
    }

    // MARK: - Fetch

    var queuedAndRunningJobs: [Job] {
        let queuedStatus = JobStatus.queued.rawValue
        let runningStatus = JobStatus.running.rawValue
        let descriptor = FetchDescriptor<Job>(
            predicate: #Predicate {
                $0.statusRaw == queuedStatus ||
                $0.statusRaw == runningStatus
            },
            sortBy: [SortDescriptor(\.createdAt)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var filteredJobs: [Job] {
        if searchText.isEmpty {
            return queuedAndRunningJobs
        }

        return queuedAndRunningJobs.filter { job in
            job.name.localizedCaseInsensitiveContains(searchText) ||
            job.type.displayName.localizedCaseInsensitiveContains(searchText)
        }
    }

    // MARK: - Actions

    func cancelJob(_ job: Job) {
        jobManager.cancelJob(job)
    }

    func cancelSelected() {
        for jobId in selectedJobs {
            if let job = try? modelContext.fetch(FetchDescriptor<Job>(
                predicate: #Predicate { $0.id == jobId }
            )).first {
                jobManager.cancelJob(job)
            }
        }
        selectedJobs.removeAll()
    }

    func cancelAll() {
        jobManager.cancelAll()
        selectedJobs.removeAll()
    }

    func retryJob(_ job: Job) {
        jobManager.retryJob(job)
    }

    func viewLogs(_ job: Job) {
        // This will be handled by the view showing a modal
    }

    func revealOutput(_ job: Job) {
        guard let outputPath = job.outputPath else { return }
        PathHelpers.revealInFinder(path: outputPath)
    }

    func openOutput(_ job: Job) {
        guard let outputPath = job.outputPath else { return }
        PathHelpers.openFile(path: outputPath)
    }

    func copyOutputPath(_ job: Job) {
        guard let outputPath = job.outputPath else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(outputPath, forType: .string)
    }

    func toggleSelection(_ job: Job) {
        if selectedJobs.contains(job.id) {
            selectedJobs.remove(job.id)
        } else {
            selectedJobs.insert(job.id)
        }
    }

    func selectAll() {
        selectedJobs = Set(filteredJobs.map { $0.id })
    }

    func deselectAll() {
        selectedJobs.removeAll()
    }
}

import AppKit
