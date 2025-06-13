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
        get throws {
            let element = menuBars.menuItems["Quit Gowi"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Quit Gowi' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Quit Gowi"
                ])
            }
            return element
        }
    }

    // MARK: File

    var menubarFileMenu: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["File"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu bar 'File' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_bar_item": "File"
                ])
            }
            return element
        }
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
        get throws {
            let element = menuBars.menuItems["Save Changes"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Save Changes' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Save Changes"
                ])
            }
            return element
        }
    }


    var menubarFileRevertChanges: XCUIElement {
        get throws {
            let element = menuBars.menuItems["Revert Changes"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Revert Changes' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Revert Changes"
                ])
            }
            return element
        }
    }

    // MARK: Edit


    var menubarEditMenu: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Edit"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu bar 'Edit' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_bar_item": "Edit"
                ])
            }
            return element
        }
    }


    var menubarUndo: XCUIElement {
        get throws {
            let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Undo")
            let element = menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Edit' > 'Undo' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Undo"
                ])
            }
            return element
        }
    }


    var menubarRedo: XCUIElement {
        get throws {
            let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Redo")
            let element = menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Edit' > 'Redo' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Redo"
                ])
            }
            return element
        }
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
    

    var menubarWindowClose: XCUIElement {
        get throws {
            try menubarFileMenu.click()
            let element = menuBars.menuItems["Close"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'Close' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "Close"
                ])
            }
            return element
        }
    }


    var menubarWindowsCloseAll: XCUIElement {
        get throws {
            let element = menuBars.menuItems["closeAll:"]
            guard element.waitForExistence(timeout: 3) else {
                throw XCTestError(.failureWhileWaiting, userInfo: [
                    "description": "Menu item 'closeAll:' failed to exist within timeout",
                    "timeout": "3 seconds",
                    "menu_item": "closeAll:"
                ])
            }
            return element
        }
    }
}
