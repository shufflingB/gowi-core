//
//  File.swift
//  Gowi
//
//  Created by Jonathan Hume on 07/07/2025.
//
@testable import GowiAppModel

import XCTest

class Test_020_Item_Deletions: XCTestCase {
    
    var appModel = AppModel.sharedInMemoryWithTestData
    var rootItem: Item { appModel.systemRootItem }
    
    override func setUpWithError() throws {
        appModel = AppModel.sharedInMemoryWithTestData
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    func test_010_itemsCanBeDeleted() {
        let rootItem = appModel.systemRootItem
        let originalSortedList = Array(rootItem.childrenListAsSet)
        
        XCTAssertGreaterThan(originalSortedList.count, 9,
                             "When there are more nine Items in the list at the start of the test")
        
        let deleteItems: Array<Item> = [originalSortedList[1], originalSortedList[2]]
        
        AppModel.itemsDelete(appModel.viewContext, items: deleteItems)
        
        let afterDeleting = Array(rootItem.childrenListAsSet)
        
        XCTAssertEqual(afterDeleting.count, originalSortedList.count - deleteItems.count,
                       "Then after deleting the number in the list should be reduced by \(deleteItems.count)")
    }
    
    func test_100_an_items_can_be_deleted_is_undoable_using_instance() throws {
        let um = UndoManager()
        let rootItem = appModel.systemRootItem
        let originalSortedList = Array(rootItem.childrenListAsSet)
        let deleteItems: Array<Item> = [originalSortedList[1], originalSortedList[2]]
        
//        XCTAssertGreaterThan(originalSortedList.count, 9,
//                             "When there are more nine Items in the list at the start of the test")
//        
       
        
        appModel.itemsDelete(externalUM: um, list: deleteItems)
        
        let afterDeleting = Array(rootItem.childrenListAsSet)
        
        XCTAssertEqual(afterDeleting.count, originalSortedList.count - deleteItems.count,
                       "Then after deleting the number in the list should be reduced by \(deleteItems.count)")
        
        um.undo()
        
        let afterUndo = Array(rootItem.childrenListAsSet)
        
        XCTAssertEqual(afterUndo.count, originalSortedList.count,
                       "And after an undo is triggered the deleted Items are restored")
    }
}
