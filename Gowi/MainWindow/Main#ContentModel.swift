//
//  Main#ContentModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import GowiAppModel

/**
 ## Content Area Data and Filtering Logic
 
 This extension provides the computed properties and filtering logic for the content area.
 It coordinates between sidebar filter selection, search text, and the underlying item data
 to produce the filtered list displayed in the UI.
 
 ### Filtering Architecture:
 - **Two-Stage Filtering**: First by completion status (sidebar), then by search text
 - **Per-Filter Search**: Each filter (All/Waiting/Done) maintains independent search state
 - **Real-Time Updates**: Automatic recalculation when any filter criteria changes
 - **Performance**: Efficient filtering with minimal recalculation using SwiftUI's dependency tracking
 */
extension Main {
    /// Computed list of items for display, combining sidebar and search filtering
    ///
    /// This property orchestrates the two-stage filtering process:
    /// 1. **Status Filtering**: Applies sidebar selection (All/Waiting/Done)
    /// 2. **Text Filtering**: Applies search text for the current filter
    ///
    /// The filtering is reactive - any change to sidebar selection or search text
    /// automatically triggers recalculation with smooth animations.
    internal var contentItems: Array<Item> {
        withAnimation {
            let baseItems: Array<Item>
            switch sideBarFilterSelected {
            case .waiting:
                baseItems = contentItemsListWaiting
            case .done:
                baseItems = contentItemsListDone
            case .all:
                baseItems = contentItemsListAll
            }
            
            // Apply search filtering based on current search text
            let searchText: String
            switch sideBarFilterSelected {
            case .all:
                searchText = searchTextAll
            case .done:
                searchText = searchTextDone
            case .waiting:
                searchText = searchTextWaiting
            }
            
            return Self.contentItemsFiltered(items: baseItems, searchText: searchText)
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
    
    /// Filters items based on search text, matching against the item's title
    /// - Parameters:
    ///   - items: The array of items to filter
    ///   - searchText: The search text to match against item titles
    /// - Returns: Filtered array of items that match the search text, preserving original sorting
    static func contentItemsFiltered(items: Array<Item>, searchText: String) -> Array<Item> {
        // If search text is empty, return all items
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return items
        }
        
        // Filter items whose title contains the search text (case-insensitive)
        return items.filter { item in
            item.titleS.localizedCaseInsensitiveContains(searchText)
        }
    }
}
