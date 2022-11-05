//
//  fileCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/11/2022.
//

import SwiftUI

extension Menubar {
    var fileCommands: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
            Section {
                Text("TODO: JSON import and export")
                Text("Moc has changes = \(appModel.hasUnPushedChanges.description)")
                Button("Save Changes") {
                    withAnimation {
                        appModel.saveToCoreData()
                    }
                }
                .disabled(appModel.hasUnPushedChanges == false)
                .accessibilityIdentifier(AccessId.FileMenuSave.rawValue)
                .keyboardShortcut(KbShortcuts.fileSaveChanges)

                Button("Revert Changes") {
                    withAnimation {
                        showConfirmCancelLocalDialogue?.wrappedValue = true
                    }
                }
                .disabled(appModel.hasUnPushedChanges == false)
                .accessibilityIdentifier(AccessId.FileMenuSave.rawValue)
//                .keyboardShortcut(KbShortcuts.fileSaveChanges)
            }
        }
    }
}
