//
//  Main_Model_Detail.swift
//  Gowi
//
//  Created by Jonathan Hume on 11/10/2022.
//

import Foundation

extension Main {
    internal var detailItems: Array<Item> {
        return Self.detailItems(sideBarTabSelected: sideBarFilterSelected, sideBarItemIdsSelected: contentItemIdsSelected, all: contentItemsListAll, waiting: contentItemsListWaiting, done: contentItemsListDone)
    }

    static func detailItems(sideBarTabSelected: SideBar.ListFilterOption, sideBarItemIdsSelected: Set<UUID>, all: Array<Item>, waiting: Array<Item>, done: Array<Item>) -> Array<Item> {
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