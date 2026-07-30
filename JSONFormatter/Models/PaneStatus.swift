//
//----------------------------------------------
// Original project: JSONFormatter
//----------------------------------------------
// Copyright © 2026 CreaTECH Solutions (Stewart Lynch). All rights reserved.

import SwiftUI

enum PaneStatus {
    case ready
    case waiting
    case valid
    case error

    var title: String {
        switch self {
        case .ready:
            "Ready"
        case .waiting:
            "Waiting"
        case .valid:
            "Valid"
        case .error:
            "Error"
        }
    }

    var systemImage: String {
        switch self {
        case .ready, .waiting:
            "circle"
        case .valid:
            "checkmark.circle.fill"
        case .error:
            "xmark.circle.fill"
        }
    }

    var foregroundStyle: AnyShapeStyle {
        switch self {
        case .ready, .waiting:
            AnyShapeStyle(.secondary)
        case .valid:
            AnyShapeStyle(.green)
        case .error:
            AnyShapeStyle(.red)
        }
    }

    var backgroundStyle: AnyShapeStyle {
        switch self {
        case .ready, .waiting:
            AnyShapeStyle(.quaternary)
        case .valid:
            AnyShapeStyle(.green.opacity(0.12))
        case .error:
            AnyShapeStyle(.red.opacity(0.12))
        }
    }

    var borderStyle: AnyShapeStyle {
        switch self {
        case .ready, .waiting:
            AnyShapeStyle(.separator)
        case .valid:
            AnyShapeStyle(.green.opacity(0.35))
        case .error:
            AnyShapeStyle(.red.opacity(0.35))
        }
    }

    var accessibilityLabel: String {
        "Status: \(title)"
    }
}
