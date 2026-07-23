import XCTest
@testable import DifferCore

final class TestRunTests: XCTestCase {
    
    // MARK: - Helper Methods
    
    private func makeSnapshotTest(status: TestStatus, id: String = UUID().uuidString) -> SnapshotTest {
        SnapshotTest(
            id: id,
            name: "Test_\(id)",
            status: status,
            referenceImagePath: URL(fileURLWithPath: "/ref.png"),
            failedImagePath: status == .failed ? URL(fileURLWithPath: "/failed.png") : nil,
            diffImagePath: status == .failed ? URL(fileURLWithPath: "/diff.png") : nil,
            testClass: "TestClass",
            testMethod: "testMethod"
        )
    }
    
    // MARK: - Initialization
    
    func testInit_WithAllProperties() {
        let xcresultPath = URL(fileURLWithPath: "/path/to/test.xcresult")
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(120)
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .failed),
        ]
        
        let testRun = TestRun(
            id: "run-1",
            xcresultPath: xcresultPath,
            startDate: startDate,
            endDate: endDate,
            tests: tests
        )
        
        XCTAssertEqual(testRun.id, "run-1")
        XCTAssertEqual(testRun.xcresultPath, xcresultPath)
        XCTAssertEqual(testRun.startDate, startDate)
        XCTAssertEqual(testRun.endDate, endDate)
        XCTAssertEqual(testRun.tests.count, 2)
    }
    
    // MARK: - Statistics
    
    func testPassedCount() {
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .failed),
            makeSnapshotTest(status: .new),
        ]
        
        let testRun = TestRun(
            id: "run-stats",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            endDate: Date(),
            tests: tests
        )
        
        XCTAssertEqual(testRun.passedCount, 2)
    }
    
    func testFailedCount() {
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .failed),
            makeSnapshotTest(status: .failed),
            makeSnapshotTest(status: .new),
        ]
        
        let testRun = TestRun(
            id: "run-stats",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            endDate: Date(),
            tests: tests
        )
        
        XCTAssertEqual(testRun.failedCount, 2)
    }
    
    func testNewCount() {
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .failed),
            makeSnapshotTest(status: .new),
            makeSnapshotTest(status: .new),
            makeSnapshotTest(status: .new),
        ]
        
        let testRun = TestRun(
            id: "run-stats",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            endDate: Date(),
            tests: tests
        )
        
        XCTAssertEqual(testRun.newCount, 3)
    }
    
    func testMissingCount() {
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .missing),
            makeSnapshotTest(status: .missing),
        ]
        
        let testRun = TestRun(
            id: "run-stats",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            endDate: Date(),
            tests: tests
        )
        
        XCTAssertEqual(testRun.missingCount, 2)
    }
    
    func testTotalCount() {
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .failed),
            makeSnapshotTest(status: .new),
            makeSnapshotTest(status: .missing),
        ]
        
        let testRun = TestRun(
            id: "run-stats",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            endDate: Date(),
            tests: tests
        )
        
        XCTAssertEqual(testRun.totalCount, 4)
    }
    
    func testStatistics_EmptyTests() {
        let testRun = TestRun(
            id: "run-empty",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            endDate: Date(),
            tests: []
        )
        
        XCTAssertEqual(testRun.passedCount, 0)
        XCTAssertEqual(testRun.failedCount, 0)
        XCTAssertEqual(testRun.newCount, 0)
        XCTAssertEqual(testRun.missingCount, 0)
        XCTAssertEqual(testRun.totalCount, 0)
    }
    
    // MARK: - Duration
    
    func testDuration() {
        let startDate = Date()
        let endDate = startDate.addingTimeInterval(300) // 5 minutes
        
        let testRun = TestRun(
            id: "run-duration",
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: startDate,
            endDate: endDate,
            tests: []
        )
        
        let duration = testRun.endDate.timeIntervalSince(testRun.startDate)
        XCTAssertEqual(duration, 300, accuracy: 0.1)
    }
    
    // MARK: - Codable
    
    func testCodable_EncodeDecode() throws {
        let tests = [
            makeSnapshotTest(status: .passed, id: "test-1"),
            makeSnapshotTest(status: .failed, id: "test-2"),
        ]
        
        let original = TestRun(
            id: "run-codable",
            xcresultPath: URL(fileURLWithPath: "/path/to/test.xcresult"),
            startDate: Date(),
            endDate: Date().addingTimeInterval(120),
            tests: tests
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TestRun.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.xcresultPath, original.xcresultPath)
        XCTAssertEqual(decoded.tests.count, original.tests.count)
        XCTAssertEqual(decoded.tests[0].id, original.tests[0].id)
        XCTAssertEqual(decoded.tests[1].id, original.tests[1].id)
    }
}
