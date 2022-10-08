//
//  Main_Model.swift
//  Gowi
//
//  Created by Jonathan Hume on 07/10/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

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

    static func itemsDelete(
        appModel: AppModel, windoUM: UndoManager?,
        sideBarShowingList: Array<Item>,
        previousListSelectionsGoingDown: Bool,
        deleteItems: Array<Item>
    ) -> Set<UUID> {
        //
        // On deletion Apple places the selection on row above or below depending in what direction previous selections
        // have been going.
        guard let firstToDelete = deleteItems.first, let lastToDelete = deleteItems.last else {
            log.warning("\(#function) not deleting bc nothing passed to delete")
            return []
        }

        guard let firstToDeleteIdx = sideBarShowingList.firstIndex(of: firstToDelete), let lastToDeleteIdx = sideBarShowingList.firstIndex(of: lastToDelete) else {
            log.warning("\(#function) not deleting bc unable to find selection in what is showing")
            return []
        }

        let possPrecIdx = firstToDeleteIdx - 1
        let idxPrecedingFirst: Int? = sideBarShowingList.indices.contains(possPrecIdx) ? possPrecIdx : nil

        let possTrailIdx = lastToDeleteIdx + 1
        let idxTrailingLast: Int? = sideBarShowingList.indices.contains(possTrailIdx) ? possTrailIdx : nil

        let newSelection: Set<UUID> = {
            if previousListSelectionsGoingDown {
                if let idxTrailingLast = idxTrailingLast {
                    return [sideBarShowingList[idxTrailingLast].ourIdS]
                } else if let idxPrecedingFirst = idxPrecedingFirst {
                    return [sideBarShowingList[idxPrecedingFirst].ourIdS]
                } else {
                    return []
                }

            } else { // Going Up
                if let idxPrecedingFirst = idxPrecedingFirst {
                    return [sideBarShowingList[idxPrecedingFirst].ourIdS]
                } else if let idxTrailingLast = idxTrailingLast {
                    return [sideBarShowingList[idxTrailingLast].ourIdS]
                } else {
                    return []
                }
            }
        }()

        appModel.itemsDelete(externalUM: windoUM, list: deleteItems)
        return newSelection
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

    internal var sideBarItemsVisible: Array<Item> {
        switch sideBarTabSelected {
        case .all:
            return sideBarItemsListAll
        case .waiting:
            return sideBarItemsListWaiting
        case .done:
            return sideBarItemsListDone
        }
    }

    internal var sideBarItemsSelectedVisible: Array<Item> { detailItems }

    internal var detailItems: Array<Item> {
        return Self.detailItems(sideBarTabSelected: sideBarTabSelected, sideBarItemIdsSelected: sideBarItemIdsSelected, all: sideBarItemsListAll, waiting: sideBarItemsListWaiting, done: sideBarItemsListDone)
    }

    static func detailItems(sideBarTabSelected: SideBar.TabOption, sideBarItemIdsSelected: Set<UUID>, all: Array<Item>, waiting: Array<Item>, done: Array<Item>) -> Array<Item> {
        func onlySelected(_ items: Array<Item>) -> Array<Item> {
            items.filter({ sideBarItemIdsSelected.contains($0.ourIdS) })
        }

        switch sideBarTabSelected {
        case .all:
            return onlySelected(all)
        case .waiting:
            return onlySelected(waiting)
        case .done:
            return onlySelected(done)
        }
    }
}
