import SwiftUI
import Combine
import DifferCore
import DifferServices

/// ViewModel for the diff comparison view
@MainActor
final class DiffViewModel: ObservableObject {
    @Published var snapshotTest: SnapshotTest
    @Published var referenceImage: NSImage?
    @Published var currentImage: NSImage?
    @Published var diffImage: NSImage?
    @Published var diffResult: DiffResult?
    
    @Published var isLoading = false
    @Published var error: Error?
    
    @Published var zoomLevel: CGFloat = 1.0
    @Published var showOverlay = false
    @Published var overlayOpacity: Double = 0.5
    
    private let imageComparisonService: ImageComparisonService
    
    init(snapshotTest: SnapshotTest, imageComparisonService: ImageComparisonService) {
        self.snapshotTest = snapshotTest
        self.imageComparisonService = imageComparisonService
    }
    
    /// Load images and compute diff
    func loadImages() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Load reference image
            if let refPath = snapshotTest.referenceImagePath {
                referenceImage = NSImage(contentsOf: refPath)
            }
            
            // Load current/failed image
            if let curPath = snapshotTest.failedImagePath {
                currentImage = NSImage(contentsOf: curPath)
            }
            
            // Compute diff if both images exist
            if let ref = referenceImage, let cur = currentImage {
                diffResult = try await imageComparisonService.compare(
                    reference: ref,
                    current: cur,
                    algorithm: .pixelByPixel
                )
                
                // Generate diff image
                diffImage = try await imageComparisonService.generateDiffImage(
                    reference: ref,
                    current: cur
                )
            }
        } catch {
            self.error = error
        }
    }
    
    /// Reset zoom to 100%
    func resetZoom() {
        zoomLevel = 1.0
    }
    
    /// Zoom in
    func zoomIn() {
        zoomLevel = min(zoomLevel + 0.25, 5.0)
    }
    
    /// Zoom out
    func zoomOut() {
        zoomLevel = max(zoomLevel - 0.25, 0.25)
    }
    
    /// Toggle overlay mode
    func toggleOverlay() {
        showOverlay.toggle()
    }
}
