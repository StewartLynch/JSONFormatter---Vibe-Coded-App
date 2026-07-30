//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct ErrorStateView: View {
    let error: JSONFormattingError

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Label("Invalid JSON", systemImage: "exclamationmark.triangle.fill")
                    .font(.headline)
                    .foregroundStyle(.red)

                Text(error.message)
                    .font(.body)
                    .textSelection(.enabled)

                if let line = error.line, let column = error.column {
                    Text("Line \(line), Column \(column)")
                        .font(.subheadline.weight(.semibold))
                }

                if let snippet = error.snippet, !snippet.isEmpty {
                    ErrorLocationSnippetView(
                        snippet: snippet,
                        column: error.column
                    )
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .accessibilityLabel("JSON validation error")
    }
}

#Preview {
    ErrorStateView(
        error: JSONFormattingError(
            message: "The data could not be read because it is missing.",
            line: 1,
            column: 9,
            snippet: "{\"name\":"
        )
    )
    .frame(width: 500, height: 420)
}
