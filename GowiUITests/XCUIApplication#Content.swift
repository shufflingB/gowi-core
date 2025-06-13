//
//  XCUIApplication#Content.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import XCTest
extension XCUIApplication {
    func contentRows_NON_THROWING(win: XCUIElement? = nil) -> Array<XCUIElement> {
        /** NB: When the contents of the sidebar is larger than the height of the window then the contents of the returned query is incomplete (suspect this is
         because the app is is lazily loading only what's visible).  The least PITA approach to work around this is to make what is use below of what should  strictly be a redundant query on
         the last element in the list that forces the loading of everything.
         (Other options might include ensuring smaller amounts of fixture data so as to ensure window always contains it, using a shortcut to jump to end of list to force loading of contents )
         */

        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
//
        let query: XCUIElementQuery = winS.outlines.children(matching: .outlineRow)
            .textFields
            .matching(identifier: AccessId.MainWindowContentTitleField.rawValue)

        _ = query.element.waitForExistence(timeout: 3)
        

        return query.allElementsBoundByIndex
    }

    func contentRows(win: XCUIElement? = nil) throws -> Array<XCUIElement> {
        /** Throwing version of contentRows that fails the test if essential UI elements are not found.
         This ensures test framework failures rather than app behavior failures when UI elements that must be present are missing.
         */

        let winS: XCUIElement = win == nil ? try win1 : win!
        
        // First, verify the essential UI structure exists (the outline itself)
        guard winS.outlines.firstMatch.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Content outline failed to exist within timeout",
                "timeout": "3 seconds",
                "window": winS.debugDescription
            ])
        }
        
        let query: XCUIElementQuery = winS.outlines.children(matching: .outlineRow)
            .textFields
            .matching(identifier: AccessId.MainWindowContentTitleField.rawValue)

        // Wait a moment for the query to settle, but don't fail if no elements exist
        // (empty content is a valid state)
        _ = query.element.waitForExistence(timeout: 3)

        let elements = query.allElementsBoundByIndex
        
        return elements
    }

    private func contentRow_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.outlines.children(matching: .outlineRow).element(boundBy: row)
    }

    func contentRowTextField_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        return contentRow_NON_THROWING(win: win, row).textFields[AccessId.MainWindowContentTitleField.rawValue]
    }

    func contentRowTextFieldValue_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> String {
        contentRowTextField_NON_THROWING(win: win, row).value as! String
    }

    func contentRowsSelect(win: XCUIElement? = nil, indices itemIdxs: Array<Int>) throws {
        let currentRows = contentRows_NON_THROWING(win: win)

        // Check what's being requested to select is sane
        itemIdxs.forEach { idx in
            assert(currentRows.indices.contains(idx),
                   "Selection idx \(idx) must be between 0 and \(currentRows.count - 1) to be selectable")
        }

        // Now attempt to select it in the app
        itemIdxs.indices.forEach { idx in
            let itemIdx = itemIdxs[idx]
            if idx == 0 {
                // Make initial selection
                currentRows[itemIdx].click()
            } else {
                // And then carry on with a discontinuos selection
                XCUIElement.perform(withKeyModifiers: .command) {
                    currentRows[itemIdx].click()
                }
            }
        }
    }

//    func sidebarRowCountValue() -> Int {
//        sidebarRowTextField(0).click()
//        shortcutSelectEndOfList()
//        return sidebarRows.count
//    }

    /*
     Context menu - to use, need to right click on the row selection to open the menu first
     */
    // TODO: See if possible to remove need for a priori opening of the context menu
//    var sidebarContextMenuOpenInNewWindow: XCUIElement { windows.firstMatch.outlines.menuItems["Open in New Window"] }
//    var sidebarContextMenuDuplicate: XCUIElement { windows.firstMatch.outlines.menuItems["Duplicate"] }

//    func contentContextMenuDelete(

    func contentContextMenuDelete_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.outlines.menuItems[AccessId.MainWindowContentContextDelete.rawValue]
    }

    func contentContextMenuOpenInNewTab_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.outlines.menuItems[AccessId.MainWindowContentContextOpenInNewTab.rawValue]
    }

    func contentContextMenuOpenInNewWindow_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.outlines.menuItems[AccessId.MainWindowContentContextOpenInNewWindow.rawValue]
    }
}
