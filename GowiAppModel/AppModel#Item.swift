//
//  AppModel#Item.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Combine
import CoreData


import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// AppModel public functionallity specifically associated with the handling of `Item`s
extension AppModel {
    /// Persists changes made against `AppModel#viewContext`
    public func saveToBackend() {
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
        /// Used to instantiate the bare minimum for item
        let newItem = Item(context: moc)
        newItem.ourId = UUID()
        newItem.created = Date()
        newItem.title = title
        newItem.completed = complete
        newItem.notes = notes
        
        for parent in parents {
            /// No need to check for duplicats as the use of Sets removes them.
            let _ = itemLinkAdd(moc, parent: parent, child: newItem, priority: priority)
        }


        for child in children {
            /// No need to check for duplicats as the use of Sets removes them.
            let _ = itemLinkAdd(moc, parent: newItem, child: child, priority: priority)
        }
        
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
    public func itemNewInsertInPriority(
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
        
        let priorities = AppModel.itemPriorityPair(parent: parent, forEdgeIdx: tgtIdxsEdge, items: items)
        
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
    public func itemsDelete(
        externalUM: UndoManager?,
        list items: Array<Item>
    ) {
        //
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "Delete") {
            Self.itemsDelete(self.viewContext, items: items)
        }
    }
    
    /// As `AppModel#itemsDelete`, except not undoable and works with arbitrary moc
    public static func itemsDelete(_ moc: NSManagedObjectContext, items: Array<Item>) {
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
    public func itemsSetCompletionDate(
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
    public static func itemsSetCompletionDate(_ moc: NSManagedObjectContext, items: Array<Item>, date: Date?) {
        items.forEach { item in
            item.completed = date
            item.objectWillChange.send()
        }
    }
    
    /// Computes priority values for above and below a desired `tgtEdgeIdx`.
    private static func itemPriorityPair(
        parent: Item,
        forEdgeIdx tgtEdgeIdx: Int,
        items: [Item]
    ) -> (aboveEdge: Double, belowEdge: Double) {
        
        guard !items.isEmpty else {
            return (aboveEdge: DefaultOffset, belowEdge: -DefaultOffset)
        }
        
        let itemAbove = tgtEdgeIdx == 0
            ? items[0]
            : items[tgtEdgeIdx - 1]
        
        let itemBelow = tgtEdgeIdx == items.count
            ? items[items.count - 1]
            : items[tgtEdgeIdx]
        
        // Use the computed method with the parent
        let above = itemAbove.priority(withRespectTo: parent) ?? 0.0
        let below = itemBelow.priority(withRespectTo: parent) ?? 0.0
        
        let itemPriorityAboveTgtEdge = tgtEdgeIdx == 0
            ? above + DefaultOffset
            : above
        
        let itemPriorityBelowTgtEdge = tgtEdgeIdx == items.count
            ? below - DefaultOffset
            : below
        
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
    public func rearrangeUsingPriority(
        externalUM: UndoManager?, parent: Item,
        items: Array<Item>, sourceIndices: IndexSet, tgtEdgeIdx: Int
    ) {
        //
        Self.registerPassThroughUndo(with: externalUM, passingTo: viewContext.undoManager, withTarget: self, setActionName: "Move") {
            AppModel.rearrangeUsingPriority(parent: parent, items: items, sourceIndices: sourceIndices, tgtEdgeIdx: tgtEdgeIdx)
        }
    }
    
    ///  Re-arrange an arbitray list of `Item`s according to the their priortiy.
    static func rearrangeUsingPriority(parent: Item, items: Array<Item>, sourceIndices: IndexSet, tgtEdgeIdx: Int) {
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
        
        let itemPriorities = itemPriorityPair( parent: parent , forEdgeIdx: tgtEdgeIdx, items: items)
        
        let priorityStepSize = (itemPriorities.aboveEdge - itemPriorities.belowEdge) / Double(itemsSelected.count + 1)
        
        if movingUp {
            _ = itemsSelected
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nicer animation
                    item.setPriority(itemPriorities.belowEdge + priorityStepSize * Double(itemsSelected.count - idx), withRespectTo: parent)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        } else {
            _ = itemsSelected
                .reversed()
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nicer animation
                    item.setPriority(itemPriorities.aboveEdge - priorityStepSize * Double(itemsSelected.count - idx), withRespectTo: parent)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        }
    }
    
    /// The default priority offset to use when inserting an `Item` where either as the result of moving (or creation) the insertion point is happening at the end or beginning of the the
    /// list i.e. there is no priortiy value above or below to use for the calculation so we need a default.
    private static let DefaultOffset = 100.0
    
    
}
