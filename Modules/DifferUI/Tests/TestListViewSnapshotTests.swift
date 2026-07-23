import XCTest
import SnapshotTesting
import SwiftUI
@testable import DifferUI
import DifferCore

@MainActor
final class TestListViewSnapshotTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        NSAnimationContext.current.duration = 0
    }
    
    // MARK: - Basic States
    
    func testEmptyState() {
        let viewModel = TestListViewModel(tests: TestFixtures.emptyTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "empty-state")
    }
    
    func testFullList_MixedStatuses() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "full-list-mixed")
    }
    
    func testFullList_FailedOnly() {
        let viewModel = TestListViewModel(tests: TestFixtures.failedTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "full-list-failed-only")
    }
    
    // MARK: - Search & Filters
    
    func testSearchBar_Active() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.searchText = "Login"
        
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "search-active")
    }
    
    func testFilters_FailedSelected() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .failed
        
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "filter-failed")
    }
    
    func testFilters_PassedSelected() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .passed
        
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "filter-passed")
    }
    
    func testFilters_NewSelected() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .new
        
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "filter-new")
    }
    
    // MARK: - Selection States
    
    func testSelectedRow() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedTest = TestFixtures.failedTest
        
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "selected-row")
    }
    
    // MARK: - Different Heights
    
    func testCompactHeight() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 300)
        
        assertSnapshot(of: view, as: .image, named: "compact-height")
    }
    
    func testTallHeight() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 400, height: 900)
        
        assertSnapshot(of: view, as: .image, named: "tall-height")
    }
    
    // MARK: - Different Widths
    
    func testNarrowWidth() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 250, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "narrow-width")
    }
    
    func testWideWidth() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        let view = TestListView(viewModel: viewModel)
            .frame(width: 600, height: 600)
        
        assertSnapshot(of: view, as: .image, named: "wide-width")
    }
}
