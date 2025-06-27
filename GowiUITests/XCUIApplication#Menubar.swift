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
            return try validateElement(element, description: "Menu item 'Quit Gowi'", additionalUserInfo: [
                "menu_item": "Quit Gowi"
            ])
        }
    }

    // MARK: File

    var menubarFileMenu: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["File"]
            return try validateElement(element, description: "Menu bar 'File'", additionalUserInfo: [
                "menu_bar_item": "File"
            ])
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
            return try validateElement(element, description: "Menu item 'Save Changes'", additionalUserInfo: [
                "menu_item": "Save Changes"
            ])
        }
    }


    var menubarFileRevertChanges: XCUIElement {
        get throws {
            let element = menuBars.menuItems["Revert Changes"]
            return try validateElement(element, description: "Menu item 'Revert Changes'", additionalUserInfo: [
                "menu_item": "Revert Changes"
            ])
        }
    }

    // MARK: Edit


    var menubarEditMenu: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Edit"]
            return try validateElement(element, description: "Menu bar 'Edit'", additionalUserInfo: [
                "menu_bar_item": "Edit"
            ])
        }
    }


    var menubarUndo: XCUIElement {
        get throws {
            let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Undo")
            let element = menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
            return try validateElement(element, description: "Menu item 'Edit' > 'Undo'", additionalUserInfo: [
                "menu_item": "Undo"
            ])
        }
    }


    var menubarRedo: XCUIElement {
        get throws {
            let predicate = NSPredicate(format: "identifier CONTAINS[c] %@", "Redo")
            let element = menuBars.menuBarItems["Edit"].menuItems.containing(predicate).firstMatch
            return try validateElement(element, description: "Menu item 'Edit' > 'Redo'", additionalUserInfo: [
                "menu_item": "Redo"
            ])
        }
    }

    // MARK: Item



    var menubarItemNew: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["New Item"]
            return try validateElement(element, description: "Menu item 'Items' > 'New Item'", additionalUserInfo: [
                "menu_item": "New Item"
            ])
        }
    }

    var menubarItemDelete: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["Delete"]
            return try validateElement(element, description: "Menu item 'Items' > 'Delete'", additionalUserInfo: [
                "menu_item": "Delete"
            ])
        }
    }


    var menubarItemOpenInNewWindow: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["Open in New Window"]
            return try validateElement(element, description: "Menu item 'Items' > 'Open in New Window'", additionalUserInfo: [
                "menu_item": "Open in New Window"
            ])
        }
    }


    var menubarItemOpenInNewTab: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Items"].menuItems["Open in New Tab"]
            return try validateElement(element, description: "Menu item 'Items' > 'Open in New Tab'", additionalUserInfo: [
                "menu_item": "Open in New Tab"
            ])
        }
    }

    // MARK: Window operations ...


    
    var menubarWindowMenu: XCUIElement {
        get throws {
            let element = menuBars.menuBarItems["Window"]
            return try validateElement(element, description: "menuBarItems[\"Window\"]", timeout: 2, additionalUserInfo: [
                "available_menuBarItems":  menuBarItems.allElementsBoundByIndex.map { $0.identifier }
            ])
        }
    }
    
    var menubarWindowNew: XCUIElement {
        get throws {
            let element = menuBars.menuItems["New Window"]
            return try validateElement(element, description: "menuBarItems[\"Window\"] > \"New Window\"", timeout: 2, additionalUserInfo: [
                "available_menuBarItems":  menuBarItems.allElementsBoundByIndex.map { $0.identifier }
            ])
        }
    }
    

    var menubarWindowClose: XCUIElement {
        get throws {
            try menubarFileMenu.click()
            let element = menuBars.menuItems["Close"]
            return try validateElement(element, description: "Menu item 'Close'", additionalUserInfo: [
                "menu_item": "Close"
            ])
        }
    }


    var menubarWindowsCloseAll: XCUIElement {
        get throws {
            let element = menuBars.menuItems["closeAll:"]
            return try validateElement(element, description: "Menu item 'closeAll:'", additionalUserInfo: [
                "menu_item": "closeAll:"
            ])
        }
    }
}
