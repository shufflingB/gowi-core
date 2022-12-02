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

    var menubarGowiQuit: XCUIElement {
        return menuBars.menuItems["Quit Gowi"]
    }

    // MARK: File

    var menubarFileMenu: XCUIElement {
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

    var menubarFileSaveChanges: XCUIElement {
        return menuBars.menuItems["Save Changes"]
    }

    var menubarFileRevertChanges: XCUIElement {
        return menuBars.menuItems["Revert Changes"]
    }

    // MARK: Edit

    var menubarEditMenu: XCUIElement {
        _ = menuBars.menuBarItems["Edit"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["Edit"]
    }

    var menubarUndo: XCUIElement {
        let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Undo")
        return menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
    }

    var menubarRedo: XCUIElement {
        let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Redo")
        return menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
    }

    // MARK: Item

    var menuBarItemsMenu: XCUIElement {
//        _ = menuBars.menuBarItems["Items"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["Items"]
    }

    var menubarItemNew: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["New Item"]
    }

    var menubarItemDelete: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["Delete"]
    }

    var menubarItemOpenInNewWindow: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["Open in New Window"]
    }

    var menubarItemOpenInNewTab: XCUIElement {
        return menuBars.menuBarItems["Items"].menuItems["Open in New Tab"]
    }

    // MARK: Window operations ...

    var menubarWindowMenu: XCUIElement {
        _ = menuBars.menuBarItems["Window"].waitForExistence(timeout: 2)
        return menuBars.menuBarItems["Window"]
    }

    var menubarWindowNew: XCUIElement {
        menubarWindowMenu.click()
        return menuBars.menuItems["New Window"]
    }

    var menubarWindowClose: XCUIElement {
        menubarFileMenu.click()
        return menuBars.menuItems["Close"]
    }

    var menubarWindowsCloseAll: XCUIElement {
        return menuBars.menuItems["closeAll:"] // Has to be used with XCUIElement.perform ( ... most of time just use the shortcut instead
    }
}
