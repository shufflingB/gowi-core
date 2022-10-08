//
//  Main_Model.swift
//  Gowi
//
//  Created by Jonathan Hume on 07/10/2022.
//

import SwiftUI
extension Main { // MARK: Model Intents
    // MARK: Window

    internal var itemsAll: Set<Item> {
        Set(itemsAllFromFR)
    }

    static func itemAddNew(
        appModel: AppModel, windowUM: UndoManager?,
        tabSelected: SideBar.TabOption,
        parent: Item, list items: Array<Item>
    ) -> (newItem: Item, tabSelected: SideBar.TabOption, itemIdsSelected: Set<UUID>) {
        //
        let newItem = appModel.itemNewInsertInPriority(
            externalUM: windowUM,
            parent: parent, list: items, where: 0,
            title: "New Item", complete: nil, notes: "", children: []
        )

        let newTabSelected: SideBar.TabOption = tabSelected == .done ? .waiting : tabSelected

        return (newItem: newItem, tabSelected: newTabSelected, itemIdsSelected: [newItem.ourIdS])
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
}
