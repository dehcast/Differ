# Differ Testing Strategy

This document outlines the testing approach for the Differ project.

## Test Organization

### 1. Unit Tests

**DifferCore Tests** (`Modules/DifferCore/Tests/`)
- `SnapshotTestTests.swift` - Tests for SnapshotTest model
- `DiffResultTests.swift` - Tests for DiffResult calculations
- `TestRunTests.swift` - Tests for TestRun statistics

**DifferUI Tests** (`Modules/DifferUI/Tests/`)
- `TestListViewModelTests.swift` - ViewModel logic (filtering, searching, selection)
- `DiffViewModelTests.swift` - ViewModel logic (zoom, overlay, loading states)
- `TestFixtures.swift` - Shared mock data for all tests

### 2. Snapshot Tests

**DifferUI Snapshot Tests** (`Modules/DifferUI/Tests/`)
- `DiffViewSnapshotTests.swift` - Visual regression tests for DiffView
- `TestListViewSnapshotTests.swift` - Visual regression tests for TestListView
- `PreferencesViewSnapshotTests.swift` - Visual regression tests for PreferencesView
- `MainWindowSnapshotTests.swift` - Full window layout tests

## Running Tests

### Run All Tests
```bash
cd /path/to/Differ
swift test
```

### Run Module-Specific Tests
```bash
cd Modules/DifferCore
swift test

cd Modules/DifferUI
swift test
```

### Run in Xcode
```bash
open Package.swift
# ⌘U to run all tests
# ⌘⌥U to run last test
```

## Test Coverage Goals

| Module | Coverage Target | Current Status |
|--------|----------------|----------------|
| DifferCore | 90%+ | ✅ Models covered |
| DifferKit | 80%+ | ⏳ Pending implementation |
| DifferServices | 80%+ | ⏳ Pending implementation |
| DifferUI | 70%+ | ✅ ViewModels + Snapshots |

## Snapshot Testing

### First Run
On first run, snapshot tests will **record** reference images:
```bash
cd Modules/DifferUI
swift test
```

Reference images are saved to:
```
Modules/DifferUI/Tests/__Snapshots__/
├── DiffViewSnapshotTests/
├── TestListViewSnapshotTests/
├── PreferencesViewSnapshotTests/
└── MainWindowSnapshotTests/
```

### Subsequent Runs
Tests compare rendered views against reference images and **fail** if they differ.

### Updating Snapshots
When UI changes are intentional:
```bash
# Set environment variable to record new snapshots
SNAPSHOT_RECORDING=1 swift test

# Or delete snapshots and re-run
rm -rf Modules/DifferUI/Tests/__Snapshots__
swift test
```

### Reviewing Snapshot Failures
When a snapshot test fails:
1. Check the failure diff in Xcode test results
2. **Dogfooding**: Use Differ itself to review the change! (Week 7+)
3. If intentional, re-record snapshots
4. If bug, fix and re-run

## Test Fixtures

`TestFixtures.swift` provides mock data:
- `mockImage()` - Generate colored test images
- `passedTest`, `failedTest`, `newTest`, `missingTest` - Sample SnapshotTests
- `sampleDiffResult` - Sample comparison result
- `allTests` - Collection for testing lists

## Continuous Integration

Tests run on:
- ✅ Every commit to main
- ✅ Every pull request
- ✅ Nightly builds

CI configuration:
```yaml
# .github/workflows/test.yml
- name: Run tests
  run: swift test --parallel
```

## Testing Best Practices

### Unit Tests
- **Fast**: No network, no file I/O, no UI rendering
- **Isolated**: Test one thing at a time
- **Deterministic**: Same input = same output
- **Clear**: Test names describe what they verify

### Snapshot Tests
- **Fixed sizes**: Always set `.frame(width:height:)` on views
- **Fixed appearance**: Test in light mode only (for consistency)
- **Minimal state**: Test one state per snapshot
- **Meaningful names**: `testThreePanelLayout_WithImages` not `test1()`

### Mock Services
- Keep mocks simple and predictable
- Return fixture data, not random/dynamic data
- Fail tests explicitly for unimplemented methods

## Future Additions

### Phase 2 (Weeks 4-6)
- [ ] Integration tests for XCResult parsing
- [ ] Service layer unit tests
- [ ] Performance tests for image comparison

### Phase 3 (Weeks 7-8)
- [ ] Git service unit tests
- [ ] Repository detection tests
- [ ] Dogfooding: Use Differ to review own snapshot failures

### Phase 4 (Weeks 9-11)
- [ ] Test dependency graph logic
- [ ] Intelligent test selection tests
- [ ] Watch mode tests

### Phase 5 (Weeks 12-14)
- [ ] End-to-end tests
- [ ] Performance benchmarks
- [ ] Accessibility tests

## Dogfooding Plan

Starting **Week 7**, we'll use Differ to review its own snapshot test failures:

1. Make a UI change to DiffView
2. Run snapshot tests → they fail
3. Run Differ app
4. Load Differ's own `.xcresult`
5. Review the visual diff in Differ itself
6. Approve or iterate

This provides real-world usage feedback and validates the tool works as intended.

## Test Metrics

Track and improve:
- **Code coverage** (aim for 80%+)
- **Test execution time** (aim for <30s total)
- **Snapshot count** (currently: 28 snapshots)
- **Failure rate** (aim for 0% on main branch)

## Resources

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [SnapshotTesting Library](https://github.com/pointfreeco/swift-snapshot-testing)
- [Testing Best Practices](https://developer.apple.com/documentation/xcode/testing-your-apps-in-xcode)
