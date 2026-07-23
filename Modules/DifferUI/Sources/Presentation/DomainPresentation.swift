import SwiftUI
import DifferCore

// Presentation-layer mappings for domain types.
// These intentionally live in DifferUI so DifferCore stays free of AppKit/SwiftUI concerns.

extension TestStatus {
    /// Human-readable label for the status.
    var displayName: String {
        switch self {
        case .passed: return "Passed"
        case .failed: return "Failed"
        case .new: return "New Snapshot"
        case .missing: return "Missing"
        case .unknown: return "Unknown"
        }
    }

    /// SF Symbol used to represent the status.
    var iconName: String {
        switch self {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .new: return "plus.circle.fill"
        case .missing: return "questionmark.circle.fill"
        case .unknown: return "circle"
        }
    }

    /// Accent color used across the UI for the status.
    var color: Color {
        switch self {
        case .passed: return .green
        case .failed: return .red
        case .new: return .blue
        case .missing: return .orange
        case .unknown: return .gray
        }
    }
}

extension DiffAlgorithm {
    /// Human-readable label for the comparison algorithm.
    var displayName: String {
        switch self {
        case .pixelByPixel: return "Pixel-by-Pixel"
        case .perceptual: return "Perceptual (CIEDE2000)"
        case .structural: return "Structural (SSIM)"
        case .combined: return "Combined"
        }
    }
}
