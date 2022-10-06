//
//  Item.swift
//  Item
//
//  Created by Jonathan Hume on 11/08/2021.
//

import Combine
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

    private static func undoPreFlight(externalUM: UndoManager?, contextUM: UndoManager?)
        -> (externalUM: UndoManager, contextUM: UndoManager)? {
        guard let externalUM = externalUM else {
            log.debug("\(#function), Not reordering, externalUM is nil")
            return nil
        }

        guard let contextUM = contextUM else {
            log.debug("\(#function), Not reordering, contextUM is nil")
            return nil
        }
        return (externalUM, contextUM)
    }

    private static func registerPassThroughUndo(
        with externalUM: UndoManager?, passingTo undoableTgtUM: UndoManager?, withTarget: AnyObject,
        setActionName actionName: String, action: @escaping () -> Void) {
        ///
        guard let (externalUM, undoableTgtUM) = Self.undoPreFlight(externalUM: externalUM, contextUM: undoableTgtUM) else {
            log.warning("\(#function) can't make undoable as externalUM is nil ")
            action()
            return
        }
        let extUMgroupsByEventStash = externalUM.groupsByEvent
        externalUM.groupsByEvent = false

        externalUM.beginUndoGrouping()

        // Carry out the action that can the undoableTgtUM "knows" how to to undo.
        undoableTgtUM.beginUndoGrouping()

        action()

        undoableTgtUM.endUndoGrouping()

        externalUM.registerUndo(withTarget: withTarget) { (targetInstance: AnyObject) in
            log.debug(" SwiftUI UndoManager undo call triggered running of pass-through to viewContext's UndoManager")
            withAnimation {
                undoableTgtUM.undo()
            }

            /// Register how to Redo the Undo if necessary
            externalUM.registerUndo(withTarget: targetInstance) { _ in
                log.debug("SwiftUI UndoManager undo call triggered running of its registered redo operation")
                withAnimation {
                    registerPassThroughUndo(with: externalUM, passingTo: undoableTgtUM, withTarget: withTarget, setActionName: actionName, action: action)
                }
            }
        }
        externalUM.setActionName(actionName)
        externalUM.endUndoGrouping()
        externalUM.groupsByEvent = extUMgroupsByEventStash
    }

    func reOrderUsingPriority(externalUM: UndoManager?, items: Array<Item>, sourceIndices: IndexSet, tgtIdxsEdge: Int) {
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "Move") {
            AppModel.reOrderUsingPriority(items: items, sourceIndices: sourceIndices, tgtIdxsEdge: tgtIdxsEdge)
        }
    }

    private static let SideBarDefaultOffset = 100.0

    static func reOrderUsingPriority(items: Array<Item>, sourceIndices: IndexSet, tgtIdxsEdge: Int) {
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

//    func itemAddToUndoable(
//        externalUM: UndoManager,
//        parents: Set<Item>, title: String, priority: Double, complete: Date?, notes: String, children: Set<Item>
//    ) -> Item {
//
//
//
//    }

    func itemAddTo(externalUM: UndoManager?, parents: Set<Item>, title: String, priority: Double, complete: Date?, notes: String, children: Set<Item>) -> Item {
        var item: Item?
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "New Item") {
            item = Self.itemAddTo(self.viewContext, title: title, parents: parents, priority: priority, complete: complete, children: children, notes: notes)
        }
        return item!
    }

    static func itemAddTo(_ moc: NSManagedObjectContext, title: String, parents: Set<Item>, priority: Double, complete: Date?, children: Set<Item>, notes: String?) -> Item {
        /// Used to instantiate the bare minimum for iit
        let newItem = Item(context: moc)
        newItem.ourId = UUID()
        newItem.created = Date()
        newItem.title = title
        newItem.priority = priority
        newItem.completed = complete
        newItem.notes = notes

        newItem.parentList = parents as NSSet
        newItem.childrenList = children as NSSet

        return newItem
    }
}
