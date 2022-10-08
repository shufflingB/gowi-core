//
//  Test020_AppModel_Item_Deletion.swift
//  GowiTests
//
//  Created by Jonathan Hume on 08/10/2022.
//

@testable import Gowi
import XCTest

final class Test020_AppModel_Item_Deletion: XCTestCase {
    override func setUpWithError() throws {
//        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test010_an_items_can_be_deleted() {
        let appModel = AppModel.sharedInMemoryWithTestData

        let originalSortedList = Main.sideBarItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertGreaterThan(originalSortedList.count, 9,
                             "When there are more nine Items in the list at the start of the test")

        let deleteItems: Array<Item> = [originalSortedList[1], originalSortedList[2]]

        AppModel.itemsDelete(appModel.viewContext, items: deleteItems)

        let afterDeleting = Main.sideBarItemsListAll(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(afterDeleting.count, originalSortedList.count - deleteItems.count,
                       "Then after deleting the number in the list should be reduced by \(deleteItems.count)")
    }
}
