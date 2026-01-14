//
//  HistoryView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct HistoryView: View {
    @StateObject var viewModel: HistoryViewModel
    @State private var selectedJob: Job?
    @State private var showLogs = false

    var body: some View {
        let completedJobs = viewModel.completedJobs
        let filteredJobs = viewModel.filteredJobs
        let isEmpty = filteredJobs.isEmpty
        let noCompletedJobs = completedJobs.isEmpty

        VStack(spacing: 0) {
            // Toolbar
            HistoryToolbar(viewModel: viewModel)

            Divider()

            // Filters
            HistoryFilters(viewModel: viewModel)

            Divider()

            // Job List
            if isEmpty {
                if noCompletedJobs {
                    EmptyStateView(
                        icon: "clock.arrow.circlepath",
                        title: "No History",
                        message: "Completed jobs will appear here"
                    )
                } else {
                    EmptyStateView(
                        icon: "magnifyingglass",
                        title: "No Results",
                        message: "No jobs match your filters"
                    )
                }
            } else {
                List(filteredJobs) { job in
                    HistoryItemRow(job: job, viewModel: viewModel)
                        .contextMenu {
                            HistoryJobContextMenu(job: job, viewModel: viewModel, selectedJob: $selectedJob, showLogs: $showLogs)
                        }
                }
            }

            // Stats Footer
            HistoryStatsFooter(viewModel: viewModel)
        }
        .navigationTitle("History")
        .sheet(isPresented: $showLogs) {
            if let job = selectedJob {
                LogViewerView(jobId: job.id)
            }
        }
    }
}

// MARK: - History Toolbar
struct HistoryToolbar: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        HStack {
            TextField("Search...", text: $viewModel.searchText)
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 300)

            Spacer()

            Button("Retry Failed") {
                viewModel.retryFailed()
            }
            .buttonStyle(.bordered)

            Button("Clear Completed") {
                viewModel.clearCompleted()
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

// MARK: - History Filters
struct HistoryFilters: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        HStack {
            Text("Filter:")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Picker("Status", selection: $viewModel.filterStatus) {
                Text("All").tag(nil as JobStatus?)
                ForEach(JobStatus.allCases.filter { $0.isComplete }, id: \.self) { status in
                    Text(status.displayName).tag(status as JobStatus?)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)

            Picker("Type", selection: $viewModel.filterType) {
                Text("All").tag(nil as JobType?)
                ForEach(JobType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type as JobType?)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 120)

            if viewModel.filterStatus != nil || viewModel.filterType != nil {
                Button("Clear Filters") {
                    viewModel.clearFilters()
                }
                .buttonStyle(.bordered)
            }

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let job: Job
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: job.statusIcon)
                .foregroundStyle(job.statusColor)
                .font(.title3)
                .frame(width: 24)

            Image(systemName: job.type.icon)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 4) {
                Text(job.displayName)
                    .font(.body)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(job.formattedCreatedAt)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let duration = job.formattedDuration {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(duration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    if job.status == .failed, let error = job.errorMessage {
                        Text("•")
                            .foregroundStyle(.secondary)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .lineLimit(1)
                    }
                }
            }

            Spacer()

            if job.canRetry() {
                Button("Retry") {
                    viewModel.retryJob(job)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - History Job Context Menu
struct HistoryJobContextMenu: View {
    let job: Job
    @ObservedObject var viewModel: HistoryViewModel
    @Binding var selectedJob: Job?
    @Binding var showLogs: Bool

    var body: some View {
        Button("View Logs") {
            selectedJob = job
            showLogs = true
        }

        if job.canRetry() {
            Button("Retry") {
                viewModel.retryJob(job)
            }
        }

        Button("Delete") {
            viewModel.deleteJob(job)
        }

        if let outputPath = job.outputPath, PathHelpers.fileExists(at: outputPath) {
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

// MARK: - History Stats Footer
struct HistoryStatsFooter: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        HStack {
            StatLabel(icon: "checkmark.circle.fill", color: .green, count: viewModel.totalCompleted, label: "Success")
            StatLabel(icon: "xmark.circle.fill", color: .red, count: viewModel.totalFailed, label: "Failed")
            StatLabel(icon: "stop.circle.fill", color: .orange, count: viewModel.totalCanceled, label: "Canceled")

            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.05))
    }
}

struct StatLabel: View {
    let icon: String
    let color: Color
    let count: Int
    let label: String

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text("\(count) \(label)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
