import SwiftUI
import DifferCore
import DifferServices
import DifferUI

@main
struct DifferApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            MainWindow()
                .environmentObject(appState)
                .frame(minWidth: 1200, minHeight: 800)
        }
        .commands {
            DifferCommands()
        }
        
        Settings {
            PreferencesView()
                .environmentObject(appState)
        }
    }
}

/// Global application state
final class AppState: ObservableObject {
    @Published var currentRepository: Repository?
    @Published var currentTestRun: TestRun?
    @Published var selectedTest: SnapshotTest?
    
    // Services
    let imageComparisonService: ImageComparisonService
    let xcresultParser: XCResultParser
    let gitService: GitService
    let testRunner: TestRunner
    
    init() {
        self.imageComparisonService = ImageComparisonService()
        self.xcresultParser = XCResultParser()
        self.gitService = GitService()
        self.testRunner = TestRunner()
    }
    
    /// Load a repository
    @MainActor
    func loadRepository(at url: URL) async {
        do {
            if let repo = try await gitService.detectRepository(at: url) {
                self.currentRepository = repo
            }
        } catch {
            print("Failed to load repository: \(error)")
        }
    }
    
    /// Open and parse an xcresult bundle
    @MainActor
    func openXCResult(at url: URL) async {
        do {
            let testRun = try await xcresultParser.parse(xcresultPath: url)
            self.currentTestRun = testRun
        } catch {
            print("Failed to parse XCResult: \(error)")
        }
    }
}
