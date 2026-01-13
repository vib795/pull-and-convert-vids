//
//  PathHelpers.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

enum PathHelpers {
    /// Expands tilde (~) in path and resolves to absolute path
    static func expandPath(_ path: String) -> String {
        if path.hasPrefix("~") {
            let homeDirectory = FileManager.default.homeDirectoryForCurrentUser.path
            return path.replacingOccurrences(of: "~", with: homeDirectory)
        }
        return path
    }

    /// Checks if file exists at path
    static func fileExists(at path: String) -> Bool {
        let expandedPath = expandPath(path)
        return FileManager.default.fileExists(atPath: expandedPath)
    }

    /// Checks if path is a directory
    static func isDirectory(at path: String) -> Bool {
        var isDir: ObjCBool = false
        let expandedPath = expandPath(path)
        let exists = FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    /// Creates directory at path if it doesn't exist
    static func ensureDirectoryExists(at path: String) throws {
        let expandedPath = expandPath(path)
        var isDir: ObjCBool = false

        if !FileManager.default.fileExists(atPath: expandedPath, isDirectory: &isDir) {
            try FileManager.default.createDirectory(
                atPath: expandedPath,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } else if !isDir.boolValue {
            throw PathError.notADirectory(expandedPath)
        }
    }

    /// Generates output path with "_converted" suffix if not specified
    static func generateOutputPath(for inputPath: String, format: String) -> String {
        let url = URL(fileURLWithPath: expandPath(inputPath))
        let directory = url.deletingLastPathComponent()
        let filename = url.deletingPathExtension().lastPathComponent
        return directory.appendingPathComponent("\(filename)_converted.\(format)").path
    }

    /// Validates that path doesn't contain invalid characters
    static func isValidPath(_ path: String) -> Bool {
        // Check for null bytes and other invalid characters
        return !path.contains("\0")
    }

    /// Gets all video files in directory with supported extensions
    static func getVideoFiles(in directory: String, extensions: [String]) throws -> [String] {
        let expandedPath = expandPath(directory)
        let contents = try FileManager.default.contentsOfDirectory(atPath: expandedPath)

        return contents.compactMap { filename in
            let fileURL = URL(fileURLWithPath: expandedPath).appendingPathComponent(filename)
            let ext = fileURL.pathExtension.lowercased()
            return extensions.contains(ext) ? fileURL.path : nil
        }
    }

    /// Reveals file in Finder
    static func revealInFinder(path: String) {
        let expandedPath = expandPath(path)
        let url = URL(fileURLWithPath: expandedPath)
        NSWorkspace.shared.activateFileViewerSelecting([url])
    }

    /// Opens file with default application
    static func openFile(path: String) {
        let expandedPath = expandPath(path)
        let url = URL(fileURLWithPath: expandedPath)
        NSWorkspace.shared.open(url)
    }

    /// Gets human-readable file size
    static func formatFileSize(bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB, .useGB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: bytes)
    }

    /// Gets file size in bytes
    static func getFileSize(at path: String) -> Int64? {
        let expandedPath = expandPath(path)
        guard let attributes = try? FileManager.default.attributesOfItem(atPath: expandedPath) else {
            return nil
        }
        return attributes[.size] as? Int64
    }

    /// Checks if path has spaces or special characters that need quoting
    static func needsQuoting(_ path: String) -> Bool {
        return path.contains(" ") || path.contains("'") || path.contains("\"")
    }
}

enum PathError: LocalizedError {
    case notADirectory(String)
    case invalidPath(String)
    case notFound(String)

    var errorDescription: String? {
        switch self {
        case .notADirectory(let path):
            return "Path exists but is not a directory: \(path)"
        case .invalidPath(let path):
            return "Invalid path: \(path)"
        case .notFound(let path):
            return "Path not found: \(path)"
        }
    }
}
