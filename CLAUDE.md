# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Gowi is a SwiftUI-based todo application for macOS that demonstrates comprehensive macOS platform integration and serves as a reference implementation for SwiftUI best practices. It uses a "Model StateView View" (MSV) architecture pattern and integrates CoreData with CloudKit for data persistence and sync.

## Guidelines

- **Code Guidance**: Must always let the user know if the approach they have, or are implementing is not idiomatic, deprecated, or there are better, more modern approaches becoming popular unless they specifically instructed not to for a particular implementation. If instructed not to do so then must suggest adding developer documentation containing an explanation for future development entities as to the rational for the deviation.

## Build and Test Commands

This is an Xcode project with multiple schemes. Common development commands:

```bash
# Build the main application
xcodebuild -scheme GowiAppScheme -configuration Debug build

# Build the AppModel framework
xcodebuild -scheme AppModelScheme -configuration Debug build

# Run all tests
xcodebuild -scheme GowiAppScheme -destination 'platform=macOS' test

# Run only AppModel framework tests
xcodebuild -scheme AppModelScheme -destination 'platform=macOS' test -only-testing:GowiAppModelTests

# Run only app UI tests  
xcodebuild -scheme GowiAppScheme -destination 'platform=macOS' test -only-testing:GowiAppTests

# Clean build
xcodebuild -scheme GowiAppScheme clean
```

## Architecture

### Framework Structure
- **GowiAppModel**: Standalone framework containing all data layer components
  - `AppModel`: Business logic and data management
  - CoreData model and extensions
  - Item management and priority system
  - CloudKit integration
- **Gowi**: Main application containing UI and interaction layer
  - SwiftUI views and components
  - Window management and routing
  - Menu system and user interactions

### MSV (Model StateView View) Pattern
- **Model**: `AppModel` handles business logic and data (now in `GowiAppModel` framework)
- **StateView**: High-level views that centralize state management (e.g., `Main`)  
- **Views**: Stateless UI components that receive data and intents from StateViews

### Key Components
- **AppModel**: Singleton managing CoreData stack, business logic, and app state (GowiAppModel framework)
- **Main**: Root StateView handling window routing, state coordination, and sub-view intents
- **Item**: CoreData entity representing todo items with hierarchical relationships
- **URL Routing**: Custom `gowi://` scheme for deep linking to specific views and items

### File Naming Convention
Files use `#` delimiter for logical grouping:
- `Main#ContentView.swift` - Main window content view
- `Main#Model.swift` - Main window intents and state management
- `AppModel#Item.swift` - Item-related AppModel extensions

## Testing Infrastructure

### Test Modes
Set environment variable `GOWI_TESTMODE` to control test data:
- `GOWI_TESTMODE=0` - Clean slate, no test data
- `GOWI_TESTMODE=1` - Pre-populated with 10 test items

### Test Structure
- **AppModel Framework Tests** (`GowiAppModel/Tests/`): Test business logic, data models, and core functionality
- **App UI Tests** (`GowiAppTests/`): Test complete user workflows and UI interactions
- **Test Utilities**: `AppModel#Testing.swift` provides consistent test fixtures

### Running Single Tests
```bash
# Run specific AppModel framework test
xcodebuild -scheme AppModelScheme test -only-testing:GowiAppModelTests/Test_010_AppModel_Item_Creation

# Run specific app UI test
xcodebuild -scheme GowiAppScheme test -only-testing:GowiAppTests/Test_050_ItemCreation
```

## Development Notes

### CoreData + CloudKit
- Uses `NSPersistentCloudKitContainer` for iCloud sync
- Custom undo management integrates with SwiftUI's UndoManager
- `Item` entities support hierarchical parent-child relationships

### URL Scheme Support
Deep linking via `gowi://` URLs:
- `gowi://main/v1/newItem` - Create new item
- `gowi://main/v1/showitems?fid=All` - Show all items
- `gowi://main/v1/showitems?fid=All&id=<UUID>` - Show specific item

### Multi-Window Architecture
- Uses `WindowGroup` with routing parameters
- `@FocusedValues` communicate between windows and menubar
- Each window maintains independent state while sharing the AppModel

### Key Patterns
- **Shared Singleton**: `AppModel.shared` provides consistent instance across app and tests
- **Intent Pattern**: Static methods in Model extensions provide testable business logic
- **StateView Adapter**: High-level views inject dependencies into stateless child views
- **Comprehensive Undo**: All user actions are undoable through coordinated UndoManager usage

## Debugging

### CoreData SQL Debugging
Add launch argument in Xcode scheme: `-com.apple.CoreData.SQLDebug 1`

### Test Data Inspection
Use `AppModel.debugPrintAllItems()` to inspect current data state during development.

## Git Commit Guidelines
- Must not add credit information to commit messages. Just state the changes.
