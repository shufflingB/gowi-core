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

    func test_minus_001_frameworkThrowsWhenAccessingNonExistentWindow() throws {
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

    func test_000_appTestMode0HasNoData() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        app.sidebarAllList_NON_THROWING().click()
        XCTAssertEqual(app.contentRows_NON_THROWING().count, 0,
                       "When the app is opened in test mode 0, it opens an empty, in memory only, backing store")
        
        XCTAssertEqual(try app.contentRows().count, 0,
                       "When the app is opened in test mode 0, it opens an empty, in memory only, backing store")
        
        
    }
    
    func test_010_appTestMode1HasHasFixture() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        app.sidebarAllList_NON_THROWING().click()

        XCTAssertEqual(try app.contentRows().count, 10,
                       "When the app is opened in test mode 1, it opens with 10 existing test Items")
        
//TODO: Verify that expected UUID is presenttestingMode1ourIdPresent
    }

//    fun test_can_create_new_date
    
//
//        app.menubarItemNew.click()
//        app.typeText("000")
//        XCTAssertEqual(app.contentRows_NON_THROWING().count, 1,
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
//        app.sidebarAllList_NON_THROWING().click()
//        XCTAssertEqual(app.contentRows_NON_THROWING().count, 0,
//                       "And yet when the app is relaunched the created Item has been expunged")
//    }



    func test_100_appCanCreateNewWindowsFromMenuBar() {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        let initialWindowCount = app.windows.count

        app.menubarWindowNew_NON_THROWING.click()
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
