//
//  LogViewerView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct LogViewerView: View {
    let jobId: UUID
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var job: Job?

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Logs: \(job?.displayName ?? "Loading...")")
                    .font(.headline)

                Spacer()

                Button("Copy") {
                    copyLogs()
                }
                .disabled(job == nil)

                Button("Close") {
                    dismiss()
                }
            }
            .padding()

            Divider()

            // Logs
            ScrollView {
                if let job = job {
                    Text(job.logs.isEmpty ? "No logs available" : job.logs)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                } else {
                    ProgressView("Loading logs...")
                        .padding()
                }
            }
            .background(Color(nsColor: .textBackgroundColor))
        }
        .frame(width: 700, height: 500)
        .onAppear {
            fetchJob()
        }
    }

    private func fetchJob() {
        let jobIdToFetch = jobId
        let descriptor = FetchDescriptor<Job>(
            predicate: #Predicate { $0.id == jobIdToFetch }
        )

        if let fetchedJob = try? modelContext.fetch(descriptor).first {
            job = fetchedJob
        }
    }

    private func copyLogs() {
        guard let job = job else { return }
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(job.logs, forType: .string)
    }
}

import AppKit
