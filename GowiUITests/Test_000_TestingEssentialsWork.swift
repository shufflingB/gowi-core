//
//  Test_000_TestingEssentialsWork.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 29/07/2022.
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

    func test_000_appHasEmptyInMemoryTestMode0() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        app.sidebarAllList().click()

        XCTAssertEqual(app.contentRows().count, 0,
                       "When the app is opened in test mode 0, it opens an empty, in memory only, backing store")

        app.menubarItemNew.click()
        app.typeText("000")
        XCTAssertEqual(app.contentRows().count, 1,
                       "And it is possible to create a new Item in this test mode")
        XCTAssertTrue(app.toolbarSaveChangesIsShowingPending,
                      "That detects it needs saving")

        app.menubarFileSaveChanges.click()
        XCTAssertFalse(app.toolbarSaveChangesIsShowingPending,
                       "Detects that it has been saved")

        app.menubarGowiQuit.click()

        app.launch()
        app.sidebarAllList().click()
        XCTAssertEqual(app.contentRows().count, 0,
                       "And yet when the app is relaunched the created Item has been expunged")
    }

    func test_010_appHasInMemoryWithFixtureDataTestMode1() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()

        XCTAssertEqual(app.contentRows().count, 10,
                       "When the app is opened in test mode 1, it opens with 10 existing test Items")
    }

    func test_100_appCanCreateNewWindowsFromMenuBar() {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        let initialWindowCount = app.windows.count

        app.menubarWindowNew.click()
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
