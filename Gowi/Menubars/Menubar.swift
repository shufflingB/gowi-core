//
//  Menubar.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import AppKit
import os
import SwiftUI
import GowiAppModel

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/**
 ## Application Menu Bar Coordinator
 
 Constructs the complete menu bar for the Gowi application, coordinating between
 global app-level commands and window-specific operations through SwiftUI's 
 focused value system.
 
 ### Menu Structure:
 - **File Menu**: Save, revert, and document-level operations
 - **Items Menu**: Todo item creation, deletion, and state management  
 - **Window Menu**: Window creation and management commands
 
 ### Dual Data Sources:
 The menu bar needs access to both global and window-specific state:
 
 - **AppModel**: For operations that work without windows (e.g., "New Item")
 - **MainStateView**: For window-specific operations (e.g., "Delete Selected Items")
 
 This dual approach ensures menu commands remain functional even when no windows
 are open, while providing context-aware behavior when windows are focused.
 
 ### Focus Integration:
 Uses SwiftUI's @FocusedValue system to automatically enable/disable menu items
 based on the currently focused window and its selection state.
 */
struct Menubar: Commands {
    /// Global app model for window-independent operations
    ///
    /// Required for commands that should work even when no Main windows exist,
    /// such as creating new items or opening new windows. Cannot rely solely on
    /// focused window state since the menu bar persists when all windows are closed.
    @ObservedObject var appModel: AppModel

    /// Currently focused Main window (if any)
    ///
    /// Provides window-specific context for operations like deleting selected items,
    /// saving changes, or accessing current selection state. Will be nil when no
    /// Main windows are focused or when the app is in background.
    @FocusedValue(\.mainStateView) var mainStateView: Main?

    /// SwiftUI environment for opening new windows
    @Environment(\.openWindow) internal var openWindow

    var body: some Commands {
        fileCommands
        itemCommands
        windowCommands
    }
}
