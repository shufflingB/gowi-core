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

extension Item {
    var ourIdS: UUID {
        get { ourId ?? UUID() }

        set(nv) { ourId = nv }
    }

    var titleS: String {
        get { title ?? "" }

        set(nv) {
            if nv != title {
//                log.debug("Title being set to \(nv)")
                title = nv
                /// Need this to workaround  "Binding<String> action tried to update multiple times per frame" bug and to ensure the title  displayed in the Sidebar
                /// and Detail stay properly in sync. See  macOSToDo://main/v1/all?id=08C85195-4871-4011-867A-23E8CF2415B2 for more on that.
                objectWillChange.send()
            }
        }
    }

    var notesS: String {
        get { notes ?? "" }

        set(nv) {
            if nv != notes {
//            print("Notes being set")
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
