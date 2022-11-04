//
//  Main_Model_Window.swift
//  Gowi
//
//  Created by Jonathan Hume on 11/10/2022.
//

import SwiftUI

extension Main { // Content specific Intents
    internal var contentItems: Array<Item> {
        withAnimation {
            switch sideBarFilterSelected {
            case .waiting:
                return contentItemsListWaiting
            case .done:
                return contentItemsListDone
            case .all:
                return contentItemsListAll
            }
        }
    }
    
    
    internal var contentItemsSelected: Array<Item> {
        contentItems.filter({contentItemIdsSelected.contains($0.ourIdS)})
    }

    internal var contentOnMovePerform: (IndexSet, Int) -> Void {
        switch sideBarFilterSelected {
        case .waiting:
            return withAnimation { contentOnMoveOfWaitingItems }
        case .done:
            /// Could use movement to adjust completion date but currently just do nothing
            return { _, _ in }
        case .all:
            /// Do nothing
            return { _, _ in }
        }
    }

    internal var contentItemsListWaiting: Array<Item> {
        Self.contentItemsListWaiting(itemsAll)
    }

    static func contentItemsListWaiting(_ items: Set<Item>) -> Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        items.filter({ $0.completed == nil }).sorted { $0.priority > $1.priority }
    }

    internal var contentItemsListDone: Array<Item> {
        Self.contentItemsListDone(itemsAll)
    }

    static func contentItemsListDone(_ items: Set<Item>) -> Array<Item> {
        // Want [0] to have the newest i.e largest completion date, [end] to have lowest
        // there should be any, but to keep compiler happy, set a very low sentinel value

        items.filter({ $0.completed != nil }).sorted { item1, item2 in
            let date1: Date = item1.completed!
            let date2: Date = item2.completed!
            return date1 > date2
        }
    }

    internal var contentItemsListAll: Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        Self.contentItemsListAll(itemsAll)
    }

    static func contentItemsListAll(_ items: Set<Item>) -> Array<Item> {
        // Same as for Waiting, Want  [0] to have largest priority value, [end] to have lowest
        items.sorted { $0.priority > $1.priority }
    }

    internal func contentOnMoveOfWaitingItems(_ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        appModel.reOrderUsingPriority(externalUM: windowUM, items: contentItemsListWaiting, sourceIndices: sourceIndices, tgtIdxsEdge: tgtIdxsEdge)
    }
}
