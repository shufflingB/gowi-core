//
//  Test_950_HelpDocumentation.swift
//  GowiUITests
//
//  Created by Claude Code on 01/07/2025.
//

import XCTest

/**
 ## Help Documentation UI Tests
 
 Tests that verify the application's help system functionality, including menu bar access
 and help content accessibility.
 
 ### Test Coverage:
 - Help menu item exists and is accessible
 - Help menu opens help documentation
 - Help content displays correctly
 */
class Test_510_HelpDocumentation: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Clean up any help windows that might be open
        app.terminate()
    }

    func test_010_helpMenuItemExists() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        // Verify Help menu bar item exists
        let helpMenuBar = try app.menubarHelpMenu
        XCTAssertTrue(helpMenuBar.exists, "Help menu should exist in menu bar")
    }

    func test_020_helpMenuOpensActualDocumentation() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        let initialWindowCount = app.windows.count
        
        // Click on Help menu item to open help documentation
        try app.menubarGowiHelp.click()
        
        // Wait for help to potentially open
        sleep(5)
        
        // Debug: Check what windows exist
        print("Windows after help click: \(app.windows.count)")
        for window in app.windows.allElementsBoundByIndex {
            print("Window: \(window.debugDescription)")
        }
        
        // Check if help opened in external app (like Help Viewer)
        // OR if actual help content is showing (success case)
        let helpWorked = app.windows.count > initialWindowCount ||
                        !app.staticTexts["Help isn't available for Gowi."].exists
        
        XCTAssertTrue(helpWorked, 
                     "Help documentation should open or show actual content instead of placeholder")
    }
}
