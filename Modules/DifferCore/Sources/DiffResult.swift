import Foundation

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
    
    /// Image dimensions (width, height)
    public let dimensions: (width: Int, height: Int)
    
    /// Time taken to compute the diff
    public let computationTime: TimeInterval
    
    /// Algorithm used for comparison
    public let algorithm: DiffAlgorithm
    
    public init(
        pixelDifferences: Int,
        percentDifference: Double,
        diffImagePath: URL? = nil,
        perceptualDifference: Double? = nil,
        dimensions: (width: Int, height: Int),
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
    
    // Codable implementation for tuple
    enum CodingKeys: String, CodingKey {
        case pixelDifferences, percentDifference, diffImagePath
        case perceptualDifference, width, height, computationTime, algorithm
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pixelDifferences, forKey: .pixelDifferences)
        try container.encode(percentDifference, forKey: .percentDifference)
        try container.encodeIfPresent(diffImagePath, forKey: .diffImagePath)
        try container.encodeIfPresent(perceptualDifference, forKey: .perceptualDifference)
        try container.encode(dimensions.width, forKey: .width)
        try container.encode(dimensions.height, forKey: .height)
        try container.encode(computationTime, forKey: .computationTime)
        try container.encode(algorithm, forKey: .algorithm)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        pixelDifferences = try container.decode(Int.self, forKey: .pixelDifferences)
        percentDifference = try container.decode(Double.self, forKey: .percentDifference)
        diffImagePath = try container.decodeIfPresent(URL.self, forKey: .diffImagePath)
        perceptualDifference = try container.decodeIfPresent(Double.self, forKey: .perceptualDifference)
        let width = try container.decode(Int.self, forKey: .width)
        let height = try container.decode(Int.self, forKey: .height)
        dimensions = (width: width, height: height)
        computationTime = try container.decode(TimeInterval.self, forKey: .computationTime)
        algorithm = try container.decode(DiffAlgorithm.self, forKey: .algorithm)
    }
}

/// Algorithm used for image comparison
public enum DiffAlgorithm: String, Codable, CaseIterable {
    case pixelByPixel = "pixel_by_pixel"
    case perceptual = "perceptual"      // CIEDE2000
    case structural = "structural"      // SSIM-based
    case combined = "combined"          // Multiple algorithms
    
    var displayName: String {
        switch self {
        case .pixelByPixel: return "Pixel-by-Pixel"
        case .perceptual: return "Perceptual (CIEDE2000)"
        case .structural: return "Structural (SSIM)"
        case .combined: return "Combined"
        }
    }
}
