//
//  ContentView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selection: NavigationItem? = .download
    @StateObject private var jobManager: JobManager

    // Services
    private let pullVidsService: PullVidsService
    private let convertVidService: ConvertVidService

    init(modelContext: ModelContext) {
        let pullVidsService = PullVidsService()
        let convertVidService = ConvertVidService()

        self.pullVidsService = pullVidsService
        self.convertVidService = convertVidService

        _jobManager = StateObject(wrappedValue: JobManager(
            modelContext: modelContext,
            pullVidsService: pullVidsService,
            convertVidService: convertVidService
        ))
    }

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(NavigationItem.allCases, id: \.self, selection: $selection) { item in
                NavigationLink(value: item) {
                    Label(item.title, systemImage: item.icon)
                }
                .keyboardShortcut(item.shortcut)
            }
            .navigationTitle(Constants.appName)
            .frame(minWidth: 200)
        } detail: {
            // Detail view
            if let selection = selection {
                destinationView(for: selection)
                    .toolbar {
                        ToolbarItem(placement: .automatic) {
                            HStack {
                                if jobManager.activeJobCount > 0 {
                                    HStack(spacing: 4) {
                                        ProgressView()
                                            .scaleEffect(0.7)
                                        Text("\(jobManager.activeJobCount) active")
                                            .font(.caption)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(4)
                                }
                            }
                        }
                    }
            } else {
                EmptyStateView(
                    icon: "sidebar.left",
                    title: "Select a Section",
                    message: "Choose a section from the sidebar to get started"
                )
            }
        }
        .onAppear {
            // Start processing queued jobs on launch
            jobManager.processNext()
        }
    }

    @ViewBuilder
    private func destinationView(for item: NavigationItem) -> some View {
        switch item {
        case .download:
            DownloadView(viewModel: DownloadViewModel(modelContext: modelContext, jobManager: jobManager))
        case .convert:
            ConvertView(viewModel: ConvertViewModel(modelContext: modelContext, jobManager: jobManager))
        case .queue:
            QueueView(viewModel: QueueViewModel(modelContext: modelContext, jobManager: jobManager))
        case .history:
            HistoryView(viewModel: HistoryViewModel(modelContext: modelContext, jobManager: jobManager))
        case .settings:
            SettingsView(viewModel: SettingsViewModel(
                modelContext: modelContext,
                pullVidsService: pullVidsService,
                convertVidService: convertVidService
            ))
        case .diagnostics:
            DiagnosticsView(viewModel: DiagnosticsViewModel(
                modelContext: modelContext,
                pullVidsService: pullVidsService,
                convertVidService: convertVidService
            ))
        }
    }
}

// MARK: - Navigation Items
enum NavigationItem: String, CaseIterable {
    case download
    case convert
    case queue
    case history
    case settings
    case diagnostics

    var title: String {
        switch self {
        case .download: return "Download"
        case .convert: return "Convert"
        case .queue: return "Queue"
        case .history: return "History"
        case .settings: return "Settings"
        case .diagnostics: return "Diagnostics"
        }
    }

    var icon: String {
        switch self {
        case .download: return "arrow.down.circle"
        case .convert: return "arrow.triangle.2.circlepath"
        case .queue: return "list.bullet"
        case .history: return "clock.arrow.circlepath"
        case .settings: return "gearshape"
        case .diagnostics: return "stethoscope"
        }
    }

    var shortcut: KeyEquivalent? {
        switch self {
        case .download: return "d"
        case .convert: return "k"
        case .queue: return "q"
        case .history: return "h"
        case .settings: return ","
        case .diagnostics: return nil
        }
    }
}
