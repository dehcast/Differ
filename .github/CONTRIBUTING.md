# Contributing to Differ

Thank you for contributing to Differ! This document provides guidelines for development workflows.

## Development Setup

### Prerequisites
- macOS 13.0+
- Xcode 15.2+
- Swift 5.9+
- SwiftLint (install via Homebrew: `brew install swiftlint`)

### Initial Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/dehcast/Differ.git
   cd Differ
   ```

2. Initialize submodules (Swift Agent Skills catalog):
   ```bash
   git submodule update --init --recursive
   ```

3. Install git hooks (recommended):
   ```bash
   chmod +x scripts/install-hooks.sh
   ./scripts/install-hooks.sh
   ```

4. Resolve dependencies:
   ```bash
   swift package resolve
   ```

5. Build the project:
   ```bash
   swift build
   ```

## Before Creating a Pull Request

### Local Validation (Required)

Run these commands before pushing:

1. **Run SwiftLint** (catches style violations):
   ```bash
   swiftlint lint --strict
   ```

2. **Run all tests**:
   ```bash
   # Core module tests
   cd Modules/DifferCore && swift test --parallel && cd ../..
   
   # Or from root
   swift test --parallel
   ```

3. **Build in both configurations**:
   ```bash
   swift build              # debug
   swift build -c release   # release
   ```

### Git Hooks (Automated)

If you've installed the git hooks, they will automatically:
- Run SwiftLint before every commit
- Prevent commits with linting violations
- Ensure tests pass before push

### Temporarily Disabling Hooks

To temporarily disable hooks (not recommended):
```bash
# Uninstall
rm .git/hooks/pre-commit .git/hooks/pre-push

# Restore
./scripts/install-hooks.sh
```

Note: All commits **must** pass CI checks before merging, regardless of local hooks.

## Pull Request Requirements

### CI Checks (All Must Pass)
- ✅ Test (5.9) - All unit tests must pass
- ✅ Build (debug) - Debug build must succeed
- ✅ Build (release) - Release build must succeed
- ✅ SwiftLint - Zero violations allowed
- ✅ Check Module Compilation - All modules must compile
- ✅ Test Coverage Report - Coverage data collected
- ✅ Compilation Time Check - Build performance tracked

### Code Review
- ✅ **1 approval required from @dehcast**
- ✅ Stale reviews dismissed on new pushes
- ✅ All conversations must be resolved
- ❌ No force-push allowed after review

### PR Guidelines
- Keep PRs focused and reasonably sized
- Write clear, descriptive PR titles
- Reference related issues with `Fixes #123` or `Relates to #456`
- Update documentation if changing public APIs
- Add tests for new functionality

## Development Workflow

### Creating a Feature Branch
```bash
git checkout -b feature/your-feature-name
```

### Making Changes

1. Write your code following Swift conventions
2. Add tests for new functionality
3. Update documentation if needed
4. Run local validation (see above)

### Committing Changes
```bash
git add .
git commit -m "feat: add image comparison feature"
```

Commit message format:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation only
- `test:` - Adding or fixing tests
- `refactor:` - Code restructuring
- `perf:` - Performance improvements
- `chore:` - Maintenance tasks

### Pushing Changes
```bash
git push origin feature/your-feature-name
```

### Creating a Pull Request

1. Go to GitHub and create a PR from your branch to `main`
2. Fill out the PR description template
3. Request review from @dehcast
4. Wait for CI to pass (all checks must be green)
5. Address any review feedback
6. Wait for approval before merging

## Common Issues & Solutions

### Git Bare Repository Errors

If you see SPM errors about bare repositories:
```bash
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0="safe.bareRepository"
export GIT_CONFIG_VALUE_0="all"
```

This workaround is for local use on Git 2.53+ and is not currently needed in CI.

### SwiftLint Violations

Common violations and fixes:

**Trailing commas**:
```swift
// ❌ Bad
let items = [1, 2, 3,]

// ✅ Good
let items = [1, 2, 3]
```

**Large tuples** (use structs instead):
```swift
// ❌ Bad
func compare() -> (Double, Double, Int) { ... }

// ✅ Good
struct ComparisonResult {
    let score: Double
    let threshold: Double
    let matches: Int
}
func compare() -> ComparisonResult { ... }
```

**Multiple trailing closures**:
```swift
// ❌ Bad
Button("Title") { action() } label: { Icon() }

// ✅ Good
Button(action: { action() }, label: { Icon() })
```

### Test Failures

If tests fail locally:

1. Check model API signatures match test expectations
2. Ensure test fixtures use correct parameter names
3. Verify enum values match (e.g., `.structural` not `.structuralSimilarity`)
4. Check parameter order (e.g., `computationTime` before `algorithm`)

### Build Failures

If modules don't compile:

1. Check all dependencies are resolved: `swift package resolve`
2. Clean build folder: `rm -rf .build`
3. Verify module visibility (public/internal access control)
4. Check `Package.swift` dependencies are correctly declared

## Project Structure

```
Differ/
├── App/                    # Main macOS application
├── Modules/
│   ├── DifferCore/        # Core models and logic
│   ├── DifferKit/         # UI components
│   ├── DifferServices/    # Business logic services
│   └── DifferUI/          # SwiftUI views and state
├── .github/
│   ├── workflows/         # CI/CD configuration
│   └── CONTRIBUTING.md    # This file
└── scripts/               # Development scripts
```

## Testing Guidelines

### Unit Tests
- Place in `Modules/*/Tests/` directories
- Test one component at a time
- Use descriptive test names: `testImageComparisonReturnsCorrectScore`
- Mock external dependencies

### Snapshot Tests
- Use for visual regression testing
- Place snapshots in `Tests/__Snapshots__/`
- Update with `RECORD_SNAPSHOTS=1` environment variable
- Review snapshot changes carefully in PRs

## Code Style

We use SwiftLint with strict settings. Key conventions:

- **Naming**: camelCase for variables/functions, PascalCase for types
- **Access control**: Explicit public/private/internal
- **Line length**: Generally 120 characters (flexible for SwiftUI)
- **Formatting**: 2-space indentation, no trailing whitespace
- **Comments**: Only when clarifying complex logic
- **Imports**: No unused imports, one per line

## Getting Help

- **Questions**: Open a GitHub Discussion
- **Bugs**: Open a GitHub Issue with reproduction steps
- **Security**: Email dehcast (don't open public issues)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project (see LICENSE file).
