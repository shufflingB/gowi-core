//
//  SDItemLink.swift
//  GowiAppModel
//
//  Created by Jonathan Hume on 07/07/2025.
//

import SwiftData
import Foundation

@Model
class SDItemLink {
    @Attribute(.unique) var id: UUID
    var priority: Int

    @Relationship(deleteRule: .nullify) var parent: SDItem
    @Relationship(deleteRule: .nullify) var child: SDItem

    init(parent: SDItem, child: SDItem, priority: Int) {
        self.id = UUID()
        self.parent = parent
        self.child = child
        self.priority = priority
    }
}
