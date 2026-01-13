//
//  HistoryViewModel.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var filterStatus: JobStatus?
    @Published var filterType: JobType?
    @Published var selectedJobs: Set<UUID> = []

    private let modelContext: ModelContext
    private let jobManager: JobManager

    init(modelContext: ModelContext, jobManager: JobManager) {
        self.modelContext = modelContext
        self.jobManager = jobManager
    }

    // MARK: - Fetch

    var completedJobs: [Job] {
        let successStatus = JobStatus.success.rawValue
        let failedStatus = JobStatus.failed.rawValue
        let canceledStatus = JobStatus.canceled.rawValue
        let descriptor = FetchDescriptor<Job>(
            predicate: #Predicate {
                $0.statusRaw == successStatus ||
                $0.statusRaw == failedStatus ||
                $0.statusRaw == canceledStatus
            },
            sortBy: [SortDescriptor(\.completedAt, order: .reverse)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    var filteredJobs: [Job] {
        var jobs = completedJobs

        // Filter by status
        if let status = filterStatus {
            jobs = jobs.filter { $0.status == status }
        }

        // Filter by type
        if let type = filterType {
            jobs = jobs.filter { $0.type == type }
        }

        // Filter by search text
        if !searchText.isEmpty {
            jobs = jobs.filter { job in
                job.name.localizedCaseInsensitiveContains(searchText) ||
                job.type.displayName.localizedCaseInsensitiveContains(searchText)
            }
        }

        return jobs
    }

    // MARK: - Statistics

    var totalCompleted: Int {
        completedJobs.filter { $0.status == .success }.count
    }

    var totalFailed: Int {
        completedJobs.filter { $0.status == .failed }.count
    }

    var totalCanceled: Int {
        completedJobs.filter { $0.status == .canceled }.count
    }

    // MARK: - Actions

    func retryJob(_ job: Job) {
        jobManager.retryJob(job)
    }

    func deleteJob(_ job: Job) {
        modelContext.delete(job)
        try? modelContext.save()
    }

    func deleteSelected() {
        for jobId in selectedJobs {
            if let job = try? modelContext.fetch(FetchDescriptor<Job>(
                predicate: #Predicate { $0.id == jobId }
            )).first {
                modelContext.delete(job)
            }
        }
        try? modelContext.save()
        selectedJobs.removeAll()
    }

    func clearAll() {
        for job in completedJobs {
            modelContext.delete(job)
        }
        try? modelContext.save()
    }

    func clearCompleted() {
        jobManager.clearCompleted()
    }

    func retryFailed() {
        jobManager.retryFailed()
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

    func clearFilters() {
        searchText = ""
        filterStatus = nil
        filterType = nil
    }
}

import AppKit
