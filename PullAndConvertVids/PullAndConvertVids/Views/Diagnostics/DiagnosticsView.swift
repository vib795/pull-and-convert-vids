//
//  DiagnosticsView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI

struct DiagnosticsView: View {
    @StateObject var viewModel: DiagnosticsViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Text("System Diagnostics")
                        .font(.title2)
                        .fontWeight(.bold)

                    Spacer()

                    Button(action: { viewModel.refresh() }) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                    .disabled(viewModel.isRefreshing)

                    Button("Export") {
                        viewModel.saveDiagnosticsToFile()
                    }
                }

                Divider()

                // App & System Info
                SystemInfoSection(viewModel: viewModel)

                Divider()

                // Binary Information
                BinaryInfoSection(viewModel: viewModel)

                Divider()

                // Command History
                CommandHistorySection(viewModel: viewModel)
            }
            .padding()
        }
        .navigationTitle("Diagnostics")
        .onAppear {
            if viewModel.pullVidsInfo == nil {
                viewModel.refresh()
            }
        }
    }
}

// MARK: - System Info Section
struct SystemInfoSection: View {
    @ObservedObject var viewModel: DiagnosticsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("System Information")
                .font(.headline)

            InfoRow(label: "App Version", value: Constants.version)
            InfoRow(label: "Bundle ID", value: Constants.bundleIdentifier)

            Text(viewModel.systemInfo)
                .font(.system(.caption, design: .monospaced))
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(4)
        }
    }
}

// MARK: - Binary Info Section
struct BinaryInfoSection: View {
    @ObservedObject var viewModel: DiagnosticsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Binary Information")
                .font(.headline)

            if let info = viewModel.pullVidsInfo {
                BinaryInfoCard(info: info, viewModel: viewModel)
            }

            if let info = viewModel.convertVidInfo {
                BinaryInfoCard(info: info, viewModel: viewModel)
            }

            if !viewModel.dependencyInfo.isEmpty {
                Text("Dependencies")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                ForEach(viewModel.dependencyInfo) { dep in
                    BinaryInfoCard(info: dep, viewModel: viewModel)
                }
            }

            if viewModel.pullVidsInfo == nil && viewModel.convertVidInfo == nil {
                Text("Click 'Refresh' to check binary status")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct BinaryInfoCard: View {
    let info: BinaryInfo
    @ObservedObject var viewModel: DiagnosticsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: info.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(info.isAvailable ? .green : .red)

                Text(info.name)
                    .font(.body)
                    .fontWeight(.medium)

                Spacer()

                if info.path != nil {
                    Button("Copy Path") {
                        viewModel.copyBinaryPath(info)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                }
            }

            if let path = info.path {
                Text("Path: \(path)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let version = info.version {
                Text("Version: \(version)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if info.isAvailable {
                Text("Version: Unknown")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if let error = info.error {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Command History Section
struct CommandHistorySection: View {
    @ObservedObject var viewModel: DiagnosticsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent Commands (\(viewModel.recentCommands.count))")
                    .font(.headline)

                Spacer()

                if !viewModel.recentCommands.isEmpty {
                    Button("Clear") {
                        viewModel.clearCommandHistory()
                    }
                    .buttonStyle(.bordered)
                }
            }

            if viewModel.recentCommands.isEmpty {
                Text("No commands have been executed yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.recentCommands) { cmd in
                    CommandRecordCard(record: cmd, viewModel: viewModel)
                }
            }
        }
    }
}

struct CommandRecordCard: View {
    let record: CommandRecord
    @ObservedObject var viewModel: DiagnosticsViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(record.statusIcon)
                    .font(.caption)

                Text(record.formattedTimestamp)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if let duration = record.formattedDuration {
                    Text(duration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button("Copy") {
                    viewModel.copyCommand(record)
                }
                .buttonStyle(.borderless)
                .controlSize(.small)
            }

            Text(record.command)
                .font(.system(.caption, design: .monospaced))
                .lineLimit(3)
                .textSelection(.enabled)
        }
        .padding(8)
        .background(Color.gray.opacity(0.05))
        .cornerRadius(4)
    }
}

// MARK: - Info Row
struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline)
        }
    }
}
