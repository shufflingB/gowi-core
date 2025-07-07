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
    var title: String

    // These are the links from this item to children (parent → child)
    @Relationship( deleteRule: .cascade, inverse: \SDItemLink.parent)
    var childLinks: [SDItemLink] = []

    // These are the links from this item to parents (child ← parent)
    @Relationship( deleteRule: .cascade, inverse: \SDItemLink.child)
    var parentLinks: [SDItemLink] = []

    init(title: String) {
        self.id = UUID()
        self.title = title
    }

    var children: [SDItem] {
        childLinks.sorted { $0.priority < $1.priority }.map { $0.child }
    }

    var parents: [SDItem] {
        parentLinks.map { $0.parent }
    }
}
