//
//  XCUIApplication#Menubar.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import XCTest

extension XCUIApplication {
    /*
     App menu bar definitions
     */

    // MARK: Gowi

    var menubarGowiQuit_NON_THROWING: XCUIElement {
        return menuBars.menuItems["Quit Gowi"]
    }

    // MARK: File

    var menubarFileMenu_NON_THROWING: XCUIElement {
        _ = menuBars.menuBarItems["File"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["File"]
    }

//    var menubarFileExportItems: XCUIElement {
//        menubarFileMenu.click()
//        if menuBars.menuItems["Export Items"].exists {
//            return menuBars.menuItems["Export Items"]
//
//        } else {
//            return menuBars.menuItems["Export Item"]
//        }
//    }
//
//    var menubarFileImportItems: XCUIElement {
//        menubarFileMenu.click()
//        return menuBars.menuItems["Import Items"]
//    }

    var menubarFileSaveChanges_NON_THROWING: XCUIElement {
        return menuBars.menuItems["Save Changes"]
    }

    var menubarFileRevertChanges_NON_THROWING: XCUIElement {
        return menuBars.menuItems["Revert Changes"]
    }

    // MARK: Edit

    var menubarEditMenu_NON_THROWING: XCUIElement {
        _ = menuBars.menuBarItems["Edit"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["Edit"]
    }

    var menubarUndo_NON_THROWING: XCUIElement {
        let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Undo")
        return menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
    }

    var menubarRedo_NON_THROWING: XCUIElement {
        let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Redo")
        return menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
    }

    // MARK: Item

    var menuBarItemsMenu_NON_THROWING: XCUIElement {
//        _ = menuBars.menuBarItems["Items"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["Items"]
    }

    var menubarItemNew_NON_THROWING: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["New Item"]
    }

    var menubarItemDelete_NON_THROWING: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["Delete"]
    }

    var menubarItemOpenInNewWindow_NON_THROWING: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["Open in New Window"]
    }

    var menubarItemOpenInNewTab_NON_THROWING: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["Open in New Tab"]
    }

    // MARK: Window operations ...

    var menubarWindowMenu_NON_THROWING: XCUIElement {
        _ = menuBars.menuBarItems["Window"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["Window"]
    }

    var menubarWindowNew_NON_THROWING: XCUIElement {
        menubarWindowMenu_NON_THROWING.click()
        return menuBars.menuItems["New Window"]
    }

    var menubarWindowClose_NON_THROWING: XCUIElement {
        menubarFileMenu_NON_THROWING.click()
        return menuBars.menuItems["Close"]
    }

    var menubarWindowsCloseAll_NON_THROWING: XCUIElement {
        return menuBars.menuItems["closeAll:"] // Has to be used with XCUIElement.perform ( ... most of time just use the shortcut instead
    }
}
