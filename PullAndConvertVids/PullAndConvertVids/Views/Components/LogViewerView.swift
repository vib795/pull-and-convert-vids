//
//  LogViewerView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI

struct LogViewerView: View {
    let job: Job
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Logs: \(job.displayName)")
                    .font(.headline)

                Spacer()

                Button("Copy") {
                    copyLogs()
                }

                Button("Close") {
                    dismiss()
                }
            }
            .padding()

            Divider()

            // Logs
            ScrollView {
                Text(job.logs.isEmpty ? "No logs available" : job.logs)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
            .background(Color(nsColor: .textBackgroundColor))
        }
        .frame(width: 700, height: 500)
    }

    private func copyLogs() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(job.logs, forType: .string)
    }
}

import AppKit
