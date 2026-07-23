import XCTest
@testable import DifferUI
import DifferCore

@MainActor
final class TestListViewModelTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInit_WithTests() {
        let tests = [
            TestFixtures.passedTest,
            TestFixtures.failedTest
        ]
        
        let viewModel = TestListViewModel(tests: tests)
        
        XCTAssertEqual(viewModel.tests.count, 2)
        XCTAssertEqual(viewModel.searchText, "")
        XCTAssertEqual(viewModel.selectedFilter, .all)
        XCTAssertNil(viewModel.selectedTest)
    }
    
    func testInit_EmptyTests() {
        let viewModel = TestListViewModel(tests: [])
        
        XCTAssertEqual(viewModel.tests.count, 0)
        XCTAssertEqual(viewModel.filteredTests.count, 0)
    }
    
    // MARK: - Filtering
    
    func testFilteredTests_All() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .all
        
        XCTAssertEqual(viewModel.filteredTests.count, 5)
    }
    
    func testFilteredTests_Failed() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .failed
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 2)
        XCTAssertTrue(filteredTests.allSatisfy { $0.status == .failed })
    }
    
    func testFilteredTests_Passed() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .passed
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertTrue(filteredTests.allSatisfy { $0.status == .passed })
    }
    
    func testFilteredTests_New() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .new
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertTrue(filteredTests.allSatisfy { $0.status == .new })
    }
    
    func testFilteredTests_Missing() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .missing
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertTrue(filteredTests.allSatisfy { $0.status == .missing })
    }
    
    // MARK: - Search
    
    func testSearch_ByTestName() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.searchText = "Login"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertEqual(filteredTests.first?.testClass, "LoginViewTests")
    }
    
    func testSearch_ByTestClass() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.searchText = "Settings"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertEqual(filteredTests.first?.testClass, "SettingsViewTests")
    }
    
    func testSearch_CaseInsensitive() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.searchText = "PROFILE"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertEqual(filteredTests.first?.testClass, "ProfileViewTests")
    }
    
    func testSearch_NoResults() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.searchText = "NonExistentTest"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 0)
    }
    
    func testSearch_EmptyString() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.searchText = ""
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 5)
    }
    
    // MARK: - Combined Search and Filter
    
    func testSearchAndFilter_FailedWithText() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .failed
        viewModel.searchText = "Login"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertEqual(filteredTests.first?.status, .failed)
        XCTAssertEqual(filteredTests.first?.testClass, "LoginViewTests")
    }
    
    func testSearchAndFilter_PassedWithText() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .passed
        viewModel.searchText = "Profile"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 1)
        XCTAssertEqual(filteredTests.first?.status, .passed)
    }
    
    func testSearchAndFilter_NoMatches() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        viewModel.selectedFilter = .new
        viewModel.searchText = "Login"
        
        let filteredTests = viewModel.filteredTests
        XCTAssertEqual(filteredTests.count, 0)
    }
    
    // MARK: - Selection
    
    func testSelection_SelectTest() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        
        XCTAssertNil(viewModel.selectedTest)
        
        viewModel.selectedTest = TestFixtures.failedTest
        
        XCTAssertNotNil(viewModel.selectedTest)
        XCTAssertEqual(viewModel.selectedTest?.id, TestFixtures.failedTest.id)
    }
    
    func testSelection_ChangeSelection() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        
        viewModel.selectedTest = TestFixtures.failedTest
        XCTAssertEqual(viewModel.selectedTest?.id, TestFixtures.failedTest.id)
        
        viewModel.selectedTest = TestFixtures.passedTest
        XCTAssertEqual(viewModel.selectedTest?.id, TestFixtures.passedTest.id)
    }
    
    func testSelection_Deselect() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        
        viewModel.selectedTest = TestFixtures.failedTest
        XCTAssertNotNil(viewModel.selectedTest)
        
        viewModel.selectedTest = nil
        XCTAssertNil(viewModel.selectedTest)
    }
    
    // MARK: - Statistics
    
    func testStatistics() {
        let viewModel = TestListViewModel(tests: TestFixtures.allTests)
        
        XCTAssertEqual(viewModel.tests.filter { $0.status == .passed }.count, 1)
        XCTAssertEqual(viewModel.tests.filter { $0.status == .failed }.count, 2)
        XCTAssertEqual(viewModel.tests.filter { $0.status == .new }.count, 1)
        XCTAssertEqual(viewModel.tests.filter { $0.status == .missing }.count, 1)
    }
}
