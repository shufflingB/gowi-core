//
//  Item#App.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import CoreData
import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

import SwiftUI

// App level extension of `Item`
extension Item {
    public var ourIdS: UUID {
        get { ourId ?? UUID() }

        set(nv) { ourId = nv }
    }

    public var titleS: String {
        get { title ?? "" }

        set(nv) {
            if nv != title {
                title = nv
            }
        }
    }

    public var notesS: String {
        get { notes ?? "" }

        set(nv) {
            if nv != notes {
                notes = nv
            }
        }
    }

    public var parentListAsSet: Set<Item> {
        // parentList now contains ItemLink objects, not Items directly
        // Use the new ItemLink-based accessor
        return Set(parentItemsViaLinks)
    }

    public var childrenListAsSet: Set<Item> {
        // childrenList now contains ItemLink objects, not Items directly
        // Use the new ItemLink-based accessor
        return Set(childrenOrderedByPriority)
    }
    
    /// Gets children ordered by ItemLink priority (highest first)
    /// - Returns: Array of child Items ordered by ItemLink priority
    public var childrenOrderedByPriority: [Item] {
        let itemTitle = titleS
        guard let moc = managedObjectContext else {
            log.warning("No managed object context available for \(itemTitle)")
            return []
        }
        
        let request: NSFetchRequest<ItemLink> = ItemLink.fetchRequest()
        request.predicate = NSPredicate(format: "parent == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        
        do {
            let itemLinks = try moc.fetch(request)
            return itemLinks.compactMap { $0.child }
        } catch {
            log.error("Failed to fetch ordered children for \(itemTitle): \(error)")
            return []
        }
    }
    
    /// Gets ItemLink entities where this item is the parent
    /// - Returns: Array of ItemLink entities
    public var childrenLinks: [ItemLink] {
        let itemTitle = titleS
        guard let moc = managedObjectContext else {
            log.warning("No managed object context available for \(itemTitle)")
            return []
        }
        
        let request: NSFetchRequest<ItemLink> = ItemLink.fetchRequest()
        request.predicate = NSPredicate(format: "parent == %@", self)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: false)]
        
        do {
            return try moc.fetch(request)
        } catch {
            log.error("Failed to fetch children links for \(itemTitle): \(error)")
            return []
        }
    }
    
    /// Gets ItemLink entities where this item is the child
    /// - Returns: Array of ItemLink entities
    public var parentLinks: [ItemLink] {
        let itemTitle = titleS
        guard let moc = managedObjectContext else {
            log.warning("No managed object context available for \(itemTitle)")
            return []
        }
        
        let request: NSFetchRequest<ItemLink> = ItemLink.fetchRequest()
        request.predicate = NSPredicate(format: "child == %@", self)
        
        do {
            return try moc.fetch(request)
        } catch {
            log.error("Failed to fetch parent links for \(itemTitle): \(error)")
            return []
        }
    }
    
    /// Gets all parent Items via ItemLink relationships
    /// - Returns: Array of parent Items
    public var parentItemsViaLinks: [Item] {
        return parentLinks.compactMap { $0.parent }
    }
    
    public func priority(withRespectTo parent: Item) -> Double? {
        self.parentLinks.first { iLink in
            iLink.parent == parent
        }?.priority ?? 0.0
    }
    
    public func setPriority(_ newPriority: Double, withRespectTo parent: Item) {
        if let link = self.parentLinks.first(where: { $0.parent == parent }) {
            link.priority = newPriority
        } else {
            assertionFailure("No ItemLink exists between \(String(describing: parent.title)) and \(String(describing: self.title))")
        }
    }

}

// MARK: - Codable Conformance
extension Item: Encodable {
    enum CodingKeys: String, CodingKey {
        case title
        case ourId
        case creationDate
        case completionDate
        case notes
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(titleS, forKey: .title)
        try container.encode(ourIdS.uuidString, forKey: .ourId)
        try container.encode(notesS, forKey: .notes)
        
        let formatter = ISO8601DateFormatter()
        
        // Handle creation date
        if let createdDate = created {
            try container.encode(formatter.string(from: createdDate), forKey: .creationDate)
        } else {
            try container.encode("", forKey: .creationDate)
        }
        
        // Handle completion date
        if let completedDate = completed {
            try container.encode(formatter.string(from: completedDate), forKey: .completionDate)
        } else {
            try container.encode("null", forKey: .completionDate)
        }
    }
}

// MARK: - JSON Export
extension Item {
    /// Exports the Item as JSON data
    /// - Returns: JSON Data representation of the Item
    /// - Throws: EncodingError if JSON serialization fails
    public func exportAsJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(self)
    }
}
