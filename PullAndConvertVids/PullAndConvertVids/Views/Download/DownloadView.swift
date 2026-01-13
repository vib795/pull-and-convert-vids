//
//  DownloadView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI

struct DownloadView: View {
    @StateObject var viewModel: DownloadViewModel
    @State private var showCookieSection = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // URL Input
                URLInputSection(viewModel: viewModel)

                // Quality & Format
                QualityFormatSection(viewModel: viewModel)

                // Output Directory
                OutputDirectorySection(viewModel: viewModel)

                // Options
                OptionsSection(viewModel: viewModel)

                // Cookie Authentication (Advanced)
                CookieAuthSection(viewModel: viewModel, isExpanded: $showCookieSection)

                // Pipeline
                PipelineSection(viewModel: viewModel)

                // Error
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.errorMessage = nil
                    }
                }

                // Add to Queue Button
                Button(action: viewModel.addToQueue) {
                    Label("Add to Queue", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.isValidInput || viewModel.isProcessing)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Download")
    }
}

// MARK: - URL Input Section
struct URLInputSection: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("URLs", systemImage: "link")
                .font(.headline)

            TextEditor(text: $viewModel.urlText)
                .font(.body)
                .frame(minHeight: 100)
                .border(Color.gray.opacity(0.2))

            Text("Enter one URL per line. \(viewModel.urlCount) URLs detected.")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack {
                Button("Import from File") {
                    importFile()
                }
                .buttonStyle(.bordered)

                Button("Paste") {
                    if let text = NSPasteboard.general.string(forType: .string) {
                        viewModel.urlText += text + "\n"
                    }
                }
                .buttonStyle(.bordered)

                Button("Clear") {
                    viewModel.urlText = ""
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private func importFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.text]
        if panel.runModal() == .OK, let url = panel.url {
            viewModel.importURLsFromFile(url: url)
        }
    }
}

// MARK: - Quality & Format Section
struct QualityFormatSection: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Quality & Format", systemImage: "slider.horizontal.3")
                .font(.headline)

            // Quality presets
            HStack {
                ForEach([Constants.DownloadQuality.best, .fullHD, .hd], id: \.self) { quality in
                    Button(quality.displayName) {
                        viewModel.setQualityPreset(quality)
                    }
                    .buttonStyle(viewModel.settings.quality == quality.rawValue ? .borderedProminent : .bordered)
                }
            }

            // Audio-only toggle
            Toggle("Audio Only", isOn: $viewModel.settings.isAudioOnly)

            // Format picker
            if viewModel.settings.isAudioOnly {
                Picker("Audio Format", selection: Binding(
                    get: { viewModel.settings.audioFormat ?? "mp3" },
                    set: { viewModel.settings.audioFormat = $0 }
                )) {
                    ForEach(Constants.AudioFormat.allCases) { format in
                        Text(format.rawValue.uppercased()).tag(format.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            } else {
                Picker("Video Format", selection: Binding(
                    get: { viewModel.settings.videoFormat ?? "mp4" },
                    set: { viewModel.settings.videoFormat = $0 }
                )) {
                    ForEach(Constants.VideoFormat.allCases) { format in
                        Text(format.rawValue.uppercased()).tag(format.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

// MARK: - Output Directory Section
struct OutputDirectorySection: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Output Directory", systemImage: "folder")
                .font(.headline)

            HStack {
                Text(viewModel.settings.outputDirectory)
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(4)

                Button("Choose...") {
                    viewModel.selectOutputDirectory()
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

// MARK: - Options Section
struct OptionsSection: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Options", systemImage: "gearshape")
                .font(.headline)

            Toggle("Download Playlist/Channel", isOn: $viewModel.settings.isPlaylist)
        }
    }
}

// MARK: - Cookie Auth Section
struct CookieAuthSection: View {
    @ObservedObject var viewModel: DownloadViewModel
    @Binding var isExpanded: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Label("Cookie Authentication", systemImage: "key.fill")
                        .font(.headline)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Toggle("Enable Cookie Authentication", isOn: $viewModel.cookieAuthEnabled)
                        .fontWeight(.medium)

                    if viewModel.cookieAuthEnabled {
                        Picker("Method", selection: $viewModel.cookieAuthMethod) {
                            Text("Browser").tag(DownloadViewModel.CookieAuthMethod.browser)
                            Text("File").tag(DownloadViewModel.CookieAuthMethod.file)
                        }
                        .pickerStyle(.segmented)

                        if viewModel.cookieAuthMethod == .browser {
                            Picker("Browser", selection: $viewModel.selectedBrowser) {
                                ForEach(Constants.Browser.allCases) { browser in
                                    Text(browser.displayName).tag(browser.rawValue)
                                }
                            }

                            if viewModel.selectedBrowser == Constants.Browser.safari.rawValue {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.yellow)
                                    Text("Safari requires Full Disk Access for Terminal/app")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(8)
                                .background(Color.yellow.opacity(0.1))
                                .cornerRadius(4)
                            }
                        } else {
                            HStack {
                                Text(viewModel.cookieFilePath.isEmpty ? "No file selected" : viewModel.cookieFilePath)
                                    .lineLimit(1)
                                    .truncationMode(.middle)
                                Spacer()
                                Button("Choose...") {
                                    viewModel.selectCookieFile()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                    }
                }
                .padding(.leading)
            }
        }
    }
}

// MARK: - Pipeline Section
struct PipelineSection: View {
    @ObservedObject var viewModel: DownloadViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Auto-Convert After Download", systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)

            Toggle("Enable Auto-Convert", isOn: $viewModel.settings.autoConvert)

            if viewModel.settings.autoConvert {
                VStack(alignment: .leading, spacing: 8) {
                    Picker("Convert to", selection: Binding(
                        get: { viewModel.settings.autoConvertSettings?.format ?? "mp4" },
                        set: { format in
                            if viewModel.settings.autoConvertSettings == nil {
                                viewModel.settings.autoConvertSettings = .default
                            }
                            viewModel.settings.autoConvertSettings?.format = format
                        }
                    )) {
                        ForEach(Constants.ConvertFormat.allCases) { format in
                            Text(format.rawValue.uppercased()).tag(format.rawValue)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Quality", selection: Binding(
                        get: { viewModel.settings.autoConvertSettings?.quality ?? "medium" },
                        set: { quality in
                            if viewModel.settings.autoConvertSettings == nil {
                                viewModel.settings.autoConvertSettings = .default
                            }
                            viewModel.settings.autoConvertSettings?.quality = quality
                        }
                    )) {
                        ForEach(Constants.ConvertQuality.allCases) { quality in
                            Text(quality.displayName).tag(quality.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding(.leading)
            }
        }
    }
}

import AppKit
