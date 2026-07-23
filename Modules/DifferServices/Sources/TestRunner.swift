import Foundation
import DifferCore

/// Protocol for running tests
public protocol TestExecution: Sendable {
    /// Execute specific tests and return the result
    func runTests(
        tests: [SnapshotTest],
        scheme: String,
        configuration: String?
    ) async throws -> TestRun
    
    /// Cancel a running test execution
    func cancelExecution() async
}

/// Service for running xcodebuild tests
public actor TestRunner: TestExecution {
    
    // MARK: - Configuration
    
    public struct Configuration: Sendable {
        public var xcodebuildPath: String
        public var derivedDataPath: URL?
        
        public init(
            xcodebuildPath: String = "/usr/bin/xcodebuild",
            derivedDataPath: URL? = nil
        ) {
            self.xcodebuildPath = xcodebuildPath
            self.derivedDataPath = derivedDataPath
        }
    }
    
    private let configuration: Configuration
    private var currentProcess: Process?
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Public API
    
    public func runTests(
        tests: [SnapshotTest],
        scheme: String,
        configuration: String? = nil
    ) async throws -> TestRun {
        // TODO: Implement test execution
        // This will be implemented in Phase 2 (build-test-runner, implement-test-execution tasks)
        
        let testRun = TestRun(
            startDate: Date(),
            status: .running,
            scheme: scheme,
            configuration: configuration
        )
        
        // Build the xcodebuild command that a real implementation would run.
        // xcodebuild test -scheme <scheme> -only-testing <test1> -only-testing <test2> ...
        let testSelectors = tests.map { test in
            "\(test.testTarget)/\(test.testName)"
        }
        let arguments = buildXcodebuildCommand(
            scheme: scheme,
            testSelectors: testSelectors,
            configuration: configuration
        )
        _ = try await executeXcodebuild(arguments: arguments)
        
        return testRun
    }
    
    public func cancelExecution() {
        // TODO: Implement cancellation
        currentProcess?.terminate()
        currentProcess = nil
    }
    
    // MARK: - Private Methods
    
    private func buildXcodebuildCommand(
        scheme: String,
        testSelectors: [String],
        configuration: String?
    ) -> [String] {
        var arguments = ["test", "-scheme", scheme]
        
        if let config = configuration {
            arguments += ["-configuration", config]
        }
        
        if let derivedData = self.configuration.derivedDataPath {
            arguments += ["-derivedDataPath", derivedData.path]
        }
        
        // Add test selectors
        for selector in testSelectors {
            arguments += ["-only-testing", selector]
        }
        
        // Disable parallel testing for more reliable results
        arguments += ["-parallel-testing-enabled", "NO"]
        
        return arguments
    }
    
    private func executeXcodebuild(arguments: [String]) async throws -> String {
        // TODO: Implement xcodebuild execution using Process
        // This will be implemented in Phase 2
        
        return ""
    }
}

// MARK: - Errors

public enum TestRunnerError: LocalizedError {
    case xcodebuildNotFound
    case executionFailed(String)
    case schemeNotFound(String)
    case invalidTestSelector(String)
    
    public var errorDescription: String? {
        switch self {
        case .xcodebuildNotFound:
            return "xcodebuild not found. Make sure Xcode Command Line Tools are installed."
        case .executionFailed(let message):
            return "Test execution failed: \(message)"
        case .schemeNotFound(let scheme):
            return "Scheme not found: \(scheme)"
        case .invalidTestSelector(let selector):
            return "Invalid test selector: \(selector)"
        }
    }
}
