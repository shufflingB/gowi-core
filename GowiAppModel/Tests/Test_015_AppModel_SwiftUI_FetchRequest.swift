//
//  Test_015_AppModel_SwiftUI_FetchRequest.swift
//  GowiAppModelTests
//
//  Created by Jonathan Hume on 04/07/2025.
//



@testable import GowiAppModel
import XCTest
import SwiftUI

class Test_015_AppModel_SwiftUI_FetchRequest: XCTestCase {
    
    var appModel: AppModel!
    var rootItem: Item!
    
    override func setUpWithError() throws {
        // Use in-memory database for all tests
        appModel = AppModel(inMemory: true)
        rootItem = appModel.systemRootItem
    }
    
    override func tearDownWithError() throws {
        appModel = nil
        rootItem = nil
    }
    
  
    
    func test_010_makeFetchRequestForChildrenOf_shouldFetchChildrenOfSpecifiedRoot() throws {
        // Create a second root item
        let secondRoot = appModel.itemAddNewTo(
            externalUM: nil,
            parents: [],
            title: "Second Root",
            priority: 0.0,
            complete: nil,
            notes: "",
            children: []
        )
        
        // Add children to first root
        let firstRootChild = appModel.itemAddNewTo(
            externalUM: nil,
            parents: [rootItem],
            title: "First Root Child",
            priority: 1.0,
            complete: nil,
            notes: "",
            children: []
        )
        
        // Add children to second root  
        let secondRootChild = appModel.itemAddNewTo(
            externalUM: nil,
            parents: [secondRoot],
            title: "Second Root Child",
            priority: 1.0,
            complete: nil,
            notes: "",
            children: []
        )
        
        appModel.saveToCoreData()
        
        
        // Get the fetch configuration from the factory method
        let fetchConfig = AppModel.makeFetchRequestConfigForChildrenOf(rootItem)
        
        let coreDataFetchRequest = NSFetchRequest<Item>(entityName: "Item")
        coreDataFetchRequest.predicate = fetchConfig.predicate
        
        let fetchedItems = try appModel.viewContext.fetch(coreDataFetchRequest)
        
        // Should only contain children of the specified root
        XCTAssertEqual(fetchedItems.count, 1, "Should fetch only children of specified root")
        XCTAssertEqual(fetchedItems[0].ourIdS, firstRootChild.ourIdS, "Should fetch the correct child item")
        
        // Verify it doesn't contain children of other roots
        let fetchedIds = Set(fetchedItems.map { $0.ourIdS })
        XCTAssertFalse(fetchedIds.contains(secondRootChild.ourIdS), "Should not contain children of other roots")
        
        /// Do nothing with result, just need it to have on, as this is implicity built on the
        let _: FetchRequest<Item> = AppModel.fetchRequestForChildrenOf(rootItem)

    }
}
