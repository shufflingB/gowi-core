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

    private static let SideBarDefaultOffset = 100.0
    static func onMoveHighToLowPriority(_ items: Array<Item>, _ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        // i.e. those sorted by Item priority
        /// just use what we've already worked out for the detail.
        /// E.g. for 3 item list
        ///
        /// --------------- tgtIdxEdge = 0
        /// sourceItem  0
        /// --------------- tgtIdxEdge = 1
        /// source Idx = 1
        /// -------------- tgtIdxEdge = 2
        /// source Idx =2
        /// -------------- tgtIdxEdge = 3

        guard let sourceIndicesFirstIdx = sourceIndices.first, let sourceIndicesLastIdx = sourceIndices.last else {
            return
        }

        let notMovingEdges = (sourceIndicesFirstIdx ... sourceIndicesLastIdx + 1)
        guard notMovingEdges.contains(tgtIdxsEdge) == false else {
            // print("Not moving because trying to move within the range of the existing items")
            return
        }

        let itemsSelected: Array<Item> = sourceIndices.map({ items[$0] })

        let movingUp: Bool = sourceIndicesFirstIdx > tgtIdxsEdge ? true : false
        // print("sourceIndixe.first =\(sourceIndicesFirstIdx),  last = \(sourceIndices.last!) tgtEdge = \(tgtIdxsEdge), Moving up \(movingUp)")

        let itemPriorityAboveTgtEdge = tgtIdxsEdge == 0
            ? items[0].priority + SideBarDefaultOffset ///  Then dragging to head of List, no Item above so have to special cars
            : items[tgtIdxsEdge - 1].priority

        let itemPriorityBelowTgtEdge = tgtIdxsEdge == items.count
            ? items[items.count - 1].priority - SideBarDefaultOffset /// Dragging to tail, no Item below so have to special case
            : items[tgtIdxsEdge].priority

        let priorityStepSize = (itemPriorityAboveTgtEdge - itemPriorityBelowTgtEdge) / Double(itemsSelected.count + 1)

        if movingUp {
            _ = itemsSelected
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nice animation
                    item.priority = itemPriorityBelowTgtEdge + priorityStepSize * Double(itemsSelected.count - idx)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        } else {
            _ = itemsSelected
                .reversed()
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nice animation
                    item.priority = itemPriorityAboveTgtEdge - priorityStepSize * Double(itemsSelected.count - idx)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        }
    }

//    func itemNewFromExisting(_ existingItem: Item, forParent: Item) -> Item {
//        let newItem = Self.itemNewFromExisting(viewContext, existingItem: existingItem, forParent: forParent)
//        objectWillChange.send()
//        return newItem
//    }

//    static func itemNewFromExisting(_ moc: NSManagedObjectContext, existingItem: Item, forParent: Item) -> Item {
//        /// Will put it at the front of the queue
//        let newItemSortOrder = sortOrderInsertAtFront(moc, parent: forParent)
//
//        /// NB: Will only duplicate it to a particular parent and it will use the exising item as a template from which to create a new, incomplete item
//        let newItem = itemSetup(
//            moc,
//            priority: newItemSortOrder,
//            complete: nil,
//            parentList: [forParent],
//            childrenList: existingItem.childrenList
//        )
//        newItem.title = String(">> \(existingItem.titleS) ")
//
//        let dateFormatter: DateFormatter = {
//            let formatter = DateFormatter()
//            formatter.dateStyle = .short
//            formatter.timeStyle = .short
//            return formatter
//        }()
//
//        newItem.notes = String(">> Copied from \(existingItem.ourIdS) at \(dateFormatter.string(from: Date()))\n\(existingItem.notesS)")
//        return newItem
//    }

    static func itemSetup(_ moc: NSManagedObjectContext, priority: Double, complete: Date?, parentList: NSSet?, childrenList: NSSet?) -> Item {
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
