import SwiftUI
import DifferCore

/// Preferences/Settings view
struct PreferencesView: View {
    var body: some View {
        TabView {
            GeneralPreferencesView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
            
            SnapshotPreferencesView()
                .tabItem {
                    Label("Snapshots", systemImage: "photo")
                }
            
            DiffPreferencesView()
                .tabItem {
                    Label("Diff", systemImage: "slider.horizontal.3")
                }
        }
        .frame(width: 500, height: 400)
    }
}

/// General preferences
struct GeneralPreferencesView: View {
    @AppStorage("defaultAlgorithm") private var defaultAlgorithm: String = "pixel_by_pixel"
    
    var body: some View {
        Form {
            Section("Comparison") {
                Picker("Default Algorithm:", selection: $defaultAlgorithm) {
                    ForEach(DiffAlgorithm.allCases, id: \.rawValue) { algorithm in
                        Text(algorithm.displayName).tag(algorithm.rawValue)
                    }
                }
            }
        }
        .padding()
    }
}

/// Snapshot directory preferences
struct SnapshotPreferencesView: View {
    @AppStorage("snapshotDirectories") private var snapshotDirectories: String = ""
    
    var body: some View {
        Form {
            Section("Snapshot Directories") {
                Text("Configure custom snapshot directories")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                // TODO: Add directory picker and list
            }
        }
        .padding()
    }
}

/// Diff visualization preferences
struct DiffPreferencesView: View {
    @AppStorage("diffTolerance") private var diffTolerance: Double = 0.01
    @AppStorage("highlightColorRed") private var highlightColorRed: Double = 1.0
    @AppStorage("highlightColorGreen") private var highlightColorGreen: Double = 0.0
    @AppStorage("highlightColorBlue") private var highlightColorBlue: Double = 0.0
    
    var body: some View {
        Form {
            Section("Difference Detection") {
                Slider(value: $diffTolerance, in: 0...0.1) {
                    Text("Tolerance: \(diffTolerance, specifier: "%.3f")")
                }
            }
            
            Section("Highlight Color") {
                ColorPicker("Color:", selection: Binding(
                    get: {
                        Color(
                            red: highlightColorRed,
                            green: highlightColorGreen,
                            blue: highlightColorBlue
                        )
                    },
                    set: { newColor in
                        if let components = NSColor(newColor).cgColor.components {
                            highlightColorRed = Double(components[0])
                            highlightColorGreen = Double(components[1])
                            highlightColorBlue = Double(components[2])
                        }
                    }
                ))
            }
        }
        .padding()
    }
}

#Preview {
    PreferencesView()
}
