//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct JSONFormatterCommands: Commands {
    @FocusedValue(\.jsonFormatterMenuActions) private var menuActions

    var body: some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Open...") {
                menuActions?.open()
            }
            .keyboardShortcut("o")
            .disabled(menuActions == nil)
        }

        CommandGroup(replacing: .saveItem) {
            Button("Export Formatted JSON...") {
                menuActions?.exportFormatted()
            }
            .keyboardShortcut("s", modifiers: [.command, .shift])
            .disabled(menuActions?.canExportFormatted != true)
        }
    }
}
