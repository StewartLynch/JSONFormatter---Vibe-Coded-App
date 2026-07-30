//
//----------------------------------------------
// Original project: JSONFormatter
//
// Follow me on Mastodon: https://iosdev.space/@StewartLynch
// Follow me on Threads: https://www.threads.net/@stewartlynch
// Follow me on Bluesky: https://bsky.app/profile/stewartlynch.bsky.social
// Follow me on X: https://x.com/StewartLynch
// Follow me on LinkedIn: https://linkedin.com/in/StewartLynch
// Email: slynch@createchsol.com
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var viewModel = JSONFormatterViewModel()
    @State private var isFileImporterPresented = false
    @State private var isFileExporterPresented = false
    @State private var exportErrorMessage = ""
    @State private var isShowingExportError = false

    var body: some View {
        @Bindable var viewModel = viewModel

        VStack(spacing: 0) {
            AppHeaderView()

            HSplitView {
                SourceJSONPane(
                    sourceJSON: $viewModel.sourceJSON,
                    status: viewModel.sourceStatus,
                    isLoadingFile: viewModel.isLoadingFile,
                    fileLoadingStatusMessage: viewModel.fileLoadingStatusMessage
                ) { urls in
                    viewModel.handleDroppedFiles(urls)
                }
                .frame(minWidth: 320)

                FormattedResultPane(result: viewModel.formattingResult)
                    .frame(minWidth: 320)
            }
        }
        .frame(minWidth: 760, minHeight: 480)
        .focusedSceneValue(\.jsonFormatterMenuActions, menuActions)
        .fileImporter(
            isPresented: $isFileImporterPresented,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImporterResult(result)
        }
        .fileExporter(
            isPresented: $isFileExporterPresented,
            document: exportDocument,
            contentType: .json,
            defaultFilename: viewModel.exportDefaultFilename
        ) { result in
            handleFileExporterResult(result)
        }
        .alert("File Could Not Be Opened", isPresented: $viewModel.isShowingFileLoadingError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.fileLoadingErrorMessage)
        }
        .alert("Export Failed", isPresented: $isShowingExportError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(exportErrorMessage)
        }
        .onAppear {
            viewModel.validateImmediately()
        }
    }

    private var exportDocument: FormattedJSONDocument? {
        guard let formattedOutput = viewModel.formattedOutput else { return nil }
        return FormattedJSONDocument(text: formattedOutput)
    }

    private var menuActions: JSONFormatterMenuActions {
        JSONFormatterMenuActions(
            open: openMenuItemSelected,
            exportFormatted: exportMenuItemSelected,
            canExportFormatted: viewModel.canExportFormattedJSON
        )
    }

    private func openMenuItemSelected() {
        isFileImporterPresented = true
    }

    private func exportMenuItemSelected() {
        isFileExporterPresented = true
    }

    private func handleFileImporterResult(_ result: Result<[URL], any Error>) {
        switch result {
        case let .success(urls):
            guard let url = urls.first else { return }
            viewModel.loadFile(from: url)
        case let .failure(error):
            viewModel.fileLoadingErrorMessage = error.localizedDescription
            viewModel.isShowingFileLoadingError = true
        }
    }

    private func handleFileExporterResult(_ result: Result<URL, any Error>) {
        if case let .failure(error) = result {
            exportErrorMessage = error.localizedDescription
            isShowingExportError = true
        }
    }
}

#Preview {
    ContentView()
}
