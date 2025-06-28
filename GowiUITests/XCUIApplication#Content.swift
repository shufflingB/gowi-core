//
//  XCUIApplication#Content.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import XCTest
extension XCUIApplication {

    func contentRows(win: XCUIElement? = nil) throws -> Array<XCUIElement> {
        /** Throwing version of contentRows that fails the test if essential UI elements are not found.
         This ensures test framework failures rather than app behavior failures when UI elements that must be present are missing.
         */

        let winS: XCUIElement = win == nil ? try win1 : win!
        
        // First, verify the essential UI structure exists (the outline itself)
        _ = try validateElement(winS.outlines.firstMatch, description: "Content outline", additionalUserInfo: [
            "window": winS.debugDescription
        ])
        
        // Modified query to be more specific: look for text fields within outline rows only
        // This avoids conflicts with search fields that might be at the same level
        let outlineRows = winS.outlines.children(matching: .outlineRow)
        let query: XCUIElementQuery = outlineRows.textFields
            .matching(identifier: AccessId.MainWindowContentTitleField.rawValue)

        // Wait a moment for the query to settle, but don't fail if no elements exist
        // (empty content is a valid state)
        _ = query.element.waitForExistence(timeout: 3)

        let elements = query.allElementsBoundByIndex
        
        return elements
    }

    private func contentRow_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement
        if let providedWin = win {
            winS = providedWin
        } else {
            do {
                winS = try win1
            } catch {
                winS = windows.firstMatch
            }
        }
        return winS.outlines.children(matching: .outlineRow).element(boundBy: row)
    }

     private func contentRow(win: XCUIElement? = nil, _ row: Int) throws -> XCUIElement {
        let winS: XCUIElement = win == nil ? try win1 : win!
        
        // First verify the outline structure exists
        _ = try validateElement(winS.outlines.firstMatch, description: "Content outline when accessing row \(row)", additionalUserInfo: [
            "window": winS.debugDescription,
            "requested_row": row
        ])
        
        let outlineRows = winS.outlines.children(matching: .outlineRow)
        let element = outlineRows.element(boundBy: row)
        
        // Verify the specific row exists
        return try validateElement(element, description: "Content row \(row)", additionalUserInfo: [
            "window": winS.debugDescription,
            "requested_row": row,
            "available_rows": outlineRows.count
        ])
    }

    func contentRowTextField(win: XCUIElement? = nil, _ row: Int) throws -> XCUIElement {
        let winS: XCUIElement = win == nil ? try win1 : win!
        
        // Get text field from within the outline structure to avoid search field conflicts
        let textField = winS.outlines.children(matching: .outlineRow)
            .textFields.matching(identifier: AccessId.MainWindowContentTitleField.rawValue)
            .element(boundBy: row)
        
        return try validateElement(textField, description: "Content row \(row) textfield", additionalUserInfo: [
            "requested_row": row,
            "text_field_identifier": AccessId.MainWindowContentTitleField.rawValue
        ])
    }

    func contentRowTextFieldValue(win: XCUIElement? = nil, _ row: Int) throws -> String {
        return try contentRowTextField(win: win, row).value as! String
    }

    func contentRowsSelect(win: XCUIElement? = nil, indices itemIdxs: Array<Int>) throws {
        let currentRows = try contentRows(win: win)

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


    /*
     Context menu - to use, need to right click on the row selection to open the menu first
     */
    // TODO: See if possible to remove need for a priori opening of the context menu
//    var sidebarContextMenuOpenInNewWindow: XCUIElement { windows.firstMatch.outlines.menuItems["Open in New Window"] }
//    var sidebarContextMenuDuplicate: XCUIElement { windows.firstMatch.outlines.menuItems["Duplicate"] }

//    func contentContextMenuDelete(

    func contentContextMenuDelete_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement
        if let providedWin = win {
            winS = providedWin
        } else {
            do {
                winS = try win1
            } catch {
                winS = windows.firstMatch
            }
        }
        return winS.outlines.menuItems[AccessId.MainWindowContentContextDelete.rawValue]
    }

    func contentContextMenuOpenInNewTab_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement
        if let providedWin = win {
            winS = providedWin
        } else {
            do {
                winS = try win1
            } catch {
                winS = windows.firstMatch
            }
        }
        return winS.outlines.menuItems[AccessId.MainWindowContentContextOpenInNewTab.rawValue]
    }

    func contentContextMenuOpenInNewWindow_NON_THROWING(win: XCUIElement? = nil, _ row: Int) -> XCUIElement {
        let winS: XCUIElement
        if let providedWin = win {
            winS = providedWin
        } else {
            do {
                winS = try win1
            } catch {
                winS = windows.firstMatch
            }
        }
        return winS.outlines.menuItems[AccessId.MainWindowContentContextOpenInNewWindow.rawValue]
    }
    
    // MARK: Search functionality test helpers
    
    /// Returns the search field for the content view
    /// - Parameter win: Optional window element, defaults to win1 if not provided
    /// - Returns: XCUIElement for the search field
    func searchField(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = win == nil ? try win1 : win!
        return try validateElement(winS.searchFields.firstMatch, description: "Search field")
    }
    
    /// Performs a search in the content view
    /// - Parameters:
    ///   - searchText: The text to search for
    ///   - win: Optional window element, defaults to win1 if not provided
    func searchFor(_ searchText: String, win: XCUIElement? = nil) throws {
        let searchField = try self.searchField(win: win)
        searchField.click()
        searchField.typeText(searchText)
    }
    
    /// Clears the search field
    /// - Parameter win: Optional window element, defaults to win1 if not provided
    func clearSearch(win: XCUIElement? = nil) throws {
        let searchField = try self.searchField(win: win)
        searchField.click()
        // Select all and delete
        searchField.typeKey("a", modifierFlags: .command)
        searchField.typeKey(.delete, modifierFlags: [])
    }
    
    /// Gets the current search text
    /// - Parameter win: Optional window element, defaults to win1 if not provided
    /// - Returns: Current search text as a string
    func currentSearchText(win: XCUIElement? = nil) throws -> String {
        let searchField = try self.searchField(win: win)
        return searchField.value as? String ?? ""
    }
}
