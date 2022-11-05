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

    enum WindowGroupRoutingOpt: Hashable, Codable {
        case showItems(sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>)
    }

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
        return WindowGroupRouteView(
            winId: winId,
            sideBarFilterSelected: $sideBarFilterSelected,
            contentItemIdsSelected: $contentItemIdsSelected,
            route: $windowGroupRoute
        ) {
            NavigationSplitView(
                columnVisibility: $sideBarListIsVisible,
                sidebar: {
                    Sidebar(stateView: self)
                }, content: {
                    Content(selections: $contentItemIdsSelected, items: contentItems, onMovePerform: contentOnMovePerform)
                }, detail: {
                    Detail(stateView: self)
                }
            )
            .navigationTitle("Window \(winId)")
            .toolbar(id: "mainWindowToolBar", content: toolbar)
            .confirmationDialog(Text("Revert cancels all unsaved changes?") + Text("(is not undoable)"), isPresented: $showConfirmCancelLocalDialogue) {
                Button("Revert", role: .destructive) {
                    withAnimation {
                        showConfirmCancelLocalDialogue = false
                        appModel.viewContext.rollback()
                    }
                }
            }
        }

        .focusedValue(\.windowUndoManager, windowUM ?? UndoManager())
        .focusedValue(\.sideBarFilterSelected, $sideBarFilterSelected)
        .focusedValue(\.contentItemIdsSelected, $contentItemIdsSelected)
        .focusedValue(\.contentItemsSelected, contentItemsSelected)
        .focusedValue(\.contentItems, contentItems)
        .focusedValue(\.showConfirmCancelLocalDialogue, $showConfirmCancelLocalDialogue)
    }

    @FetchRequest internal var itemsAllFromFetchRequest: FetchedResults<Item>

    @State var sideBarListIsVisible: NavigationSplitViewVisibility = .detailOnly
    @SceneStorage("filter") internal var sideBarFilterSelected: SidebarFilterOpt = .waiting

    @SceneStorage("itemIdsSelected") var contentItemIdsSelected: Set<UUID> = []
//    @State internal var contentItemIdsSelected: Set<UUID> = []

    @Environment(\.undoManager) internal var windowUM: UndoManager?
    @Environment(\.openWindow) internal var openWindow

    private static var instantiationCount: Int = 0
    @Binding private var windowGroupRoute: WindowGroupRoutingOpt?
    @State private var winId: Int
    @State internal var showConfirmCancelLocalDialogue: Bool = false
}
