import Foundation
import Combine
import DifferCore
import DifferServices

/// Application-wide state
public class AppState: ObservableObject {
    // MARK: - Published Properties
    
    /// Current repository
    @Published public var currentRepository: Repository?
    
    /// Current test run
    @Published public var currentTestRun: TestRun?
    
    /// Selected test for diff viewing
    @Published public var selectedTest: SnapshotTest?
    
    /// Whether a test is currently running
    @Published public var isRunningTests: Bool = false
    
    // MARK: - Services
    
    /// Image comparison service
    public let imageComparisonService: ImageComparisonService
    
    /// XCResult parser service
    public let xcresultParser: XCResultParser
    
    /// Git service
    public let gitService: GitService
    
    /// Test runner service
    public let testRunner: TestRunner
    
    // MARK: - Initialization
    
    public init(
        imageComparisonService: ImageComparisonService = ImageComparisonService(),
        xcresultParser: XCResultParser = XCResultParser(),
        gitService: GitService = GitService(),
        testRunner: TestRunner = TestRunner()
    ) {
        self.imageComparisonService = imageComparisonService
        self.xcresultParser = xcresultParser
        self.gitService = gitService
        self.testRunner = testRunner
    }
    
    // MARK: - Methods
    
    /// Load a repository
    @MainActor
    public func loadRepository(at url: URL) async {
        do {
            if let repo = try await gitService.detectRepository(at: url) {
                self.currentRepository = repo
            }
        } catch {
            // TODO: Replace with proper logging
            print("Failed to load repository: \(error)")
        }
    }
    
    /// Open and parse an xcresult bundle
    @MainActor
    public func openXCResult(at url: URL) async {
        do {
            let testRun = try await xcresultParser.parse(xcresultPath: url)
            self.currentTestRun = testRun
        } catch {
            // TODO: Replace with proper logging
            print("Failed to parse XCResult: \(error)")
        }
    }
}
