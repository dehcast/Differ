import XCTest
@testable import DifferUI
import DifferCore

@MainActor
final class DiffViewModelTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInit() {
        let test = TestFixtures.failedTest
        let service = MockImageComparisonService()
        
        let viewModel = DiffViewModel(snapshotTest: test, imageComparisonService: service)
        
        XCTAssertEqual(viewModel.snapshotTest.id, test.id)
        XCTAssertNil(viewModel.referenceImage)
        XCTAssertNil(viewModel.currentImage)
        XCTAssertNil(viewModel.diffImage)
        XCTAssertNil(viewModel.diffResult)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.error)
    }
    
    // MARK: - Zoom
    
    func testZoomLevel_Default() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        XCTAssertEqual(viewModel.zoomLevel, 1.0)
    }
    
    func testZoomLevel_SetValue() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.zoomLevel = 2.0
        XCTAssertEqual(viewModel.zoomLevel, 2.0)
        
        viewModel.zoomLevel = 0.5
        XCTAssertEqual(viewModel.zoomLevel, 0.5)
        
        viewModel.zoomLevel = 3.5
        XCTAssertEqual(viewModel.zoomLevel, 3.5)
    }
    
    func testZoomIn() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.zoomLevel = 1.0
        viewModel.zoomIn()
        
        XCTAssertGreaterThan(viewModel.zoomLevel, 1.0)
    }
    
    func testZoomOut() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.zoomLevel = 2.0
        viewModel.zoomOut()
        
        XCTAssertLessThan(viewModel.zoomLevel, 2.0)
    }
    
    func testResetZoom() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.zoomLevel = 3.5
        viewModel.resetZoom()
        
        XCTAssertEqual(viewModel.zoomLevel, 1.0)
    }
    
    // MARK: - Overlay Mode
    
    func testOverlay_Default() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        XCTAssertFalse(viewModel.showOverlay)
        XCTAssertEqual(viewModel.overlayOpacity, 0.5)
    }
    
    func testOverlay_Toggle() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        XCTAssertFalse(viewModel.showOverlay)
        
        viewModel.toggleOverlay()
        XCTAssertTrue(viewModel.showOverlay)
        
        viewModel.toggleOverlay()
        XCTAssertFalse(viewModel.showOverlay)
    }
    
    func testOverlay_SetOpacity() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.overlayOpacity = 0.75
        XCTAssertEqual(viewModel.overlayOpacity, 0.75)
        
        viewModel.overlayOpacity = 0.1
        XCTAssertEqual(viewModel.overlayOpacity, 0.1)
        
        viewModel.overlayOpacity = 1.0
        XCTAssertEqual(viewModel.overlayOpacity, 1.0)
    }
    
    // MARK: - Loading State
    
    func testLoadImages_SetsLoadingState() async {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        XCTAssertFalse(viewModel.isLoading)
        
        // Note: In a real test, we'd await loadImages() but the current
        // implementation doesn't have real async work yet
        // This test will be updated when implementation is complete
    }
    
    func testErrorState() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        XCTAssertNil(viewModel.error)
        
        let error = NSError(domain: "TestError", code: 1)
        viewModel.error = error
        
        XCTAssertNotNil(viewModel.error)
    }
    
    // MARK: - Image Loading
    
    func testSetImages() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.diffImage = TestFixtures.diffImage
        
        XCTAssertNotNil(viewModel.referenceImage)
        XCTAssertNotNil(viewModel.currentImage)
        XCTAssertNotNil(viewModel.diffImage)
    }
    
    func testSetDiffResult() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        viewModel.diffResult = TestFixtures.sampleDiffResult
        
        XCTAssertNotNil(viewModel.diffResult)
        XCTAssertEqual(viewModel.diffResult?.pixelDifferenceCount, 1234)
    }
}

// MARK: - Mock Service

private class MockImageComparisonService: ImageComparisonService {
    func compare(reference: NSImage, current: NSImage, algorithm: DiffAlgorithm) async throws -> DiffResult {
        TestFixtures.sampleDiffResult
    }
    
    func generateDiffImage(reference: NSImage, current: NSImage) async throws -> NSImage {
        TestFixtures.diffImage
    }
}
