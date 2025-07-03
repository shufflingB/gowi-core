//
//  Test020_AppModel_Item_Deletion.swift
//  GowiTests
//
//  Created by Jonathan Hume on 02/12/2022.
//


@testable import Gowi
import GowiAppModel
import XCTest

final class Test_020_AppModel_Item_Deletion: XCTestCase {
    var appModel = AppModel(inMemory: true)
    override func setUpWithError() throws {
        appModel = AppModel(inMemory: true)
        appModel.addTestData(.one)
//        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_010_items_can_be_deleted() {
        let originalSortedList = Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertGreaterThan(originalSortedList.count, 9,
                             "When there are more nine Items in the list at the start of the test")

        let deleteItems: Array<Item> = [originalSortedList[1], originalSortedList[2]]

        AppModel.itemsDelete(appModel.viewContext, items: deleteItems)

        let afterDeleting = Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(afterDeleting.count, originalSortedList.count - deleteItems.count,
                       "Then after deleting the number in the list should be reduced by \(deleteItems.count)")
    }

    func test_100_an_items_can_be_deleted_is_undoable_using_instance() {
        let um = UndoManager()

        let originalSortedList = Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertGreaterThan(originalSortedList.count, 9,
                             "When there are more nine Items in the list at the start of the test")

        let deleteItems: Array<Item> = [originalSortedList[1], originalSortedList[2]]

        appModel.itemsDelete(externalUM: um, list: deleteItems)

        let afterDeleting = Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(afterDeleting.count, originalSortedList.count - deleteItems.count,
                       "Then after deleting the number in the list should be reduced by \(deleteItems.count)")

        um.undo()

        let afterUndo = Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(afterUndo.count, originalSortedList.count,
                       "And after an undo is triggered the deleted Items are restored")
    }
}
