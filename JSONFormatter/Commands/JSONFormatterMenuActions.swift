//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct JSONFormatterMenuActions {
    let open: @MainActor () -> Void
    let exportFormatted: @MainActor () -> Void
    let canExportFormatted: Bool
}

extension FocusedValues {
    @Entry var jsonFormatterMenuActions: JSONFormatterMenuActions?
}
