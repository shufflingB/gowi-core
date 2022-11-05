//
//  Main_Toolbar.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 31/03/2022.
//

import SwiftUI

extension Main {
    @ToolbarContentBuilder func toolbar() -> some CustomizableToolbarContent {
        ToolbarItem(id: "tbar.new") {
            Button(action: {
                withAnimation {
                    let route = Main.itemAddNew(
                        appModel: appModel, windowUM: windowUM,
                        tabSelected: sideBarFilterSelected, parent: appModel.systemRootItem,
                        list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                    )

                    sideBarFilterSelected = route.tabSelected
                    contentItemIdsSelected = route.itemIdsSelected
                }
            }) {
                Label("New item", systemImage: "square.and.pencil")
            }
            
            .accessibilityIdentifier(AccessId.MainWindowToolbarCreateItemButton.rawValue)
            .font(.title2)
            .help("Create a new item")
        }

        ToolbarItem(id: "tbar.save") {
            Button(action: {
                withAnimation {
                    appModel.saveToCoreData()
                }
            }) {
                Label("Save Changes", systemImage: appModel.hasUnPushedChanges ? "icloud.and.arrow.up.fill" : "checkmark.icloud")
                    .foregroundColor(appModel.hasUnPushedChanges ? .accentColor : Color.gray)
            }
            .accessibilityIdentifier(appModel.hasUnPushedChanges ? AccessId.MainWindowToolbarSaveChangesPending.rawValue : AccessId.MainWindowToolbarSaveChangesNone.rawValue)
            .font(.title2)
            .help("Save changes")
        }

        ToolbarItem(id: "tbar.spacer") {
            Spacer()
        }

        ToolbarItem(id: "tbar.cancel") {
            Button(action: {
                showConfirmCancelLocalDialogue = true
            }) {
                Label("Cancel changes", systemImage: appModel.hasUnPushedChanges ? "arrow.uturn.backward.square" : "arrow.uturn.backward.square")
                    .foregroundColor(appModel.hasUnPushedChanges ? Color.red : Color.gray)
            }
            .disabled(appModel.hasUnPushedChanges == false)
            .accessibilityIdentifier(appModel.hasUnPushedChanges ? AccessId.MainWindowToolbarRevertChangesPending.rawValue : AccessId.MainWindowToolbarRevertChangesNone.rawValue)
            .font(.title2)
            .help("Cancel changes and revert to last saved state")
        }
    }
}
