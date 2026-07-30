//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct LoadingOverlayView: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)

            Text(message.isEmpty ? "Loading..." : message)
                .font(.headline)

            Text("Large files can take a moment to read and format.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(message.isEmpty ? "Loading JSON file" : message)
    }
}

#Preview {
    LoadingOverlayView(message: "Formatting JSON...")
        .frame(width: 420, height: 300)
        .padding()
}
