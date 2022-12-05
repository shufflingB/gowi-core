//
//  AppModel#Item.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Combine
import CoreData
import SwiftUI

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// AppModel public functionallity specifically associated with the handling of `Item`s
extension AppModel {
    /// Persists changes made against `AppModel#viewContext`
    func saveToCoreData() {
        Self.saveToCoreData(viewContext)
    }

    /// Persist changes made against an arbitray moc
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

    /// Adds a new `Item` to the parent in the current `AppModel#viewContext` in an undoalbe way
    /// - Parameters:
    ///   - externalUM: Add an entry to undo the creation of the `Item` with this `UndoManager`
    ///   - parents: Parent `Item`s for the new `Item`
    ///   - title: Title to assign to the new `Item`
    ///   - priority: Priority to assign to the new `Item`
    ///   - complete: A completion `Date` to assign, or not.
    ///   - notes: Notes to assign.
    ///   - children: The set of child `Item`s to assign to the new `Item`
    /// - Returns: The newly created, and as yet, unpersisted `Item`
    func itemAddNewTo(
        externalUM: UndoManager?,
        parents: Set<Item>, title: String, priority: Double, complete: Date?, notes: String, children: Set<Item>
    ) -> Item {
        //
        var item: Item?
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "New Item") {
            item = Self.itemAddNewTo(self.viewContext, parents: parents, title: title, priority: priority, complete: complete, children: children, notes: notes)
        }
        return item!
    }

    /// As per `AppModel#itemAddNewTo`, except not undoable and works with arbitrary moc
    static func itemAddNewTo(
        _ moc: NSManagedObjectContext,
        parents: Set<Item>, title: String, priority: Double, complete: Date?, children: Set<Item>, notes: String?
    ) -> Item {
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

    /// Creates and inserts and new `Item` into a list organised by priority on the `AppModel#viewContext` in an undoable way.
    /// - Parameters:
    ///   - externalUM: Add an entry to undo the creation the and insertion of the new `Item` with this `UndoManager`
    ///   - parent: A single parent `Item` which owns the priortiy list.
    ///   - items: The priority sorted array of `Items` in that list
    ///   - tgtIdxsEdge: The edge where the new `Item` is to be inserted at. Insert __Above__ item @ idx = n use `tgtIdxsEdge` = n, __Below__  idx = n use `tgtIdxsEdge` = n + 1
    ///   - title: The title for the new `Item`
    ///   - complete: The `Date` for the new `Item`
    ///   - notes: The notes for the new `Item`
    ///   - children: The list of child `Items` to assign to the new `Item`
    /// - Returns: he newly created, and as yet, unpersisted `Item`
    func itemNewInsertInPriority(
        externalUM: UndoManager?,
        parent: Item, list items: Array<Item>, where tgtIdxsEdge: Int,
        title: String, complete: Date?, notes: String, children: Set<Item>
    ) -> Item {
        // --------------- tgtIdxEdge = 0
        //  sourceItem  0
        // --------------- tgtIdxEdge = 1
        // source Idx = 1
        // -------------- tgtIdxEdge = 2
        // source Idx =2
        // -------------- tgtIdxEdge = 3
        // ...

        let priorities = AppModel.itemPriorityPair(forEdgeIdx: tgtIdxsEdge, items: items)

        let priorityStep: Double = (priorities.aboveEdge - priorities.belowEdge) / 2

        let insertPriority = tgtIdxsEdge < items.count
            ? priorities.belowEdge + priorityStep
            : priorities.aboveEdge - priorityStep

        return itemAddNewTo(externalUM: externalUM, parents: [parent], title: title, priority: insertPriority, complete: nil, notes: notes, children: children)
    }

    /// Deletes a list of `Items` from the `AppModel#viewContext` in an undoable way
    /// - Parameters:
    ///   - externalUM: Add an entry to undo the deletion of the `Item`s with this `UndoManager`
    ///   - items: List of `Items` to delete
    func itemsDelete(
        externalUM: UndoManager?,
        list items: Array<Item>
    ) {
        //
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "Delete") {
            Self.itemsDelete(self.viewContext, items: items)
        }
    }

    /// As `AppModel#itemsDelete`, except not undoable and works with arbitrary moc
    static func itemsDelete(_ moc: NSManagedObjectContext, items: Array<Item>) {
        items.forEach { item in
            item.parentList = nil /// Just deleting the item is not enough as it doesn't get removed  from  the parent's children lists until after the moc is saved
            moc.delete(item)
        }
    }

    /// Sets a completed `Date` for a list of `Item`s on the `AppModel#viewContext` in an undoable way.
    /// - Parameters:
    ///   - externalUM: Add an entry to undo the setting of the completion `Date` for these `Item`s with this `UndoManager`
    ///   - items: The list of a `Item` to assign the completion `Date` to.
    ///   - date: The `Date` to assign to the `Item`s
    func itemsSetCompletionDate(
        externalUM: UndoManager?,
        items: Array<Item>,
        date: Date?
    ) {
        print("Setting new completion date \(String(describing: date))")
        let actionName = date == nil ? "Marking Incomplete" : "Setting Complete Date"
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: actionName) {
            Self.itemsSetCompletionDate(self.viewContext, items: items, date: date)
        }
        objectWillChange.send()
    }

    /// As `AppModel#itemsSetCompletionDate`, except not undoable and works with arbitrary moc
    static func itemsSetCompletionDate(_ moc: NSManagedObjectContext, items: Array<Item>, date: Date?) {
        items.forEach { item in
            item.completed = date
            item.objectWillChange.send()
        }
    }

    /// Computes priority values for above and below a desired `tgtEdgeIdx`.
    private static func itemPriorityPair(forEdgeIdx tgtEdgeIdx: Int, items: Array<Item>) -> (aboveEdge: Double, belowEdge: Double) {
        guard items.count > 0 else {
            return (aboveEdge: DefaultOffset, belowEdge: -DefaultOffset)
        }

        let itemPriorityAboveTgtEdge = tgtEdgeIdx == 0
            ? items[0].priority + DefaultOffset ///  Then dragging to head of List, no Item above so have to special cars
            : items[tgtEdgeIdx - 1].priority

        let itemPriorityBelowTgtEdge = tgtEdgeIdx == items.count
            ? items[items.count - 1].priority - DefaultOffset /// Dragging to tail, no Item below so have to special case
            : items[tgtEdgeIdx].priority

        return (aboveEdge: itemPriorityAboveTgtEdge, belowEdge: itemPriorityBelowTgtEdge)
    }

    /**
      Rearranges a priortiy list on `AppModel#viewContext` in an undoable way
      - Parameters:
         -  externalUM: Add an entry to undo the reorder of the priority list with this `UndoManager`
         - items: Current sorted priortiy list
         - sourceIndices: The set of indices in the `Items` current priortiy list
         - tgtEdgeIdx: The edge where the `Items` at `sourceIndices` at to be insert __Above__ item @ idx = n use `tgtIdxsEdge` = n, __Below__  idx = n use `tgtIdxsEdge` = n + 1

      Items in a list have their movement controlled by the specification relative to the original List by:
         1) A set of the indices of the source Items to be moved
         2) A target Item edge where the Items that are to be moved are to be inserted.

      For a list of N items, normally the list will have these laid out as follows from top to bottom

     ------------------- tgt edge idx = 0
     src Item idx = 0
     ------------------- tgt edge idx = 1
     src Item Idx = 1
     ------------------- tgt edge idx = 2
     src Item Idx = 2
     ------------------- tgt edge idx= 3
     ...
     ------------------- tgt edge idx = N - 1
     src Item Idx = N - 1
     ------------------- tgt edge idx = N

      */
    func rearrangeUsingPriority(
        externalUM: UndoManager?,
        items: Array<Item>, sourceIndices: IndexSet, tgtEdgeIdx: Int
    ) {
        //
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "Move") {
            AppModel.rearrangeUsingPriority(items: items, sourceIndices: sourceIndices, tgtEdgeIdx: tgtEdgeIdx)
        }
    }

    ///  Re-arrange an arbitray list of `Item`s according to the their priortiy.
    static func rearrangeUsingPriority(items: Array<Item>, sourceIndices: IndexSet, tgtEdgeIdx: Int) {
        guard let sourceIndicesFirstIdx = sourceIndices.first, let sourceIndicesLastIdx = sourceIndices.last else {
            return
        }

        let notMovingEdges = (sourceIndicesFirstIdx ... sourceIndicesLastIdx + 1)
        guard notMovingEdges.contains(tgtEdgeIdx) == false else {
            // print("Not moving because trying to move within the range of the existing items")
            return
        }

        guard sourceIndices.allSatisfy({ $0 >= 0 && $0 < items.count }) else {
            log.warning("Not moving - not all src idx \(sourceIndices) are in valid range for items to move 0 to \(items.count - 1) ")
            return
        }

        let itemsSelected: Array<Item> = sourceIndices.map({ items[$0] })

        let movingUp: Bool = sourceIndicesFirstIdx > tgtEdgeIdx ? true : false
        // print("sourceIndixe.first =\(sourceIndicesFirstIdx),  last = \(sourceIndices.last!) tgtEdge = \(tgtIdxsEdge), Moving up \(movingUp)")

        let itemPriorities = itemPriorityPair(forEdgeIdx: tgtEdgeIdx, items: items)

        let priorityStepSize = (itemPriorities.aboveEdge - itemPriorities.belowEdge) / Double(itemsSelected.count + 1)

        if movingUp {
            _ = itemsSelected
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nicer animation
                    item.priority = itemPriorities.belowEdge + priorityStepSize * Double(itemsSelected.count - idx)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        } else {
            _ = itemsSelected
                .reversed()
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nicer animation
                    item.priority = itemPriorities.aboveEdge - priorityStepSize * Double(itemsSelected.count - idx)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        }
    }

    /// The default priority offset to use when inserting an `Item` where either as the result of moving (or creation) the insertion point is happening at the end or beginning of the the
    /// list i.e. there is no priortiy value above or below to use for the calculation so we need a default.
    private static let DefaultOffset = 100.0

    /// Pass-through undo operations boiler-plate
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

    /**
     Registers a pass-through undo from one external undo manager that triggers an undo with another.
     - Parameters:
     - externalUM: The external `UndoManager` that the pass-through is to be registered with
     - undoableTgtUM: The  `UndoManager` (usually`AppModel#viewContext` (and possibly needs to be))  that will actually perform the undo and redo operations.
     - withTarget:  ..
     - actionName: The base action name to assign (shows up in the `Undo` and `Redo` App Menubar entries).
     - action: A closure containing the action tthat is to be made undoable by the `undoableTgtUM`
      */

    private static func registerPassThroughUndo(
        with externalUM: UndoManager?, passingTo undoableTgtUM: UndoManager?, withTarget: AnyObject,
        setActionName actionName: String, action: @escaping () -> Void
    ) {
        //
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
}
