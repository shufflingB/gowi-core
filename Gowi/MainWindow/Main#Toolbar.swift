//
//  Toolbar.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import GowiAppModel

// The Main window's Toolbar menu builder
extension Main {
    @ToolbarContentBuilder func toolbar() -> some CustomizableToolbarContent {
        ToolbarItem(id: "tbar.new") {
            Button(action: {
                withAnimation {
                    let route = Main.itemAddNew(
                        appModel: appModel, windowUM: windowUM,
                        filterSelected: sideBarFilterSelected, parent: appModel.systemRootItem,
                        filteredChildren: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet, parent: appModel.systemRootItem)
                    )

                    sideBarFilterSelected = route.filterSelected
                    itemIdsSelected = route.itemIdsSelected
                }
            }) {
                Label("New Item", systemImage: "square.and.pencil")
            }

            .accessibilityIdentifier(AccessId.MainWindowToolbarCreateItemButton.rawValue)
            .font(.title2)
            .help("Create a new Item")
        }

        ToolbarItem(id: "tbar.cancel") {
            Button(action: {
                guard Self.modalUserConfirmsRevert() else {
                    return
                }
                withAnimation {
                    appModel.viewContext.rollback()
                }
            }) {
                Label("Cancel Changes", systemImage: appModel.hasUnPushedChanges ? "arrow.uturn.backward.square" : "arrow.uturn.backward.square")
                    .foregroundColor(appModel.hasUnPushedChanges ? Color.red : Color.gray)
            }

            .disabled(appModel.hasUnPushedChanges == false)
            .accessibilityIdentifier(appModel.hasUnPushedChanges ? AccessId.MainWindowToolbarRevertChangesPending.rawValue : AccessId.MainWindowToolbarRevertChangesNone.rawValue)
            .font(.title2)
            .help("Cancel changes and revert to last saved state")
        }

        ToolbarItem(id: "tbar.save") {
            Button(action: {
                withAnimation {
                    appModel.saveToBackend()
                }
            }) {
                Label("Save Changes", systemImage: appModel.hasUnPushedChanges ? "icloud.and.arrow.up.fill" : "checkmark.icloud")
                    .foregroundColor(appModel.hasUnPushedChanges ? .accentColor : Color.gray)
            }
            .accessibilityIdentifier(appModel.hasUnPushedChanges ? AccessId.MainWindowToolbarSaveChangesPending.rawValue : AccessId.MainWindowToolbarSaveChangesNone.rawValue)
            .disabled(appModel.hasUnPushedChanges == false)
            .font(.title2)
            .help("Save changes")
        }
        
        ToolbarItem(id: "tbar.debug") {
            Button(action: {
                appModel.debugPrintAllItems()
            }) {
                Label("Debug Print Items", systemImage: "ladybug")
            }
            .font(.title2)
            .help("Print all item data to console (for debugging)")
        }
    }
}
