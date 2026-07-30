//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import Foundation

enum JSONFormattingResult: Equatable, Sendable {
    case idle
    case valid(formatted: String)
    case invalid(JSONFormattingError)

    var formattedOutput: String? {
        guard case let .valid(formatted) = self else { return nil }
        return formatted
    }
}
