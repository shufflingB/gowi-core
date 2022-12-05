//
//  windowCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Menubar {
    /// Builds the App specific parts of the Main window's  Menubar Window menu.
    var windowCommands: some Commands {
        CommandGroup(after: CommandGroupPlacement.windowSize) {
            Section {
                Button("New Window") {
                    openWindow(id: GowiApp.WindowGroupId.Main.rawValue)
                }
                .accessibilityIdentifier(AccessId.WindowMenuNewMain.rawValue)
                .keyboardShortcut(KbShortcuts.windowOpenNew)
            }
        }
    }
}
