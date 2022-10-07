//
//  ContentView.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import Combine
import CoreData
import SwiftUI

struct Main: View {
    @EnvironmentObject var appModel: AppModel
    @Environment(\.undoManager) var windowUM: UndoManager?

    init(with root: Item) {
        _itemsAllFromFR = FetchRequest<Item>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "parentList CONTAINS %@", root as CVarArg)
        )
    }

//    @SceneStorage("selection051022") var sideBarItemSelections: Set<String> = []
    @State var sideBarItemSelections: Set<UUID> = []
    @SceneStorage("tab051022") var sideBarTabSelected: SideBar.TabOption = .waiting

    var body: some View {
        NavigationView {
            SideBar(stateView: self)
        }
        .focusedValue(\.windowUndoManager, windowUM ?? UndoManager())
    }

    @FetchRequest private var itemsAllFromFR: FetchedResults<Item>
}

extension Main {
    internal var itemsAll: Set<Item> {
        Set(itemsAllFromFR)
    }

    // MARK: SideBar

    internal var sideBarItemsListWaiting: Array<Item> {
        Self.sideBarItemsListWaiting(itemsAll)
    }

    static func sideBarItemsListWaiting(_ items: Set<Item>) -> Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        items.filter({ $0.completed == nil }).sorted { $0.priority > $1.priority }
    }

    internal var sideBarItemsListDone: Array<Item> {
        Self.sideBarItemsListDone(itemsAll)
    }

    static func sideBarItemsListDone(_ items: Set<Item>) -> Array<Item> {
        // Want [0] to have the newest i.e largest completion date, [end] to have lowest
        // there should be any, but to keep compiler happy, set a very low sentinel value

        items.filter({ $0.completed != nil }).sorted { item1, item2 in
            let date1: Date = item1.completed!
            let date2: Date = item2.completed!
            return date1 > date2
        }
    }

    internal var sideBarItemsListAll: Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        Self.sideBarItemsListAll(itemsAll)
    }

    static func sideBarItemsListAll(_ items: Set<Item>) -> Array<Item> {
        // Same as for Waiting, Want  [0] to have largest priority value, [end] to have lowest
        items.sorted { $0.priority > $1.priority }
    }

    internal func sideBarOnMoveOfWaitingItems(_ items: Array<Item>, _ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        appModel.reOrderUsingPriority(externalUM: windowUM, items: items, sourceIndices: sourceIndices, tgtIdxsEdge: tgtIdxsEdge)
    }

    static func itemNewInsertInPriority(appModel: AppModel, windowUM: UndoManager?, parent: Item, list items: Array<Item>, where tgtIdxsEdge: Int) -> Item {
        /// --------------- tgtIdxEdge = 0
        /// sourceItem  0
        /// --------------- tgtIdxEdge = 1
        /// source Idx = 1
        /// -------------- tgtIdxEdge = 2
        /// source Idx =2
        /// -------------- tgtIdxEdge = 3
        /// ...

        let priorities = AppModel.itemPriorityPair(forEdgeIdx: tgtIdxsEdge, items: items)

        let priorityStep: Double = (priorities.aboveEdge - priorities.belowEdge) / 2

        let insertPriority = tgtIdxsEdge < items.count
            ? priorities.belowEdge + priorityStep
            : priorities.aboveEdge - priorityStep

        return appModel.itemAddNewTo(externalUM: windowUM, parents: [parent], title: "New item", priority: insertPriority, complete: nil, notes: "", children: [])
    }
}
