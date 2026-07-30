//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI
#if os(macOS)
import AppKit
#endif

struct FormattedResultPane: View {
    let result: JSONFormattingResult

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header

            outputContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.separator, lineWidth: 1)
                }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(.background)
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            PaneHeader(
                title: "Formatted Result",
                subtitle: "Read-only output",
                status: outputStatus
            )

            if let formattedOutput = result.formattedOutput {
                Button("Copy", systemImage: "doc.on.doc") {
                    copyButtonTapped(formattedOutput)
                }
                .accessibilityLabel("Copy formatted JSON")
            }
        }
    }

    private var outputStatus: PaneStatus {
        switch result {
        case .idle:
            .waiting
        case .valid:
            .valid
        case .invalid:
            .error
        }
    }

    @ViewBuilder
    private var outputContent: some View {
        switch result {
        case .idle:
            OutputEmptyStateView()
        case let .valid(formatted):
            ScrollView([.horizontal, .vertical]) {
                Text(formatted)
                    .font(.system(.body, design: .monospaced))
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .padding(16)
            }
            .accessibilityLabel("Formatted JSON output. Text selection and copy are enabled.")
        case let .invalid(error):
            ErrorStateView(error: error)
        }
    }

    private func copyButtonTapped(_ formattedOutput: String) {
        #if os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(formattedOutput, forType: .string)
        #endif
    }
}

#Preview {
    FormattedResultPane(result: .valid(formatted: "{\n    \"name\" : \"Test\"\n}\n"))
        .frame(width: 500, height: 420)
}
