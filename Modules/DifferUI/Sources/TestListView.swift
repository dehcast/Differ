import SwiftUI
import DifferCore

/// View displaying the list of tests
struct TestListView: View {
    @ObservedObject var viewModel: TestListViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            SearchBarView(searchText: $viewModel.searchText)
            
            // Status filter
            StatusFilterView(
                selectedStatus: $viewModel.statusFilter,
                statusCounts: [
                    .failed: viewModel.count(for: .failed),
                    .passed: viewModel.count(for: .passed),
                    .new: viewModel.count(for: .new),
                    .missing: viewModel.count(for: .missing)
                ]
            )
            
            Divider()
            
            // Test list
            if viewModel.isLoading {
                ProgressView("Loading tests...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.filteredTests.isEmpty {
                EmptyTestListView(searchText: viewModel.searchText)
            } else {
                List(viewModel.filteredTests, selection: $viewModel.selectedTest) { test in
                    TestRowView(test: test)
                        .tag(test)
                }
                .listStyle(.sidebar)
            }
        }
    }
}

/// Search bar for filtering tests
struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search tests", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button(
                    action: { searchText = "" },
                    label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                )
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

/// Status filter pills
struct StatusFilterView: View {
    @Binding var selectedStatus: TestStatus?
    let statusCounts: [TestStatus: Int]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All button
                FilterPill(
                    title: "All",
                    count: statusCounts.values.reduce(0, +),
                    isSelected: selectedStatus == nil,
                    color: .gray
                ) {
                    selectedStatus = nil
                }
                
                // Status-specific buttons
                ForEach(TestStatus.allCases.filter { $0 != .unknown }, id: \.self) { status in
                    if let count = statusCounts[status], count > 0 {
                        FilterPill(
                            title: status.displayName,
                            count: count,
                            isSelected: selectedStatus == status,
                            color: status.color
                        ) {
                            selectedStatus = status == selectedStatus ? nil : status
                        }
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
    }
}

/// Individual filter pill button
struct FilterPill: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                    .font(.caption)
                Text("\(count)")
                    .font(.caption.bold())
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isSelected ? color.opacity(0.2) : Color.clear)
            .foregroundColor(isSelected ? color : .secondary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(isSelected ? 1.0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

/// Row view for a single test
struct TestRowView: View {
    let test: SnapshotTest
    
    var body: some View {
        HStack {
            Image(systemName: test.status.iconName)
                .foregroundColor(test.status.color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(test.displayName)
                    .font(.body)
                
                Text(test.testClass)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let lastRun = test.lastRun {
                Text(lastRun, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for test list
struct EmptyTestListView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            if searchText.isEmpty {
                Text("No Tests")
                    .font(.headline)
                Text("Open an XCResult to see tests")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No Results")
                    .font(.headline)
                Text("No tests match '\(searchText)'")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    TestListView(viewModel: TestListViewModel())
        .frame(width: 300, height: 600)
}
