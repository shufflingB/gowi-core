# Introduction

Gowi (*Get On With It*) is a feature complete(ish) implementation in SwiftUI of a canonical "Todo" example application.

The goals of the project are to:

1. Determine and document how to:

    2. Achieve established platform norms using SwiftUI.
    2. Test that it does.
    
2. Form a usable \* and scalable basis for future experimentation and development, e.g. add `iPadOS` version, work 
sharing, time estimation, richer text editing ...

\* **For small personal projects.**

# Supported platforms

Gowi runs on `macOS` and requires Sequoia version 15.0 or better 

# Current User Capabilities 

The app provides the user with an interface to create, update and manage work-package *todo* `Item`s. 

Each of the user's *todo* `Item`s have a unique Id, Title, Notes, Creation and Completion dates and a Priority attribute 
associated with it. 

And each of these attributes - Id and Creation date aside - may be altered by the user.

To help the user to find their `Item`s the app:

- Provides URL routing to:
	1. `Item`s within the system, e.g. [gowi://main/v1/showitems?fid=All&id=42FA9B5A-959A-42C3-A5D1-184E634E2E33](gowi://main/v1/showitems?fid=All&id=42FA9B5A-959A-42C3-A5D1-184E634E2E33)
	2. Lists of `Item`s
- And uses the `Item`'s Completion date to derive lists of them that are either:
	- Waiting for action sorted by their Priority relative to one and other. Or,
	- Done and sorted by completion date.

For convenience, most of  the app's functionality is deep linkable through a predictable versioned URL interface e.g.

- New `Item` creation - [gowi://main/v1/newItem](gowi://main/v1/newItem)
- The list of:
	- All `Item`s - [gowi://main/v1/showitems?fid=All](gowi://main/v1/showitems?fid=All)
    - Done  `Item`s - [gowi://main/v1/showitems?fid=Done](gowi://main/v1/showitems?fid=Done)
    - Waiting `Item`s - [gowi://main/v1/showitems?fid=Waiting](gowi://main/v1/showitems?fid=Waiting)

 
It guards against accidental user data loss through app termination with unsaved changes.

And the app persists the user's data - and is syncable to their other devices - via their private iCloud account. 

Further, on `macOs` it endeavours to follow the de-facto platform conventions for:

- Drag and drop list rearrangement, e.g. when adjusting `Item` priorities in the Waiting list.
- Keyboard shortcut keys and menu structures.
- Keyboard navigation.
- Pop-up text.
- Multi-window behaviour.
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
- An in-app routing scheme to open and handle multi-window, tabs and rich URL  requests on `macOS`.
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

## Source code documentation

Is hopefully extensive and useful.  

- `Main#WindowGroupRouteView` goes into some depth about how the dark-arts of making SwiftUI route works.
- `Main#WindowGroupUndoView`  attempts to get over how undo management works. 


Thanks for reading down to here - Have fun! 🙂


      


