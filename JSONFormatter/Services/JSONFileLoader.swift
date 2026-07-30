//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import Foundation

struct JSONFileLoader: Sendable {
    nonisolated init() {}

    nonisolated func loadSource(from url: URL) async throws -> String {
        try await Task.detached(priority: .userInitiated) {
            let isSecurityScoped = url.startAccessingSecurityScopedResource()
            defer {
                if isSecurityScoped {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            return try String(contentsOf: url, encoding: .utf8)
        }.value
    }
}
