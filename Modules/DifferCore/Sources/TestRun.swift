import Foundation

/// Represents a test execution run
public struct TestRun: Identifiable, Codable, Equatable, Sendable {
    public let id: UUID
    public let xcresultPath: URL?
    public let startDate: Date
    public var endDate: Date?
    public var testResults: [SnapshotTest]
    public var status: RunStatus
    
    // Execution details
    public let scheme: String?
    public let target: String?
    public let configuration: String?
    
    // Statistics
    public var totalTests: Int {
        testResults.count
    }
    
    public var passedTests: Int {
        testResults.filter { $0.status == .passed }.count
    }
    
    public var failedTests: Int {
        testResults.filter { $0.status == .failed }.count
    }
    
    public var duration: TimeInterval? {
        guard let end = endDate else { return nil }
        return end.timeIntervalSince(startDate)
    }
    
    public init(
        id: UUID = UUID(),
        xcresultPath: URL? = nil,
        startDate: Date = Date(),
        endDate: Date? = nil,
        testResults: [SnapshotTest] = [],
        status: RunStatus = .running,
        scheme: String? = nil,
        target: String? = nil,
        configuration: String? = nil
    ) {
        self.id = id
        self.xcresultPath = xcresultPath
        self.startDate = startDate
        self.endDate = endDate
        self.testResults = testResults
        self.status = status
        self.scheme = scheme
        self.target = target
        self.configuration = configuration
    }
    
    /// Mark this run as completed
    public mutating func complete(with results: [SnapshotTest]) {
        self.endDate = Date()
        self.testResults = results
        self.status = results.contains(where: { $0.status == .failed }) ? .completedWithFailures : .completed
    }
    
    /// Mark this run as failed
    public mutating func fail() {
        self.endDate = Date()
        self.status = .failed
    }
}

/// Status of a test run
public enum RunStatus: String, Codable, CaseIterable, Sendable {
    case running = "running"
    case completed = "completed"
    case completedWithFailures = "completed_with_failures"
    case failed = "failed"
    case cancelled = "cancelled"
    
    /// Whether the run has finished (domain logic, not presentation).
    public var isComplete: Bool {
        self != .running
    }
}
