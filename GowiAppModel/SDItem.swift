//
//  SdItem.swift
//  GowiAppModel
//
//  Created by Jonathan Hume on 07/07/2025.
//

import SwiftData
import Foundation

@Model
class SDItem {
    @Attribute(.unique) var id: UUID
    
    var root: Bool
    var title: String
    var ourId: UUID
    var created: Date
    var completed : Date?
    var notes: String
    
    // These are the links from this item to children (parent → child)
    @Relationship( deleteRule: .cascade, inverse: \SDItemLink.parent)
    var childrenList: [SDItemLink] = []

    // These are the links from this item to parents (child ← parent)
    @Relationship( deleteRule: .cascade, inverse: \SDItemLink.child)
    var parentList: [SDItemLink] = []

    init(title: String = "", ourId: UUID?, created: Date?, completed: Date?, notes: String = "", isRoot root: Bool = false) {
        self.id = UUID()
        self.root = root
        
        self.title = title
        
        if let ourId = ourId {
            self.ourId = ourId
        } else {
            self.ourId = UUID()
        }
        
        if let created = created {
            self.created = created
        } else {
            self.created = Date()
        }
        
        self.completed = completed
        
        self.notes = notes
        
        self.root = root
        
        
    }

}
