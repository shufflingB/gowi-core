//
//  ContentView.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import CoreData
import SwiftUI

struct Main: View {
    @EnvironmentObject internal var appModel: AppModel

    init(with root: Item) {
        _itemsAllFromFR = FetchRequest<Item>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "parentList CONTAINS %@", root as CVarArg)
        )
    }

    var body: some View {
        NavigationView {
            SideBar(stateView: self)
        }
        .focusedValue(\.windowUndoManager, windowUM ?? UndoManager())
        .focusedValue(\.sideBarItemIdsSelected, $sideBarItemIdsSelected)
        .focusedValue(\.sideBarTabSelected, $sideBarTabSelected)
    }

    //    @SceneStorage("selection051022") var sideBarItemSelections: Set<String> = []
    @State internal var sideBarItemIdsSelected: Set<UUID> = []
    @SceneStorage("tab051022") internal var sideBarTabSelected: SideBar.TabOption = .waiting

    @FetchRequest internal var itemsAllFromFR: FetchedResults<Item>
    @Environment(\.undoManager) internal var windowUM: UndoManager?
}
