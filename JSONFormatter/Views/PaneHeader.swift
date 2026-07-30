//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct PaneHeader: View {
    let title: String
    let subtitle: String
    let status: PaneStatus

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.title3.weight(.semibold))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            StatusPill(status: status)
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    PaneHeader(title: "Formatted Result", subtitle: "Read-only output", status: .waiting)
        .padding()
}
