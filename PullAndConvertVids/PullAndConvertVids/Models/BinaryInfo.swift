//
//  BinaryInfo.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

struct BinaryInfo: Identifiable {
    let id = UUID()
    let name: String
    let path: String?
    let version: String?
    let isAvailable: Bool
    let error: String?

    var displayStatus: String {
        if isAvailable, let version = version {
            return "✓ \(version)"
        } else if isAvailable {
            return "✓ Available"
        } else {
            return "✗ Not found"
        }
    }

    var displayPath: String {
        path ?? "Not found"
    }

    static func notFound(name: String, error: String? = nil) -> BinaryInfo {
        BinaryInfo(
            name: name,
            path: nil,
            version: nil,
            isAvailable: false,
            error: error
        )
    }

    static func found(name: String, path: String, version: String? = nil) -> BinaryInfo {
        BinaryInfo(
            name: name,
            path: path,
            version: version,
            isAvailable: true,
            error: nil
        )
    }
}
