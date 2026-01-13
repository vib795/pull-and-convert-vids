//
//  SettingsView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel

    var body: some View {
        Form {
            // Binary Management
            BinaryManagementSection(viewModel: viewModel)

            Divider()

            // Dependencies
            DependencyStatusSection(viewModel: viewModel)

            Divider()

            // Default Paths
            DefaultPathsSection(viewModel: viewModel)

            Divider()

            // Preferences
            PreferencesSection(viewModel: viewModel)
        }
        .formStyle(.grouped)
        .navigationTitle("Settings")
        .frame(minWidth: 600, minHeight: 500)
    }
}

// MARK: - Binary Management Section
struct BinaryManagementSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section("Binary Management") {
            Picker("CLI Source", selection: $viewModel.settings.binarySource) {
                Text("Bundled (inside app)").tag("bundled")
                Text("System (Homebrew/PATH)").tag("system")
                Text("Custom Paths").tag("custom")
            }
            .onChange(of: viewModel.settings.binarySource) { _, _ in
                viewModel.saveSettings()
            }

            Text(viewModel.binarySourceDescription)
                .font(.caption)
                .foregroundStyle(.secondary)

            if viewModel.settings.binarySource == "custom" {
                HStack {
                    Text("pull-vids:")
                    TextField("Path", text: Binding(
                        get: { viewModel.settings.customPullVidsPath ?? "" },
                        set: { viewModel.settings.customPullVidsPath = $0 }
                    ))
                    Button("Choose...") {
                        viewModel.selectCustomPullVidsBinary()
                    }
                }

                HStack {
                    Text("convert-vid:")
                    TextField("Path", text: Binding(
                        get: { viewModel.settings.customConvertVidPath ?? "" },
                        set: { viewModel.settings.customConvertVidPath = $0 }
                    ))
                    Button("Choose...") {
                        viewModel.selectCustomConvertVidBinary()
                    }
                }
            }

            Button(action: { viewModel.verifyBinaries() }) {
                HStack {
                    if viewModel.isVerifying {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    Text("Verify Binaries")
                }
            }
            .disabled(viewModel.isVerifying)

            if let message = viewModel.verificationMessage {
                Text(message)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundStyle(viewModel.allBinariesAvailable ? .green : .red)
            }
        }
    }
}

// MARK: - Dependency Status Section
struct DependencyStatusSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section("Dependencies") {
            ForEach(viewModel.dependencyInfo) { dep in
                HStack {
                    Image(systemName: dep.isAvailable ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundStyle(dep.isAvailable ? .green : .red)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(dep.name)
                            .font(.body)

                        if let path = dep.path {
                            Text(path)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        if let version = dep.version {
                            Text(version)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    if !dep.isAvailable {
                        Button("Install") {
                            showInstallInstructions(for: dep.name)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            if viewModel.dependencyInfo.isEmpty {
                Text("Click 'Verify Binaries' to check dependencies")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func showInstallInstructions(for dependency: String) {
        let instructions = DependencyChecker.installInstructions(for: dependency)
        let alert = NSAlert()
        alert.messageText = "Install \(dependency)"
        alert.informativeText = instructions
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

// MARK: - Default Paths Section
struct DefaultPathsSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section("Default Paths") {
            HStack {
                Text("Download Directory:")
                Spacer()
                Text(viewModel.settings.defaultDownloadDirectory)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Button("Choose...") {
                    viewModel.selectDefaultDownloadDirectory()
                }
            }

            Picker("Convert Output", selection: $viewModel.settings.defaultConvertOutputRule) {
                Text("Same folder as input").tag("same-folder")
            }
            .onChange(of: viewModel.settings.defaultConvertOutputRule) { _, _ in
                viewModel.saveSettings()
            }

            Picker("Default Concurrency", selection: $viewModel.settings.defaultConcurrency) {
                ForEach(1...ProcessInfo.processInfo.activeProcessorCount, id: \.self) { count in
                    Text("\(count) threads").tag(count)
                }
            }
            .onChange(of: viewModel.settings.defaultConcurrency) { _, _ in
                viewModel.saveSettings()
            }
        }
    }
}

// MARK: - Preferences Section
struct PreferencesSection: View {
    @ObservedObject var viewModel: SettingsViewModel

    var body: some View {
        Section("Preferences") {
            Toggle("Remember last used values", isOn: $viewModel.settings.rememberLastUsedValues)
                .onChange(of: viewModel.settings.rememberLastUsedValues) { _, _ in
                    viewModel.saveSettings()
                }

            Text("When enabled, the app will remember your last selected quality, format, and other settings")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

import AppKit
