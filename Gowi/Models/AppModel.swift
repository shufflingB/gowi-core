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

final class AppModel: ObservableObject, Identifiable {
    /// Create a shared AppModel that the app will use.  Optionally do using one of the the inMemory test modes intended for automated UI testing.
    static let shared: AppModel = {
        if let testMode = ProcessInfo.processInfo.environment["GOWI_TESTMODE"] {
            switch testMode {
            case "0": // inMemory only
                log.debug("AppModel.shared, detected Env 'GOWI_TESTMODE' mode 0")
                return AppModel.sharedInMemoryNoTestData
            case "1": // inMemory + add default test data
                log.debug("AppModel.shared, detected Env 'GOWI_TESTMODE' mode 1")
                return AppModel.sharedInMemoryWithTestData
            default:
                log.debug("AppModel.shared, detected Env 'GOWI_TESTMODE', unknown mode \(testMode), defaulting to mode 0 ")
                return AppModel.sharedInMemoryNoTestData
            }
        } else {
            return AppModel()
        }
    }()

    /// Create a shared instance for unit testing - don't worry about this extra defn bc `static var` is `lazy` by default
    static var sharedInMemoryNoTestData: AppModel = AppModel(inMemory: true)

    static var sharedInMemoryWithTestData: AppModel = {
        let am = AppModel(inMemory: true)
        am.addTestData(.one)
        return am
    }()
    
    func resetInMemShared() {
        Self.sharedInMemoryNoTestData =  AppModel(inMemory: true)
        let am = AppModel(inMemory: true)
        am.addTestData(.one)
        Self.sharedInMemoryWithTestData = am
    }
//        let am = AppModel(inMemory: true)
////        am.addTestData(.one)
//
//
//
//
//    }

    let systemRootItem: Item
    let container: NSPersistentCloudKitContainer
    @Published private(set) var hasUnPushedChanges: Bool = false

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    

    init(inMemory: Bool = false) {
        // Suggested by https://www.hackingwithswift.com/forums/macos/app-sometimes-crashes-on-launch-since-monterey/10918/15476
        // and https://developer.apple.com/forums/thread/711122
        // as a workaround for tendency to crash on startup bc of possible Apple/SwiftUI bug
        // Force assignment of main thread to the correct correct queue/thread
        // TODO: Try removing this to see if any problems
        _ = NSApplication.shared

        container = Self.CKContainerGet(
            name: "Gowi",
            inMemory: inMemory
        )
        let vcUM = UndoManager()
        vcUM.groupsByEvent = false
        container.viewContext.undoManager = vcUM
        

        let dbgTitle = inMemory ? Self.RootInMemoryTitle : Self.RootNormalTitle

        systemRootItem = Self.rootItemGet(container.viewContext, dbgTitle: dbgTitle)

        container.viewContext.publisher(for: \.hasChanges).eraseToAnyPublisher().sink { newHasChangesValue in
            self.hasUnPushedChanges = newHasChangesValue
        }
        .store(in: &anyCancellable)
    }

    private static let RootInMemoryTitle = "InMemory root safe to delete" // Should never persist anyway
    private static let RootNormalTitle = "Normal system root."
    private var anyCancellable: Set<AnyCancellable> = []

    private static func CKContainerGet(name: String, inMemory: Bool) -> NSPersistentCloudKitContainer {
        let ckc = NSPersistentCloudKitContainer(name: name)

        log.debug("\(#function) using inMemory \(inMemory)")

        if inMemory {
            ckc.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
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

//
//
//                    if item.childrenList?.count == 0 {
//                        log.warning("Deleting idx = \(idx), id = \(item.idS), title = \(item.titleS), created = \(dateStr), children = \(item.childrenList?.count ?? 0)")
//                        moc.delete(item)
//                        Self.saveToCoreData(moc)
//                    } else {
//                        log.warning("Not sure to delete, save moc to kill, idx = \(idx), id = \(item.idS), title = \(item.titleS), created = \(dateStr), children = \(item.childrenList?.count ?? 0)")
//                        moc.delete(item)
//                    }
                }
            }

            return possibleRootItems[0]
        }
    }

    static func houseKeepingHackToCleanUpInMemoryProblem(_ moc: NSManagedObjectContext, bogusRoot badRoot: Item) {
        // TODO: Check if can remove this hack to fix buggy CloudKit/CoreData creation of persisted InMemory items.
        // To recreate issue:
        // 1) Run app with InMemory /dev/nul back end storage at least once -> creates an InMemory root item
        // 2) Fire up the app in normal mode, get normal, correctly picks up single, normal root item from backend.
        // 3) Fire up the ap a second time in _normal_ mode and it (wtf) detects two root items. First one is correct one, second one
        // is the it should not be persisting, inMemory only one.
        // Best I can figure is that it is the CloudKit syn that is not pushing inMemory one back around to us, i.e. doesn't know how to handle
        // properly.
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
