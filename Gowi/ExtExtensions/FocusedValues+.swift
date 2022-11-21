//
//  FocusedValues_.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 06/04/2022.
//

import SwiftUI

struct WindowUndoManager: FocusedValueKey {
    typealias Value = UndoManager
}

struct SideBarFilterSelected: FocusedValueKey {
    typealias Value = Binding<Main.SidebarFilterOpt>
}

struct ContentItemIdsSelected: FocusedValueKey {
    typealias Value = Binding<Set<UUID>>
}

struct ContentItemsSelected: FocusedValueKey {
    typealias Value = Array<Item>
}

struct ContentItems: FocusedValueKey {
    typealias Value = Array<Item>
}

struct UndoWorkFocusAreaKey: FocusedValueKey {
    typealias Value = Main.UndoWorkFocusArea
}

extension FocusedValues {
    var contentItemIdsSelected: ContentItemIdsSelected.Value? {
        get { self[ContentItemIdsSelected.self] }
        set {
            self[ContentItemIdsSelected.self] = newValue
        }
    }

    var contentItemsSelected: ContentItemsSelected.Value? {
        get { self[ContentItemsSelected.self] }
        set {
            self[ContentItemsSelected.self] = newValue
        }
    }

    var contentItems: ContentItems.Value? {
        get { self[ContentItems.self] }
        set {
            self[ContentItems.self] = newValue
        }
    }

    var sideBarFilterSelected: SideBarFilterSelected.Value? {
        get { self[SideBarFilterSelected.self] }
        set {
            self[SideBarFilterSelected.self] = newValue
        }
    }

    var windowUndoManager: WindowUndoManager.Value? {
        get { self[WindowUndoManager.self] }
        set {
            self[WindowUndoManager.self] = newValue
        }
    }

    var undoWfa: UndoWorkFocusAreaKey.Value? {
        get { self[UndoWorkFocusAreaKey.self] }
        set {
            self[UndoWorkFocusAreaKey.self] = newValue
        }
    }
}
