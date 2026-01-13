//
//  JobType.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation

enum JobType: String, Codable, CaseIterable {
    case download
    case convert
    case pipeline // Download followed by convert

    var displayName: String {
        switch self {
        case .download: return "Download"
        case .convert: return "Convert"
        case .pipeline: return "Pipeline"
        }
    }

    var icon: String {
        switch self {
        case .download: return "arrow.down.circle"
        case .convert: return "arrow.triangle.2.circlepath"
        case .pipeline: return "arrow.forward.circle"
        }
    }
}
