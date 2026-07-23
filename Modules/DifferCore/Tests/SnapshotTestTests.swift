import XCTest
@testable import DifferCore

final class SnapshotTestTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testInit_WithAllProperties() {
        let referenceURL = URL(fileURLWithPath: "/path/to/reference.png")
        let failedURL = URL(fileURLWithPath: "/path/to/failed.png")
        let diffURL = URL(fileURLWithPath: "/path/to/diff.png")
        
        let test = SnapshotTest(
            id: "test-1",
            name: "ProfileViewTests.testUserProfile",
            status: .failed,
            referenceImagePath: referenceURL,
            failedImagePath: failedURL,
            diffImagePath: diffURL,
            testClass: "ProfileViewTests",
            testMethod: "testUserProfile"
        )
        
        XCTAssertEqual(test.id, "test-1")
        XCTAssertEqual(test.name, "ProfileViewTests.testUserProfile")
        XCTAssertEqual(test.status, .failed)
        XCTAssertEqual(test.referenceImagePath, referenceURL)
        XCTAssertEqual(test.failedImagePath, failedURL)
        XCTAssertEqual(test.diffImagePath, diffURL)
        XCTAssertEqual(test.testClass, "ProfileViewTests")
        XCTAssertEqual(test.testMethod, "testUserProfile")
    }
    
    func testInit_WithOptionalProperties() {
        let test = SnapshotTest(
            id: "test-2",
            name: "LoginViewTests.testLoginButton",
            status: .passed,
            referenceImagePath: URL(fileURLWithPath: "/path/to/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "LoginViewTests",
            testMethod: "testLoginButton"
        )
        
        XCTAssertNil(test.failedImagePath)
        XCTAssertNil(test.diffImagePath)
    }
    
    // MARK: - Status Tests
    
    func testStatus_Passed() {
        let test = SnapshotTest(
            id: "test-passed",
            name: "Test",
            status: .passed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        XCTAssertEqual(test.status, .passed)
    }
    
    func testStatus_Failed() {
        let test = SnapshotTest(
            id: "test-failed",
            name: "Test",
            status: .failed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: URL(fileURLWithPath: "/failed.png"),
            diffImagePath: URL(fileURLWithPath: "/diff.png"),
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        XCTAssertEqual(test.status, .failed)
        XCTAssertNotNil(test.failedImagePath)
    }
    
    func testStatus_New() {
        let test = SnapshotTest(
            id: "test-new",
            name: "Test",
            status: .new,
            referenceImagePath: nil,
            failedImagePath: URL(fileURLWithPath: "/new.png"),
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        XCTAssertEqual(test.status, .new)
        XCTAssertNil(test.referenceImagePath)
    }
    
    func testStatus_Missing() {
        let test = SnapshotTest(
            id: "test-missing",
            name: "Test",
            status: .missing,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        XCTAssertEqual(test.status, .missing)
        XCTAssertNil(test.failedImagePath)
    }
    
    // MARK: - Equatable
    
    func testEquatable_SameID() {
        let test1 = SnapshotTest(
            id: "test-1",
            name: "Test",
            status: .passed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        let test2 = SnapshotTest(
            id: "test-1",
            name: "Different Name",
            status: .failed,
            referenceImagePath: URL(fileURLWithPath: "/different.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "DifferentClass",
            testMethod: "differentMethod"
        )
        
        XCTAssertEqual(test1, test2, "Tests with same ID should be equal")
    }
    
    func testEquatable_DifferentID() {
        let test1 = SnapshotTest(
            id: "test-1",
            name: "Test",
            status: .passed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        let test2 = SnapshotTest(
            id: "test-2",
            name: "Test",
            status: .passed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        XCTAssertNotEqual(test1, test2, "Tests with different IDs should not be equal")
    }
    
    // MARK: - Hashable
    
    func testHashable() {
        let test1 = SnapshotTest(
            id: "test-1",
            name: "Test",
            status: .passed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
        
        let test2 = SnapshotTest(
            id: "test-1",
            name: "Different",
            status: .failed,
            referenceImagePath: URL(fileURLWithPath: "/other.png"),
            failedImagePath: nil,
            diffImagePath: nil,
            testClass: "OtherClass",
            testMethod: "otherMethod"
        )
        
        var set = Set<SnapshotTest>()
        set.insert(test1)
        set.insert(test2)
        
        XCTAssertEqual(set.count, 1, "Set should contain only one test with same ID")
    }
    
    // MARK: - Codable
    
    func testCodable_EncodeDecode() throws {
        let original = SnapshotTest(
            id: "test-codable",
            name: "CodableTest.testEncoding",
            status: .failed,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: URL(fileURLWithPath: "/failed.png"),
            diffImagePath: URL(fileURLWithPath: "/diff.png"),
            testClass: "CodableTest",
            testMethod: "testEncoding"
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(SnapshotTest.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.status, original.status)
        XCTAssertEqual(decoded.referenceImagePath, original.referenceImagePath)
        XCTAssertEqual(decoded.failedImagePath, original.failedImagePath)
        XCTAssertEqual(decoded.diffImagePath, original.diffImagePath)
        XCTAssertEqual(decoded.testClass, original.testClass)
        XCTAssertEqual(decoded.testMethod, original.testMethod)
    }
}
