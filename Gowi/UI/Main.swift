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

    static var instantiationCount: Int = 0
    @Binding var windowGroupRoute: WindowGroupRoutingOpt?
    @State var winId: Int
    
    init(with root: Item, route: Binding<Main.WindowGroupRoutingOpt?>) {
        _itemsAllFromFetchRequest = FetchRequest<Item>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "parentList CONTAINS %@", root as CVarArg)
        )
        _windowGroupRoute = route
        

        _winId = State(initialValue: Self.instantiationCount)
        Self.instantiationCount += 1
    }

    
    var body: some View {
        
        return WindowGroupRoute(
            winId: winId,
            sideBarFilterSelected: $sideBarFilterSelected,
            contentItemIdsSelected: $contentItemIdsSelected,
            route: $windowGroupRoute
        ) {
            NavigationSplitView(
                columnVisibility: $sideBarListIsVisible,
                sidebar: {
                    SideBar(stateView: self)
                }, content: {
                    Content(selections: $contentItemIdsSelected, items: contentItems, onMovePerform: contentOnMovePerform)
                }, detail: {
                    Text("Number selected = \(detailItems.count)")
                }
            )
            .navigationTitle("Window \(winId)")
        }


        .focusedValue(\.windowUndoManager, windowUM ?? UndoManager())
        .focusedValue(\.sideBarFilterSelected, $sideBarFilterSelected)
        .focusedValue(\.contentItemIdsSelected, $contentItemIdsSelected)
        .focusedValue(\.contentItemsSelected, contentItemsSelected)
        .focusedValue(\.contentItems, contentItems)
    }

    @FetchRequest internal var itemsAllFromFetchRequest: FetchedResults<Item>

    @State var sideBarListIsVisible: NavigationSplitViewVisibility = .detailOnly
    @SceneStorage("filter") internal var sideBarFilterSelected: SideBar.ListFilterOption = .waiting

    @SceneStorage("itemIdsSelected") var contentItemIdsSelected: Set<UUID> = []
//    @State internal var contentItemIdsSelected: Set<UUID> = []

    @Environment(\.undoManager) internal var windowUM: UndoManager?
    @Environment(\.openWindow) internal var openWindow
}
