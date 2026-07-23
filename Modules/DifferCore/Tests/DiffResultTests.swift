import XCTest
@testable import DifferCore

final class DiffResultTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInit_WithAllProperties() {
        let result = DiffResult(
            pixelDifferences: 1500,
            percentDifference: 15.5,
            perceptualDifference: 8.2,
            width: 375, height: 667,
            algorithm: .pixelByPixel,
            computationTime: 0.042
        )
        
        XCTAssertEqual(result.pixelDifferences, 1500)
        XCTAssertEqual(result.percentDifference, 15.5, accuracy: 0.01)
        XCTAssertEqual(result.perceptualDifference, 8.2, accuracy: 0.01)
        XCTAssertEqual(result.dimensions.width, 375)
        XCTAssertEqual(result.dimensions.height, 667)
        XCTAssertEqual(result.algorithm, .pixelByPixel)
        XCTAssertEqual(result.computationTime, 0.042, accuracy: 0.001)
    }
    
    // MARK: - Percentage Calculation
    
    func testPercentageCalculation_SmallDifference() {
        let totalPixels = 375 * 667 // 250,125 pixels
        let differentPixels = 100
        let percentage = Double(differentPixels) / Double(totalPixels) * 100
        
        let result = DiffResult(
            pixelDifferences: differentPixels,
            percentDifference: percentage,
            perceptualDifference: 0.5,
            width: 375, height: 667,
            algorithm: .pixelByPixel,
            computationTime: 0.01
        )
        
        XCTAssertEqual(result.percentDifference, 0.04, accuracy: 0.01)
    }
    
    func testPercentageCalculation_LargeDifference() {
        let totalPixels = 1000 * 1000 // 1,000,000 pixels
        let differentPixels = 500_000
        let percentage = Double(differentPixels) / Double(totalPixels) * 100
        
        let result = DiffResult(
            pixelDifferences: differentPixels,
            percentDifference: percentage,
            perceptualDifference: 50.0,
            width: 1000, height: 1000,
            algorithm: .pixelByPixel,
            computationTime: 0.15
        )
        
        XCTAssertEqual(result.percentDifference, 50.0, accuracy: 0.01)
    }
    
    func testPercentageCalculation_NoDifference() {
        let result = DiffResult(
            pixelDifferences: 0,
            percentDifference: 0.0,
            perceptualDifference: 0.0,
            width: 500, height: 500,
            algorithm: .pixelByPixel,
            computationTime: 0.005
        )
        
        XCTAssertEqual(result.pixelDifferences, 0)
        XCTAssertEqual(result.percentDifference, 0.0)
        XCTAssertEqual(result.perceptualDifference, 0.0)
    }
    
    // MARK: - Algorithm Types
    
    func testAlgorithm_PixelByPixel() {
        let result = DiffResult(
            pixelDifferences: 100,
            percentDifference: 1.0,
            perceptualDifference: 0.5,
            width: 100, height: 100,
            algorithm: .pixelByPixel,
            computationTime: 0.01
        )
        
        XCTAssertEqual(result.algorithm, .pixelByPixel)
    }
    
    func testAlgorithm_Perceptual() {
        let result = DiffResult(
            pixelDifferences: 100,
            percentDifference: 1.0,
            perceptualDifference: 2.5,
            width: 100, height: 100,
            algorithm: .perceptual,
            computationTime: 0.05
        )
        
        XCTAssertEqual(result.algorithm, .perceptual)
    }
    
    func testAlgorithm_StructuralSimilarity() {
        let result = DiffResult(
            pixelDifferences: 100,
            percentDifference: 1.0,
            perceptualDifference: 1.8,
            width: 100, height: 100,
            algorithm: .structuralSimilarity,
            computationTime: 0.08
        )
        
        XCTAssertEqual(result.algorithm, .structuralSimilarity)
    }
    
    // MARK: - Performance Metrics
    
    func testComputationTime_Fast() {
        let result = DiffResult(
            pixelDifferences: 10,
            percentDifference: 0.1,
            perceptualDifference: 0.05,
            width: 100, height: 100,
            algorithm: .pixelByPixel,
            computationTime: 0.001
        )
        
        XCTAssertLessThan(result.computationTime, 0.01, "Computation should be very fast for small images")
    }
    
    func testComputationTime_Slow() {
        let result = DiffResult(
            pixelDifferences: 100_000,
            percentDifference: 10.0,
            perceptualDifference: 5.0,
            width: 2000, height: 2000,
            algorithm: .perceptual,
            computationTime: 1.5
        )
        
        XCTAssertGreaterThan(result.computationTime, 1.0, "Computation should be slower for large images with perceptual algorithm")
    }
    
    // MARK: - Codable
    
    func testCodable_EncodeDecode() throws {
        let original = DiffResult(
            pixelDifferences: 2500,
            percentDifference: 25.0,
            perceptualDifference: 12.5,
            width: 500, height: 500,
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
