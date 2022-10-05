//
//  ContentView.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import CoreData
import SwiftUI

struct Main: View {
    @EnvironmentObject var appModel: AppModel
//    @SceneStorage("selection051022") var sideBarItemSelections: Set<String> = []
    @State var sideBarItemSelections: Set<UUID> = []
    @SceneStorage("tab051022") var sideBarTabSelected: SideBar.TabOption = .waiting

    var body: some View {
        NavigationView {
            SideBar(stateView: self)
        }
    }
}

extension Main {
    // MARK: SideBar

    internal var itemsAll: Set<Item> {
        appModel.systemRootItem.childrenListAsSet
    }

    internal var sideBarItemsListWaiting: Array<Item> {
        Self.sideBarItemsListWaiting(itemsAll)
    }

    static func sideBarItemsListWaiting(_ items: Set<Item>) -> Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        items.filter({ $0.completed == nil }).sorted { $0.priority > $1.priority }
    }

    internal var sideBarItemsListDone: Array<Item> {
        Self.sideBarItemsListDone(itemsAll)
    }

    static func sideBarItemsListDone(_ items: Set<Item>) -> Array<Item> {
        // Want [0] to have the newest i.e largest completion date, [end] to have lowest
        // there should be any, but to keep compiler happy, set a very low sentinel value

        items.filter({ $0.completed != nil }).sorted { item1, item2 in
            let date1: Date = item1.completed!
            let date2: Date = item2.completed!
            return date1 > date2
        }
    }

    internal var sideBarItemsListAll: Array<Item> {
        // Want  [0] to have largest priority value, [end] to have lowest
        Self.sideBarItemsListAll(itemsAll)
    }

    static func sideBarItemsListAll(_ items: Set<Item>) -> Array<Item> {
        // Same as for Waiting, Want  [0] to have largest priority value, [end] to have lowest
        items.sorted { $0.priority > $1.priority }
    }

    internal func sideBarOnMoveOfWaitingItems(_ items: Array<Item>, _ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        Self.sideBarOnMoveOfWaitingItems(items, sourceIndices, tgtIdxsEdge)
        appModel.objectWillChange.send()
    }

    private static let SideBarDefaultOffset = 100.0
    static func sideBarOnMoveOfWaitingItems(_ items: Array<Item>, _ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        // i.e. those sorted by Item priority
        /// just use what we've already worked out for the detail.
        /// E.g. for 3 item list
        ///
        /// --------------- tgtIdxEdge = 0
        /// sourceItem  0
        /// --------------- tgtIdxEdge = 1
        /// source Idx = 1
        /// -------------- tgtIdxEdge = 2
        /// source Idx =2
        /// -------------- tgtIdxEdge = 3

        guard let sourceIndicesFirstIdx = sourceIndices.first, let sourceIndicesLastIdx = sourceIndices.last else {
            return
        }

        let notMovingEdges = (sourceIndicesFirstIdx ... sourceIndicesLastIdx + 1)
        guard notMovingEdges.contains(tgtIdxsEdge) == false else {
            // print("Not moving because trying to move within the range of the existing items")
            return
        }

        let itemsSelected: Array<Item> = sourceIndices.map({ items[$0] })

        let movingUp: Bool = sourceIndicesFirstIdx > tgtIdxsEdge ? true : false
        // print("sourceIndixe.first =\(sourceIndicesFirstIdx),  last = \(sourceIndices.last!) tgtEdge = \(tgtIdxsEdge), Moving up \(movingUp)")

        let itemPriorityAboveTgtEdge = tgtIdxsEdge == 0
            ? items[0].priority + SideBarDefaultOffset ///  Then dragging to head of List, no Item above so have to special cars
            : items[tgtIdxsEdge - 1].priority

        let itemPriorityBelowTgtEdge = tgtIdxsEdge == items.count
            ? items[items.count - 1].priority - SideBarDefaultOffset /// Dragging to tail, no Item below so have to special case
            : items[tgtIdxsEdge].priority

        let priorityStepSize = (itemPriorityAboveTgtEdge - itemPriorityBelowTgtEdge) / Double(itemsSelected.count + 1)

        if movingUp {
            _ = itemsSelected
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nice animation
                    item.priority = itemPriorityBelowTgtEdge + priorityStepSize * Double(itemsSelected.count - idx)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        } else {
            _ = itemsSelected
                .reversed()
                .enumerated()
                .map { (idx: Int, item: Item) in /// map is preferred over forEach as it runs more quickly and produces a nice animation
                    item.priority = itemPriorityAboveTgtEdge - priorityStepSize * Double(itemsSelected.count - idx)
                    // print("Down Setting item \(item.id), idx = \(idx), to priority = \(item.priority) ")
                }
        }
    }
}
