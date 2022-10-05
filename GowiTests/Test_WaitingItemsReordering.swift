//
//  Test_WaitingItemsReordering.swift
//  GowiTests
//
//  Created by Jonathan Hume on 05/10/2022.
//

import XCTest

@testable import Gowi

final class Test_WaitingItemsReordering: XCTestCase {
    var appModel = AppModel.sharedInMemoryWithTestData

    var rootItem: Item {
        appModel.systemRootItem
    }

    override func setUpWithError() throws {
        appModel = AppModel.sharedInMemoryWithTestData
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test130_itemsMoveSecondItemUpToHead() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([1])
        let tgtIdx = 0
        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the second Item is moved to the head of the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[0].ourIdS, originalList[1].ourIdS,
                       "And the updated list ends up with the second Item at its head")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[0].ourIdS,
                       "And what was the head Item being shifted down one place into second")

        (2 ... originalList.count - 1).forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                           "And the other Items are not moved, remain in their previous locations")
        }
    }

    func test140_itemMoveFirstItemDownToSecond() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([0])
        let tgtIdx = 2 // <- When dragging down, Apple expects to add +1 to expected final location
        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the head Item is moved to the second place in the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[0].ourIdS,
                       "And the updated list ends up with the original head Item in second place")
        XCTAssertEqual(updatedList[0].ourIdS, originalList[1].ourIdS,
                       "And what was the second Item is now at the head")

        (2 ... originalList.count - 1).forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                           "And the other Items are not moved, remain in their previous locations")
        }
    }

    func test150_itemMoveTailItemUpToPenultimate() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        let numTestItems = originalList.count

        let srcIndices = IndexSet([numTestItems - 1])
        let tgtIdx = numTestItems - 2
        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the tail Item is moved to the penultimate position in the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[numTestItems - 2].ourIdS, originalList[numTestItems - 1].ourIdS,
                       "And the updated list ends up with what was the last Item becoming the penultimate")
        XCTAssertEqual(updatedList[numTestItems - 1].ourIdS, originalList[numTestItems - 2].ourIdS,
                       "And the penultimate becoming the tail Item")

        (0 ... numTestItems - 3).forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                           "And the other Items are not moved and remain in their previous locations")
        }
    }

    func test160_itemMovePenultimateItemDownToTail() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        let numTestItems = originalList.count

        let srcIndices = IndexSet([numTestItems - 2])
        let tgtIdx = numTestItems // <- When dragging down, Apple expects to add +1 to expected final location

        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the penultimate Item is moved to the tail of the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[numTestItems - 1].ourIdS, originalList[numTestItems - 2].ourIdS,
                       "And the updated list ends up with what was the penultimate Item in at its tail")
        XCTAssertEqual(updatedList[numTestItems - 2].ourIdS, originalList[numTestItems - 1].ourIdS,
                       "And what was the tail Item is now at the penultimate Item")

        (0 ... numTestItems - 3).forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                           "And the other Items are not moved and remain in their previous locations")
        }
    }

    func test170_itemMoveThirdItemUpToSecond() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
//        let numTestItems = originalList.count

        let srcIndices = IndexSet([2])
        let tgtIdx = 1

        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the third Item is moved to the second place in the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[2].ourIdS,
                       "And the updated list ends up with what was third Item becoming the second")
        XCTAssertEqual(updatedList[2].ourIdS, originalList[1].ourIdS,
                       "And the second Item becoming the third")

        [0, 3, 4].forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                           "And the other Items are not moved and remain in their previous locations")
        }
    }

    func test180_itemMoveThirdDownToFourth() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
//        let numTestItems = originalList.count

        let srcIndices = IndexSet([2])
        let tgtIdx = 4 // <- When dragging down, Apple expects to add +1 to expected final location

        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the third Item is moved to the fourth place in the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[3].ourIdS, originalList[2].ourIdS,
                       "And the updated list ends up with what was third Item becoming the fourth")
        XCTAssertEqual(updatedList[2].ourIdS, originalList[3].ourIdS,
                       "And the fourth Item becoming the third")

        [0, 1, 4].forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                           "And the other Items are not moved and remain in their previous locations")
        }
    }

    func test200_discontinuousItemsSelectionMoveUpToHead() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([2, 4])
        let tgtIdx = 0

        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the the third and fifth Item are moved to the head of list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[0].ourIdS, originalList[2].ourIdS,
                       "And the updated list ends up with what was third Item being at the head")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[4].ourIdS,
                       "And the fifth Item becoming the second")

        [2, 3].forEach { idx in
            XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx - 2].ourIdS,
                           "And the two items preceeding the third Item get shuffled down two")
        }

        XCTAssertEqual(updatedList[4].ourIdS, originalList[3].ourIdS,
                       "And the item between the two moved (fourth), gets shuffled down one place")
    }

    func test210_discontinuousItemsSelectionMoveDownToTail() throws {
        let originalList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([1, 3])
        let tgtIdx = 5 // <- When dragging down, Apple expects to add +1 to expected final location

        Main.sideBarOnMoveOfWaitingItems(originalList, srcIndices, tgtIdx)

        let updatedList: Array<Item> = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the the third and fifth Item are moved to the tail of list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[0].ourIdS, originalList[0].ourIdS,
                       "And the head Item remains unchanged")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[2].ourIdS,
                       "And the second Item is the third shuffled up one place")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[2].ourIdS,
                       "And the third Item is the fourth shuffled up two places")

        XCTAssertEqual(updatedList[3].ourIdS, originalList[1].ourIdS,
                       "And the fourth is first of the moved Items, i.e. the original second Item")

        XCTAssertEqual(updatedList[4].ourIdS, originalList[3].ourIdS,
                       "And the tail Item is second of the moved Items, i.e. the original fourth Item")
    }
}
