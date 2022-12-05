//
//  FocusedValues#App.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

// App level extension of `FocusedValues`
extension FocusedValues {
    struct MainStateView: FocusedValueKey {
        typealias Value = Main
    }

    struct UndoWorkFocusAreaKey: FocusedValueKey {
        typealias Value = Main.UndoWorkFocusArea
    }

    /// The Main view Window that is currently focused (has key if app is selected)
    var mainStateView: MainStateView.Value? {
        get { self[MainStateView.self] }
        set {
            self[MainStateView.self] = newValue
        }
    }

    /// The currently selected Undo Work Focus  Area.
    ///
    /// Changing the UWFA is one of the most important parameters used to  determine when to clear the `UndoManager`s  stack (the other is window change)
    /// For more  on Undoable Work Focus Aress see ``Main/WindowGroupUndoView``
    var undoWfa: UndoWorkFocusAreaKey.Value? {
        get { self[UndoWorkFocusAreaKey.self] }
        set {
            self[UndoWorkFocusAreaKey.self] = newValue
        }
    }
}
