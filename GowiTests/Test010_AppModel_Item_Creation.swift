//
//  macOSToDoTests.swift
//  macOSToDoTests
//
//  Created by Jonathan Hume on 30/05/2022.
//

import AppKit
import Foundation
@testable import Gowi

import os
import XCTest

class Test010_AppModel_Item_Creation: XCTestCase {
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

    func test010_add_a_new_item_root() throws {
        let rootKidCount: Int = rootItem.childrenListAsSet.count

        let newItem = appModel.itemAddNewTo(externalUM: nil, parents: [rootItem], title: "Some title", priority: 0.0, complete: nil, notes: "Blah", children: [])
        let eDate = Date()
        XCTAssertEqual(newItem.created!.timeIntervalSince1970, eDate.timeIntervalSince1970, accuracy: 0.1,
                       "When a new Item is created it should have an appropriate creation date")

        XCTAssertEqual(rootItem.childrenList?.count, rootKidCount + 1,
                       "And the Root Item should now have one extra Child Item")

        let rootChildItems: Set<Item> = rootItem.childrenList as? Set<Item> ?? []
//        let d: Array<Item> = c.sorted(by: {$0.sortOrder! < $1.sortOrder!})
        XCTAssertEqual(rootChildItems.first, newItem,
                       "And that Child Item should be the Item just created")

        let childParentItems: Set<Item> = newItem.parentList as? Set<Item> ?? []
        XCTAssertEqual(childParentItems.first, rootItem,
                       "And that Child Item should correspondingly also have the Root Item as its Parent")
    }

    func test020_adding_a_new_item_is_undoable() {
        let originalKidCount: Int = rootItem.childrenListAsSet.count
        let undoMgr = UndoManager()

        let newItem = appModel.itemAddNewTo(externalUM: undoMgr, parents: [rootItem], title: "Some title", priority: 0.0, complete: nil, notes: "Blah", children: [])
        appModel.saveToCoreData()

        XCTAssertEqual(rootItem.childrenListAsSet.count, originalKidCount + 1,
                       "When a new Item is created the Root Item should now have one extra Child Item")

        let rootChildItems = rootItem.childrenListAsSet

        XCTAssertEqual(rootChildItems.first?.ourIdS, newItem.ourIdS,
                       "And that Child Item should be the Item just created")

        XCTAssertTrue(undoMgr.canUndo, "And the addition of the new Item should be undoable")

        undoMgr.undo()

        XCTAssertEqual(rootItem.childrenListAsSet.count, originalKidCount,
                       "And afther the change is undone the number of children is as it was originally")
    }

    func test100_an_item_can_be_inserted_when_no_items_in_list() {
        let undoManager = UndoManager()
        let originalSortedList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(originalSortedList.count, 0,
                       "When there are no items in the list at the start")

        let newItem = appModel.itemNewInsertInPriority(
            externalUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: 0,
            title: "New item", complete: nil, notes: "", children: []
        )

        let afterInsertList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterInsertList.count, originalSortedList.count + 1,
                       "After insert a new Item the list will have grown in length by one Item ")

        XCTAssertEqual(afterInsertList.first?.ourIdS, newItem.ourIdS,
                       "And that the new Item is at the head of the list organised by priority")

        undoManager.undo()
        let afterUndoList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterUndoList.count, originalSortedList.count,
                       "And the addition is undoable ")
    }

    func test120_an_item_can_be_inserted_as_the_top_priority_in_a_list() {
        appModel.addTestData(.one)

        let undoManager = UndoManager()
        let originalSortedList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)

        let newItem = appModel.itemNewInsertInPriority(
            externalUM: undoManager, parent: appModel.systemRootItem, list: originalSortedList, where: 0,
            title: "New item", complete: nil, notes: "", children: []
        )

        let afterInsertList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterInsertList.count, originalSortedList.count + 1,
                       "After insert a new Item the list will have grown in length by one Item ")

        XCTAssertEqual(afterInsertList.first?.ourIdS, newItem.ourIdS,
                       "And that the new Item is at the head of the list organised by priority")

        undoManager.undo()
        let afterUndoList = Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet)
        XCTAssertEqual(afterUndoList.count, originalSortedList.count,
                       "And the addition is undoable ")
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
