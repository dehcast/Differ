import SwiftUI
import DifferCore
import DifferServices

/// Main window of the Differ app
public struct MainWindow: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var testListViewModel = TestListViewModel()
    
    public init() {}
    
    public var body: some View {
        NavigationSplitView {
            // Sidebar: Test list
            TestListView(viewModel: testListViewModel)
                .navigationSplitViewColumnWidth(min: 250, ideal: 300, max: 400)
        } detail: {
            // Detail: Diff viewer
            if let test = testListViewModel.selectedTest {
                DiffView(
                    snapshotTest: test,
                    imageComparisonService: appState.imageComparisonService
                )
            } else {
                EmptyStateView()
            }
        }
        .toolbar {
            ToolbarView()
        }
        .onChange(of: appState.currentTestRun) { newTestRun in
            if let testRun = newTestRun {
                testListViewModel.loadTests(from: testRun)
            }
        }
    }
}

/// Empty state when no test is selected
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            Text("No Test Selected")
                .font(.title)
            
            Text("Select a test from the sidebar to view its diff")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Toolbar for the main window
struct ToolbarView: View {
    var body: some View {
        HStack {
            Button(
                action: {
                    // TODO: Open repository
                },
                label: {
                    Label("Open Repository", systemImage: "folder")
                }
            )
            
            Button(
                action: {
                    // TODO: Open XCResult
                },
                label: {
                    Label("Open XCResult", systemImage: "doc")
                }
            )
            
            Spacer()
            
            Button(
                action: {
                    // TODO: Run tests
                },
                label: {
                    Label("Run Tests", systemImage: "play.fill")
                }
            )
            .keyboardShortcut("r", modifiers: [.command])
        }
    }
}

#Preview {
    MainWindow()
        .environmentObject(AppState())
        .frame(width: 1200, height: 800)
}
