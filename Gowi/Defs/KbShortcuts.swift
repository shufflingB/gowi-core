//
//  AccessibilityIdentifiers.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

/**
 ## Keyboard Shortcuts Definition
 
 Defines all keyboard shortcuts used throughout the Gowi application, following macOS
 conventions and user expectations from familiar productivity applications.
 
 ### Design Philosophy:
 Shortcuts are chosen based on consistency with standard macOS applications, examined in priority order:
 1. **Finder**: File management operations
 2. **Notes, Reminders**: Text and task management  
 3. **Xcode, Mail**: Developer and communication tools
 4. **Things**: Task management specialist apps
 
 Only when no clear convention exists do we create custom shortcuts.
 
 ### Organization:
 - **Primary Shortcuts**: Used directly in the application
 - **Apple Default Extension**: Built-in SwiftUI shortcuts shared with tests
 
 ### Rationale Documentation:
 Each non-obvious shortcut includes its origin application to maintain consistency
 and help future developers understand the choices made.
 */

/// Application-specific keyboard shortcuts
struct KbShortcuts {
    static let fileSaveChanges = KeyboardShortcut("s", modifiers: .command)

    static let itemsNew = KeyboardShortcut("n", modifiers: .command) // Reminders'
    static let itemsDuplicate = KeyboardShortcut("d", modifiers: .command) // Finder and other

    static let itemsDelete = KeyboardShortcut(.delete, modifiers: .command) // Finder but with extra modifier to prevent accidental.
    static let itemsMarkComplete = KeyboardShortcut("c", modifiers: [.command, .shift]) // Reminders
    static let itemsMarkOpen = KeyboardShortcut("c", modifiers: [.option, .shift]) // Reminders

    static let itemsOpenInNewWindow = KeyboardShortcut("o", modifiers: [.command, .option])
    static let itemsOpenInNewTab = KeyboardShortcut("o", modifiers: [.command])

    static let itemsSelectedNudgePriorityUp = KeyboardShortcut(.upArrow, modifiers: [.command, .control]) // Notes
    static let itemsSelectedNudgePriorityDown = KeyboardShortcut(.downArrow, modifiers: [.command, .control]) // Notes

    static let windowOpenTab = KeyboardShortcut("t", modifiers: [.command]) // Xcode, Safari etc
    static let windowOpenNew = KeyboardShortcut("t", modifiers: [.command, .shift]) // Xcode

    // TODO: static let jumpToDetailTextEditor = KeyboardShortcut("j", modifiers: [.command]) // As in what A uses in Xcode
}

/**
 ## Apple Default Shortcuts Extension
 
 This extension defines SwiftUI's built-in shortcuts that aren't explicitly used in the app
 but are needed for UI testing consistency. While these shortcuts work automatically in SwiftUI,
 defining them here provides several benefits:
 
 ### Benefits:
 - **Test Consistency**: UI tests can reference the same shortcut definitions
 - **Conflict Prevention**: Prevents accidental conflicting shortcut definitions
 - **Documentation**: Makes implicit shortcuts explicit for developer awareness
 - **Future-Proofing**: Reduces risk of confusion when adding new shortcuts
 
 ### Trade-off Analysis:
 The small increase in app code size is outweighed by the reduced risk of conflicts
 and "WTF moments" when shortcuts mysteriously don't work as expected.
 */
extension KbShortcuts { // Apple default shortcuts - primarily used in UI testing
    static let appQuit = KeyboardShortcut("q", modifiers: [.command])
    static let onExit = KeyboardShortcut(.escape)
    static let windowClose = KeyboardShortcut("w", modifiers: [.command])
    static let windowsCloseAll = KeyboardShortcut("w", modifiers: [.command, .option])
    static let windowsMoveFocusToNext = KeyboardShortcut("`", modifiers: [.command])
    static let selectHeadOfList = KeyboardShortcut(.upArrow, modifiers: [.option])
    static let selectEndOfList = KeyboardShortcut(.downArrow, modifiers: [.option])

    // A uses the same shortcut for opening the entry panel with its open and save dialogues, hence name ...
    static let NSPanelsOpenGoToPathEntryPanel = KeyboardShortcut("g", modifiers: [.command, .shift])
    static let undo = KeyboardShortcut("z", modifiers: [.command])
    static let redo = KeyboardShortcut("z", modifiers: [.command, .shift])
}
