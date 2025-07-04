//
//  Main#WindowGroupUndoView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// Handle UndoWorkFocus areas for the Main window.
extension Main {
    /// List of Undoable Work Focus Area (place where undoable operations group).
    enum UndoWorkFocusArea {
        case content
        case detailTitle, detailCompletedDate, detailNotes
    }

    /**
     Handles clearing the undo stack for the Window when the user shifts their work focus

     ## Background

     ### Undoable Work Focus Areas (UWFA)

     For an app to provide a pleasant undo experience, it needs to be able to define a set of  UI controls that are likely to be used as part of particular user Work Focus such that:
        - within the set - the user will expect undo and redo operations to combine in the same stack
        - outside of the set - they will adopt a different different stack.

     This concept is referred to in this app as an  Undoable Work Focus Area (UWFA)

     Examples:
         - Two `TextField`s, one in a content list and the other in a detail displaying the same date,  would ideally (not possible with SwiftUI currently) share the same undo stack
        and therefore be part of the same UWFA.

        - The controls for managing `Items` in the `Waiting` list such as those for  drag and drop rearrangement and the addition of new `Item` might form part of another UWFA.

        - The notes `TextEditor` for an `Item` another.

     Generally the idea with a UWFA is to stop  things like  a user manipulating their `Waiting` list from accidentally undoing one too many times and in the process undoing all of the
     changes they previously made in say the detail notes for the current `Item`  Or worse, to an `Item`'s notes that is no longer visible.

     ### The Issue

     SwiftUI by default provides:
     - An `UndoManager` instance per Window that it integrates into:
         - The app menubar.
         - its `TextEditor` and `TextField` components to enable domain specific text undo capabilities, i.e. when the user undoes a change, it undoes a block of changes,
         and not just individual characters. Where the
             - `TextField` clears its undo stack, i.e. its ability to undo/redo, the moment the user moves their input elsewhere (UWFA == just that `TextField`)
             - `TextEditor` never clears the `UndoManager`even when different instances are editing different data (no UWFA!!!)
         - And It does not provide any specific api for definining  UWFAs .
             - And the `TextEditor` implentation of undo and redo is liable to breaking when there is either:
                 - More than one `TextEditor`rendering different data in a window
                 - A single `TextEditor` rendering the same data in different windows.

     QED; to create an app with a usable undo implementation the app has to provide it's own Undoable Work Focus Area implementation to handle clearing the window undo stacks.

     ## Solution

     1)  The window defines a set of available UWFA in ``UndoWorkFocusArea`` corresponding to one more controls within UI.

     2) The app sets the  `FocusedValue.undoWfa` to the corresponding ``UndoWorkFocusArea``  when the user interacts with those controls.

     4) This component clears the default SwiftUI  per-window `UndoManager` when it detects that the user has either:
        - started working in another window.
        - or when they are working in a different  `undoWfa`.

     ### Why?
     - Similar to the approach adopted by `TextField`
     - App doesn't really need anything more sophisticated (at the moment).
     - Deelivering something more sophisticated, as Xcode does, with the existing api requires a disproportionate amount of additional work work (see https://github.com/shufflingB/swiftui-macos-undoable-texteditor for an example of one way around it)

       */

    struct WindowGroupUndoView<Content: View>: View {
        @ViewBuilder let content: Content

        @Environment(\.undoManager) internal var windowUM: UndoManager?
        @FocusedValue(\.undoWfa) var wfa: UndoWorkFocusArea?

        // Have to use the hack 🤮 bc we're using FocusedValue to indicate the area of the UI
        // that the user is working with. The problem is that with the DatePicker (and possibly
        // others), it triggers a pop-up. And it's not possible to assign the same WFA focused value
        // recursively to the pop-up content. So without the hack, everytime we get the pop-up appear
        // or dissaper, the undo stack gets cleared, which given it gets triggered very easily, would
        // negate most of the the point of having undoable date changes.
        @State private var hackedWFA: UndoWorkFocusArea? = nil

        var body: some View {
            content
                .onChange(of: wfa) { oldWFA, newWFA in
                    // DatePicker popover workaround: prevent undo clearing during normal popover cycles
                    if oldWFA == .detailCompletedDate && newWFA == nil {
                        // Transitioning from date control to popover - don't clear undo
//                        log.debug("Not clearing undo stack: Detected Date flat View to Pop Up transition")
                        return
                    }
                    if oldWFA == nil && hackedWFA == .detailCompletedDate {
                        // Transitioning from popover back to date control - don't clear undo
//                        log.debug("Not clearing undo stack: Detected Date Pop Up to flat View transition")
                        return
                    }

                    // Normal focus area transition - update tracked state
                    hackedWFA = newWFA
                }
                .onChange(of: hackedWFA) {
                    // Clear undo stack when work focus area changes
//                    log.debug("Got new hackedWFA, clearing window undo stack")
                    windowUM?.removeAllActions()
                }
                .onReceive(NSApplication.shared.publisher(for: \.keyWindow)) { _ in
                    // Clear undo stack when user switches to different window
                    windowUM?.removeAllActions()
                }
        }
    }
}
