import Foundation

/// Represents the status of a snapshot test
public enum TestStatus: String, Codable, CaseIterable {
    case passed
    case failed
    case new              // No reference exists
    case missing       // Reference exists but no current
    case unknown
    
    public var displayName: String {
        switch self {
        case .passed: return "Passed"
        case .failed: return "Failed"
        case .new: return "New Snapshot"
        case .missing: return "Missing"
        case .unknown: return "Unknown"
        }
    }
    
    public var iconName: String {
        switch self {
        case .passed: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .new: return "plus.circle.fill"
        case .missing: return "questionmark.circle.fill"
        case .unknown: return "circle"
        }
    }
}

/// Represents a single snapshot test with its associated images
public struct SnapshotTest: Identifiable, Codable, Hashable {
    public let id: UUID
    public let testName: String              // e.g., "MyViewControllerTests.testAppearance"
    public let testTarget: String            // e.g., "MyAppTests"
    public let testClass: String             // e.g., "MyViewControllerTests"
    public let testMethod: String            // e.g., "testAppearance"
    
    public var referenceImagePath: URL?
    public var failedImagePath: URL?
    public var diffImagePath: URL?
    
    public var status: TestStatus
    public var failureReason: String?
    public var lastRun: Date?
    
    // Metadata
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(
        id: UUID = UUID(),
        testName: String,
        testTarget: String,
        referenceImagePath: URL? = nil,
        failedImagePath: URL? = nil,
        diffImagePath: URL? = nil,
        status: TestStatus = .unknown,
        failureReason: String? = nil,
        lastRun: Date? = nil
    ) {
        self.id = id
        self.testName = testName
        self.testTarget = testTarget
        
        // Parse test class and method from testName
        let components = testName.split(separator: ".", maxSplits: 1)
        self.testClass = components.first.map(String.init) ?? testName
        self.testMethod = components.count > 1 ? String(components[1]) : testName
        
        self.referenceImagePath = referenceImagePath
        self.failedImagePath = failedImagePath
        self.diffImagePath = diffImagePath
        self.status = status
        self.failureReason = failureReason
        self.lastRun = lastRun
        
        let now = Date()
        self.createdAt = now
        self.updatedAt = now
    }
    
    /// Returns true if this test has images to compare
    public var hasComparableImages: Bool {
        referenceImagePath != nil && failedImagePath != nil
    }
    
    /// Returns the display name for the test (method name only)
    public var displayName: String {
        testMethod
    }
}

// MARK: - Convenience Methods
extension SnapshotTest {
    /// Update the status and set updatedAt
    public mutating func updateStatus(_ newStatus: TestStatus) {
        self.status = newStatus
        self.updatedAt = Date()
    }
    
    /// Mark this test as run
    public mutating func markAsRun() {
        self.lastRun = Date()
        self.updatedAt = Date()
    }
}
