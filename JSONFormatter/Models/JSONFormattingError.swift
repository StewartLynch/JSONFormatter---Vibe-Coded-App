//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import Foundation

struct JSONFormattingError: Equatable, Sendable {
    let message: String
    let line: Int?
    let column: Int?
    let snippet: String?
}
