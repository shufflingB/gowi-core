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

    @FocusedValue(\.windowUndoManager) var windowUM
    @FocusedValue(\.contentItemIdsSelected) var contentItemIdsSelected
    @FocusedValue(\.contentItemsSelected) var contentItemsSelected

    @FocusedValue(\.contentItems) var contentItems
    @FocusedValue(\.sideBarFilterSelected) var sideBarFilterSelected

    var body: some Commands {
        menuCommandsFile
        menuCommandsItem
        menuCommandsWindow
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
                              let contentItemIdsSelected = contentItemIdsSelected else {
                            return
                        }

                        let route = Main.itemAddNew(
                            appModel: appModel, windowUM: windowUM,
                            tabSelected: sideBarFilterSelected.wrappedValue, parent: appModel.systemRootItem,
                            list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                        )

                        sideBarFilterSelected.wrappedValue = route.tabSelected
                        contentItemIdsSelected.wrappedValue = route.itemIdsSelected
                    }
                }
                .disabled(sideBarFilterSelected == nil)
                .accessibilityIdentifier(AccessId.ItemsMenuNewItem.rawValue)
                .keyboardShortcut(KbShortcuts.itemsNew)
            }

            Section {
                Button("Print URL to console") {
                    guard let sideBarFilterSelected = sideBarFilterSelected, let contentItemIdsSelected = contentItemIdsSelected else { return }
                    
                    _ = Main.urlEncode(.showItems(msgId: UUID(),
                                              sideBarFilterSelected: sideBarFilterSelected.wrappedValue, contentItemIdsSelected: contentItemIdsSelected.wrappedValue))
                    
                    
                }
                
                
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
                    guard let sideBarFilterSelected = sideBarFilterSelected, let contentItemIdsSelected = contentItemIdsSelected else { return }
                    Main.openNewWindow(
                        openWindow: openWindow,
                        sideBarFilterSelected: sideBarFilterSelected.wrappedValue,
                        contentItemIdsSelected: contentItemIdsSelected.wrappedValue
                    )
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
                            sideBarShowingList: contentItems,
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

    // MARK: Window

    var menuCommandsWindow: some Commands {
        CommandGroup(after: CommandGroupPlacement.windowSize) {
            Section {
  

                Button("New Window") {
                    Main.openNewWindow(openWindow: openWindow)
                }
                .accessibilityIdentifier(AccessId.WindowMenuNewMain.rawValue)
                .keyboardShortcut(KbShortcuts.windowOpenNew)
            }
        }
    }
}
