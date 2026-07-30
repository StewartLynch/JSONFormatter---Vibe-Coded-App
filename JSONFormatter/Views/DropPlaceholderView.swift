//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

struct DropPlaceholderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Drop a JSON file here", systemImage: "doc")
                .font(.headline)

            Text("Or use Open to load a JSON file. The source stays editable before formatting.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: 440, alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(.separator, style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Drop a JSON file here. Use File, Open to load a JSON file.")
    }
}

#Preview {
    DropPlaceholderView()
        .padding()
}
