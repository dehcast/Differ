import Foundation
import DifferCore

/// Protocol for git operations
public protocol GitOperations: Sendable {
    /// Detect git repository at the given path
    func detectRepository(at path: URL) async throws -> Repository?
    
    /// Get current branch name
    func getCurrentBranch(in repository: Repository) async throws -> String
    
    /// Get modified files in the working directory
    func getModifiedFiles(in repository: Repository) async throws -> [GitFileChange]
    
    /// Get commit history for a specific file
    func getFileHistory(filePath: String, in repository: Repository, limit: Int) async throws -> [GitCommit]
    
    /// Compare files between two branches
    func compareFile(
        path: String,
        from sourceBranch: String,
        to targetBranch: String,
        in repository: Repository
    ) async throws -> GitFileChange?
}

/// Service for interacting with git repositories
public final class GitService: GitOperations {
    
    // MARK: - Configuration
    
    public struct Configuration: Sendable {
        public var gitPath: String
        
        public init(gitPath: String = "/usr/bin/git") {
            self.gitPath = gitPath
        }
    }
    
    private let configuration: Configuration
    
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Public API
    
    public func detectRepository(at path: URL) async throws -> Repository? {
        // TODO: Implement git repository detection
        // This will be implemented in Phase 3 (detect-git-repo task)
        
        // Walk up the directory tree looking for .git
        var currentPath = path
        while currentPath.path != "/" {
            let gitDir = currentPath.appendingPathComponent(".git")
            if FileManager.default.fileExists(atPath: gitDir.path) {
                return Repository(path: currentPath)
            }
            currentPath = currentPath.deletingLastPathComponent()
        }
        
        return nil
    }
    
    public func getCurrentBranch(in repository: Repository) async throws -> String {
        // TODO: Implement current branch detection
        // This will be implemented in Phase 3 (detect-git-repo task)
        
        let output = try await runGitCommand(
            ["rev-parse", "--abbrev-ref", "HEAD"],
            in: repository
        )
        return output.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    public func getModifiedFiles(in repository: Repository) async throws -> [GitFileChange] {
        // TODO: Implement modified files detection
        // This will be implemented in Phase 3 (parse-git-diff task)
        
        return []
    }
    
    public func getFileHistory(
        filePath: String,
        in repository: Repository,
        limit: Int = 20
    ) async throws -> [GitCommit] {
        // TODO: Implement file history retrieval
        // This will be implemented in Phase 3 (show-git-history task)
        
        return []
    }
    
    public func compareFile(
        path: String,
        from sourceBranch: String,
        to targetBranch: String,
        in repository: Repository
    ) async throws -> GitFileChange? {
        // TODO: Implement file comparison across branches
        // This will be implemented in Phase 3 (compare-across-branches task)
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func runGitCommand(_ arguments: [String], in repository: Repository) async throws -> String {
        // TODO: Implement git command execution using Process
        // This will be implemented in Phase 3
        
        return ""
    }
}

// MARK: - Errors

public enum GitError: LocalizedError {
    case notAGitRepository(URL)
    case commandFailed(String)
    case gitNotFound
    case invalidBranch(String)
    
    public var errorDescription: String? {
        switch self {
        case .notAGitRepository(let path):
            return "Not a git repository: \(path.path)"
        case .commandFailed(let message):
            return "Git command failed: \(message)"
        case .gitNotFound:
            return "git executable not found"
        case .invalidBranch(let branch):
            return "Invalid branch: \(branch)"
        }
    }
}
