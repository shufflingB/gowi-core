//
//  Test010_AppModel_Item_Creation.swift
//  GowiTests
//
//  Created by Jonathan Hume on 02/12/2022.
//


@testable import GowiAppModel
import XCTest

class Test_010_AppModel_Item_Creation: XCTestCase {
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
}
