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

    static func sideBarOnMoveOfWaitingItems(_ items: Array<Item>, _ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) {
        AppModel.onMoveHighToLowPriority(items, sourceIndices, tgtIdxsEdge)
    }
}
