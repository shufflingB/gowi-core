//
//  XCUIApplication_Sidebar.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 01/07/2022.
//

import SwiftUI
import XCTest

// MARK: Extension for Main window Sidebar testing items

extension XCUIApplication {
    func sidebarList(win: XCUIElement? = nil, identifier: String) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1 : win!
        return winS.outlines.cells.containing(.staticText, identifier: identifier).element
    }

    func sidebarWaitingList(win: XCUIElement? = nil) -> XCUIElement {
        sidebarList(win: win, identifier: "Waiting")
    }

    func sidebarDoneList(win: XCUIElement? = nil) -> XCUIElement {
        sidebarList(win: win, identifier: "Done")
    }

    func sidebarAllList(win: XCUIElement? = nil) -> XCUIElement {
        sidebarList(win: win, identifier: "All")
    }
}
