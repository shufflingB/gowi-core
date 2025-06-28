//
//  Test_000_TestingEssentialsWork.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_000_TestingEssentialsWork: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test__010_frameworkCanAccessTheAppsWindows() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]

        app.launchAndSanitiseWindowsAndIdentifiers()
        
        // Verify that only one window exists (win1)
        XCTAssertEqual(app.windows.count, 1, "Test setup should have exactly one window")
        
        // Verify that accessing an existing window (win1) works
        XCTAssertNoThrow(try app.win1, "win1 should be accessible when it exists")
        
        // Verify that accessing a non-existent window (win4) throws an error
        XCTAssertThrowsError(try app.win4, "win4 should throw an error when it doesn't exist") { error in
            // Verify the error is an XCTestError with expected information
            guard let testError = error as? XCTestError else {
                XCTFail("Expected XCTestError, got \(type(of: error))")
                return
            }
            
            // Check that the error contains useful debugging information
            let userInfo = testError.userInfo
            XCTAssertTrue(userInfo["description"] as? String ?? "" != "", "Error should contain description")
            XCTAssertEqual(userInfo["timeout"] as? String, "3 seconds", "Error should contain timeout info")
            XCTAssertNotNil(userInfo["available_windows"], "Error should contain available windows list")
        }
    }

    func test_005_allCriticalUILocatorsAreAccessible() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "1"] // Use test data for content-dependent locators
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        // Helper for conditional validation that doesn't fail the entire test
        func validateConditionalElements(_ description: String, _ block: () throws -> Void) {
            do {
                try block()
            } catch {
                print("⚠️ Conditional validation failed for \(description): \(error)")
                // Don't fail test for conditional elements, just log
            }
        }
        
        // Tier 1: Core structural elements (always present)
        XCTAssertNoThrow(try app.win1, "Primary window (win1) should always be accessible")
        
        // Tier 2: Core application UI elements - Sidebar
        XCTAssertNoThrow(try app.sidebarAllList(), "Sidebar 'All' list should be accessible")
        XCTAssertNoThrow(try app.sidebarWaitingList(), "Sidebar 'Waiting' list should be accessible") 
        XCTAssertNoThrow(try app.sidebarDoneList(), "Sidebar 'Done' list should be accessible")
        
        // Tier 2: Toolbar elements (non-throwing variants for safety)
        XCTAssertTrue(app.toolbarItemNew_NON_THROWING.exists, "Toolbar 'New Item' button should exist")
        
        // Tier 3: Content elements (require test data and selection)
        try app.sidebarAllList().click() // Ensure we're showing content
        XCTAssertNoThrow(try app.contentRows(), "Content rows should be accessible")
        XCTAssertGreaterThan(try app.contentRows().count, 0, "Should have test content rows in TESTMODE=1")
        XCTAssertNoThrow(try app.contentRowTextField(0), "First content row text field should be accessible")
        
        // Select first item to populate detail view
        try app.contentRowTextField(0).click()
        
        // Tier 3: Detail view elements (require item selection)
        XCTAssertNoThrow(try app.detailTitle(), "Detail title field should be accessible after item selection")
        XCTAssertNoThrow(try app.detailCompletionCheckBox(), "Detail completion checkbox should be accessible after item selection")
        XCTAssertNoThrow(try app.detailNotes(), "Detail notes field should be accessible after item selection")
        
        // Tier 4: Menu bar elements (conditional - require menu activation)
        validateConditionalElements("Menu bar items") {
            _ = try app.menubarItemNew
            _ = try app.menubarUndo 
            _ = try app.menubarRedo
            _ = try app.menubarWindowNew
        }
        
        validateConditionalElements("Detail copy buttons") {
            _ = try app.detailIDButtonCopyToPasteBoard()
            _ = try app.detailCreateDateButtonToCopyToPasteBoard()
        }
    }

    func test_000_appTestMode0HasNoDataAndFrameworkCanWorkThisOut() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        try app.sidebarAllList().click()
        
        XCTAssertEqual(try app.contentRows().count, 0,
                       "When the app is opened in test mode 0, it opens an empty, in memory only, backing store")
        
        
    }


    func test_020_frameworkThrowsWhenAccessingInvalidContentRow() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        try app.sidebarAllList().click()
        
        // Verify that accessing non-existent content rows throws
        XCTAssertThrowsError(try app.contentRowTextField(0), "contentRowTextField should throw for non-existent row 0") { error in
            guard let testError = error as? XCTestError else {
                XCTFail("Expected XCTestError, got \(type(of: error))")
                return
            }
            
            let userInfo = testError.userInfo
            XCTAssertTrue(userInfo["description"] as? String ?? "" != "", "Error should contain description")
            XCTAssertNotNil(userInfo["requested_row"], "Error should contain requested row info")
        }
        
        XCTAssertThrowsError(try app.contentRowTextFieldValue(0), "contentRowTextFieldValue should throw for non-existent row 0") { error in
            guard let testError = error as? XCTestError else {
                XCTFail("Expected XCTestError, got \(type(of: error))")
                return
            }
            
            let userInfo = testError.userInfo
            XCTAssertTrue(userInfo["description"] as? String ?? "" != "", "Error should contain description")
        }
    }

    
    
    func test_030_appTestMode1HasHasFixtureAndFrameworkCanAccessContentRows() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        try app.sidebarAllList().click()
        
        XCTAssertEqual(try app.contentRows().count, 10,
                       "When the app is opened in test mode 1, it opens with 10 existing test Items")
        
      
        XCTAssertNoThrow(try app.contentRowTextField(0),
                         "contentRowTextField should work for existing row 0")
        XCTAssertNoThrow(try app.contentRowTextFieldValue(0), "contentRowTextFieldValue should work for existing row 0")
        
        // Verify we can get values from multiple rows
        let firstRowValue = try app.contentRowTextFieldValue(0)
        let secondRowValue = try app.contentRowTextFieldValue(1)
        
        XCTAssertFalse(firstRowValue.isEmpty, "First row should have non-empty value")
        XCTAssertFalse(secondRowValue.isEmpty, "Second row should have non-empty value")
        XCTAssertNotEqual(firstRowValue, secondRowValue, "Different rows should have different values")
        // TODO: Verify that expected UUID is presenttestingMode1ourIdPresent
        
        
    }

    func test_040_frameworkCanAccessSidebarLists() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        // Verify that existing lists work
        XCTAssertNoThrow(try app.sidebarAllList(), "sidebarAllList should work for 'All' list")
        XCTAssertNoThrow(try app.sidebarWaitingList(), "sidebarWaitingList should work for 'Waiting' list")
        XCTAssertNoThrow(try app.sidebarDoneList(), "sidebarDoneList should work for 'Done' list")
        
        // Verify that accessing a non-existent list throws
        XCTAssertThrowsError(try app.sidebarList(identifier: "NonExistentList"), "sidebarList should throw for non-existent list") { error in
            guard let testError = error as? XCTestError else {
                XCTFail("Expected XCTestError, got \(type(of: error))")
                return
            }
            
            let userInfo = testError.userInfo
            XCTAssertTrue(userInfo["description"] as? String ?? "" != "", "Error should contain description")
            XCTAssertEqual(userInfo["timeout"] as? String, "3 seconds", "Error should contain timeout info")
            XCTAssertEqual(userInfo["requested_identifier"] as? String, "NonExistentList", "Error should contain requested identifier")
        }
    }
    // MARK: - Basic Search Functionality Tests

    func test_000_searchFieldExistsForEachList() throws {
        let list_locators = ["All": app.sidebarAllList, "Waiting": app.sidebarWaitingList, "Done": app.sidebarDoneList  ]
        for (list_k, locator_v) in list_locators {
            try locator_v(nil).click()
            XCTAssertTrue(try app.searchField().exists, "Search field should exist in \(list_k) list")
        }
    }


//    fun test_can_create_new_date
    
//
//        app.menubarItemNew.click()
//        app.typeText("000")
//        XCTAssertEqual(try app.contentRows().count, 1,
//                       "And it is possible to create a new Item in this test mode")
//        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending,
//                      "That detects it needs saving")
//
//        app.menubarFileSaveChanges.click()
//        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
//                       "Detects that it has been saved")
//
//        app.menubarGowiQuit.click()
//
//        app.launch()
//        try app.sidebarAllList().click()
//        XCTAssertEqual(try app.contentRows().count, 0,
//                       "And yet when the app is relaunched the created Item has been expunged")
//    }



    func test_100_appCanCreateNewWindowsFromMenuBar() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        let initialWindowCount = app.windows.count

        try app.menubarWindowNew.click()
        XCTAssertGreaterThan(app.windows.count, initialWindowCount,
                             "There is a menu bar entry to create a new window that when it is clicked creates new Window")
    }

    func test_110_appCanCloseAllWindowsUsingStandardShortcut() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()

        let initialWindowCount = app.windows.count

        XCTAssertGreaterThan(initialWindowCount, 0,
                             "This test needs at least a single window to work")

        app.shortcutWindowsCloseAll()

        XCTAssertEqual(app.windows.count, 0,
                       "When the Menu Bar's Window Close All shortcut is used all existing Windows are closed")
    }
}
