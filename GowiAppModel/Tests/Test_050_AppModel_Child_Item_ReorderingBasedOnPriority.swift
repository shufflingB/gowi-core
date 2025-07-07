//
//  Test_050_AppModel_Child_Item_ReorderingBasedOnPriority.swift
//  GowiAppModelTests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

@testable import GowiAppModel

final class Test_050_AppModel_Child_Item_ReorderingBasedOnPriority: XCTestCase {
    var appModel: AppModel!

    var rootItem: Item {
        appModel.systemRootItem
    }

    override func setUpWithError() throws {
        appModel = AppModel(inMemory: true)
        // Create 10 test items for priority reordering tests
        for i in 1...10 {
            let _ = appModel.itemAddNewTo(
                externalUM: nil,
                parents: [appModel.systemRootItem],
                title: "Test Item \(i)",
                priority: Double(i),
                complete: nil,
                notes: "",
                children: []
            )
        }
    }

    override func tearDownWithError() throws {
       /// appModel = nil
    }
    
    /// Helper function to get sorted list of children (equivalent to UI layer sorting)
    private func getSortedChildrenList(_ childrenSet: Set<Item>) -> Array<Item> {
        // Sort by priority (descending) to match UI layer - highest priority first
        return Array(childrenSet).sorted { $0.priority > $1.priority }
    }

    func test130_itemsMoveSecondItemUpToHead() throws {
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([1])
        let tgtIdx = 0

        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

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
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([0])
        let tgtIdx = 2 // <- When dragging down, Apple expects to add +1 to expected final location
        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

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
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        let numTestItems = originalList.count

        let srcIndices = IndexSet([numTestItems - 1])
        let tgtIdx = numTestItems - 2
        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

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
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        let numTestItems = originalList.count

        let srcIndices = IndexSet([numTestItems - 2])
        let tgtIdx = numTestItems // <- When dragging down, Apple expects to add +1 to expected final location

        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

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
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([2])
        let tgtIdx = 1

        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the third Item is moved to the second place in the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[2].ourIdS,
                       "And the updated list ends up with what was third Item becoming the second")
        XCTAssertEqual(updatedList[2].ourIdS, originalList[1].ourIdS,
                       "And the second Item becoming the third")

        [0, 3, 4, 5, 6, 7, 8, 9].forEach { idx in
            if idx < updatedList.count {
                XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                               "And the other Items are not moved and remain in their previous locations")
            }
        }
    }

    func test180_itemMoveThirdDownToFourth() throws {
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([2])
        let tgtIdx = 4 // <- When dragging down, Apple expects to add +1 to expected final location

        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the third Item is moved to the fourth place in the list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[3].ourIdS, originalList[2].ourIdS,
                       "And the updated list ends up with what was third Item becoming the fourth")
        XCTAssertEqual(updatedList[2].ourIdS, originalList[3].ourIdS,
                       "And the fourth Item becoming the third")

        [0, 1, 4, 5, 6, 7, 8, 9].forEach { idx in
            if idx < updatedList.count {
                XCTAssertEqual(updatedList[idx].ourIdS, originalList[idx].ourIdS,
                               "And the other Items are not moved and remain in their previous locations")
            }
        }
    }

    func test200_discontinuousItemsSelectionMoveUpToHead() throws {
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([2, 4])
        let tgtIdx = 0

        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

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
        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        let srcIndices = IndexSet([1, 3])
        let tgtIdx = 5 // <- When dragging down, Apple expects to add +1 to expected final location

        appModel.rearrangeUsingPriority(externalUM: nil, items: originalList, sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx)

        let updatedList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(originalList.count, updatedList.count,
                       "When the the second and fourth Item are moved to the tail of list then the original and updated lists should remain the same size")

        XCTAssertEqual(updatedList[0].ourIdS, originalList[0].ourIdS,
                       "And the head Item remains unchanged")

        XCTAssertEqual(updatedList[1].ourIdS, originalList[2].ourIdS,
                       "And the second Item is the third shuffled up one place")

        XCTAssertEqual(updatedList[2].ourIdS, originalList[4].ourIdS,
                       "And the third Item is the fifth shuffled up two places")

        XCTAssertEqual(updatedList[3].ourIdS, originalList[1].ourIdS,
                       "And the fourth is first of the moved Items, i.e. the original second Item")

        XCTAssertEqual(updatedList[4].ourIdS, originalList[3].ourIdS,
                       "And the fifth Item is second of the moved Items, i.e. the original fourth Item")
    }

    func test310_itemReorderingIsUndoable() throws {
        let undoMgr = UndoManager()

        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        let srcIndices = IndexSet([0, 1])
        let tgtIdx = 3

        appModel.rearrangeUsingPriority(
            externalUM: undoMgr,
            items: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet),
            sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx
        )

        let afterMoveList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        XCTAssertEqual(afterMoveList[0].ourIdS, originalList[2].ourIdS,
                       "And the updated list ends up with the 3rd Item at the top of the list")
        XCTAssertEqual(afterMoveList[1].ourIdS, originalList[0].ourIdS)
        XCTAssertEqual(afterMoveList[2].ourIdS, originalList[1].ourIdS)

        undoMgr.undo()

        let afterUndo: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        afterUndo.indices.forEach { idx in
            XCTAssertEqual(afterUndo[idx].titleS, originalList[idx].titleS,
                           "When the Undo command is used any previous item move operations are undone")
        }
    }

    func checkNoTitleDifference(actual: Array<Item>, expected: Array<Item>) throws {
        actual.indices.forEach { idx in
            let actual = actual[idx].titleS
            let expected = expected[idx].titleS
            XCTAssertEqual(actual, expected,
                           "idx = \(idx), actual = \(actual), expected = \(expected) ")
        }
    }

    func test350_itemReorderingMultipleMovesRequireMultipleUndoesToUndo() throws {
        let undoMgr = UndoManager()

        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print("Initial list = \(originalList.map({ $0.titleS }))")

        /// Each move is intended to move the item at the head of the list down one place, looking at the titles should make it easy to understand if things are working
        /// or when they don't what's gone wrong.
        /// First reordering - Original 1st Item to 2nd position
        var srcIndices = IndexSet([0])
        var tgtIdx = 2

        appModel.rearrangeUsingPriority(
            externalUM: undoMgr,
            items: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet),
            sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx
        )
        let afterFirstList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print("After 1st move list = \(afterFirstList.map({ $0.titleS }))")

        /// Second reordering - Original 1st from current 2nd to 3rd position
        srcIndices = IndexSet([1])
        tgtIdx = 3

        appModel.rearrangeUsingPriority(
            externalUM: undoMgr,
            items: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet),
            sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx
        )

        let afterSecondList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print("After 2nd move list = \(afterSecondList.map({ $0.titleS }))")

        /// Third reorder - Original 1st from current 3rd to 4th postion
        srcIndices = IndexSet([2])
        tgtIdx = 4
        appModel.rearrangeUsingPriority(
            externalUM: undoMgr,
            items: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet),
            sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx
        )
        let afterThirdList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print("After 3rd move list = \(afterThirdList.map({ $0.titleS }))")

        undoMgr.undo()
        let afterUndo1: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print(" After 1st undo = \(afterUndo1.map({ $0.titleS }))")
        try checkNoTitleDifference(actual: afterUndo1, expected: afterSecondList)

        undoMgr.undo()
        let afterUndo2: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print(" After 2nd undo = \(afterUndo2.map({ $0.titleS }))")
        try checkNoTitleDifference(actual: afterUndo2, expected: afterFirstList)

        undoMgr.undo()
        let afterUndo3: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        print(" After 3rd undo = \(afterUndo3.map({ $0.titleS }))")
        try checkNoTitleDifference(actual: afterUndo3, expected: originalList)
    }

    func test400_undoRedoCyclesArePossible() throws {
        let undoMgr = UndoManager()

        let originalList: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        // First reordering
        let srcIndices = IndexSet([0, 1])
        let tgtIdx = 3
        appModel.rearrangeUsingPriority(
            externalUM: undoMgr,
            items: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet),
            sourceIndices: srcIndices, tgtEdgeIdx: tgtIdx
        )
        let afterFirstReorder: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)

        /// Undo/Redo first cycle
        undoMgr.undo()
        let afterFirstUndo: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        try checkNoTitleDifference(actual: afterFirstUndo, expected: originalList)

        undoMgr.redo()
        let afterFirstRedo: Array<Item> = getSortedChildrenList(appModel.systemRootItem.childrenListAsSet)
        try checkNoTitleDifference(actual: afterFirstRedo, expected: afterFirstReorder)

        /// Undo/Redo second cycle
        undoMgr.undo()
        try checkNoTitleDifference(actual: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet), expected: originalList)

        undoMgr.redo()
        try checkNoTitleDifference(actual: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet), expected: afterFirstReorder)

        /// Undo/Redo third cycle
        undoMgr.undo()
        try checkNoTitleDifference(actual: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet), expected: originalList)

        undoMgr.redo()
        try checkNoTitleDifference(actual: getSortedChildrenList(appModel.systemRootItem.childrenListAsSet), expected: afterFirstReorder)
    }
}
