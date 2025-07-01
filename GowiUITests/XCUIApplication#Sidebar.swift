//
//  XCUIApplication#Sidebar.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import XCTest

/**
 ## Sidebar Testing Extensions
 
 This extension provides access to the sidebar filter lists in the Gowi application's main window.
 The sidebar contains three filter options that control which items are displayed in the content area.
 
 ### Available Filters:
 - **All**: Shows all items regardless of completion status
 - **Waiting**: Shows only incomplete/pending items
 - **Done**: Shows only completed items
 
 ### Architecture:
 All sidebar methods use a common `sidebarList(identifier:)` base method that locates sidebar
 cells by their static text identifier. The convenience methods provide type-safe access to
 specific filter lists.
 
 ### Usage:
 ```swift
 // Select a sidebar filter list
 try app.sidebarWaitingList().click()
 try app.sidebarAllList(win: secondWindow).click()
 
 // Check if a filter is selected
 XCTAssertTrue(try app.sidebarDoneList().isSelected)
 ```
 */
// MARK: Extension for Main window Sidebar testing items

extension XCUIApplication {
    /// Base method for accessing sidebar filter lists by identifier
    ///
    /// Locates a sidebar list cell by its static text identifier. This method first validates
    /// that the sidebar outline structure exists, then finds the specific list element.
    ///
    /// - Parameters:
    ///   - win: Optional window element, defaults to win1 if not provided
    ///   - identifier: The text identifier for the sidebar list (e.g., "All", "Waiting", "Done")
    /// - Returns: XCUIElement for the specified sidebar list cell
    /// - Throws: XCTestError if sidebar structure or specific list cannot be found
    func sidebarList(win: XCUIElement? = nil, identifier: String) throws -> XCUIElement {
        let winS: XCUIElement = win == nil ? try win1 : win!

        // First verify the sidebar outline structure exists
        _ = try validateElement(winS.outlines.firstMatch, description: "Sidebar outline when accessing list '\(identifier)'", additionalUserInfo: [
            "window": winS.debugDescription,
            "requested_identifier": identifier,
        ])

        let listElement = winS.outlines.cells.containing(.staticText, identifier: identifier).element

        // Verify the specific list exists
        return try validateElement(listElement, description: "Sidebar list '\(identifier)'", additionalUserInfo: [
            "window": winS.debugDescription,
            "requested_identifier": identifier,
        ])
    }

    /// Accesses the "Waiting" filter list in the sidebar
    /// - Parameter win: Optional window element, defaults to win1 if not provided
    /// - Returns: XCUIElement for the Waiting list
    /// - Throws: XCTestError if Waiting list cannot be found
    func sidebarWaitingList(win: XCUIElement? = nil) throws -> XCUIElement {
        try sidebarList(win: win, identifier: "Waiting")
    }

    /// Accesses the "Done" filter list in the sidebar
    /// - Parameter win: Optional window element, defaults to win1 if not provided
    /// - Returns: XCUIElement for the Done list
    /// - Throws: XCTestError if Done list cannot be found
    func sidebarDoneList(win: XCUIElement? = nil) throws -> XCUIElement {
        try sidebarList(win: win, identifier: "Done")
    }

    /// Accesses the "All" filter list in the sidebar
    /// - Parameter win: Optional window element, defaults to win1 if not provided
    /// - Returns: XCUIElement for the All list
    /// - Throws: XCTestError if All list cannot be found
    func sidebarAllList(win: XCUIElement? = nil) throws -> XCUIElement {
        try sidebarList(win: win, identifier: "All")
    }
}
