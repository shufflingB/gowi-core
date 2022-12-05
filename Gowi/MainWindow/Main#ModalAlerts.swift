//
//  Main#ModalAlerts.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//
import SwiftUI

extension Main {
    /// Runs an `NSAlert` modal dialogue that asks the user to confirm that they would like to revert any unsaved data.
    /// - Returns: `true` if the user wishes to proceed with reversion, `false` otherwise.
    static func modalUserConfirmsRevert() -> Bool {
        let alert = NSAlert()
        alert.messageText = "Revert and cancel all unsaved changes?"
        alert.informativeText = "(This is not undoable)"
        alert.addButton(withTitle: "Revert")
        alert.addButton(withTitle: "Cancel")
        alert.buttons[0].hasDestructiveAction = true
        alert.alertStyle = .warning
        let modalResponse = alert.runModal()
        if modalResponse == .alertFirstButtonReturn {
            return true
        } else {
            return false
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
