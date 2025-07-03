//
//  AppModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import AppKit
import Combine
import CoreData
import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/**
 ## Application Model - Centralized Business Logic and Data Management
 
 The AppModel serves as the single source of truth for the entire Gowi application, implementing
 the "Model" layer of the MSV (Model StateView View) architecture pattern. It manages CoreData
 persistence, CloudKit synchronization, undo operations, and all business logic.
 
 ### Architecture Role:
 - **Singleton Pattern**: Single shared instance (`AppModel.shared`) across the entire app
 - **Business Logic**: All item operations, filtering, and data manipulation
 - **CoreData Stack**: Manages NSPersistentCloudKitContainer and view context
 - **CloudKit Sync**: Handles iCloud synchronization for multi-device support
 - **Undo Management**: Coordinates with SwiftUI's UndoManager for comprehensive undo/redo
 - **Change Tracking**: Publishes `hasUnPushedChanges` for UI state updates
 
 ### Key Relationships:
 - `systemRootItem`: The hierarchical root of all user items (hidden from UI)
 - `viewContext`: CoreData's main thread context for UI operations
 - `container`: NSPersistentCloudKitContainer managing persistence and sync
 
 ### Testing Support:
 - `GOWI_TESTMODE=0`: In-memory database with no test data
 - `GOWI_TESTMODE=1`: In-memory database with 10 test items
 - Default: Persistent database with CloudKit sync
 
 ### Thread Safety:
 - All UI operations use the main thread `viewContext`
 - Background sync operations handled by CoreData/CloudKit
 - Published properties automatically update UI via @ObservableObject
 */
public final class AppModel: ObservableObject, Identifiable {
    /// Hierarchical root item for all user-created items
    ///
    /// This special Item serves as the parent for all user items but is never displayed in the UI.
    /// It provides a consistent hierarchical structure and simplifies CoreData relationships.
    /// All business logic operations traverse from this root to find and manipulate user items.
    public let systemRootItem: Item

    /// Real-time indicator of unsaved changes
    ///
    /// Automatically tracks CoreData's `hasChanges` state and publishes updates to the UI.
    /// Used by the save/revert toolbar buttons and the exit confirmation dialog.
    /// Updated via Combine publisher that monitors `viewContext.hasChanges`.
    @Published public private(set) var hasUnPushedChanges: Bool = false

    /// Main thread CoreData context for all UI operations
    ///
    /// This is the primary context for reading and writing data from SwiftUI views.
    /// Automatically merges changes from CloudKit sync operations and publishes
    /// changes to trigger UI updates via @FetchRequest and other CoreData/SwiftUI integrations.
    public var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    /// Debug utility for development and testing
    ///
    /// Prints detailed information about all items in the system to the console.
    /// Useful for debugging test failures, data corruption issues, and understanding
    /// the current state of the item hierarchy during development.
    public func debugPrintAllItems() {
        let allItems = Array(systemRootItem.childrenListAsSet)
        print("=== DEBUG: All Items Data ===")
        print("Total items: \(allItems.count)")
        
        for (index, item) in allItems.enumerated() {
            print("Item \(index + 1):")
            print("  Title: '\(item.titleS)'")
            print("  ourId: \(item.ourId?.uuidString ?? "NIL")")
            print("  completed: \(item.completed?.description ?? "NIL")")
            print("  created: \(item.created?.description ?? "NIL")")
            print("  priority: \(item.priority)")
            print("  ---")
        }
        print("=== End Debug ===")
    }

    /// Global shared instance with environment-based configuration
    ///
    /// The singleton AppModel instance used throughout the application. Configuration is determined
    /// by the `GOWI_TESTMODE` environment variable, enabling different modes for testing and development:
    ///
    /// - **No GOWI_TESTMODE**: Production mode with persistent CloudKit-enabled database
    /// - **GOWI_TESTMODE=0**: Testing mode with in-memory database, no test data (clean slate)
    /// - **GOWI_TESTMODE=1**: Testing mode with in-memory database, 10 pre-populated test items
    /// - **Other values**: Defaults to mode 0 (in-memory, no test data)
    ///
    /// ## Usage in Tests:
    /// ```bash
    /// # For clean testing environment
    /// GOWI_TESTMODE=0 xcodebuild test
    /// 
    /// # For testing with sample data
    /// GOWI_TESTMODE=1 xcodebuild test
    /// ```
    public static let shared: AppModel = {
        if let testMode = ProcessInfo.processInfo.environment["GOWI_TESTMODE"] {
            switch testMode {
            case "0": // inMemory only
                log.debug("AppModel.shared, detected Env 'GOWI_TESTMODE' mode 0: in memory no test data")
                return AppModel.sharedInMemoryNoTestData
            case "1": // inMemory + add default test data
                log.debug("AppModel.shared, detected Env 'GOWI_TESTMODE' mode 1: in memory 10 items with one of them with id = \(testingMode1ourIdPresent)")
                return AppModel.sharedInMemoryWithTestData
            default:
                log.debug("AppModel.shared, detected Env 'GOWI_TESTMODE', unknown mode \(testMode), defaulting to mode 0 ")
                return AppModel.sharedInMemoryNoTestData
            }
        } else {
            return AppModel()
        }
    }()

    /// Testing instance with clean in-memory database
    ///
    /// Lazy-loaded instance for unit tests that need a clean slate without any pre-existing data.
    /// Uses in-memory storage so tests don't affect the user's real data or require cleanup.
    static var sharedInMemoryNoTestData: AppModel = AppModel(inMemory: true)

    /// Testing instance with pre-populated test data
    ///
    /// Lazy-loaded instance for tests that need sample data to work with. Creates 10 test items
    /// with one item having a predictable ID (testingMode1ourIdPresent) for reliable testing.
    /// The other 9 items have random UUIDs but provide a realistic data set for UI testing.
    public static var sharedInMemoryWithTestData: AppModel = {
        let am = AppModel(inMemory: true)
        am.addTestData(.one)  // Adds 10 items, with one having a known ID for testing
        return am
    }()

    /// Initializes the AppModel with CoreData stack and CloudKit integration
    ///
    /// Sets up the complete data persistence infrastructure including CoreData container,
    /// CloudKit synchronization, undo management, and change tracking. The initialization
    /// process creates or retrieves the system root item and establishes reactive bindings.
    ///
    /// - Parameter inMemory: When true, uses in-memory storage for testing (disables CloudKit)
    ///                      When false, uses persistent storage with full CloudKit sync
    init(inMemory: Bool = false) {
        // Workaround for macOS Monterey+ startup crashes in SwiftUI apps
        // Force NSApplication initialization on main thread to prevent race conditions
        // See: https://www.hackingwithswift.com/forums/macos/app-sometimes-crashes-on-launch-since-monterey/10918/15476
        // TODO: Test if this workaround is still needed in current macOS versions
        _ = NSApplication.shared

        // Initialize CoreData container with CloudKit integration
        container = Self.CKContainerGet(
            modelName: "Gowi",
            cloudKitContainerName: Self.cloudKitContainerName(),
            inMemory: inMemory
        )
        
        // Configure undo manager for comprehensive undo/redo support
        let vcUM = UndoManager()
        vcUM.groupsByEvent = false  // Manual grouping for fine-grained control
        container.viewContext.undoManager = vcUM

        // Create or retrieve the system root item (varies by storage mode)
        let dbgTitle = inMemory ? Self.RootInMemoryTitle : Self.RootNormalTitle
        systemRootItem = Self.rootItemGet(container.viewContext, dbgTitle: dbgTitle)

        // Establish reactive binding for change tracking
        // Publishes updates when CoreData context has unsaved changes
        container.viewContext.publisher(for: \.hasChanges).eraseToAnyPublisher().sink { newHasChangesValue in
            self.hasUnPushedChanges = newHasChangesValue
        }
        .store(in: &anyCancellable)
    }

    private let container: NSPersistentCloudKitContainer
    private static let RootInMemoryTitle = "InMemory root safe to delete" // Should never persist anyway
    private static let RootNormalTitle = "Normal system root."
    private var anyCancellable: Set<AnyCancellable> = []
    
    /// Get CloudKit container name from generated config
    private static func cloudKitContainerName() -> String {
        return CloudKitConfig.containerName
    }

    /// Initialise the app's  `NSPersistentCloudKitContainer`
    /// - Parameters:
    ///   - modelName: The CoreData model file name
    ///   - cloudKitContainerName: The CloudKit container identifier
    ///   - inMemory: whether to in memory, non-live data or not
    /// - Returns: The initiallised `NSPersistentCloudKitContainer`
    private static func CKContainerGet(modelName: String, cloudKitContainerName: String, inMemory: Bool) -> NSPersistentCloudKitContainer {
        guard let modelURL = Bundle(for: AppModel.self).url(forResource: modelName, withExtension: "momd"),
              let model = NSManagedObjectModel(contentsOf: modelURL)
        else {
            fatalError("Failed to load model named \(modelName) from bundle")
        }

        let ckc = NSPersistentCloudKitContainer(name: modelName, managedObjectModel: model)

//        let ckc = NSPersistentCloudKitContainer(name: modelName)

        log.debug("\(#function) using modelName: \(modelName), cloudKitContainerName: \(cloudKitContainerName), inMemory: \(inMemory)")

        if inMemory {
            ckc.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            // Disable CloudKit for in-memory testing
            ckc.persistentStoreDescriptions.first!.cloudKitContainerOptions = nil
        } else {
            // Configure CloudKit container for persistent stores
            if let storeDescription = ckc.persistentStoreDescriptions.first {
                storeDescription.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                storeDescription.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                storeDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.\(cloudKitContainerName)")
            }
        }

        ckc.loadPersistentStores(completionHandler: { (_: NSPersistentStoreDescription, error: Error?) in
            if let error = error as NSError? {
                fatalError("Unable to load from backend store \(error), \(error.userInfo)")
            }

        })
        ckc.viewContext.automaticallyMergesChangesFromParent = true // Automatically pick up changes from the Cloud
        ckc.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // Local changes take priority

        return ckc
    }

    /**
     Fetch the existing system root `Item` if it exists, or create a new one if it does not.
        - Parameters:
            - moc: the managed object context to query/create on
            - dbgTitle: A title to assign to root `Item`s title field as an aid to debugging.
        - Returns: The system root `Item` for the context.
     */
    private static func rootItemGet(_ moc: NSManagedObjectContext, dbgTitle: String?) -> Item {
        let rootsRequest: NSFetchRequest<Item> = {
            let entityName = String(describing: Item.self)

            let request = NSFetchRequest<Item>(entityName: entityName)
            request.sortDescriptors = [NSSortDescriptor(key: "created", ascending: true)]
            request.predicate = NSPredicate(format: "root == YES")
            return request
        }()

        var possibleRootItems: Array<Item> = []
        do {
            possibleRootItems = try moc.fetch(rootsRequest)
        } catch {
            fatalError("Failed to query root Item: \(error)")
        }

        switch possibleRootItems.count {
        case ...0:
            log.debug("\(#function) No root Items detected")
            return rootItemCreate(moc, dbgTitle: dbgTitle)
        case 1:
            //
            log.debug("\(#function) Detected an existing single root item")
            return possibleRootItems[0]

        default:
            log.warning("\(#function) Unexpected number of Root Items found \(possibleRootItems.count) in CoreData store. Using the first one but should only be one")
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            possibleRootItems.indices.forEach { idx in
                let item = possibleRootItems[idx]
                let dateStr = formatter.string(from: item.created!)
                if idx == 0 {
                    log.warning("Using idx = \(idx), id = \(item.ourIdS), title = \(item.title ?? ""), created = \(dateStr)")
                } else {
                    houseKeepingHackToCleanUpInMemoryProblem(moc, bogusRoot: item)
                }
            }

            return possibleRootItems[0]
        }
    }

    /// Create a system rootItem
    /// - Parameters:
    ///   - moc: The managed object context to create on.
    ///   - dbgTitle: A title to assign to root `Item`s title field as an aid to debugging.
    /// - Returns: The new system root `Item` for the context.
    private static func rootItemCreate(_ moc: NSManagedObjectContext, dbgTitle: String?) -> Item {
        log.debug("\(#function) creating root item")
        let item: Item = moc.performAndWait {
            let rootItem = Item(context: moc)
            rootItem.ourIdS = UUID()
            rootItem.created = Date()
            rootItem.root = true

            rootItem.title = dbgTitle
            return rootItem
        }
        do {
            try moc.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unable to create root Item \(nserror), \(nserror.userInfo)")
        }
        return item
    }

    /// Workaround for CloudKit/CoreData bug with in-memory items persisting
    ///
    /// ## The Problem:
    /// When switching between in-memory testing mode and normal persistent mode, CoreData
    /// sometimes incorrectly persists items that should only exist in memory. This creates
    /// duplicate root items that break the application's single-root assumption.
    ///
    /// ## Bug Reproduction Steps:
    /// 1. Run app with `GOWI_TESTMODE=1` (in-memory + test data) 
    /// 2. Switch to normal mode - correctly finds single persistent root
    /// 3. Run normal mode again - incorrectly detects TWO roots (persistent + leaked in-memory)
    ///
    /// ## Root Cause Theory:
    /// CloudKit sync appears to incorrectly sync in-memory items that should never be persisted,
    /// possibly due to timing issues between memory mode switching and CloudKit initialization.
    ///
    /// - TODO: Test if this bug still occurs in newer CoreData/CloudKit versions
    /// - TODO: Consider alternative root item identification strategies
    private static func houseKeepingHackToCleanUpInMemoryProblem(_ moc: NSManagedObjectContext, bogusRoot badRoot: Item) {
        guard badRoot.root == true else {
            log.warning("\(#function) erroneously called on a non-root item \n \(badRoot)")
            return
        }

        guard badRoot.title == Self.RootInMemoryTitle else {
            log.warning("\(#function) erroneously called on root Item whose title appears good \(badRoot)")
            return
        }

        // Check and remove similarly bogus child Items
        moc.performAndWait {
            log.debug("Marking for deletion bogus Root Item id = \(badRoot.ourIdS) title = \(badRoot.titleS)")
            let wouldBeOrphans = badRoot.childrenListAsSet
            wouldBeOrphans.forEach { item in
                log.debug("Marking for deletion its orphan Item id = \(item.ourIdS) title = \(item.titleS)")
                moc.delete(item)
            }
            moc.delete(badRoot)

            do {
                try moc.save()
            } catch {
                let nserror = error as NSError
                log.fault("Saving deletion of Root \(badRoot) and associated Child items failed\n \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
