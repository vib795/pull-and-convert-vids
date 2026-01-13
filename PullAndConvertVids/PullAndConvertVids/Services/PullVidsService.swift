//
//  PullVidsService.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Service for executing pull-vids commands
final class PullVidsService {
    private let processRunner: ProcessRunnerProtocol
    private let binarySource: BinaryLocator.BinarySource

    init(
        processRunner: ProcessRunnerProtocol = ProcessRunner(),
        binarySource: BinaryLocator.BinarySource = .bundled
    ) {
        self.processRunner = processRunner
        self.binarySource = binarySource
    }

    /// Downloads video(s) with the given URL and settings
    /// - Parameters:
    ///   - url: Video URL to download
    ///   - settings: Download configuration
    ///   - progressCallback: Called when progress updates are parsed
    ///   - logCallback: Called for each line of output
    ///   - completion: Called when download completes with exit code
    /// - Returns: ProcessHandle for cancellation
    func download(
        url: String,
        settings: DownloadSettings,
        progressCallback: @escaping (DownloadProgress) -> Void,
        logCallback: @escaping (String) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> ProcessHandle? {
        // Locate binary
        guard let binaryPath = BinaryLocator.locate(Constants.pullVidsBinaryName, source: binarySource) else {
            completion(.failure(PullVidsError.binaryNotFound))
            return nil
        }

        // Build arguments
        let arguments = ArgumentBuilder.buildPullVidsArguments(url: url, settings: settings)

        // Log the command
        let command = ArgumentBuilder.formatCommand(binary: binaryPath, args: arguments)
        logCallback("$ \(command)\n")

        var outputPath: String?

        // Execute process
        let handle = processRunner.run(
            binary: binaryPath,
            arguments: arguments,
            outputHandler: { line in
                logCallback(line + "\n")

                // Parse progress
                if let progress = ProgressParser.parseDownloadProgress(line) {
                    progressCallback(progress)
                }

                // Try to extract output path from log
                if line.contains("Destination:") || line.contains("has already been downloaded") {
                    outputPath = self.extractOutputPath(from: line)
                }
            },
            errorHandler: { line in
                logCallback("[stderr] \(line)\n")

                // Parse progress from stderr too (yt-dlp sometimes uses stderr)
                if let progress = ProgressParser.parseDownloadProgress(line) {
                    progressCallback(progress)
                }
            },
            completionHandler: { exitCode in
                if exitCode == 0 {
                    completion(.success(outputPath ?? settings.outputDirectory))
                } else {
                    let error = PullVidsError.downloadFailed(exitCode: exitCode)
                    completion(.failure(error))
                }
            }
        )

        return handle
    }

    /// Extracts output file path from log line
    private func extractOutputPath(from line: String) -> String? {
        // This is a best-effort extraction; yt-dlp output format may vary
        // Look for patterns like: "[download] /path/to/file.mp4 has already been downloaded"
        if let match = line.range(of: #"/[^\s]+"#, options: .regularExpression) {
            let path = String(line[match])
            if PathHelpers.fileExists(at: path) {
                return path
            }
        }
        return nil
    }

    /// Gets pull-vids version
    func getVersion() async -> String? {
        guard let binaryPath = BinaryLocator.locate(Constants.pullVidsBinaryName, source: binarySource) else {
            return nil
        }

        return await BinaryLocator.getVersion(
            binary: binaryPath,
            versionArgs: ArgumentBuilder.pullVidsVersionArgs
        )
    }

    /// Verifies pull-vids is available
    func verify() async -> BinaryInfo {
        let name = Constants.pullVidsBinaryName

        guard let path = BinaryLocator.locate(name, source: binarySource) else {
            return .notFound(name: name, error: Constants.ErrorMessage.pullVidsNotFound)
        }

        guard BinaryLocator.isExecutable(path) else {
            return .notFound(name: name, error: "Binary found but not executable")
        }

        let version = await getVersion()
        return .found(name: name, path: path, version: version)
    }
}

// MARK: - Errors

enum PullVidsError: LocalizedError {
    case binaryNotFound
    case downloadFailed(exitCode: Int32)
    case invalidURL
    case dependencyMissing(String)

    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return Constants.ErrorMessage.pullVidsNotFound
        case .downloadFailed(let code):
            return "Download failed with exit code \(code)"
        case .invalidURL:
            return Constants.ErrorMessage.invalidURL
        case .dependencyMissing(let dep):
            return "\(dep) is required but not found"
        }
    }
}
