//
//  windowCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

/**
 ## Window Menu Commands
 
 Implements window management commands for the application, extending the standard
 macOS Window menu with application-specific window creation capabilities.
 
 ### Menu Structure:
 The commands are added after the standard window size controls, providing:
 - **New Window**: Creates additional Main windows for multi-window workflows
 
 ### Multi-Window Design:
 The application supports multiple Main windows, each with independent:
 - Filter selections (All/Waiting/Done)
 - Item selections and search state
 - Undo stacks and window-specific state
 
 ### Integration:
 Uses SwiftUI's openWindow environment action with the Main window group ID
 to leverage the routing system for consistent window creation behavior.
 */
extension Menubar {
    /// Builds Window menu commands for multi-window management
    var windowCommands: some Commands {
        CommandGroup(after: CommandGroupPlacement.windowSize) {
            Section {
                // Create new Main window with default routing
                Button("New Window") {
                    openWindow(id: GowiApp.WindowGroupId.Main.rawValue)
                }
                .accessibilityIdentifier(AccessId.WindowMenuNewMain.rawValue)
                .keyboardShortcut(KbShortcuts.windowOpenNew)
            }
        }
    }
}
