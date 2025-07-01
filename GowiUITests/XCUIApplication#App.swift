//
//  XCUIApplication#App.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import XCTest

// App level extension
extension XCUIApplication {
    func isKeyFrontWindow(_ ele: XCUIElement) -> Bool {
        ele.identifier == windows.firstMatch.identifier
    }

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
        launchArguments.append("--uitesting-reset-state")
        
        launch()
        

        let needsReset: Bool
        do {
            let mainWindow = try win1
            needsReset = windows.firstMatch.identifier != mainWindow.identifier || windows.count > 1
        } catch {
            needsReset = true
        }
        
        if needsReset {
            shortcutWindowsCloseAll()
            shortcutAppQuit()
            launch()
        }

        assert(windows.count == 1)
        do {
            let mainWindow = try win1
            assert(windows.firstMatch.identifier == mainWindow.identifier)
        } catch {
            XCTFail("Main window should exist after launch and reset")
        }
    }

    /// Generic helper function to validate XCUIElements with consistent error handling
    /// - Parameters:
    ///   - element: The XCUIElement to validate
    ///   - description: Description of what element is being validated for error messages
    ///   - timeout: Timeout in seconds (default: 3)
    ///   - additionalUserInfo: Additional context for error messages
    /// - Returns: The validated element if it exists within timeout
    /// - Throws: XCTestError if element doesn't exist within timeout
    func validateElement<T: XCUIElement>(_ element: T, description: String, timeout: TimeInterval = 3, additionalUserInfo: [String: Any] = [:]) throws -> T {
        guard element.waitForExistence(timeout: timeout) else {
            var userInfo: [String: Any] = [
                "description": "\(description) failed to exist within timeout",
                "timeout": "\(Int(timeout)) seconds"
            ]
            userInfo.merge(additionalUserInfo) { _, new in new }
            throw XCTestError(.failureWhileWaiting, userInfo: userInfo)
        }
        return element
    }

    private func winX(name: String) throws -> XCUIElement {
        let mainWindow = windows[name]
        return try validateElement(mainWindow, description: "Main window '\(name)'", additionalUserInfo: [
            "available_windows": windows.allElementsBoundByIndex.map { $0.identifier }
        ])
    }
    
    var win1: XCUIElement {
        get throws {
            try winX(name: "Main-AppWindow-1")
        }
    }
    

    var win2: XCUIElement {
        get throws {
            try winX(name: "Main-AppWindow-2")
        }
    }
    
    var win3: XCUIElement {
        get throws {
            try winX(name: "Main-AppWindow-3")
        }
    }
    
    var win4: XCUIElement {
        get throws {
            try winX(name: "Main-AppWindow-4")
        }
    }
    
    var win5: XCUIElement {
        get throws {
            try winX(name: "Main-AppWindow-5")
        }
    }
    

    /// @deprecated Use `urlEncodeShowItems()` from AppUrl.swift instead for consistent URL encoding
    var urlDefault: String { "gowi://main/" }
    
    /// @deprecated Use `urlEncodeNewItem()` from AppUrl.swift instead for consistent URL encoding
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

    var dialogueConfirmRevertOK_NON_THROWING: XCUIElement {
        dialogs["alert"].buttons["Revert"]
    }

    var dialogueConfirmRevertCancel_NON_THROWING: XCUIElement {
        dialogs["alert"].buttons["Cancel"]
    }
    
    /// Opens a URL via NSWorkspace and waits for the expected number of windows
    ///
    /// Since NSWorkspace.shared.open is fire-and-forget and runs asynchronously, this method provides
    /// synchronous behavior for tests by waiting until the expected number of windows are available.
    ///
    /// - Parameters:
    ///   - url: The URL to open (typically a custom gowi:// scheme URL)
    ///   - waitForNumOfWindows: Expected number of windows after URL opens (default: 1)
    ///   - timeout: Maximum time to wait for windows to appear (default: 5.0 seconds)
    /// - Returns: Actual number of windows present when method completes
    ///
    /// ## Usage:
    /// ```swift
    /// let url = urlEncodeShowItems(sidebarFilter: .all, itemIdsSelected: nil, searchFilter: nil)!
    /// let windowCount = app.openVia(url: url, waitForNumOfWindows: 2)
    /// XCTAssertEqual(windowCount, 2, "URL should create/raise window")
    /// ```
    func openVia(url: URL, waitForNumOfWindows: Int = 1, timeout: TimeInterval = 5.0) -> Int {
        NSWorkspace.shared.open(URL(string: url.absoluteString)!)
        
        let start = Date()
        while Date().timeIntervalSince(start) < timeout {
            if windows.count == waitForNumOfWindows {
                return waitForNumOfWindows
            }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        return windows.count
    }
    
    
    
}
