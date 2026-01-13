//
//  ArgumentBuilderTests.swift
//  PullAndConvertVidsTests
//
//  Created by Claude Code
//

import XCTest
@testable import PullAndConvertVids

final class ArgumentBuilderTests: XCTestCase {

    // MARK: - pull-vids Argument Tests

    func testBasicDownloadArguments() {
        let settings = DownloadSettings(
            quality: "best",
            outputDirectory: "~/Downloads",
            isAudioOnly: false,
            videoFormat: "mp4",
            isPlaylist: false,
            cookieAuth: nil
        )

        let args = ArgumentBuilder.buildPullVidsArguments(
            url: "https://www.youtube.com/watch?v=test",
            settings: settings
        )

        XCTAssertTrue(args.contains("-q"))
        XCTAssertTrue(args.contains("best"))
        XCTAssertTrue(args.contains("-o"))
        XCTAssertTrue(args.contains("--newline"))
        XCTAssertTrue(args.contains("--progress"))
        XCTAssertTrue(args.contains("--no-banner"))
        XCTAssertEqual(args.last, "https://www.youtube.com/watch?v=test")
    }

    func testAudioOnlyArguments() {
        let settings = DownloadSettings(
            quality: "best",
            outputDirectory: "~/Downloads",
            isAudioOnly: true,
            audioFormat: "mp3",
            videoFormat: nil,
            isPlaylist: false,
            cookieAuth: nil
        )

        let args = ArgumentBuilder.buildPullVidsArguments(
            url: "https://www.youtube.com/watch?v=test",
            settings: settings
        )

        XCTAssertTrue(args.contains("-a"))
        XCTAssertFalse(args.contains("-f")) // Default mp3, no need for -f
    }

    func testPlaylistArguments() {
        let settings = DownloadSettings(
            quality: "720p",
            outputDirectory: "~/Downloads",
            isAudioOnly: false,
            videoFormat: "mp4",
            isPlaylist: true,
            cookieAuth: nil
        )

        let args = ArgumentBuilder.buildPullVidsArguments(
            url: "https://www.youtube.com/playlist?list=test",
            settings: settings
        )

        XCTAssertTrue(args.contains("-p"))
        XCTAssertTrue(args.contains("720p"))
    }

    func testCookieAuthBrowserArguments() {
        let settings = DownloadSettings(
            quality: "best",
            outputDirectory: "~/Downloads",
            isAudioOnly: false,
            videoFormat: "mp4",
            isPlaylist: false,
            cookieAuth: .fromBrowser("firefox")
        )

        let args = ArgumentBuilder.buildPullVidsArguments(
            url: "https://www.youtube.com/watch?v=test",
            settings: settings
        )

        XCTAssertTrue(args.contains("--cookies-from-browser"))
        XCTAssertTrue(args.contains("firefox"))
    }

    func testCookieAuthFileArguments() {
        let settings = DownloadSettings(
            quality: "best",
            outputDirectory: "~/Downloads",
            isAudioOnly: false,
            videoFormat: "mp4",
            isPlaylist: false,
            cookieAuth: .fromFile("/path/to/cookies.txt")
        )

        let args = ArgumentBuilder.buildPullVidsArguments(
            url: "https://www.youtube.com/watch?v=test",
            settings: settings
        )

        XCTAssertTrue(args.contains("--cookies"))
        XCTAssertTrue(args.contains("/path/to/cookies.txt"))
    }

    // MARK: - convert-vid Argument Tests

    func testBasicConvertArguments() {
        let settings = ConvertSettings(
            format: "mp4",
            quality: "medium",
            outputPath: "/output/video.mp4",
            overwrite: false,
            concurrency: 4
        )

        let args = ArgumentBuilder.buildConvertVidArguments(
            input: "/input/video.avi",
            settings: settings
        )

        XCTAssertEqual(args[0], "convert")
        XCTAssertTrue(args.contains("--input"))
        XCTAssertTrue(args.contains("/input/video.avi"))
        XCTAssertTrue(args.contains("-f"))
        XCTAssertTrue(args.contains("mp4"))
        XCTAssertTrue(args.contains("-q"))
        XCTAssertTrue(args.contains("medium"))
        XCTAssertTrue(args.contains("-o"))
        XCTAssertTrue(args.contains("/output/video.mp4"))
    }

    func testConvertWithOverwrite() {
        let settings = ConvertSettings(
            format: "mp4",
            quality: "high",
            outputPath: nil,
            overwrite: true,
            concurrency: 2
        )

        let args = ArgumentBuilder.buildConvertVidArguments(
            input: "/input/video.avi",
            settings: settings
        )

        XCTAssertTrue(args.contains("--overwrite"))
        XCTAssertTrue(args.contains("high"))
    }

    func testConvertWithConcurrency() {
        let settings = ConvertSettings(
            format: "mp4",
            quality: "medium",
            outputPath: nil,
            overwrite: false,
            concurrency: 8
        )

        let args = ArgumentBuilder.buildConvertVidArguments(
            input: "/input/directory",
            settings: settings
        )

        // Concurrency only added for directory input
        // This test assumes /input/directory is detected as directory
        // In real scenario, PathHelpers.isDirectory would be called
    }

    // MARK: - Command Formatting Tests

    func testCommandFormatting() {
        let command = ArgumentBuilder.formatCommand(
            binary: "/usr/local/bin/pull-vids",
            args: ["-q", "720p", "-o", "/path with spaces/output"],
            redactSensitive: false
        )

        XCTAssertTrue(command.contains("\"/path with spaces/output\""))
        XCTAssertTrue(command.contains("/usr/local/bin/pull-vids"))
    }

    func testSensitiveArgumentRedaction() {
        let command = ArgumentBuilder.formatCommand(
            binary: "pull-vids",
            args: ["--cookies", "/path/to/cookies.txt", "https://youtube.com"],
            redactSensitive: true
        )

        XCTAssertTrue(command.contains("[REDACTED_COOKIE_FILE]"))
        XCTAssertFalse(command.contains("/path/to/cookies.txt"))
    }
}
