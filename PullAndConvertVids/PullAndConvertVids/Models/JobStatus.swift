//
//  JobStatus.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import Foundation
import SwiftUI

enum JobStatus: String, Codable, CaseIterable {
    case queued
    case running
    case success
    case failed
    case canceled

    var displayName: String {
        switch self {
        case .queued: return "Queued"
        case .running: return "Running"
        case .success: return "Success"
        case .failed: return "Failed"
        case .canceled: return "Canceled"
        }
    }

    var icon: String {
        switch self {
        case .queued: return "clock"
        case .running: return "arrow.trianglehead.2.clockwise.rotate.90"
        case .success: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .canceled: return "stop.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .queued: return .gray
        case .running: return .blue
        case .success: return .green
        case .failed: return .red
        case .canceled: return .orange
        }
    }

    var isComplete: Bool {
        switch self {
        case .success, .failed, .canceled:
            return true
        case .queued, .running:
            return false
        }
    }

    var isActive: Bool {
        return self == .running
    }
}
