//
//  FileHelpers.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import UniformTypeIdentifiers

enum FileHelpers {
    /// Supported video file extensions
    static let videoExtensions = ["mp4", "avi", "mov", "mkv", "webm", "flv", "m4v", "mpg", "mpeg", "wmv"]

    /// Supported audio file extensions
    static let audioExtensions = ["mp3", "m4a", "opus", "wav", "aac", "flac", "ogg"]

    /// Checks if file has video extension
    static func isVideoFile(_ path: String) -> Bool {
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
        return videoExtensions.contains(ext)
    }

    /// Checks if file has audio extension
    static func isAudioFile(_ path: String) -> Bool {
        let ext = URL(fileURLWithPath: path).pathExtension.lowercased()
        return audioExtensions.contains(ext)
    }

    /// Gets file extension without dot
    static func getExtension(_ path: String) -> String {
        return URL(fileURLWithPath: path).pathExtension.lowercased()
    }

    /// Gets filename without extension
    static func getFilename(_ path: String) -> String {
        return URL(fileURLWithPath: path).deletingPathExtension().lastPathComponent
    }

    /// Gets filename with extension
    static func getFilenameWithExtension(_ path: String) -> String {
        return URL(fileURLWithPath: path).lastPathComponent
    }

    /// Gets directory path
    static func getDirectory(_ path: String) -> String {
        return URL(fileURLWithPath: path).deletingLastPathComponent().path
    }

    /// Checks if URL is a valid video URL
    static func isValidVideoURL(_ urlString: String) -> Bool {
        guard let url = URL(string: urlString) else { return false }
        guard let scheme = url.scheme?.lowercased() else { return false }
        return scheme == "http" || scheme == "https"
    }

    /// Parses multiple URLs from text (one per line)
    static func parseURLs(from text: String) -> [String] {
        return text
            .components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty && isValidVideoURL($0) }
    }

    /// Reads URLs from a text file (one per line)
    static func readURLsFromFile(_ path: String) throws -> [String] {
        let expandedPath = PathHelpers.expandPath(path)
        let content = try String(contentsOfFile: expandedPath, encoding: .utf8)
        return parseURLs(from: content)
    }

    /// Gets UTType for file
    static func getUTType(for path: String) -> UTType? {
        let ext = getExtension(path)
        return UTType(filenameExtension: ext)
    }

    /// Validates that output path doesn't conflict with input
    static func validateOutputPath(input: String, output: String) -> Bool {
        let expandedInput = PathHelpers.expandPath(input)
        let expandedOutput = PathHelpers.expandPath(output)
        return expandedInput != expandedOutput
    }

    /// Generates unique filename by appending number if file exists
    static func generateUniqueFilename(basePath: String) -> String {
        var expandedPath = PathHelpers.expandPath(basePath)

        if !PathHelpers.fileExists(at: expandedPath) {
            return expandedPath
        }

        let url = URL(fileURLWithPath: expandedPath)
        let directory = url.deletingLastPathComponent()
        let filename = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension

        var counter = 1
        repeat {
            let newFilename = "\(filename) (\(counter)).\(ext)"
            expandedPath = directory.appendingPathComponent(newFilename).path
            counter += 1
        } while PathHelpers.fileExists(at: expandedPath)

        return expandedPath
    }

    /// Copies file to destination
    static func copyFile(from source: String, to destination: String) throws {
        let expandedSource = PathHelpers.expandPath(source)
        let expandedDestination = PathHelpers.expandPath(destination)

        // Create destination directory if needed
        let destDirectory = URL(fileURLWithPath: expandedDestination).deletingLastPathComponent().path
        try PathHelpers.ensureDirectoryExists(at: destDirectory)

        // Copy file
        try FileManager.default.copyItem(atPath: expandedSource, toPath: expandedDestination)
    }

    /// Moves file to destination
    static func moveFile(from source: String, to destination: String) throws {
        let expandedSource = PathHelpers.expandPath(source)
        let expandedDestination = PathHelpers.expandPath(destination)

        // Create destination directory if needed
        let destDirectory = URL(fileURLWithPath: expandedDestination).deletingLastPathComponent().path
        try PathHelpers.ensureDirectoryExists(at: destDirectory)

        // Move file
        try FileManager.default.moveItem(atPath: expandedSource, toPath: expandedDestination)
    }

    /// Deletes file at path
    static func deleteFile(at path: String) throws {
        let expandedPath = PathHelpers.expandPath(path)
        try FileManager.default.removeItem(atPath: expandedPath)
    }
}
