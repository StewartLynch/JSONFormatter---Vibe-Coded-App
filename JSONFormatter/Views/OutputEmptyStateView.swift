//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct OutputEmptyStateView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "curlybraces")
                .font(.system(size: 42, weight: .light))
                .foregroundStyle(.secondary)

            Text("Formatted JSON appears here")
                .font(.headline)

            Text("Validation runs automatically when source JSON is entered, opened, or dropped.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 360)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    OutputEmptyStateView()
        .frame(width: 500, height: 420)
}
