//
//  fileCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

/**
 ## File Menu Commands
 
 Implements the File menu for the application, focusing on document-level operations
 like saving and reverting changes. This replaces SwiftUI's default "New Item" command
 group with application-specific file operations.
 
 ### Menu Structure:
 - **Save Changes**: Manually save unsaved CoreData changes to persistent store
 - **Revert Changes**: Rollback all unsaved changes with user confirmation
 - **Future**: JSON import/export functionality (planned)
 
 ### CoreData Integration:
 The commands integrate with the app's CoreData stack to provide manual control
 over when changes are persisted. This is particularly important for:
 - Batch operations that should be saved together
 - User-initiated save points
 - Recovery from problematic states
 
 ### User Safety:
 The revert operation includes a confirmation dialog to prevent accidental
 data loss, following macOS conventions for destructive operations.
 */
extension Menubar {
    /// Builds the File menu commands for document-level operations
    var fileCommands: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
            Section {
                // Placeholder for future import/export functionality
                Text("TODO: JSON import and export")
                
                // Manual save command for CoreData changes
                Button("Save Changes") {
                    withAnimation {
                        appModel.saveToCoreData()
                    }
                }
                .disabled(appModel.hasUnPushedChanges == false)
                .accessibilityIdentifier(AccessId.FileMenuSave.rawValue)
                .keyboardShortcut(KbShortcuts.fileSaveChanges)

                // Revert all unsaved changes with confirmation
                Button("Revert Changes") {
                    // Require user confirmation before destructive operation
                    guard Main.modalUserConfirmsRevert() else {
                        return
                    }
                    withAnimation {
                        appModel.viewContext.rollback()
                    }
                }
                .disabled(appModel.hasUnPushedChanges == false)
                .accessibilityIdentifier(AccessId.FileMenuRevert.rawValue)
                // TODO: Determine appropriate keyboard shortcut for revert operation
                // .keyboardShortcut(KbShortcuts.fileRevertChanges)
            }
        }
    }
}


