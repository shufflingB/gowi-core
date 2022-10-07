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

    var body: some Commands {
        menuCommandsFile
        menuCommandsItem
//        windowMenu
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

                Button("Fundo") {
                    guard let um = windowUM else {
                        return
                    }
                    print("Trigger")
                    um.undo()
                }
            }
        }
    }

    // MARK: Item menu

    var menuCommandsItem: some Commands {
        return CommandMenu("Items") {
            Section {
                Button("New Item") {
                    withAnimation {
                        _ = appModel.itemAddNewTo(externalUM: windowUM, parents: [appModel.systemRootItem], title: "New", priority: 0.0, complete: nil, notes: "", children: [])
                    }
                }
                .accessibilityIdentifier(AccessId.ItemsMenuNew.rawValue)
                .keyboardShortcut(KbShortcuts.itemsNew)
            }
        }
    }
}
