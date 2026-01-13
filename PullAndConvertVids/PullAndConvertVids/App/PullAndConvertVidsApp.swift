//
//  PullAndConvertVidsApp.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI
import SwiftData

@main
struct PullAndConvertVidsApp: App {
    let modelContainer: ModelContainer

    init() {
        do {
            // Configure SwiftData schema
            let schema = Schema([
                Job.self,
                AppSettings.self,
                CommandRecord.self
            ])

            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(modelContext: modelContainer.mainContext)
                .modelContainer(modelContainer)
                .frame(minWidth: 900, minHeight: 600)
        }
        .windowStyle(.automatic)
        .windowResizability(.contentSize)
        .commands {
            // File menu
            CommandGroup(replacing: .newItem) {}

            // Help menu
            CommandGroup(replacing: .help) {
                Button("View README") {
                    if let url = URL(string: "https://github.com/vib795/pull-and-convert-vids") {
                        NSWorkspace.shared.open(url)
                    }
                }
                Button("Report Issue") {
                    if let url = URL(string: "https://github.com/vib795/pull-and-convert-vids/issues") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }

        Settings {
            SettingsView(viewModel: SettingsViewModel(
                modelContext: modelContainer.mainContext,
                pullVidsService: PullVidsService(),
                convertVidService: ConvertVidService()
            ))
        }
    }
}

import AppKit
