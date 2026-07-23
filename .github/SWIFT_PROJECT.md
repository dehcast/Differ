# Swift Project Configuration

This document covers Swift Package Manager setup, environment configuration, and common troubleshooting for the Differ project.

## Swift Package Manager (SPM)

### Project Structure

This is a multi-module SPM project with the following structure:

```
Package.swift                 # Root package (main app)
Modules/
  ├── DifferCore/            # Core models and business logic
  │   └── Package.swift
  ├── DifferKit/             # Shared UI components and utilities  
  │   └── Package.swift
  ├── DifferServices/        # Service layer (Git, XCResult, image comparison)
  │   └── Package.swift
  └── DifferUI/              # SwiftUI views and application state
      └── Package.swift
```

### Dependencies

Each module can have its own dependencies:

- **DifferCore**: Foundation-only (no external deps)
- **DifferServices**: swift-log for logging
- **DifferUI**: Depends on DifferCore, DifferServices, DifferKit
- **Main App**: Depends on DifferUI

### Common Commands

```bash
# Resolve/update dependencies
swift package resolve

# Clean build artifacts
swift package clean
# OR
rm -rf .build

# Reset entire package state
swift package reset

# Build specific configuration
swift build                    # debug (default)
swift build -c release         # release

# Run tests
swift test                     # all tests
swift test --parallel          # parallel execution
cd Modules/DifferCore && swift test  # specific module

# Generate Xcode project (if needed)
swift package generate-xcodeproj
```

## Environment Configuration

### Git Bare Repository Access

**Issue**: Git 2.53+ restricts SPM from accessing bare repositories (dependency cache).

**Solution**: Already configured in CI. For local development, if you encounter errors:

```bash
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="safe.bareRepository"
export GIT_CONFIG_VALUE_0="all"
```

Add to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence:

```bash
# Swift Package Manager - Git bare repository access
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="safe.bareRepository"
export GIT_CONFIG_VALUE_0="all"
```

### Xcode Version

This project requires **Xcode 15.2** or later.

Check your version:
```bash
xcode-select -p
swift --version
```

Switch versions:
```bash
sudo xcode-select -s /Applications/Xcode_15.2.app/Contents/Developer
```

## SwiftLint Configuration

### Setup

Install SwiftLint:
```bash
brew install swiftlint
```

### Configuration

`.swiftlint.yml` is configured with:

- **Included paths**: `App/`, `Modules/`
- **Excluded paths**: `.build/`, `.swiftpm/`, `__Snapshots__/`
- **Disabled rules**: trailing_whitespace, todo, line_length
- **Opt-in rules**: empty_count, empty_string, unused_import, etc.

### Running Locally

```bash
# Check violations
swiftlint lint

# Strict mode (CI uses this)
swiftlint lint --strict

# Auto-fix some issues
swiftlint --fix

# Check specific file
swiftlint lint --path Modules/DifferCore/Sources/Repository.swift
```

### Common Violations

See [CONTRIBUTING.md](CONTRIBUTING.md#swiftlint-violations) for examples and fixes.

## Module Dependencies

### Adding a New Dependency

1. **External Package** (e.g., from GitHub):

Edit the appropriate `Package.swift`:

```swift
// In Modules/DifferServices/Package.swift
dependencies: [
    .package(url: "https://github.com/apple/swift-log.git", from: "1.5.0"),
],
targets: [
    .target(
        name: "DifferServices",
        dependencies: [
            .product(name: "Logging", package: "swift-log"),
        ]
    ),
]
```

2. **Internal Module Dependency**:

```swift
// In Modules/DifferUI/Package.swift
dependencies: [
    .package(path: "../DifferCore"),
    .package(path: "../DifferServices"),
],
targets: [
    .target(
        name: "DifferUI",
        dependencies: ["DifferCore", "DifferServices"]
    ),
]
```

3. **Resolve and verify**:

```bash
swift package resolve
swift build
```

## Testing

### Test Structure

```
Modules/ModuleName/
  ├── Sources/           # Production code
  └── Tests/             # Test code
      └── ModuleNameTests/
          ├── *Tests.swift      # Test files
          └── TestFixtures.swift # Shared test data
```

### Running Tests

```bash
# All tests
swift test

# Specific module
cd Modules/DifferCore
swift test

# Parallel execution (faster)
swift test --parallel

# Specific test
swift test --filter DiffResultTests
```

### Test Requirements

- **Minimum one test file** per test target (SPM requirement)
- Empty test directories need a placeholder test
- Tests must be discoverable (XCTest-based currently)

### Snapshot Testing

Snapshot tests are in `Tests/__Snapshots__/`:

```bash
# Record new snapshots
RECORD_SNAPSHOTS=1 swift test

# Compare against snapshots (normal)
swift test
```

## Troubleshooting

### "No such module" Errors

1. Check module is in dependencies:
   ```bash
   swift package show-dependencies
   ```

2. Verify import matches product name:
   ```swift
   import DifferCore  // Product name, not package name
   ```

3. Resolve dependencies:
   ```bash
   swift package resolve
   ```

### Build Failures

1. **Clean build**:
   ```bash
   rm -rf .build
   swift build
   ```

2. **Check module compilation**:
   ```bash
   cd Modules/DifferCore
   swift build
   ```

3. **Verify dependencies**:
   ```bash
   swift package resolve
   ```

### SwiftLint Issues

1. **Exclude build directories** (already in config):
   ```yaml
   excluded:
     - .build
     - "**/. build"
     - Modules/**/.build
   ```

2. **Check which files are linted**:
   ```bash
   swiftlint files
   ```

3. **Disable rule temporarily** (in file):
   ```swift
   // swiftlint:disable rule_name
   problematic code here
   // swiftlint:enable rule_name
   ```

### Test Discovery Issues

If tests aren't discovered:

1. Ensure test class inherits `XCTestCase`
2. Test methods start with `test`
3. File is in correct directory: `Tests/ModuleNameTests/`
4. Rebuild:
   ```bash
   swift package clean
   swift build
   swift test
   ```

## CI/CD Integration

See `.github/workflows/ci.yml` for CI configuration.

CI runs on every push/PR:
- Swift 5.9 on macOS 14
- Xcode 15.2
- Parallel tests where possible
- SwiftLint strict mode
- Both debug and release builds

## Swift Agent Skills

We maintain a fork of the community Swift agent skills catalog as a git submodule:

**Location**: `.github/swift-agent-skills/`  
**Upstream**: [dehcast/Swift-Agent-Skills](https://github.com/dehcast/Swift-Agent-Skills) (forked from twostraws/swift-agent-skills)

### Accessing the Skills Catalog

The catalog is included as a submodule. After cloning:

```bash
# Initialize and update submodule
git submodule update --init --recursive

# View the catalog
open .github/swift-agent-skills/README.md
```

### Recommended Skills for Differ

Based on our tech stack:
- **Swift Testing Pro** - Better test writing and fixtures
- **SwiftUI Pro** - UI development patterns
- **Swift Concurrency Pro** - Async/await for image loading
- **iOS Code Audit** - Catch issues before CI
- **SwiftData Pro** - If we add persistence later

### Installing Individual Skills

Skills can be installed to your Copilot environment from the catalog:

```bash
# Example: Install Swift Testing Pro to user scope
# See individual skill repos in the catalog for specific URLs
```

### Updating the Catalog

To pull latest changes from upstream:

```bash
cd .github/swift-agent-skills
git pull origin main
cd ../..
git add .github/swift-agent-skills
git commit -m "chore: update swift-agent-skills catalog"
```

## Performance Tips

### Faster Builds

1. **Use debug builds during development**:
   ```bash
   swift build  # Not -c release
   ```

2. **Parallel compilation** (default in SPM):
   Already enabled, uses all CPU cores

3. **Incremental builds**:
   Don't clean unless necessary

### Faster Tests

1. **Run specific modules**:
   ```bash
   cd Modules/DifferCore && swift test
   ```

2. **Parallel test execution**:
   ```bash
   swift test --parallel
   ```

3. **Filter to specific tests**:
   ```bash
   swift test --filter DiffResultTests
   ```

## Useful Links

- [Swift Package Manager Documentation](https://www.swift.org/package-manager/)
- [SwiftLint Rules Reference](https://realm.github.io/SwiftLint/rule-directory.html)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [Swift Testing](https://developer.apple.com/documentation/testing)
