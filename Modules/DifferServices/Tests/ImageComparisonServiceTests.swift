import XCTest
import AppKit
@testable import DifferServices
import DifferCore

@MainActor
final class ImageComparisonServiceTests: XCTestCase {

    // MARK: - Helpers

    /// Builds an opaque RGBA NSImage of the given size using a per-pixel fill closure.
    private func makeImage(
        width: Int,
        height: Int,
        fill: (_ x: Int, _ y: Int) -> (UInt8, UInt8, UInt8)
    ) -> NSImage {
        guard let rep = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: width,
            pixelsHigh: height,
            bitsPerSample: 8,
            samplesPerPixel: 4,
            hasAlpha: true,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: width * 4,
            bitsPerPixel: 32
        ), let data = rep.bitmapData else {
            fatalError("Failed to allocate test bitmap")
        }

        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * 4
                let (r, g, b) = fill(x, y)
                data[offset] = r
                data[offset + 1] = g
                data[offset + 2] = b
                data[offset + 3] = 255
            }
        }

        let image = NSImage(size: NSSize(width: width, height: height))
        image.addRepresentation(rep)
        return image
    }

    private func solidImage(width: Int, height: Int, color: (UInt8, UInt8, UInt8)) -> NSImage {
        makeImage(width: width, height: height) { _, _ in color }
    }

    // MARK: - Comparison

    func testIdenticalImagesReportZeroDifference() async throws {
        let service = ImageComparisonService()
        let reference = solidImage(width: 16, height: 16, color: (200, 50, 50))
        let current = solidImage(width: 16, height: 16, color: (200, 50, 50))

        let result = try await service.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )

        XCTAssertEqual(result.pixelDifferences, 0)
        XCTAssertEqual(result.percentDifference, 0.0, accuracy: 0.0001)
        XCTAssertTrue(result.areIdentical())
        XCTAssertEqual(result.dimensions, ImageDimensions(width: 16, height: 16))
    }

    func testCompletelyDifferentImagesReportFullDifference() async throws {
        let service = ImageComparisonService()
        let reference = solidImage(width: 16, height: 16, color: (0, 0, 0))
        let current = solidImage(width: 16, height: 16, color: (255, 255, 255))

        let result = try await service.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )

        XCTAssertEqual(result.pixelDifferences, 16 * 16)
        XCTAssertEqual(result.percentDifference, 100.0, accuracy: 0.0001)
        XCTAssertFalse(result.areIdentical())
    }

    func testPartialDifferenceCountsOnlyChangedRegion() async throws {
        let service = ImageComparisonService()
        let width = 10
        let height = 10
        let reference = solidImage(width: width, height: height, color: (255, 255, 255))
        // Change a known 2x2 block (4 pixels) to black.
        let current = makeImage(width: width, height: height) { x, y in
            if x < 2 && y < 2 {
                return (0, 0, 0)
            }
            return (255, 255, 255)
        }

        let result = try await service.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )

        XCTAssertEqual(result.pixelDifferences, 4)
        XCTAssertEqual(result.percentDifference, 4.0, accuracy: 0.0001)
    }

    func testMismatchedDimensionsThrows() async throws {
        let service = ImageComparisonService()
        let reference = solidImage(width: 16, height: 16, color: (10, 20, 30))
        let current = solidImage(width: 8, height: 16, color: (10, 20, 30))

        do {
            _ = try await service.compare(
                reference: reference,
                current: current,
                algorithm: .pixelByPixel
            )
            XCTFail("Expected dimensionMismatch to be thrown")
        } catch let error as ImageComparisonError {
            guard case .dimensionMismatch = error else {
                return XCTFail("Expected dimensionMismatch, got \(error)")
            }
        }
    }

    // MARK: - Diff Image

    func testGenerateDiffImageHighlightsChangedPixels() async throws {
        let service = ImageComparisonService()
        let width = 10
        let height = 10
        let reference = solidImage(width: width, height: height, color: (255, 255, 255))
        let current = makeImage(width: width, height: height) { x, y in
            if x < 2 && y < 2 {
                return (0, 0, 0)
            }
            return (255, 255, 255)
        }

        let diffImage = try await service.generateDiffImage(
            reference: reference,
            current: current,
            highlightColor: .systemRed
        )

        // The diff image keeps the reference's logical size. (Pixel-backing dimensions
        // may be scaled by the display's backing scale factor, so assert on size.)
        XCTAssertEqual(diffImage.size.width, CGFloat(width), accuracy: 0.5)
        XCTAssertEqual(diffImage.size.height, CGFloat(height), accuracy: 0.5)

        // A changed pixel should no longer be pure white (it is blended toward red),
        // while an unchanged pixel should remain white. Sample using the bitmap's own
        // pixel dimensions so this is independent of any backing-scale factor.
        let bitmap = try XCTUnwrap(NSBitmapImageRep(data: diffImage.tiffRepresentation ?? Data()))
        let changed = try XCTUnwrap(bitmap.colorAt(x: 0, y: 0))
        let unchanged = try XCTUnwrap(bitmap.colorAt(x: bitmap.pixelsWide - 1, y: bitmap.pixelsHigh - 1))

        XCTAssertGreaterThan(changed.redComponent, changed.blueComponent,
                             "Changed pixel should skew toward the red highlight color")
        XCTAssertLessThan(changed.blueComponent, 0.99,
                          "Changed pixel should not remain pure white")
        XCTAssertEqual(unchanged.redComponent, 1.0, accuracy: 0.02)
        XCTAssertEqual(unchanged.greenComponent, 1.0, accuracy: 0.02)
        XCTAssertEqual(unchanged.blueComponent, 1.0, accuracy: 0.02)
    }
}
