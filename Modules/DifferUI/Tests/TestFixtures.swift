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
        id: "test-passed-1",
        name: "ProfileViewTests.testUserProfileLayout",
        status: .passed,
        referenceImagePath: URL(fileURLWithPath: "/path/to/reference.png"),
        failedImagePath: nil,
        diffImagePath: nil,
        testClass: "ProfileViewTests",
        testMethod: "testUserProfileLayout"
    )
    
    static let failedTest = SnapshotTest(
        id: "test-failed-1",
        name: "LoginViewTests.testLoginButtonState",
        status: .failed,
        referenceImagePath: URL(fileURLWithPath: "/path/to/reference.png"),
        failedImagePath: URL(fileURLWithPath: "/path/to/failed.png"),
        diffImagePath: URL(fileURLWithPath: "/path/to/diff.png"),
        testClass: "LoginViewTests",
        testMethod: "testLoginButtonState"
    )
    
    static let failedTest2 = SnapshotTest(
        id: "test-failed-2",
        name: "SettingsViewTests.testDarkModeToggle",
        status: .failed,
        referenceImagePath: URL(fileURLWithPath: "/path/to/settings_ref.png"),
        failedImagePath: URL(fileURLWithPath: "/path/to/settings_failed.png"),
        diffImagePath: URL(fileURLWithPath: "/path/to/settings_diff.png"),
        testClass: "SettingsViewTests",
        testMethod: "testDarkModeToggle"
    )
    
    static let newTest = SnapshotTest(
        id: "test-new-1",
        name: "DashboardTests.testEmptyState",
        status: .new,
        referenceImagePath: nil,
        failedImagePath: URL(fileURLWithPath: "/path/to/new.png"),
        diffImagePath: nil,
        testClass: "DashboardTests",
        testMethod: "testEmptyState"
    )
    
    static let missingTest = SnapshotTest(
        id: "test-missing-1",
        name: "OnboardingTests.testWelcomeScreen",
        status: .missing,
        referenceImagePath: URL(fileURLWithPath: "/path/to/missing_ref.png"),
        failedImagePath: nil,
        diffImagePath: nil,
        testClass: "OnboardingTests",
        testMethod: "testWelcomeScreen"
    )
    
    static let allTests = [
        passedTest,
        failedTest,
        failedTest2,
        newTest,
        missingTest,
    ]
    
    static let failedTests = [failedTest, failedTest2]
    static let emptyTests: [SnapshotTest] = []
    
    // MARK: - Mock DiffResult
    
    static let sampleDiffResult = DiffResult(
        pixelDifferenceCount: 1234,
        pixelDifferencePercentage: 12.5,
        perceptualDifference: 8.3,
        imageDimensions: CGSize(width: 375, height: 667),
        algorithm: .pixelByPixel,
        computationTime: 0.045
    )
    
    // MARK: - Mock TestRun
    
    static let sampleTestRun = TestRun(
        id: "run-1",
        xcresultPath: URL(fileURLWithPath: "/path/to/test.xcresult"),
        startDate: Date().addingTimeInterval(-300), // 5 minutes ago
        endDate: Date(),
        tests: allTests
    )
}
