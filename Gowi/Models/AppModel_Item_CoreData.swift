//
//  Item.swift
//  Item
//
//  Created by Jonathan Hume on 11/08/2021.
//

import CoreData
import SwiftUI

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension AppModel {
    func saveToCoreData() {
        AppModel.saveToCoreData(viewContext)
    }

    static func saveToCoreData(_ moc: NSManagedObjectContext) {
        if moc.hasChanges {
            do {
                log.debug("Saving data to backend ")
                try moc.save()
            } catch {
                /** This is straight out of Apple's default implementation. As such Apple advises to replace
                 this implementation with code to handle the error appropriately.
                 In particular fatalError() will causes the application to generate a crash log and terminate.
                 And as such, you are advised not use this function in a shipping application, although it may be useful during development.
                 */
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    private static let itemSortDescriptors: Array<NSSortDescriptor> = [NSSortDescriptor(key: "priority", ascending: true)]

    private static func childrenOf(_ item: Item) -> NSPredicate {
        NSPredicate(format: "parentList CONTAINS %@", item as CVarArg)
    }

//    // Returns NSFetchRequest and not FetchRequest, can initialise a SwiftUI FetchRequest from a NSFetchRequest but not
//    // other way around.
//    private static func childItemsOfFetchRequest(_ parent: Item, sortDescriptors: Array<NSSortDescriptor>, otherPredicates: Array<NSPredicate> = []) -> NSFetchRequest<Item> {
//        let parentPredicate = AppModel.childrenOf(parent)
//        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate] + otherPredicates)
//
//        let request = NSFetchRequest<Item>(entityName: String(describing: Item.self))
//        request.sortDescriptors = sortDescriptors
//        request.predicate = combinedPredicate
//        return request
//    }
//
//    private static func childItemsOfFetchRequest(_ parent: Item, sortDescriptors: Array<NSSortDescriptor>, otherPredicates: [NSPredicate] = []) -> FetchRequest<Item> {
//        return FetchRequest(fetchRequest: childItemsOfFetchRequest(parent, sortDescriptors: sortDescriptors, otherPredicates: otherPredicates))
//    }
//
//    private static func itemIsDone() -> NSPredicate {
//        NSPredicate(format: "%K != %@", "completed", 0) // 0 is NS Old skool for nil
//    }
//
//    private static func itemIsIncomplete() -> NSPredicate {
//        NSPredicate(format: "%K == %@", "completed", 0)
//    }
//
//    func childItemsOfRootFetchRequest() -> FetchRequest<Item> {
////        guard let systemRootItem = systemRootItem else {
////            fatalError("Trying to create a FetchRequest for child items of a system root item that has not been set ")
////        }
//        switch itemFilter {
//        case .None:
//            /// Just return everything
//            return Self.childItemsOfFetchRequest(systemRootItem, sortDescriptors: Self.itemSortDescriptors)
//        case .Incomplete:
//            /// Only return those not marked as done
//            return Self.childItemsOfFetchRequest(systemRootItem, sortDescriptors: Self.itemSortDescriptors, otherPredicates: [Self.itemIsIncomplete()])
//        case .Done:
//
//            let doneSortDescriptors: Array<NSSortDescriptor> = [NSSortDescriptor(key: "completed", ascending: false)]
//
//            return Self.childItemsOfFetchRequest(systemRootItem, sortDescriptors: doneSortDescriptors, otherPredicates: [Self.itemIsDone()])
//        }
//    }
//


    static func itemCreate(_ moc: NSManagedObjectContext, parent: Item) -> Item {
        let newItemSortOrder = sortOrderInsertAtFront(moc, parent: parent)

        return itemSetup(moc, priority: newItemSortOrder, complete: nil, parentList: [parent], childrenList: [])
    }

//    static func itemGetEmptyNewest(_ moc: NSManagedObjectContext, parent: Item) -> Item {
//        // Get a list of all incomplete items
//
////        var incompleteItems: Array<Item> = []
////
////        let incompleteItemsRequest: NSFetchRequest<Item> = Self.childItemsOfFetchRequest(parent, sortDescriptors: Self.itemSortDescriptors, otherPredicates: [Self.itemIsIncomplete()]) as NSFetchRequest<Item>
////        do {
////            incompleteItems = try moc.fetch(incompleteItemsRequest)
////        } catch {
////            fatalError("Failed to querry incomplete items: \(error)")
////        }
//
//        let incompleteItems: Array<Item> = parent.childrenListAsArray.filter({ (item: Item) in
//            item.completed == nil
//        })
//
//        if let firstItem = incompleteItems.first {
//            // Then if we have anything, see if the first one is empty
//            if firstItem.titleS == "" && firstItem.completed == nil && firstItem.notesS == "" {
//                /// and if it is empty we'll return that instead of creating a new one.
//
//                return firstItem
//            } else {
//                return AppModel.itemCreate(moc, parent: parent)
//            }
//        } else {
//            /// But if we don't have a first incomplete item OR the user has entered some data, then we create a new one instead
//            return AppModel.itemCreate(moc, parent: parent)
//        }
//    }

    func itemNewFromExisting(_ existingItem: Item, forParent: Item) -> Item {
        let newItem = Self.itemNewFromExisting(viewContext, existingItem: existingItem, forParent: forParent)
        objectWillChange.send()
        return newItem
    }

    static func itemNewFromExisting(_ moc: NSManagedObjectContext, existingItem: Item, forParent: Item) -> Item {
        /// Will put it at the front of the queue
        let newItemSortOrder = sortOrderInsertAtFront(moc, parent: forParent)

        /// NB: Will only duplicate it to a particular parent and it will use the exising item as a template from which to create a new, incomplete item
        let newItem = itemSetup(
            moc,
            priority: newItemSortOrder,
            complete: nil,
            parentList: [forParent],
            childrenList: existingItem.childrenList
        )
        newItem.title = String(">> \(existingItem.titleS) ")

        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            return formatter
        }()

        newItem.notes = String(">> Copied from \(existingItem.ourIdS) at \(dateFormatter.string(from: Date()))\n\(existingItem.notesS)")
        return newItem
    }


//    static func itemsReorder(_ moc: NSManagedObjectContext, fullList items: [Item], sourceIndices: IndexSet, tgtIndicesEdge: Int) {
//        guard let firstMovedIdx = sourceIndices.first else {
//            log.debug("\(#function) Failed attempt to rearrange child Items received empty set of indices to move")
//            return
//        }
//
//        guard firstMovedIdx != tgtIndicesEdge else {
//            log.debug("\(#function) No move necessary, src and tgt same")
//            return
//        }
//
//        switch tgtIndicesEdge {
//        case 0: /// Dragged to head of list
//            log.debug("\(#function) Moving idx's \(Array(sourceIndices)) to beginning of list \(tgtIndicesEdge)")
//            guard let headSortOrder = items[tgtIndicesEdge].sortOrder else {
//                return
//            }
//            var count = 1
//            sourceIndices.reversed().forEach { idx in
//
//                items[idx].sortOrder = headSortOrder - 10000 * Double(count)
//                count += 1
//            }
//
//        case items.count: /// End of list
//            log.debug("\(#function) Moving idx's \(Array(sourceIndices)) to end of list \(tgtIndicesEdge)")
//            guard let tailSortOrder = items[tgtIndicesEdge - 1].sortOrder else {
//                return
//            }
//
//            var count = 1
//            sourceIndices.forEach { idx in
//                items[idx].sortOrder = tailSortOrder + 10000 * Double(count)
//                count += 1
//            }
//
//        default:
//            log.debug("\(#function) Default")
//            guard let insertAfterSortRank = items[tgtIndicesEdge - 1].sortOrder else {
//                return
//            }
//            guard let insertBeforeSortRank = items[tgtIndicesEdge].sortOrder else {
//                return
//            }
//
//            let interval = insertBeforeSortRank.timeIntervalSince(insertAfterSortRank)
//            let stepInterval = interval / Double(sourceIndices.count + 1)
//
//            var newSortRank = insertAfterSortRank + stepInterval
//            sourceIndices.forEach { idx in
//                items[idx].sortOrder = newSortRank
//                newSortRank += stepInterval
//            }
//        }
//    }

    /*
     func parentsOf(_ item: Item) -> Array<Item> {
         Self.parentsOf(moc, item: item)
     }

     static func parentsOf(_ moc: NSManagedObjectContext, item: Item) -> Array<Item> {
         item.parentList?.sortedArray(using: itemSortDescriptors) as! [Item]
     }

     func childrenOf(_ parent: Item) -> Array<Item> {
         Self.childrenOf(moc, parent: parent)
     }
      */

    private static func childrenOf(_ moc: NSManagedObjectContext, parent: Item) -> Array<Item> {
        parent.childrenList?.sortedArray(using: itemSortDescriptors) as! [Item]
    }

    static func sortOrderInsertAtFront(_ moc: NSManagedObjectContext, parent: Item) -> Double {
        /// Workout where what the highest sort is for the parent
        let siblings: [Item] = childrenOf(moc, parent: parent)

        /// want to add to the beginning of the list
        if let firstSortOrder = siblings.first?.priority {
//            log.debug("\(#function) Is being called as something else present")
            return firstSortOrder - 10000
        } else { /// Insert at front of the list if sorting newest to oldest
//            log.debug("\(#function) No other siblings - just return today's Date as the sortOrder value")
            return 0.0
        }
    }

    private static func itemSetup(_ moc: NSManagedObjectContext, priority: Double, complete: Date?, parentList: NSSet?, childrenList: NSSet?) -> Item {
        /// Used to instantiate the bare minimum for iit
        let newItem = Item(context: moc)
        newItem.ourIdS = UUID()
        newItem.parentList = parentList
        newItem.childrenList = childrenList
        newItem.created = Date()
        newItem.completed = complete
        newItem.priority = priority
        return newItem
    }
}
