//
//  DiagnosticsViewModel.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftData

@MainActor
final class DiagnosticsViewModel: ObservableObject {
    @Published var pullVidsInfo: BinaryInfo?
    @Published var convertVidInfo: BinaryInfo?
    @Published var dependencyInfo: [BinaryInfo] = []
    @Published var recentCommands: [CommandRecord] = []
    @Published var isRefreshing: Bool = false

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

    // MARK: - Refresh

    func refresh() {
        isRefreshing = true

        Task {
            // Check binaries
            pullVidsInfo = await pullVidsService.verify()
            convertVidInfo = await convertVidService.verify()

            // Check dependencies
            dependencyInfo = await DependencyChecker.checkAll()

            // Load recent commands
            loadRecentCommands()

            isRefreshing = false
        }
    }

    private func loadRecentCommands() {
        let descriptor = FetchDescriptor<CommandRecord>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )

        if let commands = try? modelContext.fetch(descriptor) {
            recentCommands = Array(commands.prefix(Constants.commandHistoryMaxCount))
        }
    }

    // MARK: - Actions

    func copyBinaryPath(_ info: BinaryInfo) {
        guard let path = info.path else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(path, forType: .string)
    }

    func copyCommand(_ command: CommandRecord) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(command.command, forType: .string)
    }

    func clearCommandHistory() {
        for command in recentCommands {
            modelContext.delete(command)
        }
        try? modelContext.save()
        recentCommands.removeAll()
    }

    func exportDiagnostics() -> String {
        var output: [String] = []

        output.append("=== Pull and Convert Vids Diagnostics ===\n")
        output.append("Generated: \(DateFormatters.fullDate.string(from: Date()))\n")

        output.append("\n=== Binary Information ===")
        if let info = pullVidsInfo {
            output.append("pull-vids:")
            output.append("  Status: \(info.displayStatus)")
            output.append("  Path: \(info.displayPath)")
        }

        if let info = convertVidInfo {
            output.append("convert-vid:")
            output.append("  Status: \(info.displayStatus)")
            output.append("  Path: \(info.displayPath)")
        }

        output.append("\n=== Dependencies ===")
        for dep in dependencyInfo {
            output.append("\(dep.name):")
            output.append("  Status: \(dep.displayStatus)")
            output.append("  Path: \(dep.displayPath)")
        }

        output.append("\n=== Recent Commands (\(recentCommands.count)) ===")
        for (index, cmd) in recentCommands.enumerated() {
            output.append("\(index + 1). \(cmd.formattedTimestamp)")
            output.append("   \(cmd.command)")
            if let exitCode = cmd.exitCode {
                output.append("   Exit code: \(exitCode)")
            }
            if let duration = cmd.formattedDuration {
                output.append("   Duration: \(duration)")
            }
        }

        return output.joined(separator: "\n")
    }

    func saveDiagnosticsToFile() {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = "diagnostics-\(Date().timeIntervalSince1970).txt"
        panel.allowedContentTypes = [.text]
        panel.prompt = "Save Diagnostics"

        if panel.runModal() == .OK {
            if let url = panel.url {
                let content = exportDiagnostics()
                try? content.write(to: url, atomically: true, encoding: .utf8)
            }
        }
    }

    // MARK: - Computed Properties

    var systemInfo: String {
        let processInfo = ProcessInfo.processInfo
        return """
        OS: \(processInfo.operatingSystemVersionString)
        Processor Count: \(processInfo.activeProcessorCount)
        Memory: \(ByteCountFormatter.string(fromByteCount: Int64(processInfo.physicalMemory), countStyle: .memory))
        """
    }

    var bundleInfo: String {
        return """
        App Version: \(Constants.version)
        Bundle ID: \(Constants.bundleIdentifier)
        """
    }
}

import AppKit
