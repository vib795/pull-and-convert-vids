//
//  QueueView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct QueueView: View {
    @StateObject var viewModel: QueueViewModel
    @State private var selectedJob: Job?
    @State private var showLogs = false

    var body: some View {
        let jobs = viewModel.queuedAndRunningJobs

        VStack(spacing: 0) {
            // Toolbar
            QueueToolbar(viewModel: viewModel, jobCount: jobs.count)

            Divider()

            // Job List
            if jobs.isEmpty {
                EmptyStateView(
                    icon: "tray",
                    title: "No Active Jobs",
                    message: "Jobs you add will appear here"
                )
            } else {
                List(jobs) { job in
                    QueueItemRow(job: job, viewModel: viewModel)
                        .contextMenu {
                            JobContextMenu(job: job, viewModel: viewModel, selectedJob: $selectedJob, showLogs: $showLogs)
                        }
                }
            }
        }
        .navigationTitle("Queue")
        .sheet(isPresented: $showLogs) {
            if let job = selectedJob {
                LogViewerView(job: job)
            }
        }
    }
}

// MARK: - Queue Toolbar
struct QueueToolbar: View {
    @ObservedObject var viewModel: QueueViewModel
    let jobCount: Int

    var body: some View {
        HStack {
            Text("\(jobCount) active jobs")
                .font(.headline)

            Spacer()

            Button("Cancel All") {
                viewModel.cancelAll()
            }
            .buttonStyle(.bordered)
            .disabled(jobCount == 0)
        }
        .padding()
    }
}

// MARK: - Queue Item Row
struct QueueItemRow: View {
    let job: Job
    @ObservedObject var viewModel: QueueViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Status Icon
            Image(systemName: job.statusIcon)
                .foregroundStyle(job.statusColor)
                .font(.title3)
                .frame(width: 24)

            // Type Icon
            Image(systemName: job.type.icon)
                .foregroundStyle(.secondary)
                .font(.body)

            VStack(alignment: .leading, spacing: 4) {
                Text(job.displayName)
                    .font(.body)
                    .lineLimit(1)

                if let progressText = job.progressText {
                    Text(progressText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(job.status.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Progress
            if job.status == .running {
                ProgressView(value: job.progress)
                    .frame(width: 100)

                if let eta = job.eta {
                    Text(eta)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 60)
                }
            }

            // Actions
            Button(action: { viewModel.cancelJob(job) }) {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Job Context Menu
struct JobContextMenu: View {
    let job: Job
    @ObservedObject var viewModel: QueueViewModel
    @Binding var selectedJob: Job?
    @Binding var showLogs: Bool

    var body: some View {
        Button("View Logs") {
            selectedJob = job
            showLogs = true
        }

        if job.canCancel() {
            Button("Cancel") {
                viewModel.cancelJob(job)
            }
        }

        if let outputPath = job.outputPath {
            Divider()

            Button("Reveal in Finder") {
                viewModel.revealOutput(job)
            }

            Button("Open") {
                viewModel.openOutput(job)
            }

            Button("Copy Path") {
                viewModel.copyOutputPath(job)
            }
        }
    }
}
