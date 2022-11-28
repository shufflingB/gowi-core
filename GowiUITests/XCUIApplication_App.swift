//
//  XCUIApplication_App.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 01/07/2022.
//

import SwiftUI
import XCTest

// App level extension
extension XCUIApplication {
    /// The SwiftUI framework persists information about window config across launches using the identifiers for windows that it had
    /// when the app was termintated. Then when the app restarts tt:
    /// 1. Reopen those previous windows
    /// 2. Assign them the identifiers from the previous session.
    ///
    /// Further, if the restored windows (and their associated identifiers) from the previous session are closed, the app does not
    /// reset the identifiers it has previously used.
    ///
    /// QED: with the default launch command, it's easy for tests to leave the app in a state where there are multiiple windows and their
    /// identifiers are awkward to determine because they do not start from "1", which makes identifying windows in the running app awkard.
    ///
    ///  This function works around this to ensure the app tests always start with single window and it's identifier contains "1"
    ///
    func launchAndSanitiseWindowsAndIdentifiers() {
        launch()

        if win1.exists == false ||  windows.firstMatch.identifier != win1.identifier || windows.count > 1 {
            shortcutWindowsCloseAll()
            shortcutAppQuit()
            launch()
        }

        assert(windows.count == 1)
        assert(windows.firstMatch.identifier == win1.identifier)
    }

    var win1: XCUIElement {
        windows["Main-AppWindow-1"]
    }

    var win2: XCUIElement {
        windows["Main-AppWindow-2"]
    }

    var win3: XCUIElement {
        windows["Main-AppWindow-3"]
    }

    var win4: XCUIElement {
        windows["Main-AppWindow-4"]
    }

    var win5: XCUIElement {
        windows["Main-AppWindow-5"]
    }

    var urlDefault: String { "gowi://main/" }
    var urlNewItem: String { "gowi://main/v1/newItem" }

    /*
     Shortcuts
     */
    func shortcutItemNew() { typeKeyboardShortcut(KbShortcuts.itemsNew) }
    func shortcutItemDuplicate() { typeKeyboardShortcut(KbShortcuts.itemsDuplicate) }
    func shortcutItemDelete() {
        let k = XCUIKeyboardKey.delete
        let m = KeyModifierFlags([.command])
        typeKey(k, modifierFlags: m)
    }
    func shortcutItemsMarkComplete() { typeKeyboardShortcut(KbShortcuts.itemsMarkComplete) }
    func shortcutItemsMarkOpen() { typeKeyboardShortcut(KbShortcuts.itemsMarkOpen) }
    func shortcutSelectedItemsMoveUpInList() { typeKeyboardShortcut(KbShortcuts.itemsSelectedNudgePriorityUp) }
    func shortcutSelectedItemsMoveDownInList() { typeKeyboardShortcut(KbShortcuts.itemsSelectedNudgePriorityDown) }

    func shortcutSaveChanges() { typeKeyboardShortcut(KbShortcuts.fileSaveChanges) }
    func shortcutAppQuit() { typeKeyboardShortcut(KbShortcuts.appQuit) }
    func shortcutWindowOpenNew() { typeKeyboardShortcut(KbShortcuts.windowOpenNew) }
    func shortcutWindowClose() { typeKeyboardShortcut(KbShortcuts.windowClose) }
    func shortcutWindowsCloseAll() { typeKeyboardShortcut(KbShortcuts.windowsCloseAll) }
    func shortcutSelectHeadOfList() { typeKeyboardShortcut(KbShortcuts.selectHeadOfList) }
    func shortcutSelectEndOfList() { typeKeyboardShortcut(KbShortcuts.selectEndOfList) }

    func shortcutUndo() { typeKeyboardShortcut(KbShortcuts.undo) }
    func shortcutRedo() { typeKeyboardShortcut(KbShortcuts.redo) }

    // NB: Direct KeyboardShortcut to XCUIKeyboardKey translation of at least some special keys in KeyboardShortcut does not work.
    //
    // More specifically the constant that SwiftUI defines for Delete in KeyboardShortcut is different to the value that XCUIKeyboardKey
    // defines for the same key on macOS.
    // It is not known if this is:
    // 1) A bug
    // 2) If it's not a bug, how to avoid having to special case workaround
    // 3) Only impacts macOS
    // 4) Impacts any of the other "special" keys that XCUIKeyboardKey defines such as XCUIKeyboardKeyTab, XCUIKeyboardKeyUpArrow,
    // XCUIKeyboardKeySpace ....
    //
    // TL;DR; If using this function doesn't appear to work, try sending it directly as is done for Delete.
    func typeKeyboardShortcut(_ shortcut: KeyboardShortcut) {
        let key: XCUIKeyboardKey = XCUIKeyboardKey(rawValue: String(shortcut.key.character))
        let modifier = XCUIElement.KeyModifierFlags(rawValue: UInt(shortcut.modifiers.rawValue))
        typeKey(key, modifierFlags: modifier)
    }
    
    var dialogueConfirmRevertOK: XCUIElement {
        dialogs["alert"].buttons["Revert"]
    }
    var dialogueConfirmRevertCancel: XCUIElement {
        dialogs["alert"].buttons["Cancel"]
    }
    
    
}
