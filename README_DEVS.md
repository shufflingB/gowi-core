# Developer Documentation
This document contains technical information for developers working on or contributing to the Gowi codebase.

## Quick Start for Developers
### Build Requirements
- **Target Platform**: macOS Sequoia 15.0+
- **Development**: Xcode 16.0+ recommended
- **CloudKit**: Requires paid Apple Developer Account for sync functionality
- **Pandoc**: For building help documentation

### Building and Testing
The app consists of an AppModel framework and a SwiftUI (mostly) GUI implementation that uses that framework.

There is no dependency linkage between either the AppModel and the App, or between any of the tests that run against them (in order to reduce overwhelming during refactoring operations). 

**TL;DR; builds and the tests of AppModel and the App, can be broken without the main appModel or app target builds failing.**   

#### Overview complete building and testing cycle from clean for Debug (with Pandoc installed), 
```
# 1) Build AppModel
xcodebuild -scheme AppModelScheme -configuration Debug build

# 2) Build (app + tests) and run AppModel tests
xcodebuild -scheme AppModelScheme test -only-testing:GowiAppModelTests

# 3) Build App (pick up changes from AppModel)
xcodebuild -scheme GowiAppScheme -configuration Debug build

# 4) Build (app + integration tests) and run quick App to AppModel integration tests 
xcodebuild -scheme GowiAppScheme test -only-testing:GowiTests

# 5) Build (app + e2e tests) and run very slow **(1hr+)** e2e App tests
xcodebuild -scheme GowiAppScheme test -only-testing:GowiAppTests
```

Building and testing details:
* AppModel:
	* Source root directory: `.../GowiAppModel`
	* Build: `xcodebuild -scheme AppModelScheme -configuration Debug build`
	* Test's directory: `.../GowiAppModel/Tests`
	* Build and run tests: `xcodebuild -scheme AppModelScheme test -only-testing:GowiAppModelTests`
* App:
	* Source root directory: '.../Gowi'
	* Build: `xcodebuild -scheme GowiAppScheme -configuration Debug build`
	* Integration tests directory: '.../Gowi/Tests'
	* Build and run integration tests: `xcodebuild -scheme GowiAppScheme test -only-testing:GowiTests`
* End to End Application tests:
	* Directory:  `.../GowiAppTests`
	* Build & run tests: `xcodebuild -scheme GowiAppScheme test -only-testing:GowiAppTests`

**Help System Architecture:**
- **Source**: Markdown files in `Gowi/Help/Source/`
- **Templates**: HTML templates and CSS in `Gowi/Help/Templates/`
- **Build Script**: `Gowi/Help/build-help.sh` converts Markdown to Help Book format
- **Integration**: Automatic build phase generates help during app compilation
- **Output**: Apple Help Book deployed to app bundle at `Gowi/Help/Generated/`

**Help Content Structure:**
- `index.md` - Main help page with overview and navigation
- `getting-started.md` - Basic usage guide for new users
- `features.md` - Comprehensive feature documentation
- `tips-and-tricks.md` - Advanced workflows and power user techniques

**Modifying Help Content:**
1. Edit Markdown files in `Gowi/Help/Source/`
2. Update templates in `Gowi/Help/Templates/` if needed
3. Build app - help generation runs automatically
4. Test help access via Help menu in running app

**Build Process:**

The help build system runs as an Xcode build phase and:
1. Converts Markdown files to HTML using pandoc
2. Applies custom styling and Apple Help Book structure
3. Generates search index for help content
4. Deploys complete help book to app bundle

Alternatively, it can be run manually with
`./Gowi/Help/build-help.sh`

## Architecture Overview

### Framework Structure

**GowiAppModel Framework**:
- **Purpose**: Standalone framework containing all data layer components
- **Location**: `GowiAppModel/` directory
- **Components**:
  - `AppModel.swift` - Core business logic and data management
  - `AppModel#Item.swift` - Item-specific operations and CRUD
  - `AppModel#ItemLink.swift` - ItemLink relationship management with priority system
  - `AppModel#Testing.swift` - Test utilities and fixtures
  - `Item#App.swift` - Item extensions for application use, including Encodable conformance for JSON export
  - `Gowi.xcdatamodeld/` - CoreData model definition with ItemLink entity
  - `CloudKitConfig.swift` - CloudKit configuration
  - `Tests/` - Framework-specific unit tests

**Gowi Application**:
- **Purpose**: Main application containing UI and interaction layer
- **Location**: `Gowi/` directory
- **Components**:
  - SwiftUI views and components
  - Window management and routing
  - Menu system and user interactions
  - Help documentation system
  - Application-specific tests

**Benefits of Framework Separation**:
- **SwiftUI friendly**: Much of SwiftUI's built in functionallity is only available in its `View` structs.
- **Decoupling**: Clear separation between data layer and UI
- **Independent Development**: AppModel can be developed and tested separately
- **Reusability**: Framework could potentially be used in other applications
- **Testability**: Framework tests run independently of UI complexity
- **Build Performance**: Framework can be built separately and cached

### Model StateView View (MSV) Pattern

![Model StateView View architecture](DevAssets/ModelStateViewViewDiagram.png)

Gowi uses an empirically derived **Model StateView View (MSV)** architecture that balances performance, testability, and maintainability while working harmoniously with SwiftUI's built-in functionality.

**Architecture Components:**

- **Model**: Business logic and data (`AppModel` in GowiAppModel framework)
  - Singleton pattern for shared state
  - CoreData + CloudKit integration with ItemLink junction table system
  - Comprehensive undo support with ItemLink-aware operations
  - Per-parent priority management via ItemLink entities

- **StateView**: High-level SwiftUI View (e.g., `Main`)
  - Minimal UI layout
  - Centralizes access to the app model and SwiftUI specific stores
  - Derives state and intents from app model and SwiftUI injected data for sub-Views
  - Reduces "prop-drilling" boilerplate
  - Example: `Main`, `Main#Model`, `Main#SidebarModel`

- **Views**: UI components
  - Derives state and intents from injected StateView properties and local state for pure one to one Layout View.
  - Easily testable with previews
  - Examples: `Main#DetailView`, `ItemView`

### Key Benefits
- **Performance**: Efficient state management
- **Compatibility**: Works with SwiftUI's `@StateObject`, `@FetchRequest`, etc.
- **Separation of Concerns**: Clear boundaries between layers
- **Testability**: Static intent methods enable unit testing
- **Minimal Boilerplate**: Reduces repetitive code

### Complete Implementation Architecture Stack

While the MSV diagram above shows the **conceptual architecture**, the actual implementation involves additional architectural layers that wrap around the core MSV pattern. Understanding this full stack is crucial for working with the codebase:

```
┌─────────────────────────────────────────────────────────────┐
│ App Level (GowiApp.swift)                                   │
│ • WindowGroup coordination                                  │
│ • URL scheme registration                                   │
│ • Global app state                                          │
├─────────────────────────────────────────────────────────────┤
│ Routing Layer (Main#WindowGroupRouteView.swift)            │
│ • URL deep linking (gowi:// scheme handling)               │
│ • Window creation and reuse logic                          │
│ • Route state management                                    │
│ • Cross-window coordination                                 │
├─────────────────────────────────────────────────────────────┤
│ Undo Management Layer (Main#WindowGroupUndoView.swift)     │
│ • UWFA (Undo Work Focus Area) coordination                 │
│ • Per-window undo stack management                         │
│ • Focus chain monitoring                                    │
│ • Cross-area undo isolation                                │
├─────────────────────────────────────────────────────────────┤
│ StateView Layer (Main.swift + Main#*Model.swift)           │
│ • MSV pattern coordinator (shown in diagram above)         │
│ • Window-specific state management                         │
│ • Intent method coordination                               │
│ • SwiftUI store integration (@FetchRequest, etc.)          │
├─────────────────────────────────────────────────────────────┤
│ View Layer (Main#*View.swift, ItemView.swift)              │
│ • Stateless presentation components                        │
│ • Layout separation pattern                                │
│ • SwiftUI view composition                                 │
│ • User interaction handling                                │
├─────────────────────────────────────────────────────────────┤
│ App Model Foundation (AppModel.swift)                      │
│ • Business logic and data operations                       │
│ • CoreData + CloudKit integration                          │
│ • Cross-window data consistency                            │
│ • Persistence and sync                                     │
└─────────────────────────────────────────────────────────────┘
```

### How the Layers Interact

**Data Flow Down (State & Intents)**:
1. **App Level** → Creates WindowGroup and handles app lifecycle
2. **Routing Layer** → Decodes URLs, manages window creation/routing
3. **Undo Layer** → Wraps content, monitors focus changes
4. **StateView** → Coordinates app model access, derives view state
5. **Views** → Render UI based on state from StateView
6. **App Model** → Provides business logic and persistent data

**Events Flow Up (User Actions)**:
1. **Views** → Capture user interactions, call StateView intents
2. **StateView** → Processes intents, calls App Model operations
3. **App Model** → Executes business logic, updates data
4. **Undo Layer** → Registers undo operations, manages focus areas
5. **Routing Layer** → Updates route state, handles navigation
6. **App Level** → Coordinates global state changes

### Key Implementation Patterns

**Wrapper Pattern**: Each layer wraps the one below it:
```swift
// In GowiApp.swift
WindowGroup(id: "Main", for: WindowGroupRoutingOpt.self) { $route in
    WindowGroupRouteView(...) {          // Routing wrapper
        WindowGroupUndoView {             // Undo wrapper  
            Main(...)                     // StateView (MSV core)
        }
    }
}
```

**Separation of Concerns**: Each layer has a focused responsibility:
- **Routing**: "Which window should handle this URL?"
- **Undo**: "What undo behavior should this interaction have?"
- **StateView**: "What state do my child views need?"
- **Views**: "How should this state be displayed?"
- **App Model**: "How should this business operation be executed?"

### Why This Architecture Matters

This layered approach enables Gowi's sophisticated features:
- **Deep Linking**: URL routing layer handles `gowi://` URLs intelligently
- **Smart Undo**: UWFA system prevents cross-contamination between work areas
- **Multi-Window**: Routing coordinates multiple windows sharing the same data
- **Platform Integration**: Each layer handles specific macOS integration concerns
- **Testability**: Clear boundaries enable testing at each layer independently

**For New Developers**: Start by understanding the MSV pattern (the diagram above), then work outward to understand how routing and undo management enhance the core architecture without breaking the fundamental design.

## Undo Management System (UWFA)

### Understanding Undo Work Focus Areas (UWFA)

**Problem**: SwiftUI's default undo behavior creates poor user experiences:
- `TextEditor` never clears its undo stack, leading to cross-contamination
- Users can accidentally undo unrelated changes from different UI areas
- Multiple windows can interfere with each other's undo operations

**Solution**: **Undo Work Focus Areas (UWFA)** - logical groupings of UI controls that should share undo behavior.

### UWFA Concept

UWFA groups undoable changes to attempt to ensure they are:
1. **Contextually Appropriate**: Only undo changes relevant to focus of the user's current work
2. **Properly Granular**: Attempts to operate at meaningful semantic levels according to activity.
3. **Session Isolated**: Different UI areas have independent undo stacks

**Example Scenarios**:
- **Cross-Window**: User has two windows with different items - undoing in one shouldn't affect the other
- **Cross-Control**: User switches from editing item notes to adjusting completion date - overeager undo shouldn't affect the previous text edits
- **Granularity**: When editing paragraphs, undo operates on meaningful blocks, not individual characters

### UWFA Implementation

**Defined Areas** (in `Main.UndoWorkFocusArea`):
```swift
enum UndoWorkFocusArea {
    case content              // Item list operations
    case detailTitle         // Item title editing
    case detailCompletedDate // Date picker interactions  
    case detailNotes         // Notes text editing
}
```

**Focus Chain Setup**:
```swift
// Views declare their UWFA
.focusedValue(\.undoWfa, .detailTitle)

// WindowGroupUndoView monitors changes
.onChange(of: wfa) { newWFA in
    // Clear undo stack when switching between UWFAs
    windowUM?.removeAllActions()
}
```

**Special Cases**:
- **DatePicker Workaround**: macOS DatePicker popovers break focus tracking, requiring special handling to prevent unnecessary undo clearing
- **Window Switching**: Undo stacks clear when moving between windows

### Benefits
- **Predictable Behavior**: Users understand what will be undone
- **Context Isolation**: No cross-contamination between work areas
- **Professional Feel**: Matches behavior of established macOS apps

## ItemLink Architecture System

### Overview

**ItemLink** is a sophisticated junction table system that enables Items to have different priority values when they appear under different parent Items. This solves the fundamental challenge of hierarchical task management where the same item might need different ordering positions depending on the parent context.

### Key Benefits

- **Multi-Parent Support**: Same item can exist under multiple parents with independent priorities
- **Flexible Hierarchies**: Items can be organized differently in different contexts
- **Undo Integration**: All ItemLink operations are fully undoable
- **CloudKit Sync**: ItemLink relationships synchronize across device.

### Core Components

**ItemLink Entity** (`Gowi.xcdatamodeld`):
- `priority` (Double): Priority value for this specific parent-child relationship
- `parent` (Item): Parent item in the relationship
- `child` (Item): Child item in the relationship
- Marked as `syncable="YES"` for CloudKit integration

**Key Methods** (`AppModel#ItemLink.swift`):
- `itemLinkAdd(parent:child:priority:)`: Creates new ItemLink relationship
- `itemLinkRemove(parent:child:)`: Removes specific parent-child relationship
- `itemLinkUpdatePriority(parent:child:newPriority:)`: Updates priority for relationship
- `itemLinkRearrangeUsingPriority(...)`: Reorders items using priority system

**Item Extensions** (`Item#App.swift`):
- `childrenOrderedByPriority`: Returns children sorted by ItemLink priority
- `parentItemsViaLinks`: Returns all parent Items via ItemLink relationships
- `priority(withRespectTo:)`: Gets priority value for specific parent
- `setPriority(_:withRespectTo:)`: Sets priority for specific parent
- `childrenListAsSet` & `parentListAsSet`: Backwards compatibility accessors

### Usage Examples

**Creating Relationships**:
```swift
// Add item to parent with specific priority
appModel.itemLinkAdd(parent: projectA, child: sharedItem, priority: 100.0)
appModel.itemLinkAdd(parent: projectB, child: sharedItem, priority: 50.0)
```

**Accessing Ordered Children**:
```swift
// Get children in priority order for specific parent
let orderedChildren = parentItem.childrenOrderedByPriority
```

**Priority Management**:
```swift
// Update priority for specific relationship
sharedItem.setPriority(75.0, withRespectTo: projectA)
```

### Testing

**Primary Test Suite**: `Test055_AppModel_ItemLink_Priority_System.swift`
- Multi-parent relationship testing
- Independent priority validation
- ItemLink CRUD operations
- Undo/redo functionality

**SwiftUI Integration**: `Test_015_AppModel_SwiftUI_FetchRequest.swift`
- FetchRequest configuration for ItemLink entities
- SwiftUI binding validation

## CloudKit Integration

### Configuration

**Container Setup**:
1. Container name specified in `Signing & Capabilities` → `iCloud` section
2. Default: `macOSToDo` (editable in `Gowi/Gowi.entitlements`)
3. Build script auto-generates `CloudKitConfig.swift` from entitlements

**Development Modes** (via `GOWI_TESTMODE` environment variable):
- **`GOWI_TESTMODE=0`**: Clean in-memory store (no CloudKit)
- **`GOWI_TESTMODE=1`**: In-memory with 10 test items (no CloudKit)
  - Includes fixture item with predictable `ourId`: `70BF1680-CA95-48B5-BD0E-FCEAF7FEC4DD`
- **No variable**: Full CloudKit sync enabled

### Data Model Design

**Dual ID System**:
- **`ourId`**: Custom UUID for application-level identification
  - Used for deep linking and cross-device consistency
  - Predictable for testing and debugging
- **CloudKit Record ID**: System-generated for sync operations
  - Handles conflicts and merging automatically
  - Managed by `NSPersistentCloudKitContainer`

**ItemLink Integration**:
- ItemLink entities are marked `syncable="YES"` for CloudKit sync
- Priority values synchronize across devices
- Relationship consistency maintained through CloudKit's conflict resolution

**Best Practices Demonstrated**:
```swift
// Enable history tracking for CloudKit
storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)

// Enable remote change notifications
storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
```

**Conflict Resolution**: Uses `NSMergeByPropertyObjectTrumpMergePolicy` (local changes win)

### CloudKit Console Access
Monitor at [https://icloud.developer.apple.com](https://icloud.developer.apple.com):
1. Select container (e.g., `iCloud.macOSToDo`)
2. Navigate: `Records` → `Data` → `Private Database`
3. Select `com.apple.coredata.cloudkit.zone`
4. Query `CD_Item` record type

### Debugging Tools
```swift
// Print all items with sync status
AppModel.shared.debugPrintAllItems()

// Monitor pending sync operations
AppModel.shared.hasUnPushedChanges
```

## JSON Export Implementation

### Overview
Gowi provides individual item export functionality through the File menu, allowing users to save todo items as structured JSON files for backup, data analysis, or integration with external tools.

### Implementation Architecture

**Data Layer** (`Item#App.swift`):
- **Encodable Conformance**: Item class implements Swift's `Encodable` protocol
- **ISO8601 Date Format**: All dates exported in standardized ISO8601 format for universal compatibility
- **Pretty Printing**: JSON output uses `.prettyPrinted` formatting for human readability
- **Null Handling**: Incomplete items export completion date as "null" string

```swift
extension Item: Encodable {
    enum CodingKeys: String, CodingKey {
        case title, ourId, creationDate, completionDate, notes
    }
    
    public func encode(to encoder: Encoder) throws {
        // Encodes title, notes, dates, and unique ID
        // Uses ISO8601DateFormatter for consistent date representation
    }
}
```

**UI Integration** (`Menubar#fileCommands.swift`):
- **Selection-Based Availability**: Only enabled when exactly one item is selected
- **File Save Dialog**: Uses `NSSavePanel` with JSON file type restrictions
- **Error Handling**: Graceful failure with user-friendly `NSAlert` dialogs
- **Keyboard Shortcut**: ⌘E for quick access

**Menu State Management**:
- **FocusedValue Integration**: Accesses selection state via SwiftUI's focused value system
- **Dynamic Enable/Disable**: Menu item automatically enables/disables based on selection
- **Accessibility Support**: Proper accessibility identifiers for UI automation

### File Format Specification

**JSON Structure**:
```json
{
  "title": "Item title text",
  "ourId": "UUID-string-format",
  "creationDate": "2025-01-15T10:30:00Z",
  "completionDate": "2025-01-16T14:45:00Z", // or "null" for incomplete
  "notes": "Item notes content"
}
```

**Date Handling**:
- **Input Format**: UI displays dates using `.short` date/time style in local timezone
- **Output Format**: JSON exports dates as ISO8601 UTC strings
- **Timezone Conversion**: Automatic conversion preserves absolute time while changing representation

### Testing Strategy

**Unit Testing** (`Test_100_ItemExportJSON.swift`):
- JSON structure validation
- Date format verification
- File I/O operations
- Error handling scenarios

**UI Testing** (`Test_520_JsonImportAndExport.swift`):
- Complete export workflow validation
- Menu integration testing
- File save dialog interaction
- Cross-timezone date validation with 60-second tolerance

**Key Testing Challenges**:
- **Date Format Mismatch**: UI shows local timezone `.short` format, JSON exports UTC ISO8601
- **Save Panel Automation**: macOS save dialog requires specialized UI automation techniques
- **Timezone Testing**: Robust comparison between different date representations

### Usage Patterns

**User Workflow**:
1. Select exactly one item in the content list
2. Use File → Export JSON (⌘E) or keyboard shortcut
3. Choose save location in file dialog
4. Confirm save operation

**Common Use Cases**:
- **Data Backup**: Personal archive of important todos
- **External Integration**: Import into spreadsheets, databases, or other tools
- **Data Analysis**: Processing completion patterns and task metrics
- **Migration**: Moving data between different task management systems

## Focus Management & Menu Integration

### The macOS Focus Challenge

**Problem**: SwiftUI on macOS treats key window status and focus separately. New windows don't establish proper `@FocusedValue` propagation until user interaction occurs.

**Impact**: Menu commands lose access to window state immediately after window creation.

### Solution: FocusedValues + Workaround

**FocusedValues System**:
```swift
// Publishing state up the chain (in Main.swift)
.focusedValue(\.mainStateView, self)

// Accessing state (in Menubar.swift)
@FocusedValue(\.mainStateView) var mainStateView: Main?
```

**@FocusState Workaround**:
```swift
// In Main#ContentView.swift
@FocusState private var isInitiallyFocused: Bool

var body: some View {
    // ... view content
    .focused($isInitiallyFocused)
    .onAppear {
        isInitiallyFocused = true  // Establish focus chain immediately
    }
}
```

This ensures menu commands work reliably from window creation.

## Window Management & Routing

### Application States

**1. Not Running**: Standard macOS launch via Dock, Finder, or URL schemes

**2. Running with No Windows**: 
- Follows macOS convention (app stays running)
- Menu bar remains fully functional
- All commands work normally
- File operations remain available

**3. Running with Windows**:
- Each window has sequential ID: `Main-AppWindow-1`, `Main-AppWindow-2`. **NB**: Important when UI testing - Closing all windows does not reset this sequence; resets only when the application is restarted.
- Shared data model (`AppModel.shared`)
- Independent view states per window
- Immediate data synchronization across windows

### Smart Routing Logic

**Window Reuse Strategy**:
1. Check existing windows for matching content
2. Raise existing window if found
3. Create new window only if needed

**Exception**: `newItem` routes always create new windows to prevent overwriting edits.

## URL Routing Implementation

### URL Scheme Structure
**Pattern**: `gowi://main/v1/[action]?[parameters]`

**Components**:
- **Scheme**: `gowi://` (registered custom URL)
- **Host**: `main` (window type)
- **Version**: `v1` (API versioning)
- **Action**: Operation to perform
- **Parameters**: Query parameters for targeting

### Route Processing

**Encoding** (`Main.urlEncode`):
```swift
// Convert internal state to shareable URLs
let route = WindowGroupRoutingOpt.showItems(...)
let url = Main.urlEncode(route)
```

**Decoding** (`Main.urlDecode`):
```swift
// Convert URLs to internal routing structures
let route = Main.urlDecode(incomingURL)
```

**Smart Routing Matrix**:
Key concept is don't change the contents of windows that user already has setup as it will be annoying. Which translates as only ever raising windows showing exactly what is requested, anything else gets a new window opened (maybe at some point may give option to add tab instead ...). 
- **List Views**: Reuse if same content, otherwise create new
- **Specific Items**: Reuse if same item, otherwise create new  
- **New Items**: Always create new window
- **Default**: Reuse Waiting list window or create new

## Testing Architecture

### Test Strategy
- **Unit Tests**: Business logic in `AppModel` and intent methods
- **UI Tests**: Complete user workflows and platform integration
- **Preview Tests**: Layout components with mock data

### Test Environment Control
```swift
// Test fixtures with predictable data
AppModel.sharedInMemoryWithTestData

// Environment control
GOWI_TESTMODE=1  // Enables test fixtures
```

### Key Test Patterns
- **Intent Testing**: Static methods enable isolated business logic testing
- **Layout Testing**: Separated UI components support comprehensive previews
- **URL Testing**: Predictable `ourId` values enable deep linking validation
- **ItemLink Testing**: Comprehensive validation of relationship and priority management
  - **Unit Tests**: `GowiAppModelTests/Test055_AppModel_ItemLink_Priority_System.swift` - ItemLink operations
  - **SwiftUI Integration**: `GowiAppModelTests/Test_015_AppModel_SwiftUI_FetchRequest.swift` - FetchRequest validation
- **JSON Export Testing**: Comprehensive validation of data export functionality
  - **Unit Tests**: `GowiAppModelTests/Test_100_ItemExportJSON.swift` - JSON structure validation
  - **UI Tests**: `GowiAppTests/Test_520_JsonImportAndExport.swift` - End-to-end export workflow
  - **Date Format Validation**: Timezone-aware comparison between UI formats and ISO8601 JSON output

## Key Implementation Files

**Core Architecture**:
- `GowiAppModel/AppModel.swift` - Central business logic and data management
- `GowiAppModel/AppModel#ItemLink.swift` - ItemLink relationship management system
- `GowiAppModel/Item#App.swift` - Item extensions with ItemLink-aware accessors
- `Gowi/MainWindow/Main.swift` - Primary StateView for main window
- `Gowi/MainWindow/Main#Model.swift` - Business logic intents

**Routing System**:
- `Gowi/MainWindow/Main#WindowGroupRouteView.swift` - URL routing and window coordination
- `Gowi/MainWindow/Main#UrlHandlingModel.swift` - URL encoding/decoding logic
- `Gowi/AppUrl.swift` - URL scheme definitions

**Undo Management**:
- `Gowi/MainWindow/Main#WindowGroupUndoView.swift` - UWFA implementation
- `Gowi/FocusedValues#App.swift` - Focus chain definitions

**UI Components**:
- `Gowi/MainWindow/Main#ContentView.swift` - Item list with search
- `Gowi/MainWindow/Main#DetailView.swift` - Multi-selection detail view
- `Gowi/MainWindow/ItemView.swift` - Individual item editing

**Menu System**:
- `Gowi/Menubars/Menubar.swift` - Menu coordination
- `Gowi/Menubars/Menubar#fileCommands.swift` - File operations, including JSON export implementation
- `Gowi/Menubars/Menubar#itemCommands.swift` - Item management
- `Gowi/Menubars/Menubar#windowCommands.swift` - Window operations

**Data Export**:
- `GowiAppModel/Item#App.swift` - JSON export functionality with Encodable conformance
- `Gowi/Defs/KbShortcuts.swift` - Keyboard shortcut definitions including JSON export (⌘E)
- `Gowi/Defs/AccessibilityIdentifiers.swift` - Accessibility IDs for export UI elements

## Development Tips

### Common Patterns
1. **StateView + Layout**: Separate dependency injection from UI logic
2. **Static Intents**: Enable testing without full StateView initialization
3. **UWFA Declaration**: Always declare appropriate focus areas for undo behavior
4. **URL Integration**: Provide shareable URLs for major app states

### Debugging Techniques
- Use `AppModel.debugPrintAllItems()` for data inspection
- Monitor `hasUnPushedChanges` for sync status
- Check focus chain with `@FocusedValue` debugging
- Test URL routing with command line: `open "gowi://main/v1/showitems?fid=All"`

### Performance Considerations
- StateViews minimize view rebuilds through centralized state
- Efficient filtering with SwiftUI dependency tracking
- Lazy loading patterns in list views
- Minimal undo stack clearing to preserve user context

## Contributing Guidelines

### Code Style
- Follow existing MSV architecture patterns
- Document complex algorithms (especially UWFA logic and ItemLink operations)
- Provide SwiftUI previews for UI components
- Include inline comments for non-obvious code

### Testing Requirements
- Unit tests for all business logic, including ItemLink operations
- UI tests for user-facing workflows
- Preview tests for layout components
- URL routing validation tests
- ItemLink relationship and priority testing

### Architecture Compliance
- Use StateView pattern for new windows/scenes
- Implement appropriate UWFA declarations
- Follow URL routing conventions
- Maintain separation between Model, StateView, and View layers
- Use ItemLink system for all parent-child Item relationships
- Ensure backwards compatibility through computed properties

---

**See also**: The extensive source code documentation throughout the codebase provides detailed implementation notes and architectural decisions.
