//
//  macOSToDoTests.swift
//  macOSToDoTests
//
//  Created by Jonathan Hume on 30/05/2022.
//

import Foundation
@testable import Gowi
import XCTest
import AppKit
import os


class Test_AppModel: XCTestCase {
    
//    ProcessInfo.processInfo.environment["GOWI_TESTMODE"]
    
    var appModel = AppModel.sharedInMemoryNoTestData
    var rootItem: Item {
        appModel.systemRootItem
    }

    override func setUpWithError() throws {        
        appModel = AppModel.sharedInMemoryNoTestData
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test000_initCreatesValidRootItem() throws {
        let eDate = Date()

        XCTAssertNotNil(appModel.systemRootItem,
                        "When a new appModel is instantiated it automatically creates a new system Root item")

        XCTAssertTrue(rootItem.id != nil,
                      "And it should have a valid ID")

        XCTAssertTrue(rootItem.root,
                      "And it should be marked as such")

        XCTAssertEqual(rootItem.created!.timeIntervalSince1970, eDate.timeIntervalSince1970, accuracy: 0.1,
                       "With a matching created date attribute ")

        XCTAssertEqual(rootItem.parentList?.count, 0,
                       "No parent items")

        XCTAssertEqual(rootItem.childrenList?.count, 0,
                       "And initially no child items")
    }

    func test010_createOneItem() throws {
        let rootKidCount: Int = rootItem.childrenList?.count ?? 0

        let newItem = AppModel.itemCreate(appModel.viewContext, parent: rootItem)
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


}
