# Tuist Migration Guide

## Current State: SPM Multimodule

The project is currently structured as a multimodule Swift Package Manager project with local packages. This provides:

- ✅ Modular architecture
- ✅ Clear dependency boundaries
- ✅ Parallel compilation
- ✅ Independent testing

## Why Tuist?

When the project grows, Tuist provides additional benefits:

1. **Project Generation**: Generate `.xcodeproj` from code, no more merge conflicts
2. **Advanced Caching**: Binary caching for even faster builds
3. **Build Insights**: Detailed build analytics
4. **Focused Workspaces**: Generate minimal workspaces for specific features
5. **Microfeature Architecture**: Better support for complex dependency graphs

## When to Migrate

Consider migrating to Tuist when:

- [ ] Team size > 3 developers (merge conflicts on `.xcodeproj`)
- [ ] Build times > 5 minutes (can benefit from caching)
- [ ] Number of modules > 10 (Tuist scales better)
- [ ] Need advanced features (focused workspaces, code generation)

## Migration Steps

### 1. Install Tuist

```bash
curl -Ls https://install.tuist.io | bash
tuist version
```

### 2. Initialize Tuist Config

```bash
cd /Users/dehcast/Desktop/Differ
tuist init
```

This creates:
```
Tuist/
├── Config.swift
└── ProjectDescriptionHelpers/
```

### 3. Create Root Project.swift

Replace `Package.swift` with `Project.swift`:

```swift
import ProjectDescription

let project = Project(
    name: "Differ",
    organizationName: "com.differ",
    targets: [
        Target(
            name: "Differ",
            platform: .macOS,
            product: .app,
            bundleId: "com.differ.app",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            infoPlist: .default,
            sources: ["App/**"],
            dependencies: [
                .project(target: "DifferCore", path: "Modules/DifferCore"),
                .project(target: "DifferKit", path: "Modules/DifferKit"),
                .project(target: "DifferServices", path: "Modules/DifferServices"),
                .project(target: "DifferUI", path: "Modules/DifferUI"),
            ]
        )
    ]
)
```

### 4. Create Module Project.swift Files

For each module, create a `Project.swift`:

**Modules/DifferCore/Project.swift**:
```swift
import ProjectDescription

let project = Project(
    name: "DifferCore",
    targets: [
        Target(
            name: "DifferCore",
            platform: .macOS,
            product: .framework,
            bundleId: "com.differ.core",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Sources/**"],
            dependencies: []
        ),
        Target(
            name: "DifferCoreTests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "com.differ.core.tests",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "DifferCore")
            ]
        )
    ]
)
```

**Modules/DifferKit/Project.swift**:
```swift
import ProjectDescription

let project = Project(
    name: "DifferKit",
    targets: [
        Target(
            name: "DifferKit",
            platform: .macOS,
            product: .framework,
            bundleId: "com.differ.kit",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "DifferCore", path: "../DifferCore")
            ]
        ),
        Target(
            name: "DifferKitTests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "com.differ.kit.tests",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "DifferKit")
            ]
        )
    ]
)
```

**Modules/DifferServices/Project.swift**:
```swift
import ProjectDescription

let project = Project(
    name: "DifferServices",
    targets: [
        Target(
            name: "DifferServices",
            platform: .macOS,
            product: .framework,
            bundleId: "com.differ.services",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "DifferCore", path: "../DifferCore"),
                .project(target: "DifferKit", path: "../DifferKit"),
                .external(name: "XCResultKit"),
                .external(name: "Logging"),
            ]
        ),
        Target(
            name: "DifferServicesTests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "com.differ.services.tests",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "DifferServices")
            ]
        )
    ]
)
```

**Modules/DifferUI/Project.swift**:
```swift
import ProjectDescription

let project = Project(
    name: "DifferUI",
    targets: [
        Target(
            name: "DifferUI",
            platform: .macOS,
            product: .framework,
            bundleId: "com.differ.ui",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Sources/**"],
            dependencies: [
                .project(target: "DifferCore", path: "../DifferCore"),
                .project(target: "DifferKit", path: "../DifferKit"),
            ]
        ),
        Target(
            name: "DifferUITests",
            platform: .macOS,
            product: .unitTests,
            bundleId: "com.differ.ui.tests",
            deploymentTarget: .macOS(targetVersion: "13.0"),
            sources: ["Tests/**"],
            dependencies: [
                .target(name: "DifferUI")
            ]
        )
    ]
)
```

### 5. Configure External Dependencies

Create `Tuist/Dependencies.swift`:

```swift
import ProjectDescription

let dependencies = Dependencies(
    swiftPackageManager: [
        .remote(
            url: "https://github.com/davidahouse/XCResultKit.git",
            requirement: .upToNextMajor(from: "1.0.0")
        ),
        .remote(
            url: "https://github.com/apple/swift-log.git",
            requirement: .upToNextMajor(from: "1.0.0")
        ),
    ]
)
```

### 6. Fetch Dependencies

```bash
tuist fetch
```

### 7. Generate Xcode Project

```bash
tuist generate
```

This creates `Differ.xcworkspace` with all modules.

### 8. Remove SPM Files (Optional)

Once Tuist is working:
```bash
rm Package.swift
rm Modules/*/Package.swift
```

## Advanced Tuist Features

### Focused Workspaces

Generate workspace with only specific modules:

```bash
tuist generate DifferUI  # Only UI module and dependencies
```

### Binary Caching

Enable caching for faster builds:

```bash
tuist cache warm  # Pre-build and cache all frameworks
```

### Build Insights

Analyze build times:

```bash
tuist build --analyze
```

### Code Generation

Add resource generation in `Config.swift`:

```swift
let config = Config(
    generationOptions: .options(
        resolveDependenciesWithSystemScm: true,
        disableShowEnvironmentVars: true
    )
)
```

## Hybrid Approach (Recommended)

You can use both SPM and Tuist:

1. **Keep SPM** for CLI tools and package distribution
2. **Use Tuist** for Xcode project generation
3. **CI/CD** uses SPM for builds
4. **Developers** use Tuist for local development

## Comparison

| Feature | Current SPM | With Tuist |
|---------|-------------|------------|
| Modular | ✅ | ✅ |
| Fast compilation | ✅ | ✅✅ (with caching) |
| No merge conflicts | ❌ | ✅ |
| Focused workspaces | ❌ | ✅ |
| Binary caching | ❌ | ✅ |
| Project generation | ❌ | ✅ |
| Learning curve | Low | Medium |
| Team setup | Easy | Requires Tuist install |

## Migration Checklist

- [ ] Install Tuist
- [ ] Create `Tuist/Config.swift`
- [ ] Create root `Project.swift`
- [ ] Create `Project.swift` for each module
- [ ] Configure external dependencies in `Tuist/Dependencies.swift`
- [ ] Run `tuist fetch`
- [ ] Run `tuist generate`
- [ ] Test build and run
- [ ] Update documentation
- [ ] Train team on Tuist commands
- [ ] Optional: Remove `Package.swift` files

## Resources

- [Tuist Documentation](https://docs.tuist.io)
- [Tuist Examples](https://github.com/tuist/tuist/tree/main/fixtures)
- [Microfeature Architecture](https://docs.tuist.io/guides/develop/projects/microfeature-architecture)

## Current Status

✅ **Ready for Tuist Migration**

The current multimodule SPM structure is already compatible with Tuist. When ready, follow the migration steps above.
