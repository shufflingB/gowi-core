//
//  FocusedValues_.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 06/04/2022.
//

import SwiftUI


struct SideBarItemIdsSelected: FocusedValueKey {
    typealias Value = Binding<Set<UUID>>
}

struct SideBarTabSelected: FocusedValueKey {
    typealias Value = Binding<SideBar.TabOption >
}

struct WindowUndoManager: FocusedValueKey {
    typealias Value = UndoManager
}


extension FocusedValues {
    
    
    var sideBarItemIdsSelected: SideBarItemIdsSelected.Value? {
        get { self[SideBarItemIdsSelected.self] }
        set {
            self[SideBarItemIdsSelected.self] = newValue
        }
    }
    
    var sideBarTabSelected: SideBarTabSelected.Value? {
        get { self[SideBarTabSelected.self] }
        set {
            self[SideBarTabSelected.self] = newValue
        }
    }
    
    
    var windowUndoManager: WindowUndoManager.Value? {
        get { self[WindowUndoManager.self] }
        set {
            self[WindowUndoManager.self] = newValue
        }
    }
}
