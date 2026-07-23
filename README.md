# Differ

A macOS native application for visualizing snapshot test failures and intelligently running only failed tests.

## Project Structure

This project uses a **multimodule architecture** designed for scalability and clear dependency boundaries. It's compatible with Tuist but currently uses Swift Package Manager.

```
Differ/
├── App/                           # Main application target
├── Modules/
│   ├── DifferCore/               # Core models & protocols (no dependencies)
│   ├── DifferKit/                # Shared utilities & extensions
│   ├── DifferServices/           # Business logic & services
│   └── DifferUI/                 # SwiftUI views & ViewModels
├── Tests/                        # Test targets
├── ARCHITECTURE.md               # Multimodule architecture guide
└── TUIST.md                      # Tuist migration guide

```

### Module Dependencies

```
DifferApp → DifferUI → DifferCore
         → DifferServices → DifferCore
                         → DifferKit → DifferCore
```

**Benefits:**
- ✅ Parallel compilation (faster builds)
- ✅ Clear dependency boundaries
- ✅ Independent module testing
- ✅ Reusable components
- ✅ Tuist-ready architecture

See [ARCHITECTURE.md](ARCHITECTURE.md) for details.

## Features

- **Snapshot Test Detection**: Automatically parse `.xcresult` bundles from Xcode
- **Visual Diff Viewer**: Side-by-side and overlay comparison modes
- **Intelligent Test Running**: Run only the tests that actually failed
- **Git Integration**: Track snapshot changes across branches
- **Multiple Framework Support**: Works with FBSnapshotTestCase and SnapshotTesting

## Project Status

🚧 **In Development** - Phase 1: Foundation & Core

### Completed
- ✅ Multimodule project structure
- ✅ Core data models (DifferCore)
- ✅ Service layer architecture (DifferServices)
- ✅ SwiftUI app shell (DifferUI)
- ✅ Basic UI components

### In Progress
- 🔄 Image comparison algorithms
- 🔄 XCResult parsing
- 🔄 Git repository detection

## Requirements

- macOS 13.0 (Ventura) or later
- Xcode 15.0 or later
- Swift 5.9 or later

## Building

### With Swift Package Manager (Current)

```bash
# Clone the repository
git clone https://github.com/dehcast/Differ.git
cd Differ

# Build
swift build

# Or open in Xcode
open Package.swift
```

### Module Development

Each module can be built independently:

```bash
cd Modules/DifferCore
swift build

cd Modules/DifferServices
swift build
```

### Migrating to Tuist (Optional)

When ready to adopt Tuist for advanced features (binary caching, project generation):

```bash
# Install Tuist
curl -Ls https://install.tuist.io | bash

# Generate Xcode project
tuist generate
```

See [TUIST.md](TUIST.md) for complete migration guide.

## Development Roadmap

See [roadmap.md](../../../.copilot/session-state/189c196d-db05-49d7-81e3-3f67da0ec915/files/roadmap.md) for detailed implementation timeline.

### Phase 1: Foundation (Weeks 1-3) - IN PROGRESS
- [x] Multimodule project setup
- [x] Core models
- [ ] Image comparison engine
- [ ] Basic UI

### Phase 2: Xcode Integration (Weeks 4-6)
- [ ] XCResult parsing
- [ ] Test execution
- [ ] Snapshot framework adapters

### Phase 3: Git Integration (Weeks 7-8)
- [ ] Repository detection
- [ ] Change tracking
- [ ] Branch comparison

### Phase 4: Advanced Features (Weeks 9-11)
- [ ] Test intelligence
- [ ] Watch mode
- [ ] Export features

### Phase 5: Polish & Release (Weeks 12-14)
- [ ] Performance optimization
- [ ] Documentation
- [ ] Distribution

## Contributing

This project follows a structured implementation roadmap. See the task database for current priorities.

### Module Guidelines

**Adding new code?**
- Models/Protocols → `DifferCore`
- Services → `DifferServices`
- Views/ViewModels → `DifferUI`
- Utilities → `DifferKit`
- App composition → `App`

**Dependency rules:**
1. `DifferCore` has no dependencies
2. `DifferKit` depends on `Core`
3. `DifferServices` depends on `Core` + `Kit`
4. `DifferUI` depends on `Core` + `Kit`
5. `App` depends on all modules

## License

[MIT License](LICENSE)

## Acknowledgments

- [XCResultKit](https://github.com/davidahouse/XCResultKit) for XCResult parsing
- [swift-log](https://github.com/apple/swift-log) for logging
- Inspired by microfeature architecture patterns
