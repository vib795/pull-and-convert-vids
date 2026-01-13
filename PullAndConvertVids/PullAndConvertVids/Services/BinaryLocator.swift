//
//  BinaryLocator.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Locates binary executables in various locations
final class BinaryLocator {

    enum BinarySource {
        case bundled
        case system
        case custom(String)
    }

    /// Locates a binary based on source preference
    /// - Parameters:
    ///   - name: Binary name (e.g., "pull-vids")
    ///   - source: Source preference
    /// - Returns: Full path to binary, or nil if not found
    static func locate(_ name: String, source: BinarySource) -> String? {
        switch source {
        case .bundled:
            return locateBundledBinary(name)
        case .system:
            return locateSystemBinary(name)
        case .custom(let path):
            let expandedPath = PathHelpers.expandPath(path)
            return PathHelpers.fileExists(at: expandedPath) ? expandedPath : nil
        }
    }

    /// Locates binary in app bundle
    static func locateBundledBinary(_ name: String) -> String? {
        guard let resourcePath = Bundle.main.resourcePath else { return nil }
        let binaryPath = "\(resourcePath)/bin/\(name)"
        return PathHelpers.fileExists(at: binaryPath) ? binaryPath : nil
    }

    /// Locates binary in system paths
    static func locateSystemBinary(_ name: String) -> String? {
        // Try project Build directory first (for local development)
        let projectPaths = [
            PathHelpers.expandPath("~/pull-and-convert-vids/Build"),
            PathHelpers.expandPath("~/Documents/pull-and-convert-vids/Build"),
            PathHelpers.expandPath("~/Desktop/pull-and-convert-vids/Build")
        ]

        for path in projectPaths {
            let binaryPath = "\(path)/\(name)"
            if PathHelpers.fileExists(at: binaryPath) {
                return binaryPath
            }
        }

        // Try Homebrew paths
        let homebrewPaths = [
            Constants.homebrewAppleSiliconPath,
            Constants.homebrewIntelPath
        ]

        for path in homebrewPaths {
            let binaryPath = "\(path)/\(name)"
            if PathHelpers.fileExists(at: binaryPath) {
                return binaryPath
            }
        }

        // Try common Go binary paths
        var goPaths = [
            PathHelpers.expandPath("~/go/bin"),
            PathHelpers.expandPath("~/bin"),
            PathHelpers.expandPath("~/.local/bin")
        ]

        // Add GOPATH/bin if GOPATH is set
        if let gopath = ProcessInfo.processInfo.environment["GOPATH"] {
            goPaths.append("\(gopath)/bin")
        }

        for path in goPaths {
            let binaryPath = "\(path)/\(name)"
            if PathHelpers.fileExists(at: binaryPath) {
                return binaryPath
            }
        }

        // Try PATH environment variable
        if let pathBinary = locateInPath(name) {
            return pathBinary
        }

        return nil
    }

    /// Searches for binary in PATH environment variable
    static func locateInPath(_ name: String) -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/which")
        process.arguments = [name]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = Pipe() // Discard stderr

        do {
            try process.run()
            process.waitUntilExit()

            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let output = String(data: data, encoding: .utf8) {
                    let path = output.trimmingCharacters(in: .whitespacesAndNewlines)
                    return PathHelpers.fileExists(at: path) ? path : nil
                }
            }
        } catch {
            return nil
        }

        return nil
    }

    /// Tries multiple sources in order: bundled -> system -> PATH
    static func locateAny(_ name: String) -> String? {
        if let bundled = locateBundledBinary(name) {
            return bundled
        }

        if let system = locateSystemBinary(name) {
            return system
        }

        return nil
    }

    /// Checks if binary is executable
    static func isExecutable(_ path: String) -> Bool {
        let expandedPath = PathHelpers.expandPath(path)
        return FileManager.default.isExecutableFile(atPath: expandedPath)
    }

    /// Gets binary version by running --version or version command
    static func getVersion(binary: String, versionArgs: [String], timeout: TimeInterval = 5.0) async -> String? {
        return await withCheckedContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: binary)
            process.arguments = versionArgs

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            // Timeout handler
            let timeoutTask = Task {
                try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                if process.isRunning {
                    process.terminate()
                    continuation.resume(returning: nil)
                }
            }

            process.terminationHandler = { _ in
                timeoutTask.cancel()
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let result = String(data: data, encoding: .utf8) {
                    let output = result.trimmingCharacters(in: .whitespacesAndNewlines)
                    continuation.resume(returning: output.isEmpty ? nil : output)
                } else {
                    continuation.resume(returning: nil)
                }
            }

            do {
                try process.run()
            } catch {
                timeoutTask.cancel()
                continuation.resume(returning: nil)
            }
        }
    }
}
