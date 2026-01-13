//
//  ProcessRunner.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

/// Protocol for process execution (enables testing with mocks)
protocol ProcessRunnerProtocol {
    func run(
        binary: String,
        arguments: [String],
        outputHandler: @escaping (String) -> Void,
        errorHandler: @escaping (String) -> Void,
        completionHandler: @escaping (Int32) -> Void
    ) -> ProcessHandle
}

/// Handle to a running process (for cancellation)
protocol ProcessHandle {
    func cancel()
    var isRunning: Bool { get }
}

/// Real implementation of ProcessRunner
final class ProcessRunner: ProcessRunnerProtocol {

    func run(
        binary: String,
        arguments: [String],
        outputHandler: @escaping (String) -> Void,
        errorHandler: @escaping (String) -> Void,
        completionHandler: @escaping (Int32) -> Void
    ) -> ProcessHandle {
        let handle = ProcessHandleImpl()

        Task {
            let process = Process()
            handle.process = process

            // Configure process
            process.executableURL = URL(fileURLWithPath: binary)
            process.arguments = arguments

            // Setup pipes for streaming output
            let outputPipe = Pipe()
            let errorPipe = Pipe()

            process.standardOutput = outputPipe
            process.standardError = errorPipe

            // Read output asynchronously
            let outputHandle = outputPipe.fileHandleForReading
            let errorHandle = errorPipe.fileHandleForReading

            // Stream stdout
            Task {
                for try await line in outputHandle.bytes.lines {
                    outputHandler(line)
                }
            }

            // Stream stderr
            Task {
                for try await line in errorHandle.bytes.lines {
                    errorHandler(line)
                }
            }

            // Set termination handler
            process.terminationHandler = { process in
                handle.isRunning = false
                completionHandler(process.terminationStatus)
            }

            // Start process
            do {
                try process.run()
                handle.isRunning = true
            } catch {
                handle.isRunning = false
                errorHandler("Failed to start process: \(error.localizedDescription)")
                completionHandler(-1)
            }
        }

        return handle
    }
}

/// Implementation of ProcessHandle
private final class ProcessHandleImpl: ProcessHandle {
    weak var process: Process?
    var isRunning: Bool = false

    func cancel() {
        process?.terminate()
        isRunning = false
    }
}

// MARK: - AsyncSequence extension for line-by-line reading
extension AsyncSequence where Element == UInt8 {
    var lines: AsyncLineSequence<Self> {
        AsyncLineSequence(base: self)
    }
}

struct AsyncLineSequence<Base: AsyncSequence>: AsyncSequence where Base.Element == UInt8 {
    typealias Element = String

    let base: Base

    struct AsyncIterator: AsyncIteratorProtocol {
        var baseIterator: Base.AsyncIterator
        var buffer = Data()

        mutating func next() async throws -> String? {
            while let byte = try await baseIterator.next() {
                if byte == 10 { // newline character
                    defer { buffer.removeAll() }
                    return String(data: buffer, encoding: .utf8) ?? ""
                }
                buffer.append(byte)
            }

            // Return any remaining data
            if !buffer.isEmpty {
                defer { buffer.removeAll() }
                return String(data: buffer, encoding: .utf8) ?? ""
            }

            return nil
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(baseIterator: base.makeAsyncIterator())
    }
}
