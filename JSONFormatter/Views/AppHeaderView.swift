//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct AppHeaderView: View {
    var body: some View {
        HStack(spacing: 12) {
            Label("JSONFormatter", systemImage: "curlybraces")
                .font(.title3.weight(.semibold))

            Spacer()

            Text("Validate and format JSON")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("JSONFormatter. Validate and format JSON.")
    }
}

#Preview {
    AppHeaderView()
}
