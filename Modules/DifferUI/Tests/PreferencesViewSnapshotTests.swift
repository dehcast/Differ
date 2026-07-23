import XCTest
import SnapshotTesting
import SwiftUI
@testable import DifferUI
import DifferCore

@MainActor
final class PreferencesViewSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NSAnimationContext.current.duration = 0
    }
    
    // MARK: - Default State
    
    func testDefaultState() {
        let view = PreferencesView()
            .frame(width: 600, height: 500)
        
        assertSnapshot(of: view, as: .image, named: "default-state")
    }
    
    // MARK: - Different Window Sizes
    
    func testCompactSize() {
        let view = PreferencesView()
            .frame(width: 500, height: 400)
        
        assertSnapshot(of: view, as: .image, named: "compact-size")
    }
    
    func testLargeSize() {
        let view = PreferencesView()
            .frame(width: 800, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "large-size")
    }
}
