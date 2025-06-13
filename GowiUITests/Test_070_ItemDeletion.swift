//
//  Test_070_ItemDeletion.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_070_ItemDeletion: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Ensure we only have a single window
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func itemCanBeDeletedUsing(description: String, rowToDelete row: Int = 3, method: () -> Void) throws {
        try app.sidebarAllList().click()
        assert(app.contentRows_NON_THROWING().count > 5,
               "Testing from \(description) should run successfully if at least 5 existing items is present in the sidebar")

        let rowToDelete = row
        app.contentRowTextField_NON_THROWING(rowToDelete).click()
        let itemToDeleteTitle = app.contentRowTextFieldValue_NON_THROWING(rowToDelete)

        method()

        app.contentRows_NON_THROWING().indices.forEach { idx in
            XCTAssertNotEqual(app.contentRowTextFieldValue_NON_THROWING(idx), itemToDeleteTitle,
                              "And after \(description)'s deletion that title should not be visible")
        }
    }

    func test_100_canDeleteItemFromTheMenuBar() throws {
        try itemCanBeDeletedUsing(description: #function) {
            app.menubarItemDelete_NON_THROWING.click()
        }
    }

    func test_200_canDeleteItemUsingAShortcut() throws {
        try itemCanBeDeletedUsing(description: #function) {
            app.shortcutItemDelete()
        }
    }

    func test_200_canDeleteItenUsingTheContentContextMenu() throws {
        let rowToDelete = 2
        try itemCanBeDeletedUsing(description: #function, rowToDelete: rowToDelete) {
            app.contentRowTextField_NON_THROWING(rowToDelete).click()
            app.contentRowTextField_NON_THROWING(rowToDelete).rightClick()
            app.contentContextMenuDelete_NON_THROWING(rowToDelete).click()
        }
    }

    func test_300_aDiscontinuousSelectionOfItemsCanBeDeletedInOneGo() throws {
        try app.sidebarWaitingList().click()
        assert(app.contentRows_NON_THROWING().count > 5,
               "This test should run successfully if at least 5 existing items is present in the sidebar")

        let initialCount = app.contentRows_NON_THROWING().count
        let idxsToDelete = [0, 2, 4]
        let titlesToDelete: Array<String> = idxsToDelete.map({ app.contentRowTextFieldValue_NON_THROWING($0) })

        try app.contentRowsSelect(indices: idxsToDelete)

        app.menubarItemDelete_NON_THROWING.click()

        let afterDeleteCount = app.contentRows_NON_THROWING().count

        XCTAssertEqual(afterDeleteCount, initialCount - idxsToDelete.count,
                       "When a discontinuous selection is made the number ouf rows after deletion is reduced accordingly")

        app.contentRows_NON_THROWING().indices.forEach { idx in
            XCTAssertFalse(titlesToDelete.contains(where: { $0 == app.contentRowTextFieldValue_NON_THROWING(idx) }),
                           "And no item with any of those titles are no longer shown"
            )
        }
    }

    func test_600_itemDeletionsAreUndoable() throws {
        let numTestItems = 9
        let idxsOfItemsToDelete = [1, 3, 4]

        try app.sidebarWaitingList().click()
        XCTAssertGreaterThan(app.contentRows_NON_THROWING().count, numTestItems,
                             "This test should run successfully if there are \(numTestItems) in the sidebar list")

        // Stash the info on what we are about to delete so that we can compare for success post Undo ...
        let originalTitles: Array<String> = (0 ... numTestItems - 1).map { idx in
            app.contentRowTextFieldValue_NON_THROWING(idx)
        }
        let originalCount = app.contentRows_NON_THROWING().count

        // Select possibly discontinuous set of Items and then delete theme
        try app.contentRowsSelect(indices: idxsOfItemsToDelete)

        app.menubarItemDelete_NON_THROWING.click()

        // Minimal check that the deletion looks plausible
        let afterDeleteCount = app.contentRows_NON_THROWING().count
        XCTAssertEqual(afterDeleteCount, originalCount - idxsOfItemsToDelete.count)

        // Undo and see what we have

        app.menubarUndo_NON_THROWING.click()
        let afterUndoCount = app.contentRows_NON_THROWING().count
        XCTAssertEqual(afterUndoCount, originalCount,
                       "After undo the number of Items should be as it was originally")
        (0 ... numTestItems - 1).forEach { idx in
            let afterUndoTitle = app.contentRowTextFieldValue_NON_THROWING(idx)
            let expectedTitle = originalTitles[idx]
            XCTAssertEqual(afterUndoTitle, expectedTitle,
                           "And the Item's title at idx = \(idx) should match the original data")
        }

        // Then Redo and check things are as expected
        app.menubarRedo_NON_THROWING.click()
        let afterRedoCount = app.contentRows_NON_THROWING().count
        XCTAssertEqual(afterRedoCount, originalCount - idxsOfItemsToDelete.count,
                       "And Redo should redo the Delete again and the original set of Items displayed to decrease by \(idxsOfItemsToDelete.count)")

        idxsOfItemsToDelete.forEach { idx in
            XCTAssertNotEqual(app.contentRowTextFieldValue_NON_THROWING(idx), originalTitles[idx],
                              "And Title of the Item at row idx \(idx) should not be the same as it was originally, i.e. it's gone ")
        }
    }
}
