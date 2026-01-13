//
//  ConvertVidService.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Service for executing convert-vid commands
final class ConvertVidService {
    private let processRunner: ProcessRunnerProtocol
    private let binarySource: BinaryLocator.BinarySource

    init(
        processRunner: ProcessRunnerProtocol = ProcessRunner(),
        binarySource: BinaryLocator.BinarySource = .bundled
    ) {
        self.processRunner = processRunner
        self.binarySource = binarySource
    }

    /// Converts video file(s) with the given settings
    /// - Parameters:
    ///   - input: Input file or directory path
    ///   - settings: Conversion configuration
    ///   - progressCallback: Called when progress updates are parsed
    ///   - logCallback: Called for each line of output
    ///   - completion: Called when conversion completes
    /// - Returns: ProcessHandle for cancellation
    func convert(
        input: String,
        settings: ConvertSettings,
        progressCallback: @escaping (ConversionProgress) -> Void,
        logCallback: @escaping (String) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) -> ProcessHandle? {
        // Locate binary
        guard let binaryPath = BinaryLocator.locate(Constants.convertVidBinaryName, source: binarySource) else {
            completion(.failure(ConvertVidError.binaryNotFound))
            return nil
        }

        // Build arguments
        let arguments = ArgumentBuilder.buildConvertVidArguments(input: input, settings: settings)

        // Log the command
        let command = ArgumentBuilder.formatCommand(binary: binaryPath, args: arguments)
        logCallback("$ \(command)\n")

        var totalDuration: TimeInterval?

        // Execute process
        let handle = processRunner.run(
            binary: binaryPath,
            arguments: arguments,
            outputHandler: { line in
                logCallback(line + "\n")

                // Extract total duration if available (from ffprobe output)
                if let duration = self.extractDuration(from: line) {
                    totalDuration = duration
                }
            },
            errorHandler: { line in
                logCallback("[stderr] \(line)\n")

                // Parse conversion progress (ffmpeg outputs to stderr)
                if let progress = ProgressParser.parseConversionProgress(line, totalDuration: totalDuration) {
                    progressCallback(progress)
                }
            },
            completionHandler: { exitCode in
                if exitCode == 0 {
                    let outputPath = settings.outputPath ?? PathHelpers.generateOutputPath(
                        for: input,
                        format: settings.format
                    )
                    completion(.success(outputPath))
                } else {
                    let error = ConvertVidError.conversionFailed(exitCode: exitCode)
                    completion(.failure(error))
                }
            }
        )

        return handle
    }

    /// Extracts video duration from ffmpeg/ffprobe output
    private func extractDuration(from line: String) -> TimeInterval? {
        // Look for patterns like: "Duration: 00:01:23.45"
        guard let range = line.range(of: #"Duration:\s*(\d{2}):(\d{2}):(\d{2}\.\d{2})"#, options: .regularExpression) else {
            return nil
        }

        let durationString = String(line[range])
            .replacingOccurrences(of: "Duration:", with: "")
            .trimmingCharacters(in: .whitespaces)

        let components = durationString.split(separator: ":")
        guard components.count == 3,
              let hours = Double(components[0]),
              let minutes = Double(components[1]),
              let seconds = Double(components[2]) else {
            return nil
        }

        return hours * 3600 + minutes * 60 + seconds
    }

    /// Gets convert-vid version
    func getVersion() async -> String? {
        guard let binaryPath = BinaryLocator.locate(Constants.convertVidBinaryName, source: binarySource) else {
            return nil
        }

        return await BinaryLocator.getVersion(
            binary: binaryPath,
            versionArgs: ArgumentBuilder.convertVidVersionArgs
        )
    }

    /// Verifies convert-vid is available
    func verify() async -> BinaryInfo {
        let name = Constants.convertVidBinaryName

        guard let path = BinaryLocator.locate(name, source: binarySource) else {
            return .notFound(name: name, error: Constants.ErrorMessage.convertVidNotFound)
        }

        guard BinaryLocator.isExecutable(path) else {
            return .notFound(name: name, error: "Binary found but not executable")
        }

        let version = await getVersion()
        return .found(name: name, path: path, version: version)
    }
}

// MARK: - Errors

enum ConvertVidError: LocalizedError {
    case binaryNotFound
    case conversionFailed(exitCode: Int32)
    case inputNotFound
    case outputExists
    case dependencyMissing(String)

    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return Constants.ErrorMessage.convertVidNotFound
        case .conversionFailed(let code):
            return "Conversion failed with exit code \(code)"
        case .inputNotFound:
            return "Input file or directory not found"
        case .outputExists:
            return Constants.ErrorMessage.outputExists
        case .dependencyMissing(let dep):
            return "\(dep) is required but not found"
        }
    }
}
