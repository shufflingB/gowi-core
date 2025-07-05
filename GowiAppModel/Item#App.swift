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
        parentList as? Set<Item> ?? []
    }

    public var childrenListAsSet: Set<Item> {
        childrenList as? Set<Item> ?? []
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
