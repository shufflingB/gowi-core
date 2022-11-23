//
//  itemCommands.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/11/2022.
//

import SwiftUI

extension Menubar {
    var itemCommands: some Commands {
        return CommandMenu("Items") {
            Section {
                Button("New Item") {
                    if let sideBarFilterSelected = mainStateView?.sideBarFilterSelected {
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: mainStateView?.windowUM,
                                tabSelected: sideBarFilterSelected, parent: appModel.systemRootItem,
                                list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )

                            mainStateView?.sideBarFilterSelected = route.tabSelected
                            mainStateView?.contentItemIdsSelected = route.itemIdsSelected
                        }
                    } else {
                        let route = Main.WindowGroupRoutingOpt.newItem(sideBarFilterSelected: .waiting)
                        openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
                    }
                }
//                .disabled(sideBarFilterSelected == nil)
                .accessibilityIdentifier(AccessId.ItemsMenuNewItem.rawValue)
                .keyboardShortcut(KbShortcuts.itemsNew)
            }

            Section {
                Button("Open in New Tab") {
                    guard let sideBarFilterSelected = mainStateView?.sideBarFilterSelected, let contentItemIdsSelected = mainStateView?.contentItemIdsSelected else { return }
                    Main.openNewTab(
                        openWindow: openWindow,
                        sideBarFilterSelected: sideBarFilterSelected,
                        contentItemIdsSelected: contentItemIdsSelected
                    )
                }
                .accessibilityIdentifier(AccessId.ItemsMenuOpenItemInNewTab.rawValue)
                .keyboardShortcut(KbShortcuts.itemsOpenInNewTab)

                Button("Open in New Window") {
                    guard let sideBarFilterSelected = mainStateView?.sideBarFilterSelected, let contentItemIdsSelected = mainStateView?.contentItemIdsSelected else {
                        return
                    }
                    let route = Main.WindowGroupRoutingOpt.showItems(
                        sideBarFilterSelected: sideBarFilterSelected,
                        contentItemIdsSelected: contentItemIdsSelected
                    )
                    openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
                }
                .accessibilityIdentifier(AccessId.ItemsMenuOpenItemInNewWindow.rawValue)
                .keyboardShortcut(KbShortcuts.itemsOpenInNewWindow)
            }
            
            // MARK: Nudge Item priority Up & Down in Wait list Buttons
            do {
                /// --------------- tgtIdxEdge = 0
                /// sourceItem  0
                /// --------------- tgtIdxEdge = 1
                /// source Idx = 1
                /// -------------- tgtIdxEdge = 2
                /// source Idx =2
                /// -------------- tgtIdxEdge = 3
                
                let contentWaitingItems = mainStateView?.contentItemsListWaiting ?? []

                let sourceIndices: IndexSet = IndexSet(
                    mainStateView?.contentItemsSelected.compactMap { itemInSelection in
                        contentWaitingItems.firstIndex(where: { $0.ourId == itemInSelection.ourId })
                    } ?? [])

                let isDisabledBtnBase: Bool = mainStateView?.sideBarFilterSelected != .waiting || sourceIndices.count < 1
                let isDisabledUpButton: Bool = isDisabledBtnBase || sourceIndices.first ?? 0 <= 0
                let isDisabledDownButton: Bool = isDisabledBtnBase || sourceIndices.last ?? 0 >= contentWaitingItems.count - 1

                Section {
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
                            var tgtIdxsEdge: Int { idxInWaitingListNudgeAbove }

                            print("Nudge up Idxs = \(Array(sourceIndices)), to tgtIdxsEdge. \(tgtIdxsEdge). Total items = \(contentWaitingItems.count)")
                            withAnimation {
                                appModel.reOrderUsingPriority(
                                    externalUM: mainStateView?.windowUM, items: contentWaitingItems, sourceIndices: sourceIndices, tgtIdxsEdge: tgtIdxsEdge)
                            }
                        }
                    }
                    .accessibilityIdentifier(AccessId.ItemsMenuNudgePriorityUp.rawValue)
                    .disabled(isDisabledUpButton)
                    .keyboardShortcut(KbShortcuts.itemsSelectedNudgePriorityUp)
                    
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
                            var tgtIdxsEdge: Int { idxInWaitingListNudgeBelow + 1 }

                            print("Nudge down Idxs = \(Array(sourceIndices)), to tgtIdxsEdge. \(tgtIdxsEdge). Total items = \(contentWaitingItems.count)")
                            withAnimation {
                                appModel.reOrderUsingPriority(
                                    externalUM: mainStateView?.windowUM, items: contentWaitingItems, sourceIndices: sourceIndices, tgtIdxsEdge: tgtIdxsEdge)
                            }
                        }
                    }
                    .accessibilityIdentifier(AccessId.ItemsMenuNudgePriorityUp.rawValue)
                    .disabled(isDisabledDownButton)
                    .keyboardShortcut(KbShortcuts.itemsSelectedNudgePriorityDown)
                }

                // MARK: Delete Items button
                do {
                    let isDisabledBtn: Bool = mainStateView?.contentItemsSelected == nil || mainStateView?.contentItemsSelected.count ?? 0 < 1

                    Button("Delete") {
                        withAnimation {
                            guard let contentItemsSelected = mainStateView?.contentItemsSelected,
                                  let contentItems = mainStateView?.contentItems else {
                                return
                            }

                            mainStateView?.contentItemIdsSelected = Main.itemsDelete(
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
