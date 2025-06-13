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
    func sidebarList_NON_THROWING(win: XCUIElement? = nil, identifier: String) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.outlines.cells.containing(.staticText, identifier: identifier).element
    }

    func sidebarWaitingList_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        sidebarList_NON_THROWING(win: win, identifier: "Waiting")
    }

    func sidebarDoneList_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        sidebarList_NON_THROWING(win: win, identifier: "Done")
    }

    func sidebarAllList_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        sidebarList_NON_THROWING(win: win, identifier: "All")
    }
}
