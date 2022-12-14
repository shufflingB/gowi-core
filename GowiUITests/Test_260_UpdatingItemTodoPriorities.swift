//
//  Test_260_UpdatingItemTodoPriorities.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

/**
 # Specifying drop targets to drag and drop list rearrangement test

  In SwiftUI, common practice is for Items in a list have their movement controlled by the specification relative to the original List of
     1) A set of the indices of the source Items to be moved
     2) A target Item edge where the Items that are to be moved are to be inserted.

  For a list of N items, normally the list will have these laid out as follows from top to bottom

         ------------------- tgt edge idx = 0
         src Item idx = 0
         ------------------- tgt edge idx = 1
         src Item Idx = 1
         ------------------- tgt edge idx = 2
         src Item Idx = 2
         ------------------- tgt edge idx= 3
         ...
         ------------------- tgt edge idx = N - 1
         src Item Idx = N - 1
         ------------------- tgt edge idx = N

  _TESTING QUIRK_

  Confusingly enough, in testing, I've been unable to determine an easy/convenient way to directly specify the tgt edge. Instead the tests
  here do theis indirectly by:
     - Specifying the drop tgt as an Item's idx.
     - Programatically dropping the the dragged Item's in the __middle of the tgt__
     - Then rely on the __ os to DEFAULT ASSIGN to the EDGE BELOW __

  ## TL;DR: - QED

 Always think of dragging Items BELOW a target Item.

 WHEN DRAGGING DOWN specify the idx of the item below which the dragged Items should be inserted (and not the tgt edge idx)

 WHEN DRAGGING UP
  1) Specify the idx of the item one above where the Item should be inserted above
  2) Cannot drag to the head of the list

 */
class Test_260_UpdatingItemTodoPriorities: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false

        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
    }

    func test_000_anItemsPriorityInTheWaitingListCanBeIncreasedByDraggingItUpInTheList() throws {
        // Test dragging the 1st Item below the 2nd

        app.sidebarWaitingList().click()
        XCTAssertGreaterThan(app.contentRows().count, 1,
                             "This test requires at least two Items in the list")

        let firstItemTitle = app.contentRowTextFieldValue(0)
        let secondItemTitle = app.contentRowTextFieldValue(1)

        let srcEle = app.contentRowTextField(0)
        let tgtEle = app.contentRowTextField(1)

        srcEle.click()
        srcEle.press(forDuration: 1, thenDragTo: tgtEle)

        XCTAssertEqual(app.contentRowTextFieldValue(0), secondItemTitle,
                       "When the 1st item in the list is dragged down the list, the original 2nd Item moves to the top")
        XCTAssertEqual(app.contentRowTextFieldValue(1), firstItemTitle,
                       "And the original Item at the top of the list becomes the 2nd highest priority Item")
    }

    func test_010_anItemsPriorityInTheWaitingListCanBeDecreasedByDraggingItDownTheList() throws {
        // Swap last with penultimate Items
        app.sidebarWaitingList().click()
        XCTAssertGreaterThan(app.contentRows().count, 2, "This test requires at least two items")

        // Might be long list
        app.contentRowTextField(0).click()
        app.shortcutSelectEndOfList()

        let tailIdx: Int = app.contentRows().indices.last!
        let penultimateIdx: Int = tailIdx - 1

        let penultimateTitle = app.contentRowTextFieldValue(penultimateIdx)
        let lastTitle = app.contentRowTextFieldValue(tailIdx)

        let srcEle = app.contentRowTextField(tailIdx)
        /// See comments at top of file about why we specify with a -1 here.
        let tgtEle = app.contentRowTextField(penultimateIdx - 1)

        srcEle.click()
        srcEle.press(forDuration: 1, thenDragTo: tgtEle)

        XCTAssertEqual(app.contentRowTextFieldValue(penultimateIdx), lastTitle,
                       "When the last Item in the list is dragged up one place in the list it becomes the penultimate value")
        XCTAssertEqual(app.contentRowTextFieldValue(tailIdx), penultimateTitle,
                       "And what was the penultimate value becomes the last value")
    }

    func test_300_anItemsPriorityInTheWaitingListCanBeIncreasedByTheNudgeUpShortcut() throws {
        app.sidebarWaitingList().click()
        XCTAssertGreaterThan(app.contentRows().count, 6, "This test requires at least six items")

        // Select two items that we will move & stash detail for checking later
        let itemOneIdx = 3
        let itemTwoIdx = 5 // <- Intentional gappy selection
        let itemOneTitle = app.contentRowTextFieldValue(itemOneIdx)
        let itemTwoTitle = app.contentRowTextFieldValue(itemTwoIdx)

        try app.contentRowsSelect(indices: [itemOneIdx, itemTwoIdx])

        // Move them up a couple of places into the middle to check gappy selection moves as single block lead by first item
        app.shortcutSelectedItemsMoveUpInList()
        app.shortcutSelectedItemsMoveUpInList()
        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx - 2), itemOneTitle,
                       "When the sidebar's fourth and sixth items are nudged up twice with the shortcut then the fifth should end up third")
        XCTAssertEqual(app.contentRowTextFieldValue(itemTwoIdx - 3), itemTwoTitle,
                       "And the sixth should close with the fourth and end up in fourth place")

        // Now move to head

        app.shortcutSelectedItemsMoveUpInList()
        XCTAssertEqual(app.contentRowTextFieldValue(0), itemOneTitle,
                       "And nudging them up once more should put the original fourth item at the head of the list")
        XCTAssertEqual(app.contentRowTextFieldValue(1), itemTwoTitle,
                       "And the sixth item is now in second")
    }

    func test_400_anItemsPriorityInTheWaitingListCanBeDecreasedByTheNudgeDownShortcut() throws {
        app.sidebarWaitingList().click()
        XCTAssertGreaterThan(app.contentRows().count, 6, "This test requires at least six items")

        // Jump to the end just in case we have a lot of fixture data
        app.contentRowTextField(0).click() // stop it jumping end of the Sidebar List
        app.shortcutSelectEndOfList()

        // Select two items that we will move & stash detail for checking later
        let itemOneIdx = app.contentRows().count - 6
        let itemTwoIdx = itemOneIdx + 1
        let itemOneTitle = app.contentRowTextFieldValue(itemOneIdx)
        let itemTwoTitle = app.contentRowTextFieldValue(itemTwoIdx)

        try app.contentRowsSelect(indices: [itemOneIdx, itemTwoIdx])

        // Move them down a couple of places
        app.shortcutSelectedItemsMoveDownInList()
        app.shortcutSelectedItemsMoveDownInList()

        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx + 2), itemOneTitle,
                       "When two items in the sidebar are nudged down twice with the shortcut then the first should end up two places lower")
        XCTAssertEqual(app.contentRowTextFieldValue(itemTwoIdx + 2), itemTwoTitle,
                       "And the second should as well")

        // Now move them down to what should be the tail of the list
        app.shortcutSelectedItemsMoveDownInList()
        app.shortcutSelectedItemsMoveDownInList()
        XCTAssertEqual(app.contentRowTextFieldValue(app.contentRows().count - 2), itemOneTitle,
                       "And nudging them up twice more should put the first of the pair second from last")
        XCTAssertEqual(app.contentRowTextFieldValue(app.contentRows().count - 1), itemTwoTitle,
                       "And the second of the pair should be at the end of the list")
    }

    func test_500_itemPriorityChangingShortcutsStopAtHead() throws {
        app.sidebarWaitingList().click()
        app.contentRowTextField(0).click()

        XCTAssertGreaterThan(app.contentRows().count, 4, "This test requires at least four items")

        // Select two items that we will move & stash detail for checking later
        let itemOneIdx = 2
        let itemTwoIdx = 3
        let itemOneTitle = app.contentRowTextFieldValue(itemOneIdx)
        let itemTwoTitle = app.contentRowTextFieldValue(itemTwoIdx)

        try app.contentRowsSelect(indices: [itemOneIdx, itemTwoIdx])

        // Move them up to top of list
        app.shortcutSelectedItemsMoveUpInList()
        app.shortcutSelectedItemsMoveUpInList()

        XCTAssertEqual(app.contentRowTextFieldValue(0), itemOneTitle,
                       "When the sidebar's third and fourth items are nudged up twice, then with then the third should end up at the head")
        XCTAssertEqual(app.contentRowTextFieldValue(1), itemTwoTitle,
                       "And the fourth should end in second place")

        // Now attempt to over nu
        app.shortcutSelectedItemsMoveUpInList()
        XCTAssertEqual(app.contentRowTextFieldValue(0), itemOneTitle,
                       "And any further attempts to nudge them up will leave their locations unchanged")
        XCTAssertEqual(app.contentRowTextFieldValue(1), itemTwoTitle)
    }

    func test_600_itemPriorityChangingShortcutsStopAtTail() throws {
        app.sidebarWaitingList().click()

        XCTAssertGreaterThan(app.contentRows().count, 4, "This test requires at least four items")

        app.contentRowTextField(0).click()
        app.shortcutSelectEndOfList() // Jump to the end just in case we have a lot of fixture data

        // Select two items that we will move & stash detail for checking later
        let itemOneIdx = app.contentRows().count - 4
        let itemTwoIdx = app.contentRows().count - 2 // <- Note gappy selection and -2 so can move down once
        let itemOneTitle = app.contentRowTextFieldValue(itemOneIdx)
        let itemTwoTitle = app.contentRowTextFieldValue(itemTwoIdx)

        try app.contentRowsSelect(indices: [itemOneIdx, itemTwoIdx])

        // Move them down one place
        app.shortcutSelectedItemsMoveDownInList()

        XCTAssertEqual(app.contentRowTextFieldValue(app.contentRows().count - 2), itemOneTitle,
                       "When two items in the sidebar with a single gap between them are nudged down once with the shortcut then the first should end up two places lower")
        XCTAssertEqual(app.contentRowTextFieldValue(app.contentRows().count - 1), itemTwoTitle,
                       "And the second should end up one place (and up in the last location)")

        // Now attempt to over nude down
        app.shortcutSelectedItemsMoveDownInList()
        XCTAssertEqual(app.contentRowTextFieldValue(app.contentRows().count - 2), itemOneTitle,
                       "And any further attempts to nudge them up will leave their locations unchanged")
        XCTAssertEqual(app.contentRowTextFieldValue(app.contentRows().count - 1), itemTwoTitle)
    }

    func test_700_changingPrioritiesInTheWaitingListIsUndoableAndRedoable() throws {
        app.sidebarWaitingList().click()
        XCTAssertGreaterThan(app.contentRows().count, 6, "This test requires at least six items")

        // Select two items that we will move & stash detail for checking later
        let itemOneIdx = 3
        let itemTwoIdx = 5 // <- Intentional gappy selection
        let itemOneTitle = app.contentRowTextFieldValue(itemOneIdx)
        let itemTwoTitle = app.contentRowTextFieldValue(itemTwoIdx)

        try app.contentRowsSelect(indices: [itemOneIdx, itemTwoIdx])

        // Move them up a couple of places into the middle to check gappy selection moves as single block lead by first item
        app.shortcutSelectedItemsMoveUpInList()
        app.shortcutSelectedItemsMoveUpInList()
        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx - 2), itemOneTitle,
                       "When the sidebar's 4th and 6th items are nudged up twice with the shortcut then the 4th item should end up in the 2nd place")
        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx - 2 + 1), itemTwoTitle,
                       "And the 6th in 3rd ")

        // Undoing them back to the original location
        app.shortcutUndo()
        app.shortcutUndo()
        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx), itemOneTitle,
                       "Then undoing both nudges, puts the original 4th item back in its original location")
        XCTAssertEqual(app.contentRowTextFieldValue(itemTwoIdx), itemTwoTitle,
                       "As does it for the 6th item ")

        // Redo the Undo
        app.shortcutRedo()
        app.shortcutRedo()
        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx - 2), itemOneTitle,
                       "If both undo's are redone then the  4th item ends back up in the 2nd place")
        XCTAssertEqual(app.contentRowTextFieldValue(itemOneIdx - 2 + 1), itemTwoTitle,
                       "And the 6th in 3rd ")
    }
}
