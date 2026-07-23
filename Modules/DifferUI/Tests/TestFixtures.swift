import Foundation
import DifferCore

/// Mock data for snapshot tests
enum TestFixtures {
    // MARK: - Mock Images
    
    static func mockImage(size: CGSize = CGSize(width: 200, height: 150), color: NSColor) -> NSImage {
        let image = NSImage(size: size)
        image.lockFocus()
        color.setFill()
        NSRect(origin: .zero, size: size).fill()
        image.unlockFocus()
        return image
    }
    
    static let referenceImage = mockImage(color: .systemBlue)
    static let currentImage = mockImage(color: .systemGreen)
    static let diffImage = mockImage(color: .systemRed)
    
    // MARK: - Mock SnapshotTests
    
    static let passedTest = SnapshotTest(
        testName: "ProfileViewTests.testUserProfileLayout",
        testTarget: "DifferUITests",
        referenceImagePath: URL(fileURLWithPath: "/path/to/reference.png"),
        status: .passed
    )
    
    static let failedTest = SnapshotTest(
        testName: "LoginViewTests.testLoginButtonState",
        testTarget: "DifferUITests",
        referenceImagePath: URL(fileURLWithPath: "/path/to/reference.png"),
        failedImagePath: URL(fileURLWithPath: "/path/to/failed.png"),
        diffImagePath: URL(fileURLWithPath: "/path/to/diff.png"),
        status: .failed
    )
    
    static let failedTest2 = SnapshotTest(
        testName: "SettingsViewTests.testDarkModeToggle",
        testTarget: "DifferUITests",
        referenceImagePath: URL(fileURLWithPath: "/path/to/settings_ref.png"),
        failedImagePath: URL(fileURLWithPath: "/path/to/settings_failed.png"),
        diffImagePath: URL(fileURLWithPath: "/path/to/settings_diff.png"),
        status: .failed
    )
    
    static let newTest = SnapshotTest(
        testName: "DashboardTests.testEmptyState",
        testTarget: "DifferUITests",
        failedImagePath: URL(fileURLWithPath: "/path/to/new.png"),
        status: .new
    )
    
    static let missingTest = SnapshotTest(
        testName: "OnboardingTests.testWelcomeScreen",
        testTarget: "DifferUITests",
        referenceImagePath: URL(fileURLWithPath: "/path/to/missing_ref.png"),
        status: .missing
    )
    
    static let allTests = [
        passedTest,
        failedTest,
        failedTest2,
        newTest,
        missingTest
    ]
    
    static let failedTests = [failedTest, failedTest2]
    static let emptyTests: [SnapshotTest] = []
    
    // MARK: - Mock DiffResult
    
    static let sampleDiffResult = DiffResult(
        pixelDifferences: 1234,
        percentDifference: 12.5,
        perceptualDifference: 8.3,
        width: 375,
        height: 667,
        computationTime: 0.045,
        algorithm: .pixelByPixel
    )
    
    // MARK: - Mock TestRun
    
    static let sampleTestRun = TestRun(
        xcresultPath: URL(fileURLWithPath: "/path/to/test.xcresult"),
        startDate: Date().addingTimeInterval(-300), // 5 minutes ago
        endDate: Date(),
        testResults: allTests,
        status: .completedWithFailures
    )
}
