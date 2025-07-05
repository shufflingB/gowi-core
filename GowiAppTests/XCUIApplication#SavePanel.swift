//
//  XCUIApplication#Toolbar.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import XCTest
import SwiftUI

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
