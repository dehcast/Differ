import Foundation

/// Image dimensions
public struct ImageDimensions: Codable, Hashable {
    public let width: Int
    public let height: Int
    
    public init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}

/// Represents the result of comparing two images
public struct DiffResult: Codable, Hashable {
    /// Number of pixels that are different
    public let pixelDifferences: Int
    
    /// Percentage difference (0.0 - 100.0)
    public let percentDifference: Double
    
    /// Path to the generated diff image (if saved)
    public var diffImagePath: URL?
    
    /// Perceptual difference score (0.0 - 1.0) using CIEDE2000 or similar
    public var perceptualDifference: Double?
    
    /// Image dimensions
    public let dimensions: ImageDimensions
    
    /// Time taken to compute the diff
    public let computationTime: TimeInterval
    
    /// Algorithm used for comparison
    public let algorithm: DiffAlgorithm
    
    public init(
        pixelDifferences: Int,
        percentDifference: Double,
        diffImagePath: URL? = nil,
        perceptualDifference: Double? = nil,
        dimensions: ImageDimensions,
        computationTime: TimeInterval,
        algorithm: DiffAlgorithm = .pixelByPixel
    ) {
        self.pixelDifferences = pixelDifferences
        self.percentDifference = percentDifference
        self.diffImagePath = diffImagePath
        self.perceptualDifference = perceptualDifference
        self.dimensions = dimensions
        self.computationTime = computationTime
        self.algorithm = algorithm
    }
    
    /// Convenience initializer with tuple dimensions (for backwards compatibility)
    public init(
        pixelDifferences: Int,
        percentDifference: Double,
        diffImagePath: URL? = nil,
        perceptualDifference: Double? = nil,
        width: Int,
        height: Int,
        computationTime: TimeInterval,
        algorithm: DiffAlgorithm = .pixelByPixel
    ) {
        self.init(
            pixelDifferences: pixelDifferences,
            percentDifference: percentDifference,
            diffImagePath: diffImagePath,
            perceptualDifference: perceptualDifference,
            dimensions: ImageDimensions(width: width, height: height),
            computationTime: computationTime,
            algorithm: algorithm
        )
    }
    
    /// Returns true if images are identical (within tolerance)
    public func areIdentical(tolerance: Double = 0.01) -> Bool {
        percentDifference < tolerance
    }
    
    /// Returns a human-readable description of the difference
    public var description: String {
        if areIdentical() {
            return "Images are identical"
        }
        return String(format: "%.2f%% different (%d pixels)", percentDifference, pixelDifferences)
    }
    
}

/// Algorithm used for image comparison
public enum DiffAlgorithm: String, Codable, CaseIterable {
    case pixelByPixel = "pixel_by_pixel"
    case perceptual = "perceptual"      // CIEDE2000
    case structural = "structural"      // SSIM-based
    case combined = "combined"          // Multiple algorithms
    
    public var displayName: String {
        switch self {
        case .pixelByPixel: return "Pixel-by-Pixel"
        case .perceptual: return "Perceptual (CIEDE2000)"
        case .structural: return "Structural (SSIM)"
        case .combined: return "Combined"
        }
    }
}
