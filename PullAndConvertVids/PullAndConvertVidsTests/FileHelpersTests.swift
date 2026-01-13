//
//  FileHelpersTests.swift
//  PullAndConvertVidsTests
//
//  Created by Claude Code
//

import XCTest
@testable import PullAndConvertVids

final class FileHelpersTests: XCTestCase {

    func testIsVideoFile() {
        XCTAssertTrue(FileHelpers.isVideoFile("/path/to/video.mp4"))
        XCTAssertTrue(FileHelpers.isVideoFile("/path/to/video.MP4"))
        XCTAssertTrue(FileHelpers.isVideoFile("/path/to/video.mkv"))
        XCTAssertFalse(FileHelpers.isVideoFile("/path/to/document.txt"))
    }

    func testIsAudioFile() {
        XCTAssertTrue(FileHelpers.isAudioFile("/path/to/audio.mp3"))
        XCTAssertTrue(FileHelpers.isAudioFile("/path/to/audio.M4A"))
        XCTAssertFalse(FileHelpers.isAudioFile("/path/to/video.mp4"))
    }

    func testGetExtension() {
        XCTAssertEqual(FileHelpers.getExtension("/path/to/file.mp4"), "mp4")
        XCTAssertEqual(FileHelpers.getExtension("/path/to/file.TXT"), "txt")
    }

    func testGetFilename() {
        XCTAssertEqual(FileHelpers.getFilename("/path/to/video.mp4"), "video")
        XCTAssertEqual(FileHelpers.getFilename("/path/to/my.movie.mkv"), "my.movie")
    }

    func testGetFilenameWithExtension() {
        XCTAssertEqual(FileHelpers.getFilenameWithExtension("/path/to/video.mp4"), "video.mp4")
    }

    func testIsValidVideoURL() {
        XCTAssertTrue(FileHelpers.isValidVideoURL("https://www.youtube.com/watch?v=test"))
        XCTAssertTrue(FileHelpers.isValidVideoURL("http://vimeo.com/123456"))
        XCTAssertFalse(FileHelpers.isValidVideoURL("not-a-url"))
        XCTAssertFalse(FileHelpers.isValidVideoURL("ftp://invalid.com"))
    }

    func testParseURLs() {
        let text = """
        https://www.youtube.com/watch?v=test1
        https://vimeo.com/123456
        not a url
        https://www.youtube.com/watch?v=test2
        """

        let urls = FileHelpers.parseURLs(from: text)

        XCTAssertEqual(urls.count, 3)
        XCTAssertTrue(urls.contains("https://www.youtube.com/watch?v=test1"))
        XCTAssertTrue(urls.contains("https://vimeo.com/123456"))
        XCTAssertTrue(urls.contains("https://www.youtube.com/watch?v=test2"))
    }

    func testValidateOutputPath() {
        XCTAssertTrue(FileHelpers.validateOutputPath(
            input: "/input/video.avi",
            output: "/output/video.mp4"
        ))

        XCTAssertFalse(FileHelpers.validateOutputPath(
            input: "/input/video.avi",
            output: "/input/video.avi"
        ))
    }
}
