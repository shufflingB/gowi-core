//
//  XCUIApplication_Toolbar.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 01/07/2022.
//

import Foundation
import XCTest

// MARK: Extension for Main Window toolbar items
extension XCUIApplication {
    var toolbarItemNew: XCUIElement { win1.buttons[AccessId.MainWindowToolbarCreateItemButton.rawValue].firstMatch }

    var toolbarSaveChangesPending: XCUIElement { win1.buttons[AccessId.MainWindowToolbarSaveChangesPending.rawValue].firstMatch }
    var toolbarSaveChangesNone: XCUIElement { win1.buttons[AccessId.MainWindowToolbarSaveChangesNone.rawValue].firstMatch }

    var toolbarSaveChangesIsShowingPending: Bool {
        toolbarSaveChangesPending.exists
    }

    var toolbarRevertChangesPending: XCUIElement { buttons[AccessId.MainWindowToolbarRevertChangesPending.rawValue].firstMatch }
    var toolbarRevertChangesNone: XCUIElement { buttons[AccessId.MainWindowToolbarRevertChangesNone.rawValue].firstMatch }


    var toolbarRevertChangesIsShowing: Bool {
        toolbarRevertChangesPending.exists
    }
}
