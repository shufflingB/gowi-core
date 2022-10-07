//
//  Test500_Main_Intents.swift
//  GowiTests
//
//  Created by Jonathan Hume on 07/10/2022.
//
@testable import Gowi
import XCTest

final class Test500_Main_Intents: XCTestCase {
    var appModel = AppModel.sharedInMemoryWithTestData

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appModel = AppModel.sharedInMemoryWithTestData
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test100_sidebars_an_item_can_be_inserted_at_the_top_of_waiting_list() {
        let undoManager = UndoManager()
        let originalSortedList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let newItem = Main.itemNewInsertInPriority(appModel: appModel, windowUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: 0)

        let afterInsertList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterInsertList.count, originalSortedList.count + 1,
                       "After insert a new Item the list will have grown in length by one Item ")

        XCTAssertEqual(afterInsertList.first?.ourIdS, newItem.ourIdS,
                       "And that the new Item is at the head of the list organised by priority")

        undoManager.undo()
        let afterUndoList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterUndoList.count, originalSortedList.count,
                       "And the addition is undoable ")
    }

    func test110_sidebars_an_item_can_be_inserted_at_the_bottom_of_waiting_list() {
        let undoManager = UndoManager()
        let originalSortedList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let newItem = Main.itemNewInsertInPriority(appModel: appModel, windowUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: originalSortedList.count)

        let afterInsertList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterInsertList.count, originalSortedList.count + 1,
                       "After insert a new Item the list will have grown in length by one Item ")

        XCTAssertEqual(afterInsertList.last?.title, newItem.title,
                       "And that the new Item is at the tail of the list organised by priority")

        undoManager.undo()
        let afterUndoList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterUndoList.count, originalSortedList.count,
                       "And the addition is undoable ")
    }

    func test120_sidebars_an_item_can_be_inserted_between_items_of_waiting_list() {
        /// --------------- tgtIdxEdge = 0
        /// sourceItem  0
        /// --------------- tgtIdxEdge = 1
        /// source Idx = 1
        /// -------------- tgtIdxEdge = 2
        /// source Idx =2
        /// -------------- tgtIdxEdge = 3
        /// ...
        ///
        let undoManager = UndoManager()
        let originalSortedList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        // insert between the items at idx 5 and 6 in the waiting  list i.e. tgt Idx edge 6

        let whereTgtEdge = 6
        let newItem = Main.itemNewInsertInPriority(appModel: appModel, windowUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: whereTgtEdge)

        let afterInsertList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterInsertList.count, originalSortedList.count + 1,
                       "After insert a new Item the list will have grown in length by one Item ")

        XCTAssertEqual(afterInsertList[whereTgtEdge].title, newItem.title,
                       "And that the new Item will be located at the 6th idx ")

        var idxOffset = 0
        afterInsertList.indices.forEach { idx in
            if idx != whereTgtEdge {
                XCTAssertEqual(afterInsertList[idxOffset].title, originalSortedList[idxOffset].title,
                               "And the other items remain in the same place relative to each other")
            } else {
                idxOffset += 1
            }
        }

        undoManager.undo()
        let afterUndoList = Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterUndoList.count, originalSortedList.count,
                       "And the addition is undoable ")
    }
}
