//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct StatusPill: View {
    let status: PaneStatus

    var body: some View {
        Label(status.title, systemImage: status.systemImage)
            .font(.caption.weight(.medium))
            .foregroundStyle(status.foregroundStyle)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(status.backgroundStyle, in: Capsule())
            .overlay {
                Capsule()
                    .stroke(status.borderStyle, lineWidth: 1)
            }
            .accessibilityLabel(status.accessibilityLabel)
    }
}

#Preview {
    StatusPill(status: .valid)
        .padding()
}
