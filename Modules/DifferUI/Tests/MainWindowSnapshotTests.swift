import XCTest
import SnapshotTesting
import SwiftUI
@testable import DifferUI
import DifferCore

@MainActor
final class MainWindowSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NSAnimationContext.current.duration = 0
    }
    
    // MARK: - Full Window
    
    func testMainWindow_WithTestList() {
        let testListVM = TestListViewModel(tests: TestFixtures.allTests)
        testListVM.selectedTest = TestFixtures.failedTest
        
        let diffVM = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        diffVM.referenceImage = TestFixtures.referenceImage
        diffVM.currentImage = TestFixtures.currentImage
        diffVM.diffImage = TestFixtures.diffImage
        diffVM.diffResult = TestFixtures.sampleDiffResult
        
        let view = MainWindow(
            testListViewModel: testListVM,
            diffViewModel: diffVM
        )
        .frame(width: 1400, height: 900)
        
        assertSnapshot(of: view, as: .image, named: "main-window-with-test-list")
    }
    
    func testMainWindow_EmptyState() {
        let testListVM = TestListViewModel(tests: TestFixtures.emptyTests)
        let diffVM = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        
        let view = MainWindow(
            testListViewModel: testListVM,
            diffViewModel: diffVM
        )
        .frame(width: 1400, height: 900)
        
        assertSnapshot(of: view, as: .image, named: "main-window-empty")
    }
    
    func testMainWindow_NarrowSidebar() {
        let testListVM = TestListViewModel(tests: TestFixtures.allTests)
        let diffVM = DiffViewModel(
            snapshotTest: TestFixtures.failedTest,
            imageComparisonService: MockImageComparisonService()
        )
        diffVM.referenceImage = TestFixtures.referenceImage
        diffVM.currentImage = TestFixtures.currentImage
        diffVM.diffImage = TestFixtures.diffImage
        
        // Note: In real usage, sidebar width is controlled by user interaction
        // This tests the default narrow state
        let view = MainWindow(
            testListViewModel: testListVM,
            diffViewModel: diffVM
        )
        .frame(width: 1200, height: 800)
        
        assertSnapshot(of: view, as: .image, named: "main-window-narrow-sidebar")
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
