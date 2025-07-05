//
//  Test010_AppModel_Item_Creation.swift
//  GowiTests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import AppKit
import Foundation
@testable import Gowi
import GowiAppModel

import os
import XCTest

class Test_010_Main_Item_Creation: XCTestCase {
//    ProcessInfo.processInfo.environment["GOWI_TESTMODE"]

    var appModel = AppModel(inMemory: true)
    var rootItem: Item { appModel.systemRootItem }

    override func setUpWithError() throws {
        appModel = AppModel(inMemory: true)
//        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test110_sidebars_an_item_can_be_inserted_at_the_bottom_of_waiting_list() {
        appModel.addTestData(.one)

        let undoManager = UndoManager()
        let originalSortedList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let newItem = appModel.itemNewInsertInPriority(
            externalUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: originalSortedList.count,
            title: "New item", complete: nil, notes: "", children: []
        )

        let afterInsertList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterInsertList.count, originalSortedList.count + 1,
                       "After insert a new Item the list will have grown in length by one Item ")

        XCTAssertEqual(afterInsertList.last?.title, newItem.title,
                       "And that the new Item is at the tail of the list organised by priority")

        undoManager.undo()
        let afterUndoList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
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
        appModel.addTestData(.one)

        let undoManager = UndoManager()
        let originalSortedList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        // insert between the items at idx 5 and 6 in the waiting  list i.e. tgt Idx edge 6

        let whereTgtEdge = 6
        let newItem = appModel.itemNewInsertInPriority(
            externalUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: whereTgtEdge,
            title: "New item", complete: nil, notes: "", children: []
        )

        let afterInsertList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

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
        let afterUndoList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterUndoList.count, originalSortedList.count,
                       "And the addition is undoable ")
    }
}
