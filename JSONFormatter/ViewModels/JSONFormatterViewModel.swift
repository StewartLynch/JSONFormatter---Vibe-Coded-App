//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import Foundation
import Observation

@MainActor
@Observable
final class JSONFormatterViewModel {
    var sourceJSON = "" {
        didSet {
            guard !isUpdatingSourceProgrammatically else { return }
            sanitizeSourceJSON()

            if sourceJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                sourceFileURL = nil
            }

            if loadFilePathInsertedByTextEditor(previousSource: oldValue) {
                return
            }

            scheduleValidation()
        }
    }

    private(set) var formattingResult: JSONFormattingResult = .idle
    private(set) var isLoadingFile = false
    private(set) var fileLoadingStatusMessage = ""
    var fileLoadingErrorMessage = ""
    var isShowingFileLoadingError = false

    private let formatter: JSONFormatterService
    private let sanitizer: JSONSourceSanitizer
    private let fileLoader: JSONFileLoader
    private var sourceFileURL: URL?
    private var pendingSourceFileURL: URL?
    private var validationTask: Task<Void, Never>?
    private var fileLoadingTask: Task<Void, Never>?
    private var isUpdatingSourceProgrammatically = false

    init(
        formatter: JSONFormatterService? = nil,
        sanitizer: JSONSourceSanitizer? = nil,
        fileLoader: JSONFileLoader? = nil
    ) {
        self.formatter = formatter ?? JSONFormatterService()
        self.sanitizer = sanitizer ?? JSONSourceSanitizer()
        self.fileLoader = fileLoader ?? JSONFileLoader()
    }

    var sourceStatus: PaneStatus {
        switch formattingResult {
        case .idle:
            .ready
        case .valid:
            .valid
        case .invalid:
            .error
        }
    }

    var formattedOutput: String? {
        formattingResult.formattedOutput
    }

    var canExportFormattedJSON: Bool {
        formattedOutput != nil && !isLoadingFile
    }

    var exportDefaultFilename: String {
        guard let sourceFileURL else { return "formatted.json" }

        let baseName = sourceFileURL.deletingPathExtension().lastPathComponent
        guard !baseName.isEmpty else { return "formatted.json" }

        return "\(baseName)-formatted.json"
    }

    func validateImmediately() {
        validationTask?.cancel()
        startValidation(for: sourceJSON, showsLoadingProgress: false)
    }

    func loadFile(from url: URL) {
        fileLoadingTask?.cancel()
        validationTask?.cancel()
        pendingSourceFileURL = url
        isLoadingFile = true
        fileLoadingStatusMessage = "Loading \(url.lastPathComponent)..."

        fileLoadingTask = Task {
            do {
                let source = try await fileLoader.loadSource(from: url)
                guard !Task.isCancelled else { return }

                replaceSourceWithLoadedFile(source)
            } catch {
                guard !Task.isCancelled else { return }

                pendingSourceFileURL = nil
                isLoadingFile = false
                fileLoadingStatusMessage = ""
                fileLoadingErrorMessage = "\(url.lastPathComponent) could not be loaded as UTF-8 text.\n\n\(error.localizedDescription)"
                isShowingFileLoadingError = true
            }
        }
    }

    func handleDroppedFiles(_ urls: [URL]) -> Bool {
        guard let url = urls.first else { return false }

        loadFile(from: url)
        return true
    }

    private func replaceSourceWithLoadedFile(_ source: String) {
        isLoadingFile = true
        fileLoadingStatusMessage = "Preparing source..."
        sourceFileURL = pendingSourceFileURL
        pendingSourceFileURL = nil
        setSourceProgrammatically(sanitizer.sanitize(source))
        startValidation(for: sourceJSON, showsLoadingProgress: true)
    }

    private func setSourceProgrammatically(_ source: String) {
        isUpdatingSourceProgrammatically = true
        sourceJSON = source
        isUpdatingSourceProgrammatically = false
    }

    private func sanitizeSourceJSON() {
        let sanitizedSource = sanitizer.sanitize(sourceJSON)
        guard sanitizedSource != sourceJSON else { return }

        setSourceProgrammatically(sanitizedSource)
    }

    private func loadFilePathInsertedByTextEditor(previousSource: String) -> Bool {
        guard let url = insertedFileURL(previousSource: previousSource, currentSource: sourceJSON) else {
            return false
        }

        setSourceProgrammatically(previousSource)
        validateImmediately()
        loadFile(from: url)
        return true
    }

    private func insertedFileURL(previousSource: String, currentSource: String) -> URL? {
        if let url = fileURL(fromPossiblePath: currentSource) {
            return url
        }

        guard currentSource.count > previousSource.count else { return nil }

        let commonPrefixLength = zip(previousSource, currentSource).prefix { $0 == $1 }.count
        let previousSuffix = previousSource.dropFirst(commonPrefixLength)
        let currentSuffix = currentSource.dropFirst(commonPrefixLength)
        let commonSuffixLength = zip(previousSuffix.reversed(), currentSuffix.reversed()).prefix { $0 == $1 }.count
        let insertedEndIndex = currentSuffix.index(currentSuffix.endIndex, offsetBy: -commonSuffixLength)
        let insertedText = String(currentSuffix[..<insertedEndIndex])

        return fileURL(fromPossiblePath: insertedText)
    }

    private func fileURL(fromPossiblePath text: String) -> URL? {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty, trimmedText.rangeOfCharacter(from: .newlines) == nil else {
            return nil
        }

        let url: URL?
        if trimmedText.hasPrefix("file://") {
            url = URL(string: trimmedText)
        } else if trimmedText.hasPrefix("/") || trimmedText.hasPrefix("~/") {
            url = URL(fileURLWithPath: NSString(string: trimmedText).expandingTildeInPath)
        } else {
            url = nil
        }

        guard let url, url.pathExtension.lowercased() == "json" else {
            return nil
        }

        var isDirectory: ObjCBool = false
        guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory), !isDirectory.boolValue else {
            return nil
        }

        return url
    }

    private func scheduleValidation() {
        let source = sourceJSON
        validationTask?.cancel()

        validationTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(180))
            } catch {
                return
            }

            startValidation(for: source, showsLoadingProgress: false)
        }
    }

    private func startValidation(for source: String, showsLoadingProgress: Bool) {
        validationTask?.cancel()

        if showsLoadingProgress {
            isLoadingFile = true
            fileLoadingStatusMessage = "Formatting JSON..."
        }

        let formatter = formatter
        validationTask = Task {
            let result = await Task.detached(priority: .userInitiated) {
                formatter.format(source)
            }.value

            guard !Task.isCancelled, sourceJSON == source else { return }

            formattingResult = result

            if showsLoadingProgress {
                isLoadingFile = false
                fileLoadingStatusMessage = ""
            }
        }
    }
}
