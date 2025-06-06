//
//  Main.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import CoreData
import SwiftUI
import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/*
 Creates the app's Main window top-level structure, links in the `@SwiftUI` state  and defines the Intents for all component
 views used to render the window.

 In this file ...
 - How the Main window's functional structure is to be integrated i.e. routing and undo.
 - The top-level visible structural components, this case `NavigationSplitView`
 - Window level, `@SwiftUI` state injection into the window's. data model.

 Elsewhere in `extension` files named according to there view or model roles:
 - the sub-views that render the components
 - the model  __Intents__ functionallity for the top-level and sub-views.
 */

/// Creates the app's Main window top-level structure, links in the `@SwiftUI` state  and defines the Intents for all component views used to render the window.
struct Main: View {
    /// App's `AppModel` shared instance
    @EnvironmentObject internal var appModel: AppModel

    /// Initialise the top-level View for creating the Main window's content
    /// - Parameters:
    ///   - root: Item from which all `Item`s rendered in this view are descendants of.
    ///   - route: binding to the route assigned to  the view  by `WindowGroup(id:for:content)`
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
        let visibleContentItemIdsSelected: Binding<Set<UUID>> = Binding {
            Set(contentItemsSelected.map({ $0.ourIdS }))
        } set: { nv in
            log.debug("Selection binding called with: \(nv)")
            itemIdsSelected = nv
        }

        return WindowGroupRouteView(
            winId: winId,
            sideBarFilterSelected: $sideBarFilterSelected,
            visibleItemIdsSelected: visibleContentItemIdsSelected,
            route: $windowGroupRoute
        ) {
            WindowGroupUndoView {
                NavigationSplitView(
                    columnVisibility: $sideBarListIsVisible,
                    sidebar: {
                        SidebarView(stateView: self)
                    }, content: {
                        ContentView(stateView: self)
                    }, detail: {
                        DetailView(stateView: self)
                    }
                )
                .toolbar(id: "mainWindowToolBar", content: toolbar)
                .navigationTitle(Text(navigationTitleBlurb))
                .navigationSubtitle(Text(navigationSubtitleBlurb))
            }
        }
        .focusedValue(\.mainStateView, self)
    }

    /// What is displayed as window's the `navigationTitle`
    private var navigationTitleBlurb: String {
        "\(sideBarFilterSelected.rawValue) Items"
    }

    /// What is displayed as window's the `navigationSubTitle`
    private var navigationSubtitleBlurb: String {
        detailItems.first?.titleS ?? "Nothing Selected Yet"
    }

    /// Top-level CoreData request.
    @FetchRequest private var itemsAllFromFetchRequest: FetchedResults<Item>

    /// All of the first generation children of the `systemRoot` item
    internal var itemsAll: Set<Item> {
        Set(itemsAllFromFetchRequest)
    }

    /// Indicates to `NavigationSplitView` whether to display the Sidebar (and it's list of selectable filters)
    @State private var sideBarListIsVisible: NavigationSplitViewVisibility = .detailOnly

    /// Currently selected filter to apply to what is shown by Content view.
    @SceneStorage("filter") internal var sideBarFilterSelected: SidebarFilterOpt = .waiting

    /// The set of our `ourId` currently selected by any of the content lists. NB:  This may include id's from `Item`s that are not visible bc they
    /// are being filtered.
    // Why Set<UUID> used (instead of Set<Item>)? Bc it is tractable to add RawRepresentable for UUID to enable the use of @SceneStorage and thus allow the selection to be persisted across application restarts.
    @SceneStorage("itemIdsSelected") internal var itemIdsSelected: Set<UUID> = []

    @Environment(\.undoManager) internal var windowUM: UndoManager?
    @Environment(\.openWindow) internal var openWindow: OpenWindowAction

    /// Global count of how many times the Main`View` has been initialised inorder to enable deriving a unique Id for new windows.
    private static var instantiationCount: Int = 0

    /// Binding to the route assigned to  the view in `@main` by `WindowGroup(id:for:content)`
    @Binding private var windowGroupRoute: WindowGroupRoutingOpt?

    /// Unique window Id that is used during the  routing process for the window  to determine if opening a new window or tab is appropriate.
    @State private var winId: Int
}
