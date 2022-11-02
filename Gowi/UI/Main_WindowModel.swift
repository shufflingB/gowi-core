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
        tabSelected: SideBar.ListFilterOption,
        parent: Item, list items: Array<Item>
    ) -> (newItem: Item, tabSelected: SideBar.ListFilterOption, itemIdsSelected: Set<UUID>) {
        //
        let newItem = appModel.itemNewInsertInPriority(
            externalUM: windowUM,
            parent: parent, list: items, where: 0,
            title: "New Item", complete: nil, notes: "", children: []
        )

        let newTabSelected: SideBar.ListFilterOption = tabSelected == .done ? .waiting : tabSelected

        return (newItem: newItem, tabSelected: newTabSelected, itemIdsSelected: [newItem.ourIdS])
    }

    static func itemsDelete(
        appModel: AppModel, windoUM: UndoManager?,
        sideBarShowingList: Array<Item>,
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

        guard let firstToDeleteIdx = sideBarShowingList.firstIndex(of: firstToDelete), let lastToDeleteIdx = sideBarShowingList.firstIndex(of: lastToDelete) else {
            log.warning("\(#function) not deleting bc unable to find selection in what is showing")
            return []
        }

        let possPrecIdx = firstToDeleteIdx - 1
        let idxPrecedingFirst: Int? = sideBarShowingList.indices.contains(possPrecIdx) ? possPrecIdx : nil

        let possTrailIdx = lastToDeleteIdx + 1
        let idxTrailingLast: Int? = sideBarShowingList.indices.contains(possTrailIdx) ? possTrailIdx : nil

        let newSelection: Set<UUID> = {
            if previousListSelectionsGoingDown {
                if let idxTrailingLast = idxTrailingLast {
                    return [sideBarShowingList[idxTrailingLast].ourIdS]
                } else if let idxPrecedingFirst = idxPrecedingFirst {
                    return [sideBarShowingList[idxPrecedingFirst].ourIdS]
                } else {
                    return []
                }

            } else { // Going Up
                if let idxPrecedingFirst = idxPrecedingFirst {
                    return [sideBarShowingList[idxPrecedingFirst].ourIdS]
                } else if let idxTrailingLast = idxTrailingLast {
                    return [sideBarShowingList[idxTrailingLast].ourIdS]
                } else {
                    return []
                }
            }
        }()

        appModel.itemsDelete(externalUM: windoUM, list: deleteItems)
        return newSelection
    }

    // MARK: Window control

    /// When WindowGroup receives a Routing Option for which it has previously rendered a view  it will raise that instance instead of creating a new one [0]. It's understanding of same
    /// as id.new == id.previous, value.new ==  value.previous. QED to allow the same route message to create and raise existing windows; have to a field that allows unique'ification
    /// for raisg and a special value always gets used when we juse want to raise if possible.  That's what msgId: and MsgIdToUseSameWindowIfPossible are about respectively

    /// [0] It's actually more clever than just the fire and forget we're using here;  the route information that  it creates can be bound to the values in the view so that it can track what is currently being displayed.

    static func openNewWindow(openWindow: OpenWindowAction, sideBarFilterSelected: SideBar.ListFilterOption, contentItemIdsSelected: Set<UUID>) {
        let route = WindowGroupRoutingOpt.showItems(sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: contentItemIdsSelected)

        openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
    }

    static func openNewWindow(openWindow: OpenWindowAction) {
        openWindow(id: GowiApp.WindowGroupId.Main.rawValue)
    }

    static func openNewTab(openWindow: OpenWindowAction, sideBarFilterSelected: SideBar.ListFilterOption, contentItemIdsSelected: Set<UUID>) {
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
}
