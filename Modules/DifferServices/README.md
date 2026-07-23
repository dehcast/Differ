# DifferServices

Business logic and service implementations for the Differ application.

## Overview

This module contains all service implementations including image comparison, test execution, git operations, and XCResult parsing.

## Contents

### Services
- `ImageComparisonService` - Compare images and generate diffs
- `XCResultParser` - Parse .xcresult bundles
- `GitService` - Git repository operations
- `TestRunner` - Execute xcodebuild tests

### Protocols
- `ImageComparison` - Protocol for image comparison
- `XCResultParsing` - Protocol for XCResult parsing
- `GitOperations` - Protocol for git operations
- `TestExecution` - Protocol for test execution

## Dependencies

- `DifferCore` - Core types and models
- `DifferKit` - Utilities
- `XCResultKit` - External: XCResult parsing
- `swift-log` - External: Logging

## Usage

```swift
import DifferServices

let service = ImageComparisonService()
let result = try await service.compare(
    reference: refImage,
    current: curImage,
    algorithm: .pixelByPixel
)
```
