import Foundation
import AppKit
import DifferCore

/// Protocol for image comparison operations
public protocol ImageComparison {
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
    ) async throws -> NSImage
}

/// Service for comparing images and generating diffs
public final class ImageComparisonService: ImageComparison {
    
    // MARK: - Configuration
    
    public struct Configuration {
        public var highlightColor: NSColor
        public var tolerance: Double
        public var useGPU: Bool
        
        public init(
            highlightColor: NSColor = .systemRed,
            tolerance: Double = 0.01,
            useGPU: Bool = true
        ) {
            self.highlightColor = highlightColor
            self.tolerance = tolerance
            self.useGPU = useGPU
        }
    }
    
    private let configuration: Configuration
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
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
    ) async throws -> NSImage {
        // Use the reference image as the canvas. The current image is drawn into a
        // reference-sized bitmap so mismatched dimensions are handled gracefully by
        // resampling rather than throwing (this method is used purely for display).
        guard let refRep = reference.representations.first else {
            throw ImageComparisonError.invalidImage
        }
        let width = refRep.pixelsWide
        let height = refRep.pixelsHigh

        guard width > 0, height > 0 else {
            throw ImageComparisonError.invalidImage
        }

        let refBytes = try rgbaBytes(from: reference, width: width, height: height)
        let curBytes = try rgbaBytes(from: current, width: width, height: height)

        // Resolve the highlight color into sRGB 0-255 components.
        let color = highlightColor.usingColorSpace(.sRGB) ?? highlightColor
        let hr = UInt8((color.redComponent * 255.0).rounded())
        let hg = UInt8((color.greenComponent * 255.0).rounded())
        let hb = UInt8((color.blueComponent * 255.0).rounded())
        let overlayAlpha = 0.55

        let threshold = configuration.tolerance * 255.0
        var out = refBytes

        for pixel in 0..<(width * height) {
            let i = pixel * 4
            let maxDelta = channelDelta(refBytes, curBytes, at: i)
            if Double(maxDelta) > threshold {
                out[i] = blend(refBytes[i], hr, overlayAlpha)
                out[i + 1] = blend(refBytes[i + 1], hg, overlayAlpha)
                out[i + 2] = blend(refBytes[i + 2], hb, overlayAlpha)
                out[i + 3] = 255
            }
        }

        guard let image = makeImage(from: out, width: width, height: height) else {
            throw ImageComparisonError.comparisonFailed("Could not build diff image")
        }
        return image
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
        // `compare` already guarantees matching dimensions before we get here, but we
        // re-derive them defensively so this method is safe if called directly.
        guard let refRep = reference.representations.first,
              let curRep = current.representations.first else {
            throw ImageComparisonError.invalidImage
        }

        guard refRep.pixelsWide == curRep.pixelsWide,
              refRep.pixelsHigh == curRep.pixelsHigh else {
            throw ImageComparisonError.dimensionMismatch
        }

        let width = refRep.pixelsWide
        let height = refRep.pixelsHigh
        let totalPixels = width * height

        guard totalPixels > 0 else {
            return ComparisonMetrics(pixelDiff: 0, percentDiff: 0.0, perceptualDiff: nil)
        }

        let refBytes = try rgbaBytes(from: reference, width: width, height: height)
        let curBytes = try rgbaBytes(from: current, width: width, height: height)

        // Per-channel tolerance expressed in 0-255 space. Two pixels are considered
        // different when their largest channel delta (incl. alpha) exceeds the tolerance.
        let threshold = configuration.tolerance * 255.0

        var diffCount = 0
        for pixel in 0..<totalPixels {
            let i = pixel * 4
            if Double(channelDelta(refBytes, curBytes, at: i)) > threshold {
                diffCount += 1
            }
        }

        let percent = (Double(diffCount) / Double(totalPixels)) * 100.0
        return ComparisonMetrics(pixelDiff: diffCount, percentDiff: percent, perceptualDiff: nil)
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

    // MARK: - Pixel Buffer Helpers

    /// Largest absolute per-channel difference (R, G, B, A) between two RGBA pixels.
    private func channelDelta(_ lhs: [UInt8], _ rhs: [UInt8], at index: Int) -> Int {
        let dr = abs(Int(lhs[index]) - Int(rhs[index]))
        let dg = abs(Int(lhs[index + 1]) - Int(rhs[index + 1]))
        let db = abs(Int(lhs[index + 2]) - Int(rhs[index + 2]))
        let da = abs(Int(lhs[index + 3]) - Int(rhs[index + 3]))
        return max(dr, max(dg, max(db, da)))
    }

    /// Alpha-blend a highlight channel value over a base channel value.
    private func blend(_ base: UInt8, _ overlay: UInt8, _ alpha: Double) -> UInt8 {
        let value = Double(base) * (1.0 - alpha) + Double(overlay) * alpha
        return UInt8(max(0.0, min(255.0, value.rounded())))
    }

    /// Extracts the underlying `CGImage` for an `NSImage`.
    private func cgImage(from image: NSImage) -> CGImage? {
        var rect = CGRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }

    /// Renders an `NSImage` into a normalized, non-premultiplied-free RGBA8 buffer of the
    /// requested size. Normalizing both inputs into the same colorspace and geometry makes
    /// the byte-for-byte comparison meaningful regardless of the source representation.
    private func rgbaBytes(from image: NSImage, width: Int, height: Int) throws -> [UInt8] {
        guard let cgImage = cgImage(from: image) else {
            throw ImageComparisonError.invalidImage
        }

        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue

        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else {
            throw ImageComparisonError.comparisonFailed("Could not create bitmap context")
        }

        context.interpolationQuality = .high
        context.clear(CGRect(x: 0, y: 0, width: width, height: height))
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        guard let data = context.data else {
            throw ImageComparisonError.comparisonFailed("Could not read bitmap data")
        }

        let pointer = data.bindMemory(to: UInt8.self, capacity: height * bytesPerRow)
        return Array(UnsafeBufferPointer(start: pointer, count: height * bytesPerRow))
    }

    /// Builds an `NSImage` from a normalized RGBA8 buffer.
    private func makeImage(from bytes: [UInt8], width: Int, height: Int) -> NSImage? {
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

        guard let provider = CGDataProvider(data: Data(bytes) as CFData) else {
            return nil
        }

        guard let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: 8,
            bitsPerPixel: 32,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo,
            provider: provider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent
        ) else {
            return nil
        }

        return NSImage(cgImage: cgImage, size: NSSize(width: width, height: height))
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
