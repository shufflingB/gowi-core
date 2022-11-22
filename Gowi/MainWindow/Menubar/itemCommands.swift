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

            Section {
//                Button("Nudge Waiting Priority Up") {
//                    withAnimation {
//                        guard let contentItemsSelected = contentItemsSelected,
//                              let contentItems = contentItems else {
//                            return
//                        }
//
//                    }
//                }
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
                .disabled(mainStateView?.contentItemsSelected == nil || mainStateView?.contentItemsSelected.count ?? 0 < 1)
                .accessibilityIdentifier(AccessId.ItemsMenuDeleteItems.rawValue)
                .keyboardShortcut(KbShortcuts.itemsDelete)
            }
        }
    }
}
