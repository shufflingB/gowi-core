//
//  Main#ContentModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

// The Main window's intents for its NavigationSplitView Content
extension Main {
    /// List of `Items` that the content should display
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

    /// List of `Items` that have been selected from the **visible** content list
    internal var contentItemsSelected: Array<Item> {
        contentItems.filter({ itemIdsSelected.contains($0.ourIdS) })
    }

    ///  The `onMove` method  to use  (depending on what filter is being used for the content list)
    // Currently can only rearrange the waiting list by priority. This open the door to
    // say rearranging lists by other criteria, such as perhaps changing completion dates
    // if wanted to use for the "done" list.
    internal var contentOnMovePerform: (IndexSet, Int) -> Void {
        switch sideBarFilterSelected {
        case .waiting:
            return withAnimation {
                contentOnMoveOfWaitingItems
            }
        case .done:
            /// Could use movement to adjust completion date but currently just do nothing
            return { _, _ in }
        case .all:
            /// Do nothing
            return { _, _ in }
        }
    }

    /// content list filtered for waiting `Item`s
    internal var contentItemsListWaiting: Array<Item> {
        Self.contentItemsListWaiting(itemsAll)
    }

    static func contentItemsListWaiting(_ items: Set<Item>) -> Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        items.filter({ $0.completed == nil }).sorted { $0.priority > $1.priority }
    }

    /// content list filtered for done `Item`s
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

    /// content list filtered for all `Item`s
    internal var contentItemsListAll: Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        Self.contentItemsListAll(itemsAll)
    }

    static func contentItemsListAll(_ items: Set<Item>) -> Array<Item> {
        // Same as for Waiting, Want  [0] to have largest priority value, [end] to have lowest
        items.sorted { $0.priority > $1.priority }
    }

    /// `onMove` function to use for rearranging the waiting items list
    private func contentOnMoveOfWaitingItems(_ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        withAnimation {
            appModel.rearrangeUsingPriority(externalUM: windowUM, items: contentItemsListWaiting, sourceIndices: sourceIndices, tgtEdgeIdx: tgtIdxsEdge)
        }
    }
}
