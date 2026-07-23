import XCTest
@testable import DifferCore

final class SnapshotTestTests: XCTestCase {
    
    func testInit() {
        let test = SnapshotTest(
            testName: "ProfileViewTests.testUserProfile",
            testTarget: "MyAppTests",
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            status: .passed
        )
        
        XCTAssertEqual(test.testName, "ProfileViewTests.testUserProfile")
        XCTAssertEqual(test.testTarget, "MyAppTests")
        XCTAssertEqual(test.testClass, "ProfileViewTests")
        XCTAssertEqual(test.testMethod, "testUserProfile")
        XCTAssertEqual(test.status, .passed)
    }
    
    func testStatus() {
        let passed = SnapshotTest(testName: "T.t", testTarget: "A", status: .passed)
        let failed = SnapshotTest(testName: "T.t", testTarget: "A", status: .failed)
        let new = SnapshotTest(testName: "T.t", testTarget: "A", status: .new)
        
        XCTAssertEqual(passed.status, .passed)
        XCTAssertEqual(failed.status, .failed)
        XCTAssertEqual(new.status, .new)
    }
    
    func testTestNameParsing() {
        let test = SnapshotTest(testName: "MyTests.testMethod", testTarget: "A")
        XCTAssertEqual(test.testClass, "MyTests")
        XCTAssertEqual(test.testMethod, "testMethod")
    }
    
    func testHasComparableImages() {
        let withBoth = SnapshotTest(
            testName: "T.t",
            testTarget: "A",
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: URL(fileURLWithPath: "/failed.png")
        )
        let withoutFailed = SnapshotTest(
            testName: "T.t",
            testTarget: "A",
            referenceImagePath: URL(fileURLWithPath: "/ref.png")
        )
        
        XCTAssertTrue(withBoth.hasComparableImages)
        XCTAssertFalse(withoutFailed.hasComparableImages)
    }
    
    func testDisplayName() {
        let test = SnapshotTest(testName: "MyTests.testLayout", testTarget: "A")
        XCTAssertEqual(test.displayName, "testLayout")
    }
    
    func testIdentifiable() {
        let id = UUID()
        let test1 = SnapshotTest(id: id, testName: "T.t", testTarget: "A")
        let test2 = SnapshotTest(id: id, testName: "T.t", testTarget: "A")
        XCTAssertEqual(test1.id, test2.id)
    }
    
    func testCodable() throws {
        let original = SnapshotTest(
            testName: "MyTest.testMethod",
            testTarget: "MyAppTests",
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            status: .failed
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SnapshotTest.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.testName, original.testName)
        XCTAssertEqual(decoded.testTarget, original.testTarget)
        XCTAssertEqual(decoded.status, original.status)
    }
}
