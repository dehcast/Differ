import Foundation
import AppKit
import DifferCore

/// Protocol for image comparison operations
public protocol ImageComparison: Sendable {
    /// Compare two images and return the difference result
    func compare(
        reference: NSImage,
        current: NSImage,
        algorithm: DiffAlgorithm
    ) async throws -> DiffResult
    
    /// Generate a visual diff image highlighting differences
    func generateDiffImage(
        reference: NSImage,
        current: NSImage,
        highlightColor: NSColor
    ) async throws -> sending NSImage
}

/// Service for comparing images and generating diffs
public final class ImageComparisonService: ImageComparison {
    
    public init() {}
    
    // MARK: - Public API
    
    public func compare(
        reference: NSImage,
        current: NSImage,
        algorithm: DiffAlgorithm = .pixelByPixel
    ) async throws -> DiffResult {
        let startTime = Date()
        
        // Validate dimensions
        guard let refRep = reference.representations.first,
              let curRep = current.representations.first else {
            throw ImageComparisonError.invalidImage
        }
        
        guard refRep.pixelsWide == curRep.pixelsWide &&
              refRep.pixelsHigh == curRep.pixelsHigh else {
            throw ImageComparisonError.dimensionMismatch
        }
        
        let dimensions = ImageDimensions(width: refRep.pixelsWide, height: refRep.pixelsHigh)
        
        // Perform comparison based on algorithm
        let metrics = try await performComparison(
            reference: reference,
            current: current,
            algorithm: algorithm
        )
        
        let computationTime = Date().timeIntervalSince(startTime)
        
        return DiffResult(
            pixelDifferences: metrics.pixelDiff,
            percentDifference: metrics.percentDiff,
            perceptualDifference: metrics.perceptualDiff,
            dimensions: dimensions,
            computationTime: computationTime,
            algorithm: algorithm
        )
    }
    
    public func generateDiffImage(
        reference: NSImage,
        current: NSImage,
        highlightColor: NSColor = .systemRed
    ) async throws -> sending NSImage {
        // TODO: Implement diff image generation
        // This will be implemented in Phase 1.2 (implement-pixel-diff task)
        
        // Placeholder: return a fresh, empty image sized to match the input.
        // A freshly constructed value is in its own isolation region, so it can
        // be returned as `sending` across the actor boundary to the caller.
        return NSImage(size: current.size)
    }
    
    // MARK: - Private Methods
    
    /// Result of an image comparison operation
    private struct ComparisonMetrics {
        let pixelDiff: Int
        let percentDiff: Double
        let perceptualDiff: Double?
    }
    
    private func performComparison(
        reference: NSImage,
        current: NSImage,
        algorithm: DiffAlgorithm
    ) async throws -> ComparisonMetrics {
        switch algorithm {
        case .pixelByPixel:
            return try await pixelByPixelComparison(reference: reference, current: current)
        case .perceptual:
            return try await perceptualComparison(reference: reference, current: current)
        case .structural:
            return try await structuralComparison(reference: reference, current: current)
        case .combined:
            return try await combinedComparison(reference: reference, current: current)
        }
    }
    
    private func pixelByPixelComparison(
        reference: NSImage,
        current: NSImage
    ) async throws -> ComparisonMetrics {
        // TODO: Implement pixel-by-pixel comparison
        // This will be implemented in Phase 1.2 (implement-pixel-diff task)
        
        // Placeholder implementation
        return ComparisonMetrics(pixelDiff: 0, percentDiff: 0.0, perceptualDiff: nil)
    }
    
    private func perceptualComparison(
        reference: NSImage,
        current: NSImage
    ) async throws -> ComparisonMetrics {
        // TODO: Implement perceptual (CIEDE2000) comparison
        // This will be implemented in Phase 1.2 (implement-perceptual-diff task)
        
        // Placeholder implementation
        return ComparisonMetrics(pixelDiff: 0, percentDiff: 0.0, perceptualDiff: 0.0)
    }
    
    private func structuralComparison(
        reference: NSImage,
        current: NSImage
    ) async throws -> ComparisonMetrics {
        // TODO: Implement SSIM-based structural comparison
        // This is a future enhancement
        
        // Placeholder implementation
        return ComparisonMetrics(pixelDiff: 0, percentDiff: 0.0, perceptualDiff: 0.0)
    }
    
    private func combinedComparison(
        reference: NSImage,
        current: NSImage
    ) async throws -> ComparisonMetrics {
        // TODO: Implement combined algorithm approach
        // This is a future enhancement
        
        // Placeholder implementation
        return ComparisonMetrics(pixelDiff: 0, percentDiff: 0.0, perceptualDiff: 0.0)
    }
}

// MARK: - Errors

public enum ImageComparisonError: LocalizedError {
    case invalidImage
    case dimensionMismatch
    case comparisonFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidImage:
            return "One or both images are invalid"
        case .dimensionMismatch:
            return "Image dimensions do not match"
        case .comparisonFailed(let reason):
            return "Comparison failed: \(reason)"
        }
    }
}
