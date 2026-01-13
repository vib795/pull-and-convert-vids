//
//  ConvertView.swift
//  PullAndConvertVids
//
//  Created by Claude Code
//

import SwiftUI
import UniformTypeIdentifiers

struct ConvertView: View {
    @StateObject var viewModel: ConvertViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // File Drop Zone
                FileDropZone(viewModel: viewModel)

                // File List
                if !viewModel.selectedFiles.isEmpty {
                    FileListSection(viewModel: viewModel)
                }

                // Format & Quality
                FormatQualitySection(viewModel: viewModel)

                // Output Location
                OutputLocationSection(viewModel: viewModel)

                // Options
                ConvertOptionsSection(viewModel: viewModel)

                // Error
                if let error = viewModel.errorMessage {
                    ErrorBanner(message: error) {
                        viewModel.errorMessage = nil
                    }
                }

                // Start Conversion Button
                Button(action: viewModel.startConversion) {
                    Label("Start Conversion", systemImage: "play.circle.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!viewModel.isValidInput || viewModel.isProcessing)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Convert")
    }
}

// MARK: - File Drop Zone
struct FileDropZone: View {
    @ObservedObject var viewModel: ConvertViewModel

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "arrow.down.doc.fill")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text("Drop video files or folders here")
                .font(.title3)
                .fontWeight(.medium)

            Text("Supported formats: MP4, AVI, MOV, MKV, WebM, FLV, M4V")
                .font(.caption)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button("Add Files") {
                    viewModel.addFiles()
                }
                .buttonStyle(.bordered)

                Button("Add Folder") {
                    viewModel.addFolder()
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(40)
        .background(Color.blue.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [8]))
                .foregroundStyle(Color.blue.opacity(0.3))
        )
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            viewModel.handleDrop(providers: providers)
            return true
        }
    }
}

// MARK: - File List Section
struct FileListSection: View {
    @ObservedObject var viewModel: ConvertViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("\(viewModel.fileCount) files selected", systemImage: "doc.on.doc")
                    .font(.headline)

                Spacer()

                Button("Clear All") {
                    viewModel.clearFiles()
                }
                .buttonStyle(.bordered)
            }

            ForEach(viewModel.selectedFiles, id: \.self) { fileURL in
                HStack {
                    Image(systemName: "film")
                        .foregroundStyle(.blue)

                    Text(fileURL.lastPathComponent)
                        .lineLimit(1)

                    Spacer()

                    Button(action: { viewModel.removeFile(fileURL) }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(8)
                .background(Color.gray.opacity(0.05))
                .cornerRadius(4)
            }
        }
    }
}

// MARK: - Format & Quality Section
struct FormatQualitySection: View {
    @ObservedObject var viewModel: ConvertViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Format & Quality", systemImage: "slider.horizontal.3")
                .font(.headline)

            Picker("Output Format", selection: $viewModel.settings.format) {
                ForEach(Constants.ConvertFormat.allCases) { format in
                    Text(format.rawValue.uppercased()).tag(format.rawValue)
                }
            }
            .pickerStyle(.segmented)

            Picker("Quality Preset", selection: $viewModel.settings.quality) {
                ForEach(Constants.ConvertQuality.allCases) { quality in
                    Text(quality.displayName).tag(quality.rawValue)
                }
            }
            .pickerStyle(.menu)

            Text(Constants.ConvertQuality(rawValue: viewModel.settings.quality)?.description ?? "")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Output Location Section
struct OutputLocationSection: View {
    @ObservedObject var viewModel: ConvertViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Output Location", systemImage: "folder")
                .font(.headline)

            HStack {
                Text(viewModel.outputLocationChoice.displayName)
                    .foregroundStyle(.secondary)

                Spacer()

                if case .sameFolder = viewModel.outputLocationChoice {
                    Button("Choose Folder...") {
                        viewModel.selectOutputFolder()
                    }
                    .buttonStyle(.bordered)
                } else {
                    Button("Use Same Folder") {
                        viewModel.outputLocationChoice = .sameFolder
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(12)
            .background(Color.gray.opacity(0.05))
            .cornerRadius(6)
        }
    }
}

// MARK: - Convert Options Section
struct ConvertOptionsSection: View {
    @ObservedObject var viewModel: ConvertViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Options", systemImage: "gearshape")
                .font(.headline)

            Toggle("Overwrite existing files", isOn: $viewModel.settings.overwrite)

            if viewModel.fileCount > 1 {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Concurrency: \(viewModel.settings.concurrency) threads")
                        .font(.subheadline)

                    Slider(
                        value: Binding(
                            get: { Double(viewModel.settings.concurrency) },
                            set: { viewModel.setConcurrency(Int($0)) }
                        ),
                        in: 1...Double(ProcessInfo.processInfo.activeProcessorCount),
                        step: 1
                    )

                    Text("Higher concurrency = faster batch conversion but more CPU usage")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
