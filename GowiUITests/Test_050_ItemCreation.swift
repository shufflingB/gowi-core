//
//  Test_ItemCreation.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 29/07/2022.
//

import XCTest

class Test_050_ItemCreation: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Ensure we only have a single window
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_000_canCreateNewItemFromTheMenubar() throws {
        XCTAssertTrue(app.menubarItemNew.exists,
                      "The app should have a Menu Bar entry to create a new item")
        app.menubarItemNew.click()

        Self.checkNewItemLooksOkay(app)
    }

    func test_010_canCreateNewItemFromTheToolbar() throws {
        // Create new item
        XCTAssertTrue(app.toolbarItemNew.exists,
                      "The app should have a button tool bar to create a new item")
        app.toolbarItemNew.click()
        Self.checkNewItemLooksOkay(app)
    }

    func test_020_canCreateNewItemUsingKeyboardShortcut() throws {
        // Can't just use itemNewCheck - app.win1 will not exist bc it got closed
        XCTAssertEqual(app.contentRows().count, 0)
        app.shortcutItemNew()
        XCTAssertEqual(app.contentRows().count, 1)
    }

    func test_200_canCreateANewItemByOpeningAnAppUrl() throws {
        NSWorkspace.shared.open(URL(string: app.urlNewItem)!)

        XCTAssertEqual(app.windows.count, 2,
                       "When the app's 'new item' route is invoked it will create a new window that displays an empty Item")
        Self.checkNewItemLooksOkay(win: app.win2, app)
    }

    func test_210_aReqestForANewItemWillOpenANewWindowIfNoneExists() throws {
        // Close any open windows
        app.shortcutWindowsCloseAll()

        // Now attempt to create a new Item
        app.menubarItemNew.click()

        // Check that a new window has been opened
        XCTAssertEqual(app.windows.allElementsBoundByIndex.count, 1,
                       "Creating a new item when no windows are present should open new window displaying the new item")

        Self.checkNewItemLooksOkay(win: app.win2, app)
    }

    func test_230_theCreationOfNewItemsCanBeUndoneAndRedone() throws {
        app.sidebarWaitingList().click()

        let originalCount = app.contentRows().count

        app.menubarItemNew.click()
        let afterNewItemCount = app.contentRows().count
        XCTAssertEqual(afterNewItemCount, originalCount + 1,
                       "After adding a new Item there should be an additional Item displayed in the sidebar")

        app.menubarUndo.click()
        let afterUndoCount = app.contentRows().count
        XCTAssertEqual(afterUndoCount, originalCount,
                       "And when the last action is Undone the new Item is removed")

        app.menubarRedo.click()
        let afterRedoItemCount = app.contentRows().count
        XCTAssertEqual(afterRedoItemCount, afterNewItemCount,
                       "And after Redoing the new Item reappears")
    }
}

extension Test_050_ItemCreation {
    static func checkNewItemLooksOkay(win: XCUIElement? = nil, _ app: XCUIApplication) {
        let winS: XCUIElement = win == nil ? app.win1 : win!

        let clickDate = Date()

        XCTAssertEqual(app.detailTitleValue(win: winS), "",
                       "New item's should have an empty title string")

        // displays a creation date that is close enough to when the item was created
        let createdDateInApp: Date = app.detailCreateDateValueAsDate(win: win)

        XCTAssertEqual(createdDateInApp.timeIntervalSince1970, clickDate.timeIntervalSince1970, accuracy: 200.0,
                       "And the new item's detail should show a creation date close to the time the new item option was triggered")

        // and shows that the item is incomplete
        XCTAssertFalse(app.detailCompletionCheckBoxValue(win: winS),
                       "And the new item's detail should show that it is incomplete")

        // and that it has the new item at the top of todo list
        XCTAssertEqual(app.contentRowTextFieldValue(win: winS, 0), "",
                       "And the sidebar should show the empty new item at the top of the list")
    }
}
