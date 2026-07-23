# DifferCore

Core data models, protocols, and types for the Differ application.

## Overview

This module contains the fundamental types used throughout the application. It has **no dependencies** and provides pure Swift types that can be used by all other modules.

## Contents

### Models
- `SnapshotTest` - Represents a single snapshot test with reference/failed/diff images
- `DiffResult` - Result of comparing two images
- `TestRun` - Tracks test execution with statistics
- `Repository` - Git repository representation
- `GitCommit` - Git commit information
- `GitFileChange` - File changes in git

### Enums
- `TestStatus` - Test result status (passed, failed, new, missing)
- `RunStatus` - Test run status (running, completed, failed)
- `DiffAlgorithm` - Available diff algorithms
- `SnapshotFramework` - Supported snapshot frameworks

## Dependencies

None - This is a pure Swift module with no external dependencies.

## Usage

```swift
import DifferCore

let test = SnapshotTest(
    testName: "MyViewTests.testAppearance",
    testTarget: "MyAppTests",
    status: .failed
)
```
