import SwiftUI
import DifferCore
import DifferServices

/// Main diff comparison view with three panels
struct DiffView: View {
    let snapshotTest: SnapshotTest
    let imageComparisonService: ImageComparisonService
    
    @StateObject private var viewModel: DiffViewModel
    
    init(snapshotTest: SnapshotTest, imageComparisonService: ImageComparisonService) {
        self.snapshotTest = snapshotTest
        self.imageComparisonService = imageComparisonService
        _viewModel = StateObject(wrappedValue: DiffViewModel(
            snapshotTest: snapshotTest,
            imageComparisonService: imageComparisonService
        ))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with test info
            DiffHeaderView(test: snapshotTest, diffResult: viewModel.diffResult)
            
            Divider()
            
            // Main comparison view
            if viewModel.isLoading {
                ProgressView("Loading images...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.showOverlay {
                OverlayComparisonView(
                    referenceImage: viewModel.referenceImage,
                    currentImage: viewModel.currentImage,
                    opacity: $viewModel.overlayOpacity,
                    zoomLevel: viewModel.zoomLevel
                )
            } else {
                ThreePanelView(
                    referenceImage: viewModel.referenceImage,
                    currentImage: viewModel.currentImage,
                    diffImage: viewModel.diffImage,
                    zoomLevel: viewModel.zoomLevel
                )
            }
            
            Divider()
            
            // Bottom toolbar
            DiffToolbarView(viewModel: viewModel)
        }
        .task {
            await viewModel.loadImages()
        }
    }
}

/// Header showing test information and diff stats
struct DiffHeaderView: View {
    let test: SnapshotTest
    let diffResult: DiffResult?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(test.testName)
                    .font(.headline)
                
                Text(test.testTarget)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let result = diffResult {
                HStack(spacing: 16) {
                    StatView(label: "Difference", value: result.description)
                    
                    if let perceptual = result.perceptualDifference {
                        StatView(label: "Perceptual", value: String(format: "%.2f", perceptual))
                    }
                    
                    StatView(
                        label: "Size",
                        value: "\(result.dimensions.width)×\(result.dimensions.height)"
                    )
                }
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption.monospacedDigit())
        }
    }
}

/// Three-panel side-by-side comparison
struct ThreePanelView: View {
    let referenceImage: NSImage?
    let currentImage: NSImage?
    let diffImage: NSImage?
    let zoomLevel: CGFloat
    
    var body: some View {
        HStack(spacing: 0) {
            ImagePanel(title: "Reference", image: referenceImage, zoomLevel: zoomLevel)
            Divider()
            ImagePanel(title: "Current", image: currentImage, zoomLevel: zoomLevel)
            Divider()
            ImagePanel(title: "Diff", image: diffImage, zoomLevel: zoomLevel)
        }
    }
}

/// Single image panel with label
struct ImagePanel: View {
    let title: String
    let image: NSImage?
    let zoomLevel: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // Label
            Text(title)
                .font(.caption.bold())
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color(nsColor: .windowBackgroundColor))
            
            Divider()
            
            // Image
            ScrollView([.horizontal, .vertical]) {
                if let image = image {
                    Image(nsImage: image)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(zoomLevel)
                } else {
                    Text("No Image")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Overlay comparison mode with opacity slider
struct OverlayComparisonView: View {
    let referenceImage: NSImage?
    let currentImage: NSImage?
    @Binding var opacity: Double
    let zoomLevel: CGFloat
    
    var body: some View {
        VStack {
            ScrollView([.horizontal, .vertical]) {
                ZStack {
                    if let ref = referenceImage {
                        Image(nsImage: ref)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(zoomLevel)
                    }
                    
                    if let cur = currentImage {
                        Image(nsImage: cur)
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(zoomLevel)
                            .opacity(opacity)
                    }
                }
            }
            
            // Opacity slider
            HStack {
                Text("Reference")
                    .font(.caption)
                Slider(value: $opacity, in: 0...1)
                    .frame(width: 200)
                Text("Current")
                    .font(.caption)
            }
            .padding()
        }
    }
}

/// Bottom toolbar with zoom and mode controls
struct DiffToolbarView: View {
    @ObservedObject var viewModel: DiffViewModel
    
    var body: some View {
        HStack {
            // Zoom controls
            HStack(spacing: 4) {
                Button(action: viewModel.zoomOut) {
                    Image(systemName: "minus.magnifyingglass")
                }
                .keyboardShortcut("-", modifiers: [.command])
                
                Text("\(Int(viewModel.zoomLevel * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 50)
                
                Button(action: viewModel.zoomIn) {
                    Image(systemName: "plus.magnifyingglass")
                }
                .keyboardShortcut("+", modifiers: [.command])
                
                Button(action: viewModel.resetZoom) {
                    Text("100%")
                        .font(.caption)
                }
            }
            
            Spacer()
            
            // View mode toggle
            Button(action: viewModel.toggleOverlay) {
                Label(
                    viewModel.showOverlay ? "Side by Side" : "Overlay",
                    systemImage: viewModel.showOverlay ? "square.split.2x1" : "square.stack"
                )
            }
            .keyboardShortcut("o", modifiers: [.command])
            
            Spacer()
            
            // Actions
            Button(action: {
                // TODO: Approve snapshot
            }) {
                Label("Approve", systemImage: "checkmark.circle")
            }
            .keyboardShortcut("a", modifiers: [.command])
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
    }
}

#Preview {
    let test = SnapshotTest(
        testName: "MyViewTests.testAppearance",
        testTarget: "MyAppTests",
        status: .failed
    )
    
    return DiffView(
        snapshotTest: test,
        imageComparisonService: ImageComparisonService()
    )
    .frame(width: 1200, height: 800)
}
