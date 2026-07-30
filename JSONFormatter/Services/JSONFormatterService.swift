//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import Foundation

struct JSONFormatterService: Sendable {
    nonisolated init() {}

    nonisolated func format(_ source: String) -> JSONFormattingResult {
        let trimmedSource = source.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedSource.isEmpty else {
            return .idle
        }

        let data = Data(source.utf8)

        do {
            let object = try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
            let formattedData = try JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            )

            guard var formatted = String(data: formattedData, encoding: .utf8) else {
                return .invalid(
                    JSONFormattingError(
                        message: "The formatted JSON could not be encoded as UTF-8 text.",
                        line: nil,
                        column: nil,
                        snippet: nil
                    )
                )
            }

            if !formatted.hasSuffix("\n") {
                formatted.append("\n")
            }

            return .valid(formatted: formatted)
        } catch {
            return .invalid(makeFormattingError(from: error, source: source))
        }
    }

    private nonisolated func makeFormattingError(from error: Error, source: String) -> JSONFormattingError {
        let nsError = error as NSError
        let message = nsError.localizedDescription
        let location = parserLocation(from: nsError)
        let lineColumn = location.map { lineAndColumn(forUTF16Offset: $0, in: source) }
        let snippet = lineColumn.flatMap { sourceLine($0.line, in: source) }

        return JSONFormattingError(
            message: message,
            line: lineColumn?.line,
            column: lineColumn?.column,
            snippet: snippet
        )
    }

    private nonisolated func parserLocation(from error: NSError) -> Int? {
        let locationKeys = [
            "NSJSONSerializationErrorIndex",
            "NSDebugDescriptionErrorIndex",
            "NSParseErrorOffset"
        ]

        for key in locationKeys {
            if let offset = error.userInfo[key] as? Int {
                return offset
            }

            if let offset = error.userInfo[key] as? NSNumber {
                return offset.intValue
            }
        }

        if let debugDescription = error.userInfo[NSDebugDescriptionErrorKey] as? String {
            return parserLocation(fromDebugDescription: debugDescription)
        }

        return nil
    }

    private nonisolated func parserLocation(fromDebugDescription debugDescription: String) -> Int? {
        let patterns = [
            #"character\s+(\d+)"#,
            #"around character\s+(\d+)"#,
            #"at character\s+(\d+)"#
        ]

        for pattern in patterns {
            guard
                let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive]),
                let match = regex.firstMatch(
                    in: debugDescription,
                    range: NSRange(debugDescription.startIndex..., in: debugDescription)
                ),
                let range = Range(match.range(at: 1), in: debugDescription),
                let offset = Int(debugDescription[range])
            else {
                continue
            }

            return offset
        }

        return nil
    }

    private nonisolated func lineAndColumn(forUTF16Offset offset: Int, in source: String) -> (line: Int, column: Int) {
        let limitedOffset = max(0, min(offset, source.utf16.count))
        let targetIndex = String.Index(utf16Offset: limitedOffset, in: source)
        var line = 1
        var column = 1
        var currentIndex = source.startIndex

        while currentIndex < targetIndex {
            if source[currentIndex].isNewline {
                line += 1
                column = 1
            } else {
                column += 1
            }

            currentIndex = source.index(after: currentIndex)
        }

        return (line, column)
    }

    private nonisolated func sourceLine(_ requestedLine: Int, in source: String) -> String? {
        guard requestedLine > 0 else { return nil }

        let lines = source.split(separator: "\n", omittingEmptySubsequences: false)
        guard lines.indices.contains(requestedLine - 1) else { return nil }

        return String(lines[requestedLine - 1])
    }
}
