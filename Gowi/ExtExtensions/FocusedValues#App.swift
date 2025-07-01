//
//  FocusedValues#App.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

/**
 ## Application-Level Focused Values Extension
 
 Extends SwiftUI's FocusedValues system to support application-specific state coordination
 between the menu bar and focused windows. This enables context-aware menu commands that
 adapt based on the currently focused window and user interaction area.
 
 ### Focus Coordination:
 The system tracks two key pieces of state:
 - **Active Main Window**: Which Main window (if any) is currently focused
 - **Undo Work Focus Area (UWFA)**: Which UI area the user is currently working in
 
 ### Undo Work Focus Area (UWFA) Concept:
 UWFA is an attempt to group undoable changes so they are both appropriate to what the user
 is working on and undo at an appropriate granularity level. Key principles:
 - **Cross-Window Isolation**: When users have multiple windows with different content, they
   shouldn't accidentally undo changes to unrelated data from another window
 - **Cross-Control Isolation**: When users switch from editing notes text to adjusting dates
   or item priorities, they shouldn't accidentally undo their text changes when trying to
   undo date/priority adjustments if they get overeager with the undo button
 - **Appropriate Granularity**: When working with paragraph-sized text blocks, users expect
   undo to operate at meaningful semantic levels, not individual character changes
 - **Work Session Boundaries**: Different UI controls represent different "work sessions"
   that should have independent undo stacks
 
 ### Menu Integration:
 The menu bar uses these focused values to:
 - Enable/disable commands based on window state
 - Route commands to the appropriate window
 - Provide context-sensitive behavior
 */
extension FocusedValues {
    /// FocusedValue key for tracking the currently focused Main window
    struct MainStateView: FocusedValueKey {
        typealias Value = Main
    }

    /// FocusedValue key for tracking the current Undo Work Focus Area (UWFA)
    struct UndoWorkFocusAreaKey: FocusedValueKey {
        typealias Value = Main.UndoWorkFocusArea
    }

    /// The Main window that currently has focus and should receive menu commands
    ///
    /// When nil, menu commands that require window context will be disabled.
    /// The menu bar uses this to route commands to the appropriate window instance.
    var mainStateView: MainStateView.Value? {
        get { self[MainStateView.self] }
        set {
            self[MainStateView.self] = newValue
        }
    }

    /// The currently active Undo Work Focus Area (UWFA) within the focused window
    ///
    /// UWFA represents logical groupings of UI controls that should share undo behavior.
    /// This prevents users from accidentally undoing unrelated changes when they switch
    /// between different types of edits - for example, switching from editing notes text
    /// to adjusting completion dates or item priorities should clear the undo stack to
    /// prevent overeager undo operations from affecting the previous work area.
    ///
    /// Changing the UWFA is one of the most important parameters used to determine
    /// when to clear the UndoManager's stack (the other is window focus changes).
    /// For more details see ``Main/WindowGroupUndoView``.
    var undoWfa: UndoWorkFocusAreaKey.Value? {
        get { self[UndoWorkFocusAreaKey.self] }
        set {
            self[UndoWorkFocusAreaKey.self] = newValue
        }
    }
}
