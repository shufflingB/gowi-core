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
    let route: RoutingOpt?

    init(with root: Item, routing: RoutingOpt? = nil) {
        _itemsAllFromFetchRequest = FetchRequest<Item>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "parentList CONTAINS %@", root as CVarArg)
        )
        route = routing
    }

    var body: some View {
        Main.instanceId += 1
        return NavigationSplitView(columnVisibility: $sideBarListIsVisible, sidebar: {
            SideBar(stateView: self)
        }, content: {
            Content(selections: $contentItemIdsSelected, items: contentItems, onMovePerform: contentOnMovePerform)
        }, detail: {
            Text("Number selected = \(detailItems.count)")
        })
        .navigationTitle("Window \(Self.instanceId)")
        .onAppear {
            guard let route = route else {
                print("No routing for window = \(Self.instanceId) ")
                return
            }
            switch route {
            case let .showItems(_, filterSelected, contentItemIdsSelected):
                print("Is routing window = \(Self.instanceId) ")
                self.sideBarFilterSelected = filterSelected
                self.contentItemIdsSelected = contentItemIdsSelected
            }
        }
        .onOpenURL { url in
            print("URL = \(url)")
            // TODO : Coalesce routing with that in onAppear
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

    //    @SceneStorage("itemIdsSelected") var contentItemIdsSelected: Set<String> = []
    @State internal var contentItemIdsSelected: Set<UUID> = []

    @Environment(\.undoManager) internal var windowUM: UndoManager?
    @Environment(\.openWindow) internal var openWindow
}
