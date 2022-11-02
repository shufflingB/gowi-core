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
    @Binding var route: RoutingOpt?

    init(with root: Item, route: Binding<Main.RoutingOpt?>) {
        _itemsAllFromFetchRequest = FetchRequest<Item>(
            sortDescriptors: [],
            predicate: NSPredicate(format: "parentList CONTAINS %@", root as CVarArg)
        )
        _route = route
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
            case let .showItems(msgId, filterSelected, contentItemIdsSelected):
                print("Is routing window = \(Self.instanceId)  with msg Id = \(msgId)")
                self.sideBarFilterSelected = filterSelected
                self.contentItemIdsSelected = contentItemIdsSelected
            }
        }
        .onOpenURL { url in
            print("URL = \(url)")
            // TODO: Coalesce routing with that in onAppear
        }
        .onChange(of: contentItemIdsSelected, perform: { newValue in
            guard let route = route else {
                print("No route set for window so nothing to UPDATE = \(Self.instanceId) ")
                return
            }
            switch route {
            case let .showItems(msgId, filterSelected, _):
                print("Is UPDATING route for window = \(Self.instanceId)  with msg Id = \(msgId) because of seletction")
                $route.wrappedValue = .showItems(msgId: msgId, sideBarFilterSelected: filterSelected,
                                                 contentItemIdsSelected: newValue)
            }
        })
        .onChange(of: sideBarFilterSelected, perform: { newValue in
            guard let route = route else {
                print("No route set for window so nothing to UPDATE = \(Self.instanceId) ")
                return
            }
            switch route {
            case let .showItems(msgId, _, contentItemIdsSelected):
                print("Is UPDATING route for window = \(Self.instanceId)  with msg Id = \(msgId) because of filter")
                $route.wrappedValue = .showItems(msgId: msgId, sideBarFilterSelected: newValue,
                                                 contentItemIdsSelected: contentItemIdsSelected)
            }
        })

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
