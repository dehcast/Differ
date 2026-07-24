import XCTest
import AppKit
@testable import DifferServices
import DifferCore

@MainActor
final class ImageComparisonServiceTests: XCTestCase {

    // MARK: - Helpers

    /// Simple RGB triple used to describe test pixels (avoids large tuples).
    private struct RGB {
        let red: UInt8
        let green: UInt8
        let blue: UInt8

        init(_ red: UInt8, _ green: UInt8, _ blue: UInt8) {
            self.red = red
            self.green = green
            self.blue = blue
        }
    }

    /// Builds an opaque RGBA NSImage of the given size using a per-pixel fill closure.
    private func makeImage(
        width: Int,
        height: Int,
        fill: (_ x: Int, _ y: Int) -> RGB
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
                let pixel = fill(x, y)
                data[offset] = pixel.red
                data[offset + 1] = pixel.green
                data[offset + 2] = pixel.blue
                data[offset + 3] = 255
            }
        }

        let image = NSImage(size: NSSize(width: width, height: height))
        image.addRepresentation(rep)
        return image
    }

    private func solidImage(width: Int, height: Int, color: RGB) -> NSImage {
        makeImage(width: width, height: height) { _, _ in color }
    }

    // MARK: - Comparison

    func testIdenticalImagesReportZeroDifference() async throws {
        let service = ImageComparisonService()
        let reference = solidImage(width: 16, height: 16, color: RGB(200, 50, 50))
        let current = solidImage(width: 16, height: 16, color: RGB(200, 50, 50))

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
        let reference = solidImage(width: 16, height: 16, color: RGB(0, 0, 0))
        let current = solidImage(width: 16, height: 16, color: RGB(255, 255, 255))

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
        let reference = solidImage(width: width, height: height, color: RGB(255, 255, 255))
        // Change a known 2x2 block (4 pixels) to black.
        let current = makeImage(width: width, height: height) { x, y in
            if x < 2 && y < 2 {
                return RGB(0, 0, 0)
            }
            return RGB(255, 255, 255)
        }

        let result = try await service.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )

        XCTAssertEqual(result.pixelDifferences, 4)
        XCTAssertEqual(result.percentDifference, 4.0, accuracy: 0.0001)
    }

    func testConfigurableToleranceIgnoresSmallDifferences() async throws {
        // A small per-channel difference (10/255 ≈ 0.039) should count as different with
        // the default tolerance, but be ignored when the service is configured with a
        // larger tolerance.
        let reference = solidImage(width: 8, height: 8, color: RGB(100, 100, 100))
        let current = solidImage(width: 8, height: 8, color: RGB(110, 110, 110))

        let strict = ImageComparisonService()
        let strictResult = try await strict.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )
        XCTAssertEqual(strictResult.pixelDifferences, 64)

        let lenient = ImageComparisonService(tolerance: 0.1)
        let lenientResult = try await lenient.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )
        XCTAssertEqual(lenientResult.pixelDifferences, 0)
    }

    func testMismatchedDimensionsThrows() async throws {
        let service = ImageComparisonService()
        let reference = solidImage(width: 16, height: 16, color: RGB(10, 20, 30))
        let current = solidImage(width: 8, height: 16, color: RGB(10, 20, 30))

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

    func testEmptyImageThrowsInvalidImage() async throws {
        let service = ImageComparisonService()
        // An NSImage with no bitmap representation yields no comparable pixels and must
        // be rejected rather than reported as a successful (identical) comparison.
        let empty = NSImage(size: NSSize(width: 0, height: 0))

        do {
            _ = try await service.compare(
                reference: empty,
                current: empty,
                algorithm: .pixelByPixel
            )
            XCTFail("Expected invalidImage to be thrown for an empty image")
        } catch let error as ImageComparisonError {
            guard case .invalidImage = error else {
                return XCTFail("Expected invalidImage, got \(error)")
            }
        }
    }

    func testNegativeToleranceIsClampedToStrictComparison() async throws {
        // A negative tolerance must not make every pixel "different"; it should clamp to 0
        // and behave like an exact comparison, so identical images still report 0% diff.
        let service = ImageComparisonService(tolerance: -1.0)
        let reference = solidImage(width: 8, height: 8, color: RGB(120, 130, 140))
        let current = solidImage(width: 8, height: 8, color: RGB(120, 130, 140))

        let result = try await service.compare(
            reference: reference,
            current: current,
            algorithm: .pixelByPixel
        )

        XCTAssertEqual(result.pixelDifferences, 0)
    }

    // MARK: - Diff Image

    func testGenerateDiffImageHighlightsChangedPixels() async throws {
        let service = ImageComparisonService()
        let width = 10
        let height = 10
        let reference = solidImage(width: width, height: height, color: RGB(255, 255, 255))
        let current = makeImage(width: width, height: height) { x, y in
            if x < 2 && y < 2 {
                return RGB(0, 0, 0)
            }
            return RGB(255, 255, 255)
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
        let tiffData = try XCTUnwrap(diffImage.tiffRepresentation,
                                     "Diff image should provide a TIFF representation")
        let bitmap = try XCTUnwrap(NSBitmapImageRep(data: tiffData))
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

    func testChannelOrderIsRGBA() async throws {
        // Guards against a BGRA/RGBA byte-order regression: over a black reference, a pure
        // blue highlight must land in the blue channel (not red). If the normalized buffer
        // were BGRA, the highlight would appear reddish and this test would fail.
        let service = ImageComparisonService()
        let width = 4
        let height = 4
        let reference = solidImage(width: width, height: height, color: RGB(0, 0, 0))
        let current = solidImage(width: width, height: height, color: RGB(255, 255, 255))

        let blue = NSColor(srgbRed: 0, green: 0, blue: 1, alpha: 1)
        let diffImage = try await service.generateDiffImage(
            reference: reference,
            current: current,
            highlightColor: blue
        )

        let tiffData = try XCTUnwrap(diffImage.tiffRepresentation,
                                     "Diff image should provide a TIFF representation")
        let bitmap = try XCTUnwrap(NSBitmapImageRep(data: tiffData))
        let pixel = try XCTUnwrap(bitmap.colorAt(x: 0, y: 0))

        XCTAssertGreaterThan(pixel.blueComponent, pixel.redComponent,
                             "Blue highlight must appear in the blue channel (RGBA order)")
        XCTAssertGreaterThan(pixel.blueComponent, pixel.greenComponent,
                             "Blue highlight must appear in the blue channel (RGBA order)")
    }
}
