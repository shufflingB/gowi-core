//
//  App+ContentViewCommands.swift
//  App+ContentViewCommands
//
//  Created by Jonathan Hume on 23/08/2021.
//

import AppKit
import os
import SwiftUI

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

struct Main_MenuBar: Commands {
    @ObservedObject var appModel: AppModel
    @Environment(\.openWindow) internal var openWindow

    @FocusedValue(\.windowUndoManager) var windowUM
    @FocusedValue(\.contentItemIdsSelected) var contentItemIdsSelected
    @FocusedValue(\.contentItemsSelected) var contentItemsSelected

    @FocusedValue(\.contentItems) var contentItems
    @FocusedValue(\.sideBarFilterSelected) var sideBarFilterSelected

    var body: some Commands {
        fileCommands
        itemCommands
        windowCommands
    }
}

