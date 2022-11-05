//
//  Main_Model.swift
//  Gowi
//
//  Created by Jonathan Hume on 07/10/2022.
//

import os
import SwiftUI

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension Main { // Window level intents
    // MARK: Item's

    internal var itemsAll: Set<Item> {
        Set(itemsAllFromFetchRequest)
    }

    static func itemAddNew(
        appModel: AppModel, windowUM: UndoManager?,
        tabSelected: SidebarFilterOpt,
        parent: Item, list items: Array<Item>
    ) -> (newItem: Item, tabSelected: SidebarFilterOpt, itemIdsSelected: Set<UUID>) {
        //
        let newItem = appModel.itemNewInsertInPriority(
            externalUM: windowUM,
            parent: parent, list: items, where: 0,
            title: "New Item", complete: nil, notes: "", children: []
        )

        let newTabSelected: SidebarFilterOpt = tabSelected == .done ? .waiting : tabSelected

        return (newItem: newItem, tabSelected: newTabSelected, itemIdsSelected: [newItem.ourIdS])
    }

    static func itemsDelete(
        appModel: AppModel, windoUM: UndoManager?,
        currentlyShowing: Array<Item>,  //<- Use this to determine where to shift the List highlighted selection to after deletion
        previousListSelectionsGoingDown: Bool,
        deleteItems: Array<Item>
    ) -> Set<UUID> {
        //
        // On deletion Apple places the selection on row above or below depending in what direction previous selections
        // have been going.
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

        appModel.itemsDelete(externalUM: windoUM, list: deleteItems)
        return newSelection
    }

    // MARK: Window control

    static func openNewTab(openWindow: OpenWindowAction, sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>) {
        let route = WindowGroupRoutingOpt.showItems(sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: contentItemIdsSelected)

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

    // MARK: NS functionallity
}