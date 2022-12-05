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
    var ourIdS: UUID {
        get { ourId ?? UUID() }

        set(nv) { ourId = nv }
    }

    var titleS: String {
        get { title ?? "" }

        set(nv) {
            if nv != title {
                title = nv
            }
        }
    }

    var notesS: String {
        get { notes ?? "" }

        set(nv) {
            if nv != notes {
                notes = nv
            }
        }
    }

    var parentListAsSet: Set<Item> {
        parentList as? Set<Item> ?? []
    }

    var childrenListAsSet: Set<Item> {
        childrenList as? Set<Item> ?? []
    }
}
