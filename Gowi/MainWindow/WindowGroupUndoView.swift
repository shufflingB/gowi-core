//
//  WindowGroupUndoView.swift
//  Gowi
//
//  Created by Jonathan Hume on 21/11/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension Main {
    enum UndoWorkFocusArea {
        case content
        case detailTitle, detailCompletedDate, detailNotes
    }

    /// Adopt a simple, moment the user changes window or moves their focus away from a particular Work Focus Area clear the SwiftUI
    /// built in window UndoManager. Gone down this simple route bc app doesn't really need anything else (at the moment) and delivering something
    /// more sophisticated with the existing api in SwiftUI requires a disproportionate amount of additional work..
    ///
    /// If wondering why the stack has to be cleared  at all it's because SwiftUI provides a single UndoManager per Window and  to avoid annoying the user by
    /// having them accidently undo things that they believe they have finished working on it's the easiest solution. Without doing this we'd run into situations where
    /// things like a user hitting undo in the notes area would then find they have inadvertantly undone rearranging priority with which they intend to work on an item
    /// - or worse.

    struct WindowGroupUndoView<Content: View>: View {
        @ViewBuilder let content: Content

        @Environment(\.undoManager) internal var windowUM: UndoManager?
        @FocusedValue(\.undoWfa) var wfa: UndoWorkFocusArea?

        // Have to use the hack bc we're using FocusedValue to indicate the area of the UI
        // that the user is working with. The problem is that with the DatePicker (and possibly
        // others), it triggers a pop-up. And it's not possible to assign the same WFA focused value
        // to the pop-up. So without the hack, evertime we get the pop-up appear or dissaper, the
        // undo stack gets cleared, which given it gets triggered very easily, would utterly
        // negate most of the the point of having undoable date changes.
        @State private var hackedWFA: UndoWorkFocusArea? = nil

        var body: some View {
            content
                .onChange(of: wfa) { newWFA in

                    if hackedWFA == .detailCompletedDate && newWFA == nil {
//                        log.debug("Not clearing undo stack: Detected Date flat View to Pop Up transition")
                        return
                    }
                    if wfa == nil && hackedWFA == .detailCompletedDate {
//                        log.debug("Not clearing undo stack: Detected Date Pop Up to flat View transition")
                        return
                    }

                    hackedWFA = newWFA
                }
                .onChange(of: hackedWFA, perform: { _ in
//                    log.debug("Got new hackedWFA, clearing window undo stack")
                    windowUM?.removeAllActions()
                })
                .onReceive(NSApplication.shared.publisher(for: \.keyWindow)) { _ in
                    windowUM?.removeAllActions()
                }
        }
    }
}
