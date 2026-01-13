//
//  PathHelpersTests.swift
//  PullAndConvertVidsTests
//
//  Created by Claude Code
//

import XCTest
@testable import PullAndConvertVids

final class PathHelpersTests: XCTestCase {

    func testExpandPath() {
        let homePath = PathHelpers.expandPath("~/Documents")
        XCTAssertFalse(homePath.contains("~"))
        XCTAssertTrue(homePath.hasPrefix("/"))
    }

    func testExpandPathNonTilde() {
        let path = "/usr/local/bin"
        let expanded = PathHelpers.expandPath(path)
        XCTAssertEqual(path, expanded)
    }

    func testIsValidPath() {
        XCTAssertTrue(PathHelpers.isValidPath("/valid/path"))
        XCTAssertTrue(PathHelpers.isValidPath("~/valid/path"))
        XCTAssertFalse(PathHelpers.isValidPath("/path/with/\0/null"))
    }

    func testGenerateOutputPath() {
        let input = "/path/to/video.avi"
        let output = PathHelpers.generateOutputPath(for: input, format: "mp4")

        XCTAssertTrue(output.contains("video_converted"))
        XCTAssertTrue(output.hasSuffix(".mp4"))
    }

    func testFormatFileSize() {
        let size1MB = Int64(1024 * 1024)
        let formatted = PathHelpers.formatFileSize(bytes: size1MB)
        XCTAssertTrue(formatted.contains("1"))
        XCTAssertTrue(formatted.contains("MB") || formatted.contains("KB"))
    }
}
