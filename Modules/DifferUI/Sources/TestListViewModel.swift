import SwiftUI
import Combine
import DifferCore

/// ViewModel for the test list
@MainActor
final class TestListViewModel: ObservableObject {
    @Published var tests: [SnapshotTest] = []
    @Published var filteredTests: [SnapshotTest] = []
    @Published var selectedTest: SnapshotTest?
    @Published var searchText = ""
    @Published var statusFilter: TestStatus?
    
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Setup search filtering
        Publishers.CombineLatest($searchText, $statusFilter)
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .sink { [weak self] searchText, statusFilter in
                self?.filterTests(searchText: searchText, statusFilter: statusFilter)
            }
            .store(in: &cancellables)
    }
    
    /// Load tests from a test run
    func loadTests(from testRun: TestRun) {
        tests = testRun.testResults
        filterTests(searchText: searchText, statusFilter: statusFilter)
    }
    
    /// Filter tests based on search and status
    private func filterTests(searchText: String, statusFilter: TestStatus?) {
        var filtered = tests
        
        // Filter by search text
        if !searchText.isEmpty {
            filtered = filtered.filter { test in
                test.testName.localizedCaseInsensitiveContains(searchText) ||
                test.testTarget.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter by status
        if let status = statusFilter {
            filtered = filtered.filter { $0.status == status }
        }
        
        filteredTests = filtered
    }
    
    /// Select a test
    func selectTest(_ test: SnapshotTest) {
        selectedTest = test
    }
    
    /// Get count for a specific status
    func count(for status: TestStatus) -> Int {
        tests.filter { $0.status == status }.count
    }
}
