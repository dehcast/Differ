import XCTest
@testable import DifferCore

final class TestRunTests: XCTestCase {
    
    private func makeSnapshotTest(status: TestStatus) -> SnapshotTest {
        SnapshotTest(
            testName: "TestClass.testMethod",
            testTarget: "MyAppTests",
            status: status
        )
    }
    
    func testInit() {
        let tests = [makeSnapshotTest(status: .passed), makeSnapshotTest(status: .failed)]
        let testRun = TestRun(
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            testResults: tests
        )
        
        XCTAssertEqual(testRun.testResults.count, 2)
    }
    
    func testStatistics() {
        let tests = [
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .passed),
            makeSnapshotTest(status: .failed),
        ]
        
        let testRun = TestRun(xcresultPath: nil, startDate: Date(), testResults: tests)
        
        XCTAssertEqual(testRun.totalTests, 3)
        XCTAssertEqual(testRun.passedTests, 2)
        XCTAssertEqual(testRun.failedTests, 1)
    }
    
    func testDuration() {
        let start = Date()
        let end = start.addingTimeInterval(120)
        let testRun = TestRun(xcresultPath: nil, startDate: start, endDate: end, testResults: [])
        
        if let duration = testRun.duration {
            XCTAssertEqual(duration, 120, accuracy: 0.1)
        } else {
            XCTFail("Expected duration to be non-nil")
        }
    }
    
    func testComplete() {
        var testRun = TestRun(xcresultPath: nil, startDate: Date(), testResults: [])
        let results = [makeSnapshotTest(status: .passed), makeSnapshotTest(status: .failed)]
        
        testRun.complete(with: results)
        
        XCTAssertNotNil(testRun.endDate)
        XCTAssertEqual(testRun.testResults.count, 2)
        XCTAssertEqual(testRun.status, .completedWithFailures)
    }
    
    func testFail() {
        var testRun = TestRun(xcresultPath: nil, startDate: Date(), testResults: [])
        testRun.fail()
        
        XCTAssertNotNil(testRun.endDate)
        XCTAssertEqual(testRun.status, .failed)
    }
    
    func testCodable() throws {
        let original = TestRun(
            xcresultPath: URL(fileURLWithPath: "/test.xcresult"),
            startDate: Date(),
            testResults: [makeSnapshotTest(status: .passed)],
            status: .completed
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(TestRun.self, from: data)
        
        XCTAssertEqual(decoded.status, original.status)
        XCTAssertEqual(decoded.testResults.count, original.testResults.count)
    }
}
