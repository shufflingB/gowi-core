//
//  XCUIElement_Helpers.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 26/05/2022.
//

import SwiftUI
import XCTest

extension XCUIApplication {
    func isKeyFrontWindow(_ ele: XCUIElement) -> Bool {
        ele.identifier == windows.firstMatch.identifier
    }
}
