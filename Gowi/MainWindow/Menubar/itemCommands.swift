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
                    if let sideBarFilterSelected = sideBarFilterSelected,
                       let contentItemIdsSelected = contentItemIdsSelected {
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: windowUM,
                                tabSelected: sideBarFilterSelected.wrappedValue, parent: appModel.systemRootItem,
                                list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )

                            sideBarFilterSelected.wrappedValue = route.tabSelected
                            contentItemIdsSelected.wrappedValue = route.itemIdsSelected
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
                    guard let sideBarFilterSelected = sideBarFilterSelected, let contentItemIdsSelected = contentItemIdsSelected else { return }
                    Main.openNewTab(
                        openWindow: openWindow,
                        sideBarFilterSelected: sideBarFilterSelected.wrappedValue,
                        contentItemIdsSelected: contentItemIdsSelected.wrappedValue
                    )
                }
                .accessibilityIdentifier(AccessId.ItemsMenuOpenItemInNewTab.rawValue)
                .keyboardShortcut(KbShortcuts.itemsOpenInNewTab)

                Button("Open in New Window") {
                    guard let sideBarFilterSelected = sideBarFilterSelected, let contentItemIdsSelected = contentItemIdsSelected else {
                        return
                    }
                    let route = Main.WindowGroupRoutingOpt.showItems(
                        sideBarFilterSelected: sideBarFilterSelected.wrappedValue,
                        contentItemIdsSelected: contentItemIdsSelected.wrappedValue
                    )
                    openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
                }
                .accessibilityIdentifier(AccessId.ItemsMenuOpenItemInNewWindow.rawValue)
                .keyboardShortcut(KbShortcuts.itemsOpenInNewWindow)
            }

            Section {
                Button("Delete") {
                    withAnimation {
                        guard let contentItemsSelected = contentItemsSelected,
                              let contentItems = contentItems else {
                            return
                        }

                        contentItemIdsSelected?.wrappedValue = Main.itemsDelete(
                            appModel: appModel, windoUM: windowUM,
                            currentlyShowing: contentItems,
                            previousListSelectionsGoingDown: true,
                            deleteItems: contentItemsSelected
                        )
                    }
                }
                .disabled(contentItemsSelected == nil || contentItemsSelected?.count ?? 0 < 1)
                .accessibilityIdentifier(AccessId.ItemsMenuDeleteItems.rawValue)
                .keyboardShortcut(KbShortcuts.itemsDelete)
            }
        }
    }
}
