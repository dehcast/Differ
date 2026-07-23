import Foundation

/// Represents a git repository
public struct Repository: Identifiable, Codable {
    public let id: UUID
    public let path: URL
    public let name: String
    public var currentBranch: String?
    public var defaultBranch: String?
    
    // Snapshot configuration
    public var snapshotDirectories: [URL]
    public var frameworkType: SnapshotFramework?
    
    public init(
        id: UUID = UUID(),
        path: URL,
        name: String? = nil,
        currentBranch: String? = nil,
        defaultBranch: String? = nil,
        snapshotDirectories: [URL] = [],
        frameworkType: SnapshotFramework? = nil
    ) {
        self.id = id
        self.path = path
        self.name = name ?? path.lastPathComponent
        self.currentBranch = currentBranch
        self.defaultBranch = defaultBranch
        self.snapshotDirectories = snapshotDirectories
        self.frameworkType = frameworkType
    }
    
    /// Returns true if this is a valid git repository
    public var isValidGitRepo: Bool {
        let gitPath = path.appendingPathComponent(".git")
        return FileManager.default.fileExists(atPath: gitPath.path)
    }
}

/// Supported snapshot testing frameworks
public enum SnapshotFramework: String, Codable, CaseIterable {
    case fbSnapshotTestCase = "fb_snapshot_test_case"     // iOSSnapshotTestCase
    case snapshotTesting = "snapshot_testing"             // PointFree's SnapshotTesting
    case custom = "custom"                                // Custom setup
    
    var displayName: String {
        switch self {
        case .fbSnapshotTestCase: return "FBSnapshotTestCase"
        case .snapshotTesting: return "SnapshotTesting"
        case .custom: return "Custom"
        }
    }
    
    /// Default snapshot directory name for this framework
    var defaultDirectoryName: String {
        switch self {
        case .fbSnapshotTestCase:
            return "ReferenceImages"
        case .snapshotTesting:
            return "__Snapshots__"
        case .custom:
            return "Snapshots"
        }
    }
    
    /// Naming pattern for reference images
    var namingPattern: String {
        switch self {
        case .fbSnapshotTestCase:
            return "TestClass/testMethod_*.png"
        case .snapshotTesting:
            return "__Snapshots__/TestClass/testMethod.*.png"
        case .custom:
            return "*.png"
        }
    }
}

/// Represents a git commit
public struct GitCommit: Identifiable, Codable {
    public let id: String  // SHA
    public let message: String
    public let author: String
    public let date: Date
    public let shortSHA: String
    
    public init(id: String, message: String, author: String, date: Date) {
        self.id = id
        self.message = message
        self.author = author
        self.date = date
        self.shortSHA = String(id.prefix(7))
    }
}

/// Represents a file change in git
public struct GitFileChange: Identifiable, Codable {
    public let id: UUID
    public let filePath: String
    public let changeType: ChangeType
    public let additions: Int?
    public let deletions: Int?
    
    public init(
        id: UUID = UUID(),
        filePath: String,
        changeType: ChangeType,
        additions: Int? = nil,
        deletions: Int? = nil
    ) {
        self.id = id
        self.filePath = filePath
        self.changeType = changeType
        self.additions = additions
        self.deletions = deletions
    }
    
    public enum ChangeType: String, Codable {
        case added
        case modified
        case deleted
        case renamed
        
        var iconName: String {
            switch self {
            case .added: return "plus.circle.fill"
            case .modified: return "pencil.circle.fill"
            case .deleted: return "minus.circle.fill"
            case .renamed: return "arrow.right.circle.fill"
            }
        }
    }
}
