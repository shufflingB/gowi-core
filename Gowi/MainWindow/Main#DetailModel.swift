//
//  Main#DetailModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import GowiAppModel
/**
 ## Detail View Data Logic for Main Window
 
 Provides the data binding logic for the detail pane of the NavigationSplitView.
 The detail view shows comprehensive information for currently selected items.
 
 ### Current Implementation:
 Currently uses a simplified approach where detail items directly reflect
 the content selection. The commented code shows a previous more complex
 implementation that handled per-filter detail logic.
 
 ### Design Evolution:
 The simplified approach reduces complexity while maintaining the same
 user experience, demonstrating how architectural refactoring can improve
 maintainability without sacrificing functionality.
 */
extension Main {
    /// Array of items to display in the detail pane
    ///
    /// Returns the currently selected items from the content view for display
    /// in the detail pane. When multiple items are selected, the detail view
    /// uses a stacked visual effect to indicate multi-selection.
    internal var detailItems: Array<Item> {
        return contentItemsSelected
        // Previous implementation with per-filter detail logic:
        // return Self.detailItems(sideBarTabSelected: sideBarFilterSelected, sideBarItemIdsSelected: contentItemIdsSelected, all: contentItemsListAll, waiting: contentItemsListWaiting, done: contentItemsListDone)
    }

//    static func detailItems(sideBarTabSelected: SidebarFilterOpt, sideBarItemIdsSelected: Set<UUID>, all: Array<Item>, waiting: Array<Item>, done: Array<Item>) -> Array<Item> {
//        //
//        func onlySelected(_ items: Array<Item>) -> Array<Item> {
//            items.filter({ sideBarItemIdsSelected.contains($0.ourIdS) })
//        }
//
//        switch sideBarTabSelected {
//        case .all:
//            return onlySelected(all)
//        case .waiting:
//            return onlySelected(waiting)
//        case .done:
//            return onlySelected(done)
//        }
//    }
}
