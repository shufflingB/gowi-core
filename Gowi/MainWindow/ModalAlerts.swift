//
//  ModalAlerts.swift
//  Gowi
//
//  Created by Jonathan Hume on 07/11/2022.
//

import SwiftUI

extension Main {
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
