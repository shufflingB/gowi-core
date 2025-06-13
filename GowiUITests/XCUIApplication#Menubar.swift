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



    var menubarItemNew: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["New Item"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Items' > 'New Item' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "New Item"
                ])
            }
            return element
        }
    }

    var menubarItemDelete: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["Delete"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Items' > 'Delete' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Delete"
                ])
            }
            return element
        }
    }


    var menubarItemOpenInNewWindow: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["Open in New Window"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Items' > 'Open in New Window' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Open in New Window"
                ])
            }
            return element
        }
    }


    var menubarItemOpenInNewTab: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["Open in New Tab"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Items' > 'Open in New Tab' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Open in New Tab"
                ])
            }
            return element
        }
    }

    // MARK: Window operations ...


    
    var menubarWindowMenu: XCUIElement {
        get throws {
            guard menuBars.menuBarItems["Window"].waitForExistence(timeout: 2) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "menuBarItems[\"Window\"] failed to exist within timeout",
                    "timeout": "2 seconds",
                    "available_menuBarItems":  menuBarItems.allElementsBoundByIndex.map { $0.identifier }
                ])
            }
            return menuBars.menuBarItems["Window"]
            
        }
    }
    
    var menubarWindowNew: XCUIElement {
        get throws {
//            try menubarWindowMenu.click()
            guard menuBars.menuItems["New Window"].waitForExistence(timeout: 2) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "menuBarItems[\"Window\"] > \"New Window\" failed to exist within timeout",
                    "timeout": "2 seconds",
                    "available_menuBarItems":  menuBarItems.allElementsBoundByIndex.map { $0.identifier }
                ])
            }
            
            return menuBars.menuItems["New Window"]
        }
    }
    

    var menubarWindowClose_NON_THROWING: XCUIElement {
        menubarFileMenu_NON_THROWING.click()
        return menuBars.menuItems["Close"]
    }

    var menubarWindowsCloseAll_NON_THROWING: XCUIElement {
        return menuBars.menuItems["closeAll:"] // Has to be used with XCUIElement.perform ( ... most of time just use the shortcut instead
    }
}
