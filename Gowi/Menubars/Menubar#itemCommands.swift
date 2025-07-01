//
//  itemCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

/**
 ## Items Menu Commands
 
 Implements the Items menu for todo item management, providing comprehensive
 operations for creating, organizing, and manipulating todo items. The menu
 intelligently adapts based on current window state and selection.
 
 ### Menu Categories:
 - **Creation**: New item creation with smart window management
 - **Navigation**: Opening items in new windows/tabs
 - **Priority Management**: Nudging item priorities up/down in waiting list
 - **Deletion**: Safe item deletion with selection management
 
 ### Smart Window Coordination:
 Commands adapt behavior based on whether a Main window is currently focused:
 - **With Window**: Updates existing window state directly
 - **Without Window**: Creates new windows with appropriate routing
 
 ### Priority Management:
 The priority nudging system only operates on items in the "Waiting" filter,
 following the design principle that priority is most relevant for incomplete tasks.
 Complex index calculations ensure proper positioning after reordering operations.
 
 ### Selection Intelligence:
 Delete and priority operations work with current selection state, providing
 visual feedback through button enable/disable states based on context.
 */
extension Menubar {
    /// Builds the Items menu for comprehensive todo item management
    var itemCommands: some Commands {
        return CommandMenu("Items") {
            Section {
                // Create new item with intelligent window management
                Button("New Item") {
                    if let sideBarFilterSelected = mainStateView?.sideBarFilterSelected {
                        // Update existing focused window to show new item
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: mainStateView?.windowUM,
                                filterSelected: sideBarFilterSelected, parent: appModel.systemRootItem,
                                filteredChildren: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )

                            mainStateView?.sideBarFilterSelected = route.filterSelected
                            mainStateView?.itemIdsSelected = route.itemIdsSelected
                        }
                    } else {
                        // No focused window: create new window with newItem route
                        let route = Main.WindowGroupRoutingOpt.newItem(sideBarFilterSelected: .waiting)
                        openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
                    }
                }
                .accessibilityIdentifier(AccessId.ItemsMenuNewItem.rawValue)
                .keyboardShortcut(KbShortcuts.itemsNew)
            }

            Section {
                // Open selected items in new tab (grouped with current window)
                Button("Open in New Tab") {
                    guard let sideBarFilterSelected = mainStateView?.sideBarFilterSelected, 
                          let contentItemIdsSelected = mainStateView?.itemIdsSelected else { return }
                    Main.openNewTab(
                        openWindow: openWindow,
                        sideBarFilterSelected: sideBarFilterSelected,
                        contentItemIdsSelected: contentItemIdsSelected
                    )
                }
                .accessibilityIdentifier(AccessId.ItemsMenuOpenItemInNewTab.rawValue)
                .keyboardShortcut(KbShortcuts.itemsOpenInNewTab)

                // Open selected items in standalone new window
                Button("Open in New Window") {
                    guard let sideBarFilterSelected = mainStateView?.sideBarFilterSelected, 
                          let contentItemIdsSelected = mainStateView?.itemIdsSelected else {
                        return
                    }
                    let route = Main.WindowGroupRoutingOpt.showItems(
                        openNewWindow: true,
                        sideBarFilterSelected: sideBarFilterSelected,
                        contentItemIdsSelected: contentItemIdsSelected
                    )
                    openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
                }
                .accessibilityIdentifier(AccessId.ItemsMenuOpenItemInNewWindow.rawValue)
                .keyboardShortcut(KbShortcuts.itemsOpenInNewWindow)
            }

            // MARK: Priority Management for Waiting Items
            
            do {
                // Priority nudging only works on items in the "Waiting" filter
                // Priority determines display order: higher priority = higher in list
                
                /// Visual representation of target edge calculation:
                /// --------------- tgtIdxEdge = 0
                /// sourceItem  0   (highest priority)
                /// --------------- tgtIdxEdge = 1  
                /// source Idx = 1
                /// -------------- tgtIdxEdge = 2
                /// source Idx = 2  (lowest priority)
                /// -------------- tgtIdxEdge = 3

                let contentWaitingItems = mainStateView?.contentItemsListWaiting ?? []

                // Map selected items to their indices in the waiting list
                let sourceIndices: IndexSet = IndexSet(
                    mainStateView?.contentItemsSelected.compactMap { itemInSelection in
                        contentWaitingItems.firstIndex(where: { $0.ourId == itemInSelection.ourId })
                    } ?? [])

                // Button enable/disable logic based on context and boundary conditions
                let isDisabledBtnBase: Bool = mainStateView?.sideBarFilterSelected != .waiting || sourceIndices.count < 1
                let isDisabledUpButton: Bool = isDisabledBtnBase || sourceIndices.first ?? 0 <= 0
                let isDisabledDownButton: Bool = isDisabledBtnBase || sourceIndices.last ?? 0 >= contentWaitingItems.count - 1

                Section {
                    // Increase priority (move up in list)
                    Button("Nudge Waiting Item Priority Up") {
                        withAnimation {
                            guard
                                let idxInSelectionWithHighestPriority: Int = sourceIndices.first,
                                let idxInWaitingListNudgeAbove =
                                idxInSelectionWithHighestPriority - 1 >= 0
                                    ? idxInSelectionWithHighestPriority - 1
                                    : nil
                            else {
                                return
                            }
                            // Target edge is the position above the item to nudge above
                            var tgtIdxsEdge: Int { idxInWaitingListNudgeAbove }

                            withAnimation {
                                appModel.rearrangeUsingPriority(
                                    externalUM: mainStateView?.windowUM, 
                                    items: contentWaitingItems, 
                                    sourceIndices: sourceIndices, 
                                    tgtEdgeIdx: tgtIdxsEdge)
                            }
                        }
                    }
                    .accessibilityIdentifier(AccessId.ItemsMenuNudgePriorityUp.rawValue)
                    .disabled(isDisabledUpButton)
                    .keyboardShortcut(KbShortcuts.itemsSelectedNudgePriorityUp)

                    // Decrease priority (move down in list)
                    Button("Nudge Waiting Item Priority Down") {
                        withAnimation {
                            guard
                                let idxInSelectionWithLowestPriority: Int = sourceIndices.last,
                                let idxInWaitingListNudgeBelow =
                                idxInSelectionWithLowestPriority + 1 <= contentWaitingItems.count - 1
                                    ? idxInSelectionWithLowestPriority + 1
                                    : nil
                            else {
                                return
                            }
                            // Target edge is one position below the item to nudge below
                            var tgtIdxsEdge: Int { idxInWaitingListNudgeBelow + 1 }

                            withAnimation {
                                appModel.rearrangeUsingPriority(
                                    externalUM: mainStateView?.windowUM, 
                                    items: contentWaitingItems, 
                                    sourceIndices: sourceIndices, 
                                    tgtEdgeIdx: tgtIdxsEdge)
                            }
                        }
                    }
                    .accessibilityIdentifier(AccessId.ItemsMenuNudgePriorityUp.rawValue)
                    .disabled(isDisabledDownButton)
                    .keyboardShortcut(KbShortcuts.itemsSelectedNudgePriorityDown)
                }

                // MARK: Item Deletion

                do {
                    // Only enable delete when items are selected
                    let isDisabledBtn: Bool = mainStateView?.contentItemsSelected == nil || 
                                              mainStateView?.contentItemsSelected.count ?? 0 < 1

                    Button("Delete") {
                        withAnimation {
                            guard let contentItemsSelected = mainStateView?.contentItemsSelected,
                                  let contentItems = mainStateView?.contentItems else {
                                return
                            }

                            // Delete items and update selection to follow Apple's selection conventions
                            mainStateView?.itemIdsSelected = Main.itemsDelete(
                                appModel: appModel, windoUM: mainStateView?.windowUM,
                                currentlyShowing: contentItems,
                                previousListSelectionsGoingDown: true,
                                deleteItems: contentItemsSelected
                            )
                        }
                    }
                    .disabled(isDisabledBtn)
                    .accessibilityIdentifier(AccessId.ItemsMenuDeleteItems.rawValue)
                    .keyboardShortcut(KbShortcuts.itemsDelete)
                }
            }
        }
    }
}
