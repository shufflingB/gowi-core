//
//  windoCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/11/2022.
//

import SwiftUI

extension Main_MenuBar {
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
