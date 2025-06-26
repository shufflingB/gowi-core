# Introduction

Gowi (*Get On With It*) is a feature complete(ish) implementation in SwiftUI of a canonical "Todo" example application.

The goals of the project are for SwiftUI to:

1. Determine, document and demo how to:

    2. Achieve established platform norms using SwiftUI.
    2. Test that it does so.
    
2. Create a usable basic todo application that is suitable that can be used as the basis for future experimentation 
and development, e.g. add `iPadOS` version, Rich Text Descriptions, CLI API etc. 


# Supported platforms

Gowi runs on `macOS` and requires Sequoia version 15.0 or better 

# Current User Capabilities 

The app provides the user with an interface to create, update and manage work-package *todo* `Item`s. 

Each of the user's *todo* `Item`s have a unique Id, Title, Notes, Creation and Completion dates and a Priority attribute 
associated with it. 

And each of these attributes - Id and Creation date aside - may be altered by the user.

To help the user to find their `Item`s the app:

- Uses the `Item`'s Completion date to derive lists of them that are either:
	- Waiting for action sorted by their Priority relative to one and other. Or,
	- Done and sorted by completion date.
- Provides comprehensive URL routing and deep linking capabilities (see [URL Routing and Deep Linking](#url-routing-and-deep-linking) section below)

 
It guards against accidental user data loss through app termination with unsaved changes.

And the app persists the user's data - and is syncable to their other devices - via their private iCloud account. 

Further, on `macOs` it endeavours to follow the de-facto platform conventions for:

- Drag and drop list rearrangement, e.g. when adjusting `Item` priorities in the Waiting list.
- Keyboard shortcut keys and menu structures.
- Keyboard navigation.
- Pop-up text.
- Standard multi-window behavior (see [Window Management](#window-management) section below).
- Lists having context menus and are navigable by typing title characters.
- Universal undo and redo capabilities for user data.

![Gowi running on macOS Ventura](DevAssets/GowiRunningOnMacOSScreenshot.png  "Screenshot of Gowi running on macOS Ventura")



# Developer notes
## Compiling and testing

- Targets `macOS` Sequoia 15.XX.
- Testing
	- Unit test target is `GowiTests`
	- UI test test target is`GowiUITests`

## CloudKit Configuration and Development

The application uses a Private i.e. Gowi specific, per-user CloudKit container to persist and synchronise Items for the user. 

Basic CoreData functionality works and can be developed locally without a paid account, but unfortunately **CloudKit building and testing the CloudKit enabled version of Gowi will require a paid Apple Developer Account**.


### Container Configuration

1. The app uses the container name specified for the `Gowi` target in the `Signing & Capabilities` `iCloud` section, current default `macOSToDo`. This can also be directly edited in `Gowi/Gowi.entitlements`:
   ```xml
   <key>com.apple.developer.icloud-container-identifiers</key>
   <array>
       <string>iCloud.macOSToDo</string>
   </array>
   ```

2. As part of the build process a build script (`DevScripts/generate-cloudkit-config.sh`) extracts the container name from the entitlements file and generates `CloudKitConfig.swift` that is fed into the AppModel to avoid manual misconfiguration issues.


### CloudKit Console Access

Monitor and debug your CloudKit data at: [https://icloud.developer.apple.com](https://icloud.developer.apple.com)

- View records, schema, and sync status
- Debug sync conflicts and performance
- Monitor API usage and quotas
- Access requires the Apple ID associated with your Developer Account

The app uses a private i.e. per-user, database and a single Item record type. 

Records that have been synced from the app by CloudKIt can be seen in the CloudKit console by:
1. Selecting the apps's container in the UI, e.g. iCloud.macOSToDo
2. Clicking `Records` under `Data` sidebar entry.
3. Selecting `Private Database`
4. Selecting `com.apple.coredata.cloudkit.zone` (use a Zones query to fetch this information if not available )
5. Setting the RECORD TYPE as `CD_Item` and querying (if message about `record_names` not being queryable see [https://www.perplexity.ai/search/field-recordname-is-not-marked-HIqzKyFnT7OGYfzxU0Ig4A](https://www.perplexity.ai/search/field-recordname-is-not-marked-HIqzKyFnT7OGYfzxU0Ig4A) )

### Understanding Item's `ourId` vs CloudKit Record IDs

To uniquely identify items independently of backend implementation the system uses a second `ourId` UID on each `Item` record :

- **`ourId`**: Custom UUID attribute for application-level identification
  - Used for deep linking: `gowi://main/v1/showitems?fid=All&id=<UUID>`
  - Consistent across devices and test environments
  - Predictable for testing, debugging, export, and import.

- **CloudKit Record ID**: System-generated CloudKit identifier
  - Handles sync conflicts and merging
  - Opaque to the application layer
  - Managed automatically by `NSPersistentCloudKitContainer`

### Development and Testing Modes

Control CloudKit behavior via `GOWI_TESTMODE` environment variable:

- **`GOWI_TESTMODE=0`**: Clean in-memory store (no CloudKit sync)
- **`GOWI_TESTMODE=1`**: In-memory with 10 test items (no CloudKit sync)
  - Includes a fixture item with known `ourId`: `70BF1680-CA95-48B5-BD0E-FCEAF7FEC4DD`
  - Used for predictable deep linking tests and URL routing validation
- **No variable**: Full CloudKit sync enabled

### CoreData + CloudKit Integration Patterns

The app demonstrates several CloudKit best practices:

**Automatic Sync Configuration**:
```swift
// Enable history tracking for CloudKit
storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
// Enable remote change notifications  
storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
```

**Conflict Resolution**: Uses `NSMergeByPropertyObjectTrumpMergePolicy` (local changes win)

**Hierarchical Relationships**: Demonstrates parent-child relationships that sync correctly across devices

### Debugging Tools

**Built-in Debug Function**:
```swift
AppModel.shared.debugPrintAllItems() // Prints all items with ourIds and sync status
```

**Sync Status Monitoring**: The app tracks `hasUnPushedChanges` to show pending sync operations

**Known Issues**: The codebase includes a workaround (`houseKeepingHackToCleanUpInMemoryProblem`) for a CoreData/CloudKit bug where in-memory stores incorrectly persist data.

## FocusedValues and Menu Bar Communication

The app uses SwiftUI's `@FocusedValue` system to enable menu bar commands to access the current window's state, even though menu bars exist independently of any particular window.

### How FocusedValues Work

`@FocusedValue` passes data up the SwiftUI responder chain from focused views to parent containers. This enables:
- Menu commands to access the currently focused window's state
- Window-independent UI elements (like menu bars) to operate on the "active" window
- Multi-window applications to have context-aware menu commands

**Key Implementation Points**:
```swift
// In Main.swift - Publishing state up the chain
.focusedValue(\.mainStateView, self)

// In Menubar.swift - Accessing published state  
@FocusedValue(\.mainStateView) var mainStateView: Main?
```

### The macOS Focus Chain Design Limitation

SwiftUI on macOS treats key window status and focus separately. Newly opened windows don't establish a proper focus chain for `@FocusedValue` propagation until a user explicitly interacts with (clicks on or types into) a UI element within the window. This design limitation can leave menu commands without access to window state immediately after window creation.

### The @FocusState Workaround

To ensure reliable menu bar functionality, the app uses a `@FocusState` workaround in key views:

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

This approach artificially establishes the focus chain when the view appears, ensuring that `@FocusedValue` propagation works reliably from the moment a window is created.

**See the detailed explanation comment in `Gowi/MainWindow/Main#ContentView.swift` lines 16-25 for more technical context.**

## Expected app behaviour - see test cases under `GowiUITests`

Aside from playing with the app and reading the code, the app's UI tests cover most of its functionality and aims to 
provide a good plain-English introduction to app's expected behaviour.

## What is in the demo?
### Key things ...

- An alternative - non `MVVM` - scheme for the scalable general integration of bespoke app state and business logic with 
SwiftUI's prebuilt *@someStore* and *@someControl* functionality. 
- Sensible, ubiquitous user data undo capability through the combination of SwiftUI's built in `UndoManager`, a bespoke 
`viewContext.undoManager` and `@FocusedValue` driven undo/redo stack grouping.
- How to use `@NSApplicationDelegateAdaptor` with an `AppKit.NSApplicationDelegate` to protect users from app 
termination with unsaved data.
- Standard macOS window management with intelligent routing and comprehensive deep linking via custom URL schemes.
- How to test it.

### Other bits ... 

- A hierarchical `CoreData` scheme with a syncable CloudKit` backend and its own `UndoManager`.
- `@FetchRequest` - for retrieving `CoreData`
- `@SceneStorage` - to enable window config restoration across app restarts.
- `@FocusedValues` - to communicate with the app's Menubar where the user is currently working and which window's state 
it should be using in its controls.
- App specific Menubar and keyboard shortcuts.
- Sorted `ForEach` lists with drag and drop list rearrangement.
- Copy to clipboard for user data.

## App Architecture - Model StateView View (MSV) 

![Model StateView View architecture](DevAssets/ModelStateViewViewDiagram.png  "Diagram of app Model StateView View architecture")

Good app architecture for SwiftUI needs to balance the needs for:

- Performance
- Accommodating 3rd party solutions, i.e. not being an all-or-nothing solution.
	- In particular cope with SwiftUI's *@someStore* and *@someControl* built-in functionality.
- Separating and de-coupling concerns.
- Minimising boiler-plate.
- Enabling the straightforward testing of developed designs.
- The ease with which it is readily understood and applied by developers.

This app attempts to achieve this balance through the use of an empirically derived Model StateView View (MSV) approach.

In this architecture the 

- Model is the app's model of its Business Logic and Data.
	- Codebase example  =>  `AppModel`
- StateView are one or more (usually one per Window/Scene) high level SwiftUI Views that:
	- Do minimal - or no - UI layout.
	- Centralises access for a window or scene to the:
		- App model 
		- SwiftUI *@someStore* and *@someControl*  functionality.
	- Combine the data to derive the state and the Intents for all of its sub-views. 
		- With the Intents being split into instance and static parts to facilitate Unit testing and the generation of 
        Previews.
	- Reduce boiler-plate "prop-drilling"
	- Codebase examples:
		- SwiftUI *@someStore* injection =>  `Main`
		- Intents:
			- Window => `Main#Model`
			- Sidebar sub-components => `Main#SidebarModel`
			- Content sub-components => `Main#ContentModel`
			- Detail sub-components => in `Main#DetailModel`
- Views are:
	- Almost entirely stateless.
	- Use a StateView adapter and Layout pattern
		-  Layout works in concert with the StateView's Intent static part and Model to enable Preview testing without 
        initialising StateView.
	-  Codebase examples `Main#DetailView` and  `ItemView` 


## Routing and macOS Window Management

Gowi implements URL routing and macOS window management that follows platform conventions.

### Application States

The application operates in three distinct states, each with specific behaviors:

#### 1. Application Not Running
- Standard macOS launch behavior through Dock, Finder, or URL schemes
- URL routing launches the app and creates a window displaying the requested content according to scheme, e.g. list, empty new Item, existing Item ...

#### 2. Application Running with No Windows
Follows Apple macOS convention where application continues to run in the background even when all of its windows have been closed.

When no windows are visible:
- **Menu bar remains fully accessible and functional**
- All menu commands work normally (File, Edit, Window menus)
- **"New Item"** command creates a new window with an empty item
- **"New Window"** command opens a new window showing the default view
- All keyboard shortcuts continue to work
- File operations (Save, Revert) remain available
- Undo/Redo commands are accessible

creates new window displaying the requested content according to scheme, e.g. list, empty new Item, existing Item ...

### 3. Application Running with One or More Windows
- Standard operational state with full UI interaction
- Each window has a sequential identifier: `Main-AppWindow-1`, `Main-AppWindow-2`, etc.
- Windows share the same data model (`AppModel.shared`) but maintain independent view states
- Changes in one window's Item state immediately reflect in the apps other windows
- URL routing if:
    - existing window is displaying requested scheme content in window then that window is raised/made key window.
    - no existing window with content, creates a window displaying the requested content according to scheme, e.g. list, empty new Item, existing Item ... 

## Window Lifecycle

### Window Creation
Windows are created in several scenarios:
- **App Launch**: Creates initial window (unless restored from previous session)
- **Menu Commands**: "New Item" and "New Window" menu options
- **URL Deep Linking**: Smart routing creates windows when needed
- **Context Menus**: Items can be opened in new windows or tabs

### Window Management
- **Individual Close**: Windows can be closed independently using the red close button
- **Close All Windows**: `Cmd+Opt+W` closes all windows but keeps the app running
- **Quit Application**: `Cmd+Q` quits the entire application
- **Window Restoration**: SwiftUI automatically restores windows on app relaunch

## Smart Window Coordination

The application uses intelligent logic to determine whether to create new windows or reuse existing ones:

- **Shared Data**: All windows access the same `AppModel.shared` instance
- **Independent State**: Each window maintains its own view state and selection
- **Immediate Synchronization**: Data changes propagate instantly across all windows
- **Focus Management**: The app tracks which window is currently active for menu operations

# URL Routing and Deep Linking

Gowi provides comprehensive deep linking through a custom `gowi://` URL scheme with sensible window management.

## URL Scheme Structure

**Base Pattern**: `gowi://main/v1/[action]?[parameters]`

- **Scheme**: `gowi://` (registered custom URL scheme)
- **Host**: `main` (targets the main window type)
- **Version**: `v1` (versioned API for future compatibility)
- **Action**: Specific operation to perform
- **Parameters**: Query parameters for filtering and targeting

## Supported Routes

### List Views
- **All Items**: `gowi://main/v1/showitems?fid=All`
- **Waiting Items**: `gowi://main/v1/showitems?fid=Waiting` 
- **Completed Items**: `gowi://main/v1/showitems?fid=Done`
- **Default Route**: `gowi://main/` (shows Waiting list)

### Specific Items  
- **Item by ID**: `gowi://main/v1/showitems?fid=All&id=<UUID>`
  - Example: `gowi://main/v1/showitems?fid=All&id=42FA9B5A-959A-42C3-A5D1-184E634E2E33`
  - Uses the item's `ourId` UUID for consistent cross-device identification

### Item Creation
- **New Item**: `gowi://main/v1/newItem`
  - Opens with an empty item ready for editing

## Smart Routing Behavior

The application uses intelligent routing logic to provide the best user experience:

### Window Reuse Strategy
For most routes (except `newItem`), the app:
1. **Checks existing windows** to see if any are already displaying the requested content
2. **Raises existing window** if the same content is already visible
3. **Creates new window** only if no matching content is found

### New Item Exception
The `gowi://main/v1/newItem` route has special behavior:
- **Always creates a new window** regardless of existing windows
- Ensures users can create multiple items simultaneously
- Prevents accidentally overwriting existing item edits

### Cross-Application Integration
URL schemes work from:
- **Web browsers** (clicking gowi:// links)
- **Other applications** (programmatic URL opening)
- **Scripts and automation** (AppleScript, shell scripts)
- **Command line** using `open "gowi://main/v1/showitems?fid=All"`

## Route Behavior Matrix

| Route Type | No Windows | Existing Windows | Behavior |
|------------|------------|------------------|----------|
| **List Views** (`showitems`) | Creates new window | Reuses window if showing same list, otherwise creates new | Smart routing |
| **Specific Item** (`id=<UUID>`) | Creates new window | Reuses window if showing same item, otherwise creates new | Smart routing |
| **New Item** (`newItem`) | Creates new window | **Always** creates new window | Always new |
| **Default** (`gowi://main/`) | Creates new window | Reuses window showing Waiting list, otherwise creates new | Smart routing |

 





## Source code documentation

Is hopefully extensive and useful.  

- `Main#WindowGroupRouteView` goes into some depth about how the dark-arts of making SwiftUI route works.
- `Main#WindowGroupUndoView`  attempts to get over how undo management works. 


Thanks for reading down to here - Have fun! 🙂


      


