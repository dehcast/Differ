import Foundation
import AppKit
import DifferCore

/// Protocol for image comparison operations.
///
/// This is `@MainActor`-isolated because it operates on `NSImage`/`NSColor`,
/// which are AppKit main-thread-affine, non-`Sendable` types. Keeping the
/// service on the main actor lets `@MainActor` callers (e.g. view models) pass
/// images without crossing an actor boundary.
@MainActor
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
    ) async throws -> NSImage
}

/// Service for comparing images and generating diffs
@MainActor
public final class ImageComparisonService: ImageComparison {
    
    /// Per-channel color tolerance (0.0-1.0) below which pixels are considered equal.
    /// Expressed as a fraction of the 0-255 channel range.
    private let tolerance: Double

    /// - Parameter tolerance: Per-channel color tolerance (0.0-1.0). Two pixels are
    ///   treated as different when their largest channel delta exceeds this fraction of
    ///   the 0-255 range. Defaults to 0.01 (≈2.55 levels). Values are clamped to 0.0...1.0.
    public init(tolerance: Double = 0.01) {
        self.tolerance = min(max(tolerance, 0.0), 1.0)
    }

    // MARK: - Public API
    
    public func compare(
        reference: NSImage,
        current: NSImage,
        algorithm: DiffAlgorithm = .pixelByPixel
    ) async throws -> DiffResult {
        let startTime = Date()

        // Extract pixels at each image's authoritative CGImage dimensions (rather than
        // trusting `representations.first`, which may not be the representation that
        // `cgImage(forProposedRect:)` actually renders).
        let refBuffer = try pixelBuffer(from: reference)
        let curBuffer = try pixelBuffer(from: current)

        guard refBuffer.width == curBuffer.width,
              refBuffer.height == curBuffer.height else {
            throw ImageComparisonError.dimensionMismatch
        }

        let dimensions = ImageDimensions(width: refBuffer.width, height: refBuffer.height)

        // Perform comparison based on algorithm. Only pixel-by-pixel is implemented; the
        // other algorithms remain stubs and currently return placeholder metrics.
        let metrics: ComparisonMetrics
        switch algorithm {
        case .pixelByPixel:
            metrics = pixelByPixelMetrics(reference: refBuffer, current: curBuffer)
        case .perceptual:
            metrics = try await perceptualComparison(reference: reference, current: current)
        case .structural:
            metrics = try await structuralComparison(reference: reference, current: current)
        case .combined:
            metrics = try await combinedComparison(reference: reference, current: current)
        }

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
        // Use the reference image as the canvas, sized to its native CGImage dimensions.
        // The current image is resampled to that size so mismatched dimensions are handled
        // gracefully rather than throwing (this method is used purely for display).
        let refBuffer = try pixelBuffer(from: reference)
        let width = refBuffer.width
        let height = refBuffer.height

        let refBytes = refBuffer.bytes
        let curBytes = try rgbaBytes(from: current, width: width, height: height)

        // Resolve the highlight color into sRGB 0-255 components. Extended-sRGB or
        // pattern colors can produce components outside 0…1, so clamp before converting.
        let color = highlightColor.usingColorSpace(.sRGB) ?? highlightColor
        let hr = channelByte(color.redComponent)
        let hg = channelByte(color.greenComponent)
        let hb = channelByte(color.blueComponent)
        let overlayAlpha = 0.55

        let threshold = tolerance * 255.0
        var out = refBytes

        for pixel in 0..<(width * height) {
            let idx = pixel * 4
            let maxDelta = channelDelta(refBytes, curBytes, at: idx)
            if Double(maxDelta) > threshold {
                out[idx] = blend(refBytes[idx], hr, overlayAlpha)
                out[idx + 1] = blend(refBytes[idx + 1], hg, overlayAlpha)
                out[idx + 2] = blend(refBytes[idx + 2], hb, overlayAlpha)
                // Preserve the reference pixel's alpha (out is a copy of refBytes) so the
                // diff image keeps the original transparency instead of forcing opacity.
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
    
    /// Pixel-by-pixel comparison over two already-normalized, equally-sized buffers.
    private func pixelByPixelMetrics(
        reference: PixelBuffer,
        current: PixelBuffer
    ) -> ComparisonMetrics {
        let totalPixels = reference.width * reference.height
        guard totalPixels > 0 else {
            return ComparisonMetrics(pixelDiff: 0, percentDiff: 0.0, perceptualDiff: nil)
        }

        let refBytes = reference.bytes
        let curBytes = current.bytes

        // Per-channel tolerance expressed in 0-255 space. Two pixels are considered
        // different when their largest channel delta (incl. alpha) exceeds the tolerance.
        let threshold = tolerance * 255.0

        var diffCount = 0
        for pixel in 0..<totalPixels {
            let idx = pixel * 4
            if Double(channelDelta(refBytes, curBytes, at: idx)) > threshold {
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

    /// Converts a 0.0-1.0 color component to a 0-255 byte, clamping out-of-range values
    /// (extended-sRGB / pattern colors can report components below 0 or above 1).
    private func channelByte(_ component: CGFloat) -> UInt8 {
        let scaled = (Double(component) * 255.0).rounded()
        return UInt8(max(0.0, min(255.0, scaled)))
    }

    /// Extracts the underlying `CGImage` for an `NSImage`.
    private func cgImage(from image: NSImage) -> CGImage? {
        var rect = CGRect(origin: .zero, size: image.size)
        return image.cgImage(forProposedRect: &rect, context: nil, hints: nil)
    }

    /// Explicit sRGB color space used for all pixel normalization. Using a fixed,
    /// device-independent color space (rather than `CGColorSpaceCreateDeviceRGB()`) keeps
    /// comparisons deterministic across displays and machines.
    private static let workingColorSpace: CGColorSpace =
        CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()

    /// Bitmap layout pinned to memory byte order R, G, B, A. `premultipliedLast` alone
    /// only fixes alpha placement, not byte order — CoreGraphics may otherwise choose a
    /// native order (commonly BGRA), which would break the RGBA indexing in `channelDelta`
    /// and the highlight logic. `byteOrder32Big` with alpha-last guarantees R,G,B,A bytes.
    private static let rgbaBitmapInfo: UInt32 =
        CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

    /// A normalized RGBA8 pixel buffer with its own dimensions.
    private struct PixelBuffer {
        let bytes: [UInt8]
        let width: Int
        let height: Int
    }

    /// Extracts pixels at the image's authoritative CGImage dimensions. Using the
    /// extracted `CGImage`'s `width`/`height` (rather than `representations.first`) avoids
    /// wrong sizing or false `invalidImage` for multi-representation or vector images.
    private func pixelBuffer(from image: NSImage) throws -> PixelBuffer {
        guard let cgImage = cgImage(from: image) else {
            throw ImageComparisonError.invalidImage
        }

        let width = cgImage.width
        let height = cgImage.height

        // A zero-area image isn't a meaningful comparison; treat it as invalid rather
        // than silently reporting 0% difference (which would read as "identical").
        guard width > 0, height > 0 else {
            throw ImageComparisonError.invalidImage
        }

        let bytes = try rasterize(cgImage, width: width, height: height)
        return PixelBuffer(bytes: bytes, width: width, height: height)
    }

    /// Renders an `NSImage` into a normalized RGBA8 pixel buffer of the requested size,
    /// resampling if the source dimensions differ. Used when a specific canvas size is
    /// required (e.g. drawing the current image onto the reference-sized diff canvas).
    private func rgbaBytes(from image: NSImage, width: Int, height: Int) throws -> [UInt8] {
        guard let cgImage = cgImage(from: image) else {
            throw ImageComparisonError.invalidImage
        }
        return try rasterize(cgImage, width: width, height: height)
    }

    /// Draws a `CGImage` into a normalized RGBA8 bitmap of the requested size. The buffer is
    /// 8 bits per channel, RGBA byte order with premultiplied alpha, in an explicit sRGB
    /// color space. Normalizing both inputs into the same pixel format, color space, and
    /// geometry makes the byte-for-byte comparison meaningful and deterministic regardless
    /// of the source representation.
    private func rasterize(_ cgImage: CGImage, width: Int, height: Int) throws -> [UInt8] {
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        let colorSpace = Self.workingColorSpace
        let bitmapInfo = Self.rgbaBitmapInfo

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
        let colorSpace = Self.workingColorSpace
        let bitmapInfo = CGBitmapInfo(rawValue: Self.rgbaBitmapInfo)

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
