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

    static var instanceId: Int = 0
    
    init(with root: Item) {
        _itemsAllFromFetchRequest = FetchRequest<Item>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "parentList CONTAINS %@", root as CVarArg)
        )
    }

    var body: some View {
        Main.instanceId += 1
        
        return NavigationView {
            SideBar(stateView: self)
            Text("Number selected = \(detailItems.count)")
            
        }
        .navigationTitle("Window \(Self.instanceId)")
        .focusedValue(\.windowUndoManager, windowUM ?? UndoManager())
        .focusedValue(\.sideBarItemIdsSelected, $sideBarItemIdsSelected)
        .focusedValue(\.sideBarItemSelectedVisible, sideBarItemsSelectedVisible)
        .focusedValue(\.sideBarItemsVisible, sideBarItemsVisible)
        .focusedValue(\.sideBarTabSelected, $sideBarTabSelected)
    }

    //    @SceneStorage("selection051022") var sideBarItemSelections: Set<String> = []
    @State internal var sideBarItemIdsSelected: Set<UUID> = []
    @SceneStorage("tab051022") internal var sideBarTabSelected: SideBar.TabOption = .waiting

    @FetchRequest internal var itemsAllFromFetchRequest: FetchedResults<Item>
    @Environment(\.undoManager) internal var windowUM: UndoManager?
    
}
