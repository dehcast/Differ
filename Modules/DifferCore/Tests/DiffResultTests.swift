import XCTest
@testable import DifferCore

final class DiffResultTests: XCTestCase {
    
    func testInit_WithAllProperties() {
        let result = DiffResult(
            pixelDifferences: 1000,
            percentDifference: 0.5,
            diffImagePath: URL(fileURLWithPath: "/path/to/diff.png"),
            perceptualDifference: 2.5,
            width: 375, height: 667,
            computationTime: 0.042,
            algorithm: .pixelByPixel
        )
        
        XCTAssertEqual(result.pixelDifferences, 1000)
        XCTAssertEqual(result.percentDifference, 0.5)
        XCTAssertEqual(result.perceptualDifference, 2.5)
        XCTAssertEqual(result.dimensions.width, 375)
        XCTAssertEqual(result.dimensions.height, 667)
        XCTAssertEqual(result.algorithm, .pixelByPixel)
        XCTAssertEqual(result.computationTime, 0.042, accuracy: 0.001)
    }
    
    func testInit_WithOptionalProperties() {
        let result = DiffResult(
            pixelDifferences: 0,
            percentDifference: 0.0,
            width: 200, height: 200,
            computationTime: 0.01
        )
        
        XCTAssertNil(result.diffImagePath)
        XCTAssertNil(result.perceptualDifference)
        XCTAssertEqual(result.algorithm, .pixelByPixel) // default
    }
    
    func testAreIdentical_WithinTolerance() {
        let result = DiffResult(
            pixelDifferences: 50,
            percentDifference: 0.005,
            width: 375, height: 667,
            computationTime: 0.01,
            algorithm: .pixelByPixel
        )
        
        XCTAssertTrue(result.areIdentical())
    }
    
    func testAreIdentical_OutsideTolerance() {
        let result = DiffResult(
            pixelDifferences: 10000,
            percentDifference: 5.0,
            width: 1000, height: 1000,
            computationTime: 0.15,
            algorithm: .pixelByPixel
        )
        
        XCTAssertFalse(result.areIdentical())
    }
    
    func testAreIdentical_CustomTolerance() {
        let result = DiffResult(
            pixelDifferences: 2500,
            percentDifference: 1.0,
            width: 500, height: 500,
            computationTime: 0.005,
            algorithm: .pixelByPixel
        )
        
        XCTAssertTrue(result.areIdentical(tolerance: 2.0))
        XCTAssertFalse(result.areIdentical(tolerance: 0.5))
    }
    
    func testDescription_Identical() {
        let result = DiffResult(
            pixelDifferences: 0,
            percentDifference: 0.0,
            width: 100, height: 100,
            computationTime: 0.01,
            algorithm: .pixelByPixel
        )
        
        XCTAssertEqual(result.description, "Images are identical")
    }
    
    func testDescription_Different() {
        let result = DiffResult(
            pixelDifferences: 500,
            percentDifference: 2.5,
            width: 100, height: 100,
            computationTime: 0.01,
            algorithm: .pixelByPixel
        )
        
        XCTAssertTrue(result.description.contains("2.50% different"))
        XCTAssertTrue(result.description.contains("500 pixels"))
    }
    
    func testAlgorithm_PixelByPixel() {
        let result = DiffResult(
            pixelDifferences: 100,
            percentDifference: 1.0,
            width: 100, height: 100,
            computationTime: 0.01,
            algorithm: .pixelByPixel
        )
        
        XCTAssertEqual(result.algorithm, .pixelByPixel)
    }
    
    func testAlgorithm_Perceptual() {
        let result = DiffResult(
            pixelDifferences: 50,
            percentDifference: 0.5,
            perceptualDifference: 1.8,
            width: 100, height: 100,
            computationTime: 0.05,
            algorithm: .perceptual
        )
        
        XCTAssertEqual(result.algorithm, .perceptual)
    }
    
    func testAlgorithm_Structural() {
        let result = DiffResult(
            pixelDifferences: 200,
            percentDifference: 2.0,
            perceptualDifference: 1.8,
            width: 100, height: 100,
            computationTime: 0.08,
            algorithm: .structural
        )
        
        XCTAssertEqual(result.algorithm, .structural)
    }
    
    func testPerceptualDifference() {
        let result = DiffResult(
            pixelDifferences: 100,
            percentDifference: 1.0,
            perceptualDifference: 3.2,
            width: 100, height: 100,
            computationTime: 0.001,
            algorithm: .pixelByPixel
        )
        
        XCTAssertEqual(result.perceptualDifference, 3.2)
    }
    
    func testComputationTime() {
        let result = DiffResult(
            pixelDifferences: 1000000,
            percentDifference: 25.0,
            width: 2000, height: 2000,
            computationTime: 1.5,
            algorithm: .perceptual
        )
        
        XCTAssertEqual(result.computationTime, 1.5, accuracy: 0.001)
    }
    
    func testDimensions() {
        let result = DiffResult(
            pixelDifferences: 62500,
            percentDifference: 25.0,
            perceptualDifference: 12.5,
            width: 500, height: 500,
            computationTime: 0.125,
            algorithm: .structural
        )
        
        XCTAssertEqual(result.dimensions.width, 500)
        XCTAssertEqual(result.dimensions.height, 500)
    }
}
