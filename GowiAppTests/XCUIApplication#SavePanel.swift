//
//  XCUIApplication#SavePanel.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import XCTest
import SwiftUI

/**
 ## macOS Save Panel Automation Extensions
 
 This extension provides UI automation support for macOS NSSavePanel interactions.
 Save panel automation is particularly complex due to modal dialog behavior and
 system-level UI elements that require specific XCTest techniques.
 
 ### Save Panel Architecture:
 - **Modal Behavior**: Save panels block app interaction until dismissed
 - **System Elements**: Uses standard macOS dialog elements with predictable identifiers
 - **File Type Filtering**: Respects allowedContentTypes from NSSavePanel configuration
 - **Keyboard Navigation**: Supports standard macOS keyboard shortcuts (⌘⇧G, etc.)
 
 ### Automation Challenges:
 - **Timing**: Save panels need time to appear and become interactive
 - **Element Identification**: System dialogs use standard but non-obvious identifiers
 - **Path Navigation**: Complex directory navigation requires specialized techniques
 - **Error Handling**: Dialog failures can leave app in modal state
 
 ### Usage Pattern:
 ```swift
 // Trigger save operation in app
 try app.menubarFileExportJSON.click()
 
 // Wait for save panel and interact
 let savePanel = try app.savePanel
 let textField = try app.savePanelSaveAsTextField
 textField.typeText("filename.json")
 try app.savePanelSaveButton.click()
 ```
 
 ### Error Recovery:
 If save panel automation fails, use `savePanelCancelButton` to dismiss the modal
 and return the app to a testable state.
 */
extension XCUIApplication {
    var savePanel: XCUIElement {
        get throws {
            let element = windows["save-panel"]
            return try validateElement(element, description: "Modal file save panel", additionalUserInfo: [:])
        }
    }
    
    var savePanelSaveAsTextField: XCUIElement {
        get throws {
            let element = textFields["saveAsNameTextField"]
            return try validateElement(element, description: "Modal file save as filename textfield", additionalUserInfo: [:])
        }
    }
    
    
    var savePanelSaveAsTextFieldValue: String {
        get throws {
            
            return try savePanelSaveAsTextField.value as? String ?? ""
        }
    }
    
    
    var savePanelCancelButton: XCUIElement {
        get throws {
            let element = buttons["CancelButton"]
            return try validateElement(element, description: "Modal file save panel Cancel Button", additionalUserInfo: [:])
        }
    }
    
    var savePanelSaveButton: XCUIElement {
        get throws {
            let element = buttons["OKButton"]
            
            return try validateElement(element, description: "Modal file save panel Save Button", additionalUserInfo: [:])
        }
    }
    
    
}
