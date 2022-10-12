//
//  App+ContentViewCommands.swift
//  App+ContentViewCommands
//
//  Created by Jonathan Hume on 23/08/2021.
//

import AppKit
import os
import SwiftUI

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

struct Main_MenuBar: Commands {
    @ObservedObject var appModel: AppModel
    @Environment(\.openWindow) private var openWindow
    
    

//    let openItemsInNewWindow: (_ items: Array<Item>) -> Void
//    let openItemsInNewTab: (_ items: Array<Item>) -> Void

    ////        @FocusedValue(\.sidebarListSelectedKey) var listSelected: Binding<AppModel.RoutingOpts.ListSelected>?
    ////        @FocusedValue(\.itemsSelectedKey) var itemsSelected: Array<Item>?
    ////        @FocusedValue(\.itemsAllKey) var itemsAll: Array<Item>?
    ////        @FocusedValue(\.keyWindowNumberKey) var keyWindowNumber: Int?
    ////        @FocusedValue(\.keyWindowUndoManager) var keyWindowUndoManager: UndoManager?
    ////        @FocusedValue(\.mainVmKey) var mainVm: MainVM?
    ////        @FocusedValue(\.focusKey) var focus: FocusState<UIFocusable?>.Binding?
    ////        @FocusedValue(\.itemIdsSelectedKey) var itemIdsSelected: Binding<Set<UUID>>?

    @FocusedValue(\.windowUndoManager) var windowUM
    @FocusedValue(\.contentItemIdsSelected) var sideBarItemIdsSelected
    @FocusedValue(\.contentItemsSelected) var sideBarItemsSelectedVisible
    @FocusedValue(\.contentItems) var sideBarItemsVisible
    @FocusedValue(\.sideBarFilterSelected) var sideBarFilterSelected

    var body: some Commands {
        menuCommandsFile
        menuCommandsItem
        windowMenu
    }
}

extension Main_MenuBar {
    // MARK: File menu

    var menuCommandsFile: some Commands {
        CommandGroup(replacing: CommandGroupPlacement.newItem) {
            Section {
                Text("TODO: JSON import and export")
                Text("Moc has changes = \(appModel.hasUnPushedChanges.description)")
                Button("Save Changes") {
                    withAnimation {
                        appModel.saveToCoreData()
                    }
                }
                .accessibilityIdentifier(AccessId.FileMenuSave.rawValue)
                .keyboardShortcut(KbShortcuts.fileSaveChanges)

//                Button("Fundo") {
//                    guard let um = windowUM else {
//                        return
//                    }
//                    print("Trigger")
//                    um.undo()
//                }
            }
        }
    }

    // MARK: Item menu

    var menuCommandsItem: some Commands {
        return CommandMenu("Items") {
            Section {
                Button("New Item") {
                    withAnimation {
                        guard let sideBarFilterSelected = sideBarFilterSelected,
                                let sideBarItemIdsSelected = sideBarItemIdsSelected else {
                            return
                        }

                        let route = Main.itemAddNew(
                            appModel: appModel, windowUM: windowUM,
                            tabSelected: sideBarFilterSelected.wrappedValue, parent: appModel.systemRootItem,
                            list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                        )

                        sideBarFilterSelected.wrappedValue = route.tabSelected
                        sideBarItemIdsSelected.wrappedValue = route.itemIdsSelected
                    }
                }
                .disabled(sideBarFilterSelected == nil)
                .accessibilityIdentifier(AccessId.ItemsMenuNew.rawValue)
                .keyboardShortcut(KbShortcuts.itemsNew)
            }
            Section {
                
                
//                Button("Open in new Window") {
//                    guard let sideBarItemsSelectedVisible = sideBarItemsSelectedVisible,
//                          let sideBarItemsVisible = sideBarItemsVisible else {
//                        return
//                    }
//                    // TODO:
////                    Main.openNewWindow(openWindow: openWindow, items: sideBarItemsSelectedVisible)
//
////                    openWindow(
//
//                }
            }
            Section {
                Button("Delete") {
                    withAnimation {
                        guard let sideBarItemsSelectedVisible = sideBarItemsSelectedVisible,
                              let sideBarItemsVisible = sideBarItemsVisible else {
                            return
                        }

                        sideBarItemIdsSelected?.wrappedValue = Main.itemsDelete(
                            appModel: appModel, windoUM: windowUM,
                            sideBarShowingList: sideBarItemsVisible,
                            previousListSelectionsGoingDown: true,
                            deleteItems: sideBarItemsSelectedVisible
                        )
                    }
                }
                .disabled(sideBarItemsSelectedVisible == nil || sideBarItemsSelectedVisible?.count ?? 0 < 1)
                .accessibilityIdentifier(AccessId.ItemsMenuDeleteItems.rawValue)
                .keyboardShortcut(KbShortcuts.itemsDelete)
            }
        }
    }
    
    // MARK: Window
    var windowMenu: some Commands {
        CommandGroup(after: CommandGroupPlacement.windowSize) {
            Section {
                Button("New Tab") {
                    Main.openNewTab()
                }
                .accessibilityIdentifier(AccessId.WindowNewMainTab.rawValue)
                .keyboardShortcut(KbShortcuts.windowOpenTab)
                
                
                Button("New Window") {
                    Main.openNewWindow(openWindow: openWindow)
                }
                .accessibilityIdentifier(AccessId.WindowNewMain.rawValue)
                .keyboardShortcut(KbShortcuts.windowOpenNew)
            }
        }
    }
    
}
