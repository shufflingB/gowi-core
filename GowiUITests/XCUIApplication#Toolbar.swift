//
//  XCUIApplication#Toolbar.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import XCTest

/**
 ## Toolbar Testing Extensions
 
 This extension provides access to toolbar elements in the Gowi application's main window.
 The toolbar contains action buttons for creating items and managing changes.
 
 ### _NON_THROWING Pattern:
 All properties use the `_NON_THROWING` suffix to indicate they implement a fallback strategy
 instead of throwing errors. This pattern is used when:
 1. Tests need to check element existence without failing
 2. Multiple window scenarios where win1 might not be available
 3. Compatibility with legacy test code that expects non-throwing behavior
 
 ### Fallback Strategy:
 ```swift
 var toolbarItemNew_NON_THROWING: XCUIElement {
     do {
         return try win1.buttons[AccessId.MainWindowToolbarCreateItemButton.rawValue].firstMatch
     } catch {
         return windows.firstMatch.buttons[AccessId.MainWindowToolbarCreateItemButton.rawValue].firstMatch
     }
 }
 ```
 
 If accessing `win1` fails, these methods fall back to using `windows.firstMatch` to maintain
 test stability in edge cases.
 
 ### Available Toolbar Elements:
 - **New Item Button**: Creates a new todo item
 - **Save Changes**: Shows when there are pending changes (pending/none states)
 - **Revert Changes**: Shows when there are changes to revert (pending/none states)
 */
// MARK: Extension for Main Window toolbar items
extension XCUIApplication {
    var toolbarItemNew_NON_THROWING: XCUIElement {
        do {
            return try win1.buttons[AccessId.MainWindowToolbarCreateItemButton.rawValue].firstMatch
        } catch {
            return windows.firstMatch.buttons[AccessId.MainWindowToolbarCreateItemButton.rawValue].firstMatch
        }
    }

    var toolbarSaveChangesPending_NON_THROWING: XCUIElement {
        do {
            return try win1.buttons[AccessId.MainWindowToolbarSaveChangesPending.rawValue].firstMatch
        } catch {
            return windows.firstMatch.buttons[AccessId.MainWindowToolbarSaveChangesPending.rawValue].firstMatch
        }
    }
    var toolbarSaveChangesNone_NON_THROWING: XCUIElement {
        do {
            return try win1.buttons[AccessId.MainWindowToolbarSaveChangesNone.rawValue].firstMatch
        } catch {
            return windows.firstMatch.buttons[AccessId.MainWindowToolbarSaveChangesNone.rawValue].firstMatch
        }
    }

    var toolbarSaveChangesIsShowingPending_NON_THROWING: Bool {
        toolbarSaveChangesPending_NON_THROWING.exists
    }

    var toolbarRevertChangesPending_NON_THROWING: XCUIElement { buttons[AccessId.MainWindowToolbarRevertChangesPending.rawValue].firstMatch }
    var toolbarRevertChangesNone_NON_THROWING: XCUIElement { buttons[AccessId.MainWindowToolbarRevertChangesNone.rawValue].firstMatch }


    var toolbarRevertChangesIsShowing_NON_THROWING: Bool {
        toolbarRevertChangesPending_NON_THROWING.exists
    }
}
