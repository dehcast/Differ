# DifferUI

SwiftUI views and ViewModels for the Differ application.

## Overview

This module contains all UI components, views, and view models following the MVVM pattern.

## Contents

### Views
- `MainWindow` - Main split view window
- `DiffView` - Three-panel image comparison
- `TestListView` - Searchable test list with filters
- `PreferencesView` - Settings UI

### ViewModels
- `DiffViewModel` - State management for diff view
- `TestListViewModel` - State management for test list

## Dependencies

- `DifferCore` - Core types and models
- `DifferKit` - UI utilities
- `SwiftUI` - UI framework
- `AppKit` - macOS native controls

## Usage

```swift
import DifferUI

struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            MainWindow()
        }
    }
}
```

## Architecture

All views follow MVVM pattern:
- Views are pure SwiftUI
- ViewModels manage state with `@Published` properties
- Services are injected via dependency injection
