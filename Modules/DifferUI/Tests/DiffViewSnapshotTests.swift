import XCTest
import SnapshotTesting
import SwiftUI
@testable import DifferUI
import DifferCore

@MainActor
final class DiffViewSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Disable animations for consistent snapshots
        NSAnimationContext.current.duration = 0
    }
    
    // MARK: - Three Panel Layout
    
    func testThreePanelLayout_WithImages() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.diffImage = TestFixtures.diffImage
        viewModel.diffResult = TestFixtures.sampleDiffResult
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "three-panel-with-images")
    }
    
    func testThreePanelLayout_LoadingState() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.isLoading = true
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "three-panel-loading")
    }
    
    func testThreePanelLayout_ErrorState() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.error = NSError(domain: "TestError", code: 1, userInfo: [
            NSLocalizedDescriptionKey: "Failed to load images"
        ])
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "three-panel-error")
    }
    
    // MARK: - Zoom Levels
    
    func testZoomLevel_100Percent() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.diffImage = TestFixtures.diffImage
        viewModel.zoomLevel = 1.0
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "zoom-100")
    }
    
    func testZoomLevel_200Percent() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.diffImage = TestFixtures.diffImage
        viewModel.zoomLevel = 2.0
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "zoom-200")
    }
    
    func testZoomLevel_50Percent() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.diffImage = TestFixtures.diffImage
        viewModel.zoomLevel = 0.5
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "zoom-50")
    }
    
    // MARK: - Overlay Mode
    
    func testOverlayMode_Enabled() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.showOverlay = true
        viewModel.overlayOpacity = 0.5
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "overlay-enabled")
    }
    
    func testOverlayMode_HighOpacity() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.showOverlay = true
        viewModel.overlayOpacity = 0.9
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "overlay-high-opacity")
    }
    
    func testOverlayMode_LowOpacity() {
        let viewModel = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        viewModel.referenceImage = TestFixtures.referenceImage
        viewModel.currentImage = TestFixtures.currentImage
        viewModel.showOverlay = true
        viewModel.overlayOpacity = 0.1
        
        let view = DiffView(viewModel: viewModel)
            .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "overlay-low-opacity")
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
