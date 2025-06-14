//
//  Test_050_ItemCreation.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
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

        try app.menubarItemNew.click()
        try Self.checkNewItemLooksOkay(app)
    }

    func test_010_canCreateNewItemFromTheToolbar() throws {
        // Create new item
        app.toolbarItemNew_NON_THROWING.click()
        try Self.checkNewItemLooksOkay(app)
    }

//    TODO: For reasons unknown SwiftUI is during test hijacking the my chosen CMD+N shortcut and using it to open a new window. Need
    // to figure out why
    func test_020_canCreateNewItemUsingKeyboardShortcut() throws {
        XCTAssertEqual(try app.contentRows().count, 0)
        app.shortcutItemNew()
        XCTAssertEqual(try app.contentRows().count, 1)
    }

    func test_200_canCreateANewItemByOpeningAnAppUrl() throws {
        NSWorkspace.shared.open(URL(string: app.urlNewItem)!)

        XCTAssertEqual(app.windows.count, 2,
                       "When the app's 'new item' route is invoked it will create a new window that displays an empty Item")
        try Self.checkNewItemLooksOkay(win: try app.win2, app)
    }

    func test_210_aReqestForANewItemWillOpenANewWindowIfNoneExists() throws {
        // Close any open windows
        app.shortcutWindowsCloseAll()

        // Now attempt to create a new Item
        try app.menubarItemNew.click()

        // Check that a new window has been opened
        XCTAssertEqual(app.windows.allElementsBoundByIndex.count, 1,
                       "Creating a new item when no windows are present should open new window displaying the new item")

        try Self.checkNewItemLooksOkay(win: try app.win2, app)
    }

    func test_230_theCreationOfNewItemsCanBeUndoneAndRedone() throws {
        try app.sidebarWaitingList().click()

        let originalCount = try app.contentRows().count

        try app.menubarItemNew.click()
        let afterNewItemCount = try app.contentRows().count
        XCTAssertEqual(afterNewItemCount, originalCount + 1,
                       "After adding a new Item there should be an additional Item displayed in the sidebar")

        try app.menubarUndo.click()
        let afterUndoCount = try app.contentRows().count
        XCTAssertEqual(afterUndoCount, originalCount,
                       "And when the last action is Undone the new Item is removed")

        try app.menubarRedo.click()
        let afterRedoItemCount = try app.contentRows().count
        XCTAssertEqual(afterRedoItemCount, afterNewItemCount,
                       "And after Redoing the new Item reappears")
    }
}

extension Test_050_ItemCreation  {
    static func checkNewItemLooksOkay(win: XCUIElement? = nil, _ app: XCUIApplication) throws {
        let winS: XCUIElement = win == nil ? try app.win1 : win!

        let clickDate = Date()

        XCTAssertEqual(try app.detailTitleValue(win: winS), "",
                       "New item's should have an empty title string")

        // displays a creation date that is close enough to when the item was created
        let createdDateInApp: Date = app.detailCreateDateValueAsDate_NON_THROWING(win: win)

        XCTAssertEqual(createdDateInApp.timeIntervalSince1970, clickDate.timeIntervalSince1970, accuracy: 200.0,
                       "And the new item's detail should show a creation date close to the time the new item option was triggered")

        // and shows that the item is incomplete
        XCTAssertFalse(app.detailCompletionCheckBoxValue_NON_THROWING(win: winS),
                       "And the new item's detail should show that it is incomplete")

        // and that it has the new item at the top of todo list
        XCTAssertEqual(try app.contentRowTextFieldValue(win: winS, 0), "",
                       "And the sidebar should show the empty new item at the top of the list")
    }
}
