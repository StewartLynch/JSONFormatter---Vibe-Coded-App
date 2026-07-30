//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

struct SourceJSONPane: View {
    @Binding var sourceJSON: String
    let status: PaneStatus
    let isLoadingFile: Bool
    let fileLoadingStatusMessage: String
    let onDropFiles: ([URL]) -> Bool

    @State private var isDropTargeted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            ZStack(alignment: .topLeading) {
                TextEditor(text: $sourceJSON)
                    .font(.system(.body, design: .monospaced))
                    .autocorrectionDisabled()
                    .padding(12)
                    .background(.background)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(editorBorderStyle, lineWidth: isDropTargeted ? 2 : 1)
                    }
                    .accessibilityLabel("Source JSON editor")
                    .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                        handleDrop(providers)
                    }
                    .disabled(isLoadingFile)

                if sourceJSON.isEmpty && !isLoadingFile {
                    DropPlaceholderView()
                        .padding(20)
                        .allowsHitTesting(false)
                }

                if isLoadingFile {
                    LoadingOverlayView(message: fileLoadingStatusMessage)
                }
            }
            .contentShape(Rectangle())
            .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
                handleDrop(providers)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
    }

    private var editorBorderStyle: AnyShapeStyle {
        isDropTargeted ? AnyShapeStyle(.tint) : AnyShapeStyle(.separator)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Source JSON")
                    .font(.title3.weight(.semibold))

                Text("Editable input")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Clear", systemImage: "xmark.circle") {
                clearButtonTapped()
            }
            .disabled(sourceJSON.isEmpty || isLoadingFile)
            .accessibilityLabel("Clear source JSON")

            StatusPill(status: status)
        }
    }

    private func clearButtonTapped() {
        sourceJSON = ""
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        guard let provider = providers.first(where: { provider in
            provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier)
        }) else {
            return false
        }

        provider.loadItem(forTypeIdentifier: UTType.fileURL.identifier, options: nil) { item, _ in
            guard let url = fileURL(from: item) else { return }

            Task { @MainActor in
                _ = onDropFiles([url])
            }
        }

        return true
    }

    private func fileURL(from item: NSSecureCoding?) -> URL? {
        if let url = item as? URL {
            return url
        }

        if let data = item as? Data {
            return URL(dataRepresentation: data, relativeTo: nil)
        }

        if let string = item as? String {
            return URL(string: string)
        }

        return nil
    }
}

#Preview {
    SourceJSONPane(
        sourceJSON: .constant("{\"name\":\"Test\"}"),
        status: .valid,
        isLoadingFile: false,
        fileLoadingStatusMessage: ""
    ) { _ in
        true
    }
    .frame(width: 500, height: 420)
}
