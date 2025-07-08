//
//  Test055_AppModel_ItemLink_Priority_System.swift
//  GowiTests
//
//  Created by Claude Code on 2025-07-02.
//

import XCTest
@testable import GowiAppModel

final class Test055_AppModel_ItemLink_Priority_System: XCTestCase {
    var appModel = AppModel(inMemory: true)
    
    var rootItem: Item {
        appModel.systemRootItem
    }
    
    override func setUpWithError() throws {
        appModel = AppModel(inMemory: true)
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Test that items can be shared between multiple parents with different priority orders
    func test100_sharedItemsCanHaveDifferentPriorityOrdersInDifferentParents() throws {
        // Create two parent projects
        let projectA = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project A", 
            priority: 100.0, 
            complete: nil, 
            notes: "Parent project A", 
            children: []
        )
        
        let projectB = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project B", 
            priority: 90.0, 
            complete: nil, 
            notes: "Parent project B", 
            children: []
        )
        
        // Create shared items
        let sharedItem1 = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item 1", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        let sharedItem2 = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item 2", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        let sharedItem3 = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item 3", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Add shared items to both projects with different priorities
        // In Project A: Item1 (high), Item2 (medium), Item3 (low)
        appModel.itemLinkAdd(parent: projectA, child: sharedItem1, priority: 100.0)
        appModel.itemLinkAdd(parent: projectA, child: sharedItem2, priority: 50.0)
        appModel.itemLinkAdd(parent: projectA, child: sharedItem3, priority: 10.0)
        
        // In Project B: Item3 (high), Item1 (medium), Item2 (low) - different order!
        appModel.itemLinkAdd(parent: projectB, child: sharedItem3, priority: 100.0)
        appModel.itemLinkAdd(parent: projectB, child: sharedItem1, priority: 50.0)
        appModel.itemLinkAdd(parent: projectB, child: sharedItem2, priority: 10.0)
        
        appModel.saveToBackend()
        
        // Get sorted lists for each project using ItemLink priority system
        let projectAItems = projectA.childrenOrderedByPriority
        let projectBItems = projectB.childrenOrderedByPriority
        
        // Verify Project A order: Item1, Item2, Item3
        XCTAssertEqual(projectAItems.count, 3, "Project A should have 3 items")
        XCTAssertEqual(projectAItems[0].ourIdS, sharedItem1.ourIdS, "Project A: Item1 should be first (highest priority)")
        XCTAssertEqual(projectAItems[1].ourIdS, sharedItem2.ourIdS, "Project A: Item2 should be second")
        XCTAssertEqual(projectAItems[2].ourIdS, sharedItem3.ourIdS, "Project A: Item3 should be third")
        
        // Verify Project B order: Item3, Item1, Item2
        XCTAssertEqual(projectBItems.count, 3, "Project B should have 3 items")
        XCTAssertEqual(projectBItems[0].ourIdS, sharedItem3.ourIdS, "Project B: Item3 should be first (highest priority)")
        XCTAssertEqual(projectBItems[1].ourIdS, sharedItem1.ourIdS, "Project B: Item1 should be second")
        XCTAssertEqual(projectBItems[2].ourIdS, sharedItem2.ourIdS, "Project B: Item2 should be third")
    }
    
    /// Test that changing priority in one parent doesn't affect order in another parent
    func test200_changingPriorityInOneParentDoesntAffectOtherParent() throws {
        // Create two parent projects
        let projectA = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project A", 
            priority: 100.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        let projectB = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project B", 
            priority: 90.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Create shared items
        let sharedItem1 = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item 1", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        let sharedItem2 = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item 2", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Add items to both projects with same initial order
        appModel.itemLinkAdd(parent: projectA, child: sharedItem1, priority: 100.0)
        appModel.itemLinkAdd(parent: projectA, child: sharedItem2, priority: 50.0)
        appModel.itemLinkAdd(parent: projectB, child: sharedItem1, priority: 100.0)
        appModel.itemLinkAdd(parent: projectB, child: sharedItem2, priority: 50.0)
        
        appModel.saveToBackend()
        
        // Verify initial order is same in both projects
        let initialProjectAItems = projectA.childrenOrderedByPriority
        let initialProjectBItems = projectB.childrenOrderedByPriority
        
        XCTAssertEqual(initialProjectAItems[0].ourIdS, sharedItem1.ourIdS, "Initially both projects should have Item1 first")
        XCTAssertEqual(initialProjectBItems[0].ourIdS, sharedItem1.ourIdS, "Initially both projects should have Item1 first")
        
        // Change priority order in Project A only using ItemLink system
        let projectAItemsArray = projectA.childrenOrderedByPriority
        let sourceIndices = IndexSet([0]) // Move Item1 down
        let targetIndex = 2 // Move to bottom
        
        appModel.itemLinkRearrangeUsingPriority(
            parent: projectA,
            items: projectAItemsArray, 
            sourceIndices: sourceIndices, 
            tgtEdgeIdx: targetIndex,
            externalUM: nil
        )
        
        appModel.saveToBackend()
        
        // Verify Project A order changed
        let updatedProjectAItems = projectA.childrenOrderedByPriority
        XCTAssertEqual(updatedProjectAItems[0].ourIdS, sharedItem2.ourIdS, "Project A: Item2 should now be first")
        XCTAssertEqual(updatedProjectAItems[1].ourIdS, sharedItem1.ourIdS, "Project A: Item1 should now be second")
        
        // Verify Project B order remained unchanged
        let unchangedProjectBItems = projectB.childrenOrderedByPriority
        XCTAssertEqual(unchangedProjectBItems[0].ourIdS, sharedItem1.ourIdS, "Project B: Item1 should still be first")
        XCTAssertEqual(unchangedProjectBItems[1].ourIdS, sharedItem2.ourIdS, "Project B: Item2 should still be second")
    }
    
    /// Test that items can be added to multiple parents through ItemLink system
    func test300_itemsCanBeAddedToMultipleParentsViaItemLink() throws {
        // Create parent projects
        let projectA = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project A", 
            priority: 100.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        let projectB = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project B", 
            priority: 90.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Create an item
        let sharedItem = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Initially item should not be in any project
        XCTAssertEqual(projectA.childrenOrderedByPriority.count, 0, "Project A should initially have no children")
        XCTAssertEqual(projectB.childrenOrderedByPriority.count, 0, "Project B should initially have no children")
        
        // Add item to Project A
        appModel.itemLinkAdd(parent: projectA, child: sharedItem, priority: 100.0)
        appModel.saveToBackend()
        
        XCTAssertEqual(projectA.childrenOrderedByPriority.count, 1, "Project A should now have 1 child")
        XCTAssertEqual(projectB.childrenOrderedByPriority.count, 0, "Project B should still have 0 children")
        XCTAssertTrue(projectA.childrenOrderedByPriority.contains(sharedItem), "Project A should contain the shared item")
        
        // Add same item to Project B
        appModel.itemLinkAdd(parent: projectB, child: sharedItem, priority: 50.0)
        appModel.saveToBackend()
        
        XCTAssertEqual(projectA.childrenOrderedByPriority.count, 1, "Project A should still have 1 child")
        XCTAssertEqual(projectB.childrenOrderedByPriority.count, 1, "Project B should now have 1 child")
        XCTAssertTrue(projectA.childrenOrderedByPriority.contains(sharedItem), "Project A should still contain the shared item")
        XCTAssertTrue(projectB.childrenOrderedByPriority.contains(sharedItem), "Project B should now contain the shared item")
    }
    
    /// Test that removing an ItemLink removes the item from that parent only
    func test400_removingItemLinkRemovesItemFromSpecificParentOnly() throws {
        // Create parent projects
        let projectA = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project A", 
            priority: 100.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        let projectB = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [rootItem], 
            title: "Project B", 
            priority: 90.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Create shared item
        let sharedItem = appModel.itemAddNewTo(
            externalUM: nil, 
            parents: [], 
            title: "Shared Item", 
            priority: 0.0, 
            complete: nil, 
            notes: "", 
            children: []
        )
        
        // Add item to both projects
        appModel.itemLinkAdd(parent: projectA, child: sharedItem, priority: 100.0)
        appModel.itemLinkAdd(parent: projectB, child: sharedItem, priority: 50.0)
        appModel.saveToBackend()
        
        // Verify item is in both projects
        XCTAssertTrue(projectA.childrenOrderedByPriority.contains(sharedItem), "Project A should contain the shared item")
        XCTAssertTrue(projectB.childrenOrderedByPriority.contains(sharedItem), "Project B should contain the shared item")
        
        // Remove item from Project A only
        appModel.itemLinkRemove(parent: projectA, child: sharedItem)
        appModel.saveToBackend()
        
        // Verify item is removed from Project A but still in Project B
        XCTAssertFalse(projectA.childrenOrderedByPriority.contains(sharedItem), "Project A should no longer contain the shared item")
        XCTAssertTrue(projectB.childrenOrderedByPriority.contains(sharedItem), "Project B should still contain the shared item")
        
        // Verify the item itself still exists (wasn't deleted)
        let fetchRequest = Item.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "ourId == %@", sharedItem.ourId! as CVarArg)
        let fetchedItems = try appModel.viewContext.fetch(fetchRequest)
        XCTAssertEqual(fetchedItems.count, 1, "The shared item should still exist in the database")
    }
}
