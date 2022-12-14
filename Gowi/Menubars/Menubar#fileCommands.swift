//
//  fileCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Menubar {
    /// Builds the App specific parts of the Main window's  Menubar File menu.
    var fileCommands: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
            Section {
                Text("TODO: JSON import and export")
                Button("Save Changes") {
                    withAnimation {
                        appModel.saveToCoreData()
                    }
                }
                .disabled(appModel.hasUnPushedChanges == false)
                .accessibilityIdentifier(AccessId.FileMenuSave.rawValue)
                .keyboardShortcut(KbShortcuts.fileSaveChanges)

                Button("Revert Changes") {
                    guard Main.modalUserConfirmsRevert() else {
                        return
                    }
                    withAnimation {
                        appModel.viewContext.rollback()
                    }
                }
                .disabled(appModel.hasUnPushedChanges == false)
                .accessibilityIdentifier(AccessId.FileMenuRevert.rawValue)
//                .keyboardShortcut(KbShortcuts.fileSaveChanges)
            }
        }
    }
}


