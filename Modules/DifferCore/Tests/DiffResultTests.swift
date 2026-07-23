import XCTest
@testable import DifferCore

final class DiffResultTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInit_WithAllProperties() {
        let result = DiffResult(
            pixelDifferenceCount: 1500,
            pixelDifferencePercentage: 15.5,
            perceptualDifference: 8.2,
            imageDimensions: CGSize(width: 375, height: 667),
            algorithm: .pixelByPixel,
            computationTime: 0.042
        )
        
        XCTAssertEqual(result.pixelDifferenceCount, 1500)
        XCTAssertEqual(result.pixelDifferencePercentage, 15.5, accuracy: 0.01)
        XCTAssertEqual(result.perceptualDifference, 8.2, accuracy: 0.01)
        XCTAssertEqual(result.imageDimensions.width, 375)
        XCTAssertEqual(result.imageDimensions.height, 667)
        XCTAssertEqual(result.algorithm, .pixelByPixel)
        XCTAssertEqual(result.computationTime, 0.042, accuracy: 0.001)
    }
    
    // MARK: - Percentage Calculation
    
    func testPercentageCalculation_SmallDifference() {
        let totalPixels = 375 * 667 // 250,125 pixels
        let differentPixels = 100
        let percentage = Double(differentPixels) / Double(totalPixels) * 100
        
        let result = DiffResult(
            pixelDifferenceCount: differentPixels,
            pixelDifferencePercentage: percentage,
            perceptualDifference: 0.5,
            imageDimensions: CGSize(width: 375, height: 667),
            algorithm: .pixelByPixel,
            computationTime: 0.01
        )
        
        XCTAssertEqual(result.pixelDifferencePercentage, 0.04, accuracy: 0.01)
    }
    
    func testPercentageCalculation_LargeDifference() {
        let totalPixels = 1000 * 1000 // 1,000,000 pixels
        let differentPixels = 500_000
        let percentage = Double(differentPixels) / Double(totalPixels) * 100
        
        let result = DiffResult(
            pixelDifferenceCount: differentPixels,
            pixelDifferencePercentage: percentage,
            perceptualDifference: 50.0,
            imageDimensions: CGSize(width: 1000, height: 1000),
            algorithm: .pixelByPixel,
            computationTime: 0.15
        )
        
        XCTAssertEqual(result.pixelDifferencePercentage, 50.0, accuracy: 0.01)
    }
    
    func testPercentageCalculation_NoDifference() {
        let result = DiffResult(
            pixelDifferenceCount: 0,
            pixelDifferencePercentage: 0.0,
            perceptualDifference: 0.0,
            imageDimensions: CGSize(width: 500, height: 500),
            algorithm: .pixelByPixel,
            computationTime: 0.005
        )
        
        XCTAssertEqual(result.pixelDifferenceCount, 0)
        XCTAssertEqual(result.pixelDifferencePercentage, 0.0)
        XCTAssertEqual(result.perceptualDifference, 0.0)
    }
    
    // MARK: - Algorithm Types
    
    func testAlgorithm_PixelByPixel() {
        let result = DiffResult(
            pixelDifferenceCount: 100,
            pixelDifferencePercentage: 1.0,
            perceptualDifference: 0.5,
            imageDimensions: CGSize(width: 100, height: 100),
            algorithm: .pixelByPixel,
            computationTime: 0.01
        )
        
        XCTAssertEqual(result.algorithm, .pixelByPixel)
    }
    
    func testAlgorithm_Perceptual() {
        let result = DiffResult(
            pixelDifferenceCount: 100,
            pixelDifferencePercentage: 1.0,
            perceptualDifference: 2.5,
            imageDimensions: CGSize(width: 100, height: 100),
            algorithm: .perceptual,
            computationTime: 0.05
        )
        
        XCTAssertEqual(result.algorithm, .perceptual)
    }
    
    func testAlgorithm_StructuralSimilarity() {
        let result = DiffResult(
            pixelDifferenceCount: 100,
            pixelDifferencePercentage: 1.0,
            perceptualDifference: 1.8,
            imageDimensions: CGSize(width: 100, height: 100),
            algorithm: .structuralSimilarity,
            computationTime: 0.08
        )
        
        XCTAssertEqual(result.algorithm, .structuralSimilarity)
    }
    
    // MARK: - Performance Metrics
    
    func testComputationTime_Fast() {
        let result = DiffResult(
            pixelDifferenceCount: 10,
            pixelDifferencePercentage: 0.1,
            perceptualDifference: 0.05,
            imageDimensions: CGSize(width: 100, height: 100),
            algorithm: .pixelByPixel,
            computationTime: 0.001
        )
        
        XCTAssertLessThan(result.computationTime, 0.01, "Computation should be very fast for small images")
    }
    
    func testComputationTime_Slow() {
        let result = DiffResult(
            pixelDifferenceCount: 100_000,
            pixelDifferencePercentage: 10.0,
            perceptualDifference: 5.0,
            imageDimensions: CGSize(width: 2000, height: 2000),
            algorithm: .perceptual,
            computationTime: 1.5
        )
        
        XCTAssertGreaterThan(result.computationTime, 1.0, "Computation should be slower for large images with perceptual algorithm")
    }
    
    // MARK: - Codable
    
    func testCodable_EncodeDecode() throws {
        let original = DiffResult(
            pixelDifferenceCount: 2500,
            pixelDifferencePercentage: 25.0,
            perceptualDifference: 12.5,
            imageDimensions: CGSize(width: 500, height: 500),
            algorithm: .structuralSimilarity,
            computationTime: 0.125
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(DiffResult.self, from: data)
        
        XCTAssertEqual(decoded.pixelDifferenceCount, original.pixelDifferenceCount)
        XCTAssertEqual(decoded.pixelDifferencePercentage, original.pixelDifferencePercentage, accuracy: 0.01)
        XCTAssertEqual(decoded.perceptualDifference, original.perceptualDifference, accuracy: 0.01)
        XCTAssertEqual(decoded.imageDimensions.width, original.imageDimensions.width)
        XCTAssertEqual(decoded.imageDimensions.height, original.imageDimensions.height)
        XCTAssertEqual(decoded.algorithm, original.algorithm)
        XCTAssertEqual(decoded.computationTime, original.computationTime, accuracy: 0.001)
    }
}
