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
        return NavigationSplitView(columnVisibility: $sideBarListIsVisible, sidebar: {
            SideBar(stateView: self)
        }, content: {
            Content(selections: $contentItemIdsSelected, items: contentItems, onMovePerform: contentOnMovePerform)
        }, detail: {
            Text("Number selected = \(detailItems.count)")
        })
        .navigationTitle("Window \(Self.instanceId)")
        .focusedValue(\.windowUndoManager, windowUM ?? UndoManager())
        
        .focusedValue(\.sideBarFilterSelected, $sideBarFilterSelected)
        
        .focusedValue(\.contentItemIdsSelected, $contentItemIdsSelected)
        .focusedValue(\.contentItemsSelected, contentItemsSelected)
        .focusedValue(\.contentItems, contentItems )
        
        
    }

    @FetchRequest internal var itemsAllFromFetchRequest: FetchedResults<Item>
    
    @State var sideBarListIsVisible: NavigationSplitViewVisibility = .all
    @SceneStorage("filter") internal var sideBarFilterSelected: SideBar.ListFilterOptions = .waiting
    
    //    @SceneStorage("itemIdsSelected") var contentItemIdsSelected: Set<String> = []
    @State internal var contentItemIdsSelected: Set<UUID> = []

    @Environment(\.undoManager) internal var windowUM: UndoManager?
    
}

