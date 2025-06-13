//
//  XCUIApplication#Sidebar.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import XCTest

// MARK: Extension for Main window Sidebar testing items

extension XCUIApplication {
    func sidebarList(win: XCUIElement? = nil, identifier: String) throws -> XCUIElement {
        let winS: XCUIElement = win == nil ? try win1 : win!

        // First verify the sidebar outline structure exists
        guard winS.outlines.firstMatch.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Sidebar outline failed to exist within timeout when accessing list '\(identifier)'",
                "timeout": "3 seconds",
                "window": winS.debugDescription,
                "requested_identifier": identifier,
            ])
        }

        let listElement = winS.outlines.cells.containing(.staticText, identifier: identifier).element

        // Verify the specific list exists
        guard listElement.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Sidebar list '\(identifier)' failed to exist within timeout",
                "timeout": "3 seconds",
                "window": winS.debugDescription,
                "requested_identifier": identifier,
            ])
        }

        return listElement
    }

    func sidebarWaitingList(win: XCUIElement? = nil) throws -> XCUIElement {
        try sidebarList(win: win, identifier: "Waiting")
    }

    func sidebarDoneList(win: XCUIElement? = nil) throws -> XCUIElement {
        try sidebarList(win: win, identifier: "Done")
    }

    func sidebarAllList(win: XCUIElement? = nil) throws -> XCUIElement {
        try sidebarList(win: win, identifier: "All")
    }
}
