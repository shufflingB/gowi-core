//
//  Main#Model.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import os
import SwiftUI

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// The Main window's top-level Intents
extension Main {
    // MARK: Item's

    /// Undoably add a new `Item` to a `filteredChildren` list of child items from the `parent` and update what is shown iff to make it visible
    /// - Parameters:
    ///   - appModel: App's shared instance of the ``AppModel``
    ///   - windowUM: External `UndoManager` with which to register undo operations (usually SwiftUI's per-window instance)
    ///   - filterSelected: Currently visible filter selected
    ///   - parent: Item that should have the new Item added to its set of child `Item`
    ///   - filteredChildren: Filtered list of the parent's children, that at the top of which, the new `Item` is to be inserted.
    /// - Returns: The new `Item` and suggested updates to the filter and set of `Item`s being displayed such that the new `Item` would be made visible iff.
    static func itemAddNew(
        appModel: AppModel, windowUM: UndoManager?,
        filterSelected: SidebarFilterOpt,
        parent: Item, filteredChildren: Array<Item>
    ) -> (newItem: Item, filterSelected: SidebarFilterOpt, itemIdsSelected: Set<UUID>) {
        //
        let newItem = appModel.itemNewInsertInPriority(
            externalUM: windowUM,
            parent: parent, list: filteredChildren, where: 0,
            title: "", complete: nil, notes: "", children: []
        )

        let newTabSelected: SidebarFilterOpt = filterSelected == .done ? .waiting : filterSelected

        return (newItem: newItem, filterSelected: newTabSelected, itemIdsSelected: [newItem.ourIdS])
    }

    /// Undoably delete one or more `Item`s and update what is displayed.
    /// - Parameters:
    ///   - appModel: App's shared instance of the ``AppModel``
    ///   - windoUM: External `UndoManager` with which to register undo operations (usually SwiftUI's per-window instance)
    ///   - currentlyShowing: The list of `Item` currently visible to the user
    ///   - previousListSelectionsGoingDown: Used to determine where to move the selection after deletion completes. Down will put on the row beneath, up on the row above.
    ///   - deleteItems: Selection of `Item`s to delete.
    /// - Returns: The recommended updated selection set post deletion according to previous selection movements.
    static func itemsDelete(
        appModel: AppModel, windoUM: UndoManager?,
        currentlyShowing: Array<Item>,
        previousListSelectionsGoingDown: Bool, // 👈 Use this to determine where to shift the List highlighted selection to after deletion
        deleteItems: Array<Item>
    ) -> Set<UUID> {
        /*
         Most of the code in this intent about working out where to place the selection after the requested Items have been deleted.

         It's a bit involved bc we're attempting copy A's approach in their apps such as Mail. In those the new item selected post
         deletion depends on the direction the user was previously moving their item selections in. e.g. if they were to:
         1) Select the 1st row.
         2) Then the 2nd
         3) And then delete Item in the 2nd row.

         Then after the deletion the row that will normally be selected will be what was originally the 3rd row.

         While if they went in the opposit direction, say from 3rd to 2nd. And then deleted.  The 2nd, the 1st row would be selected.

         */
        guard let firstToDelete = deleteItems.first, let lastToDelete = deleteItems.last else {
            log.warning("\(#function) not deleting bc nothing passed to delete")
            return []
        }

        guard let firstToDeleteIdx = currentlyShowing.firstIndex(of: firstToDelete), let lastToDeleteIdx = currentlyShowing.firstIndex(of: lastToDelete) else {
            log.warning("\(#function) not deleting bc unable to find selection in what is showing")
            return []
        }

        let possPrecIdx = firstToDeleteIdx - 1
        let idxPrecedingFirst: Int? = currentlyShowing.indices.contains(possPrecIdx) ? possPrecIdx : nil

        let possTrailIdx = lastToDeleteIdx + 1
        let idxTrailingLast: Int? = currentlyShowing.indices.contains(possTrailIdx) ? possTrailIdx : nil

        let newSelection: Set<UUID> = {
            if previousListSelectionsGoingDown {
                if let idxTrailingLast = idxTrailingLast {
                    return [currentlyShowing[idxTrailingLast].ourIdS]
                } else if let idxPrecedingFirst = idxPrecedingFirst {
                    return [currentlyShowing[idxPrecedingFirst].ourIdS]
                } else {
                    return []
                }

            } else { // Going Up
                if let idxPrecedingFirst = idxPrecedingFirst {
                    return [currentlyShowing[idxPrecedingFirst].ourIdS]
                } else if let idxTrailingLast = idxTrailingLast {
                    return [currentlyShowing[idxTrailingLast].ourIdS]
                } else {
                    return []
                }
            }
        }()

        /*
         Actually call the appModel to remove the `Item`
         */

        appModel.itemsDelete(externalUM: windoUM, list: deleteItems)
        return newSelection
    }

    // MARK: Window control

    /// Opens  a tab on the an existing window
    /// - Parameters:
    ///   - openWindow: reference to SwiftUI's `@Environment(\.openWindow)` variable.
    ///   - sideBarFilterSelected: current filter selected
    ///   - contentItemIdsSelected: current list of `Item.ourId` selected in the content view.
    static func openNewTab(openWindow: OpenWindowAction, sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>) {
        //
        let route = WindowGroupRoutingOpt.showItems(openNewWindow: true, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: contentItemIdsSelected, searchText: nil)

        /*
         Opening a newTab is identical to opening a Window except if it gets added as a tab to the initial window that prevents it from
         being forked off into a stand-alone instance. From pov of the SwiftUI app and its state management, it's a separate Window and
         handling as such works identically.
         */
        if let intialWindow = NSApplication.shared.keyWindow {
            withAnimation {
                openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)

                guard let newWindow = NSApplication.shared.keyWindow, intialWindow != newWindow else {
                    return
                }
                intialWindow.addTabbedWindow(newWindow, ordered: .above)
            }
        }
    }
}
