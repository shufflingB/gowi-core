//
//  XCUIApplication#Toolbar.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import XCTest

// MARK: Extension for Main Window toolbar items
extension XCUIApplication {
    var toolbarItemNew_NON_THROWING: XCUIElement { win1_NON_THROWING.buttons[AccessId.MainWindowToolbarCreateItemButton.rawValue].firstMatch }

    var toolbarSaveChangesPending_NON_THROWING: XCUIElement { win1_NON_THROWING.buttons[AccessId.MainWindowToolbarSaveChangesPending.rawValue].firstMatch }
    var toolbarSaveChangesNone_NON_THROWING: XCUIElement { win1_NON_THROWING.buttons[AccessId.MainWindowToolbarSaveChangesNone.rawValue].firstMatch }

    var toolbarSaveChangesIsShowingPending_NON_THROWING: Bool {
        toolbarSaveChangesPending_NON_THROWING.exists
    }

    var toolbarRevertChangesPending_NON_THROWING: XCUIElement { buttons[AccessId.MainWindowToolbarRevertChangesPending.rawValue].firstMatch }
    var toolbarRevertChangesNone_NON_THROWING: XCUIElement { buttons[AccessId.MainWindowToolbarRevertChangesNone.rawValue].firstMatch }


    var toolbarRevertChangesIsShowing_NON_THROWING: Bool {
        toolbarRevertChangesPending_NON_THROWING.exists
    }
}
