//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct ErrorLocationSnippetView: View {
    let snippet: String
    let column: Int?

    private let contextCharacterCount = 36

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Error location")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)

            ScrollView(.horizontal) {
                VStack(alignment: .leading, spacing: 4) {
                    highlightedSnippet
                        .textSelection(.enabled)
                        .fixedSize(horizontal: true, vertical: false)

                    if let markerLine {
                        Text(markerLine)
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: true, vertical: false)
                            .accessibilityLabel("Error marker at column \(column ?? 1)")

                        Text(markerLabelLine)
                            .font(.caption.monospaced())
                            .foregroundStyle(.red)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .font(.system(.body, design: .monospaced))
                .padding(12)
            }
            .scrollIndicators(.visible)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(.red)
                    .frame(width: 3)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var highlightedSnippet: Text {
        var attributedString = AttributedString(errorExcerpt)

        if let markerOffset,
           markerOffset < errorExcerpt.endIndex,
           let attributedRange = Range(markerOffset..<errorExcerpt.index(after: markerOffset), in: attributedString) {
            attributedString[attributedRange].foregroundColor = .white
            attributedString[attributedRange].backgroundColor = .red
        }

        return Text(attributedString)
    }

    private var errorExcerpt: String {
        guard let column else { return snippet }

        let characterIndex = errorCharacterIndex(for: column)
        let startIndex = max(0, characterIndex - contextCharacterCount)
        let endIndex = min(snippet.count, max(characterIndex, characterIndex + contextCharacterCount))
        let lowerBound = snippet.index(snippet.startIndex, offsetBy: startIndex)
        let upperBound = snippet.index(snippet.startIndex, offsetBy: endIndex)
        let prefix = startIndex > 0 ? "..." : ""
        let suffix = endIndex < snippet.count ? "..." : ""
        let excerptBody = String(snippet[lowerBound..<upperBound])

        return prefix + excerptBody + suffix
    }

    private var markerOffset: String.Index? {
        guard let column else { return nil }

        let characterIndex = errorCharacterIndex(for: column)
        let startIndex = max(0, characterIndex - contextCharacterCount)
        let displayOffset = characterIndex - startIndex + (startIndex > 0 ? 3 : 0)
        guard displayOffset <= errorExcerpt.count else { return nil }

        return errorExcerpt.index(errorExcerpt.startIndex, offsetBy: displayOffset)
    }

    private var markerLine: String? {
        guard let markerOffset else { return nil }

        let offset = errorExcerpt.distance(from: errorExcerpt.startIndex, to: markerOffset)
        return String(repeating: " ", count: offset) + "^"
    }

    private var markerLabelLine: String {
        guard let markerOffset else { return "Expected near here" }

        let offset = errorExcerpt.distance(from: errorExcerpt.startIndex, to: markerOffset)
        return String(repeating: " ", count: offset) + "Expected near here"
    }

    private func errorCharacterIndex(for column: Int) -> Int {
        max(0, min(column - 1, snippet.count))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        ErrorLocationSnippetView(
            snippet: "{\"name\":\"Broken JSON\"\"items\":[1,2,3],\"enabled\":true,\"details\":{\"owner\":\"Stewart\",\"count\":5}}",
            column: 22
        )

        ErrorLocationSnippetView(
            snippet: "{\"name\":\"Broken JSON\",\"items\":[1,2,3],\"enabled\":true,\"details\":{\"owner\":\"Stewart\",\"count\":5}",
            column: 93
        )
    }
    .padding()
    .frame(width: 520)
}
