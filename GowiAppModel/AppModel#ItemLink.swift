//
//  AppModel#ItemLink.swift
//  GowiAppModel
//
//  Created by Jonathan Hume on 07/07/2025.
//

import CoreData
import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/// AppModel functionality for managing ItemLink entities (junction table for Item relationships)
extension AppModel {
    
    /// Adds a child Item to a parent Item via ItemLink with specified priority in an undoable way
    /// - Parameters:
    ///   - externalUM: UndoManager for undo support
    ///   - parent: The parent Item
    ///   - child: The child Item to add
    ///   - priority: The priority for this parent-child relationship
    /// - Returns: The created ItemLink entity
    @discardableResult
    public func itemLinkAdd(
        externalUM: UndoManager? = nil,
        parent: Item,
        child: Item,
        priority: Double
    ) -> ItemLink {
        var createdLink: ItemLink?
        
        Self.registerPassThroughUndo(
            with: externalUM,
            passingTo: viewContext.undoManager,
            withTarget: self,
            setActionName: "Add Link"
        ) { [self] in
            createdLink = Self.itemLinkAdd(
                self.viewContext,
                parent: parent,
                child: child,
                priority: priority
            )
        }
        
        return createdLink!
    }
    
    /// Static version of itemLinkAdd for use with arbitrary NSManagedObjectContext
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use
    ///   - parent: The parent Item
    ///   - child: The child Item to add
    ///   - priority: The priority for this parent-child relationship
    /// - Returns: The created ItemLink entity
    @discardableResult
    public static func itemLinkAdd(
        _ moc: NSManagedObjectContext,
        parent: Item,
        child: Item,
        priority: Double
    ) -> ItemLink {
        // Check if link already exists
        if let existingLink = findItemLink(moc, parent: parent, child: child) {
            // Update existing link's priority
            existingLink.priority = priority
            return existingLink
        }
        
        // Create new ItemLink
        let itemLink = ItemLink(context: moc)
        itemLink.parent = parent
        itemLink.child = child
        itemLink.priority = priority
        
        log.debug("Created ItemLink: parent=\(parent.titleS), child=\(child.titleS), priority=\(priority)")
        
        return itemLink
    }
    
    /// Removes the ItemLink between a parent and child Item in an undoable way
    /// - Parameters:
    ///   - externalUM: UndoManager for undo support
    ///   - parent: The parent Item
    ///   - child: The child Item to remove
    public func itemLinkRemove(
        externalUM: UndoManager? = nil,
        parent: Item,
        child: Item
    ) {
        Self.registerPassThroughUndo(
            with: externalUM,
            passingTo: viewContext.undoManager,
            withTarget: self,
            setActionName: "Remove Link"
        ) { [self] in
            Self.itemLinkRemove(self.viewContext, parent: parent, child: child)
        }
    }
    
    /// Static version of itemLinkRemove for use with arbitrary NSManagedObjectContext
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use
    ///   - parent: The parent Item
    ///   - child: The child Item to remove
    public static func itemLinkRemove(
        _ moc: NSManagedObjectContext,
        parent: Item,
        child: Item
    ) {
        if let itemLink = findItemLink(moc, parent: parent, child: child) {
            log.debug("Removing ItemLink: parent=\(parent.titleS), child=\(child.titleS)")
            moc.delete(itemLink)
        } else {
            log.warning("ItemLink not found for removal: parent=\(parent.titleS), child=\(child.titleS)")
        }
    }
    
    /// Updates the priority of an existing ItemLink in an undoable way
    /// - Parameters:
    ///   - externalUM: UndoManager for undo support
    ///   - parent: The parent Item
    ///   - child: The child Item
    ///   - newPriority: The new priority value
    public func itemLinkUpdatePriority(
        externalUM: UndoManager? = nil,
        parent: Item,
        child: Item,
        newPriority: Double
    ) {
        Self.registerPassThroughUndo(
            with: externalUM,
            passingTo: viewContext.undoManager,
            withTarget: self,
            setActionName: "Update Link Priority"
        ) { [self] in
            Self.itemLinkUpdatePriority(self.viewContext, parent: parent, child: child, newPriority: newPriority)
        }
    }
    
    /// Static version of itemLinkUpdatePriority for use with arbitrary NSManagedObjectContext
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use
    ///   - parent: The parent Item
    ///   - child: The child Item
    ///   - newPriority: The new priority value
    public static func itemLinkUpdatePriority(
        _ moc: NSManagedObjectContext,
        parent: Item,
        child: Item,
        newPriority: Double
    ) {
        if let itemLink = findItemLink(moc, parent: parent, child: child) {
            let oldPriority = itemLink.priority
            itemLink.priority = newPriority
            log.debug("Updated ItemLink priority: parent=\(parent.titleS), child=\(child.titleS), \(oldPriority) -> \(newPriority)")
        } else {
            log.warning("ItemLink not found for priority update: parent=\(parent.titleS), child=\(child.titleS)")
        }
    }
    
    /// Gets ordered children for a parent Item based on ItemLink priorities
    /// - Parameter parent: The parent Item
    /// - Returns: Array of child Items ordered by priority (highest first)
    public func itemLinkGetOrderedChildren(parent: Item) -> [Item] {
        return Self.itemLinkGetOrderedChildren(viewContext, parent: parent)
    }
    
    /// Static version of itemLinkGetOrderedChildren for use with arbitrary NSManagedObjectContext
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use
    ///   - parent: The parent Item
    /// - Returns: Array of child Items ordered by priority (highest first)
    public static func itemLinkGetOrderedChildren(_ moc: NSManagedObjectContext, parent: Item) -> [Item] {
        let request: NSFetchRequest<ItemLink> = ItemLink.fetchRequest()
        request.predicate = NSPredicate(format: "parent == %@", parent)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        
        do {
            let itemLinks = try moc.fetch(request)
            return itemLinks.compactMap { $0.child }
        } catch {
            log.error("Failed to fetch ordered children: \(error)")
            return []
        }
    }
    
    /// Rearranges items using ItemLink priorities for a specific parent in an undoable way
    /// - Parameters:
    ///   - externalUM: UndoManager for undo support
    ///   - parent: The parent Item whose children are being reordered
    ///   - items: Current sorted list of child Items
    ///   - sourceIndices: The indices of items to move
    ///   - tgtEdgeIdx: The target edge index for insertion
    public func itemLinkRearrangeUsingPriority(
        externalUM: UndoManager? = nil,
        parent: Item,
        items: [Item],
        sourceIndices: IndexSet,
        tgtEdgeIdx: Int
    ) {
        Self.registerPassThroughUndo(
            with: externalUM,
            passingTo: viewContext.undoManager,
            withTarget: self,
            setActionName: "Reorder Items"
        ) { [self] in
            Self.itemLinkRearrangeUsingPriority(
                self.viewContext,
                parent: parent,
                items: items,
                sourceIndices: sourceIndices,
                tgtEdgeIdx: tgtEdgeIdx
            )
        }
    }
    
    /// Static version of itemLinkRearrangeUsingPriority for use with arbitrary NSManagedObjectContext
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use
    ///   - parent: The parent Item whose children are being reordered
    ///   - items: Current sorted list of child Items
    ///   - sourceIndices: The indices of items to move
    ///   - tgtEdgeIdx: The target edge index for insertion
    public static func itemLinkRearrangeUsingPriority(
        _ moc: NSManagedObjectContext,
        parent: Item,
        items: [Item],
        sourceIndices: IndexSet,
        tgtEdgeIdx: Int
    ) {
        guard let sourceIndicesFirstIdx = sourceIndices.first,
              let sourceIndicesLastIdx = sourceIndices.last else {
            return
        }
        
        let notMovingEdges = (sourceIndicesFirstIdx ... sourceIndicesLastIdx + 1)
        guard !notMovingEdges.contains(tgtEdgeIdx) else {
            return
        }
        
        guard sourceIndices.allSatisfy({ $0 >= 0 && $0 < items.count }) else {
            log.warning("Invalid source indices: \(sourceIndices) for items count: \(items.count)")
            return
        }
        
        let itemsSelected = sourceIndices.map { items[$0] }
        
        // Calculate priority range for insertion using boundary priorities
        let itemPriorities = itemLinkPriorityPair(moc, parent: parent, forEdgeIdx: tgtEdgeIdx, items: items)
        
        // Distribute priorities evenly in available range: (above - below) / (count + 1)
        // +1 ensures spacing between existing items and moved items
        let priorityStepSize = (itemPriorities.aboveEdge - itemPriorities.belowEdge) / Double(itemsSelected.count + 1)
        
        let movingUp = sourceIndicesFirstIdx > tgtEdgeIdx
        
        if movingUp {
            for (idx, item) in itemsSelected.enumerated() {
                let newPriority = itemPriorities.belowEdge + priorityStepSize * Double(itemsSelected.count - idx)
                itemLinkUpdatePriority(moc, parent: parent, child: item, newPriority: newPriority)
            }
        } else {
            for (idx, item) in itemsSelected.reversed().enumerated() {
                let newPriority = itemPriorities.aboveEdge - priorityStepSize * Double(itemsSelected.count - idx)
                itemLinkUpdatePriority(moc, parent: parent, child: item, newPriority: newPriority)
            }
        }
    }
    
    /// Finds an existing ItemLink between parent and child
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use
    ///   - parent: The parent Item
    ///   - child: The child Item
    /// - Returns: The ItemLink if found, nil otherwise
    private static func findItemLink(_ moc: NSManagedObjectContext, parent: Item, child: Item) -> ItemLink? {
        let request: NSFetchRequest<ItemLink> = ItemLink.fetchRequest()
        request.predicate = NSPredicate(format: "parent == %@ AND child == %@", parent, child)
        request.fetchLimit = 1
        
        do {
            let links = try moc.fetch(request)
            return links.first
        } catch {
            log.error("Failed to find ItemLink: \(error)")
            return nil
        }
    }
    
    /// Computes priority values for above and below a desired edge index for ItemLink-based priorities
    ///
    /// Calculates priority bounds for inserting items at a specific edge position. Uses DefaultOffset
    /// for head/tail insertions to provide adequate spacing for future insertions.
    ///
    /// - Parameters:
    ///   - moc: The NSManagedObjectContext to use for ItemLink queries
    ///   - parent: The parent Item whose children are being reordered
    ///   - tgtEdgeIdx: The target edge index where insertion will occur (0 = top, items.count = bottom)
    ///   - items: Array of items in current priority order
    /// - Returns: Tuple with above and below edge priority values for calculating insertion priorities
    private static func itemLinkPriorityPair(
        _ moc: NSManagedObjectContext,
        parent: Item,
        forEdgeIdx tgtEdgeIdx: Int,
        items: [Item]

    ) -> (aboveEdge: Double, belowEdge: Double) {
        guard items.count > 0 else {
            return (aboveEdge: DefaultOffset, belowEdge: -DefaultOffset)
        }
        
        let itemPriorityAboveTgtEdge: Double
        if tgtEdgeIdx == 0 {
            // Moving to head of list
            if let firstItemLink = findItemLink(moc, parent: parent, child: items[0]) {
                itemPriorityAboveTgtEdge = firstItemLink.priority + DefaultOffset
            } else {
                itemPriorityAboveTgtEdge = DefaultOffset
            }
        } else {
            // Get priority of item above target edge
            if let itemLink = findItemLink(moc, parent: parent, child: items[tgtEdgeIdx - 1]) {
                itemPriorityAboveTgtEdge = itemLink.priority
            } else {
                itemPriorityAboveTgtEdge = DefaultOffset
            }
        }
        
        let itemPriorityBelowTgtEdge: Double
        if tgtEdgeIdx == items.count {
            // Moving to tail of list
            if let lastItemLink = findItemLink(moc, parent: parent, child: items[items.count - 1]) {
                itemPriorityBelowTgtEdge = lastItemLink.priority - DefaultOffset
            } else {
                itemPriorityBelowTgtEdge = -DefaultOffset
            }
        } else {
            // Get priority of item below target edge
            if let itemLink = findItemLink(moc, parent: parent, child: items[tgtEdgeIdx]) {
                itemPriorityBelowTgtEdge = itemLink.priority
            } else {
                itemPriorityBelowTgtEdge = -DefaultOffset
            }
        }
        
        return (aboveEdge: itemPriorityAboveTgtEdge, belowEdge: itemPriorityBelowTgtEdge)
    }
    
    /// Default priority offset for ItemLink operations
    private static let DefaultOffset = 100.0
}
