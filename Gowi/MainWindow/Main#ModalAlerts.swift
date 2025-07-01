//
//  Main#ModalAlerts.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//
import SwiftUI

/**
 ## Modal Alert Dialogs for Main Window
 
 Provides modal confirmation dialogs using AppKit's NSAlert for critical user decisions.
 Using NSAlert instead of SwiftUI dialogs ensures proper modal behavior and follows
 macOS conventions for destructive operations.
 
 ### Design Rationale:
 SwiftUI's alert modifiers can have inconsistent behavior in multi-window scenarios.
 NSAlert provides reliable modal behavior that properly blocks user interaction
 until the decision is made, which is essential for destructive operations like
 data reversion that cannot be undone.
 */
extension Main {
    /// Displays a confirmation dialog for reverting unsaved changes
    ///
    /// Shows a modal warning dialog asking the user to confirm they want to revert
    /// all unsaved changes. The dialog clearly indicates this action is not undoable
    /// and marks the primary action as destructive following macOS conventions.
    ///
    /// - Returns: `true` if user confirms reversion, `false` if they cancel
    static func modalUserConfirmsRevert() -> Bool {
        let alert = NSAlert()
        alert.messageText = "Revert and cancel all unsaved changes?"
        alert.informativeText = "(This is not undoable)"
        alert.addButton(withTitle: "Revert")
        alert.addButton(withTitle: "Cancel")
        
        // Mark the destructive action following macOS conventions
        alert.buttons[0].hasDestructiveAction = true
        alert.alertStyle = .warning
        
        // Display modal dialog and process response
        let modalResponse = alert.runModal()
        if modalResponse == .alertFirstButtonReturn {
            return true  // User confirmed reversion
        } else {
            return false  // User cancelled
        }
    }
}

struct _Main_ModalAlerts_Previews: PreviewProvider {
    static var previews: some View {
        Button("In Live view; click this button to show modal") {
            _ = Main.modalUserConfirmsRevert()
        }
    }
}
