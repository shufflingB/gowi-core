//
//  Main.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import os
import GowiAppModel

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/**
 ## Main Window StateView - MSV Architecture Root
 
 The Main struct serves as the primary "StateView" in the MSV (Model StateView View) architecture,
 coordinating between the centralized AppModel and pure stateless views. It manages window-level
 state, routing, and provides a consistent interface for all main window functionality.
 
 ### Architecture Responsibilities:
 - **State Coordination**: Manages window-specific state (selections, filters, search)
 - **Routing Integration**: Handles URL-based navigation and window management  
 - **Undo Integration**: Coordinates with SwiftUI's UndoManager for comprehensive undo/redo
 - **Intent Provision**: Provides business logic methods to child views as dependencies
 - **Multi-Window Support**: Each window instance maintains independent state
 
 ### File Organization:
 This file contains only the core StateView structure and initialization. Functionality is
 organized across extension files:
 
 - `Main#Model.swift`: Business logic intents and state management
 - `Main#ContentView.swift`: Content area view and model
 - `Main#SideBarView.swift`: Sidebar view and model  
 - `Main#DetailView.swift`: Detail panel view and model
 - `Main#WindowGroupRouteView.swift`: URL routing and window management
 - `Main#Toolbar.swift`: Window toolbar implementation
 
 ### SwiftUI Structure:
 Uses `NavigationSplitView` for the classic three-pane layout:
 - **Sidebar**: Filter lists (All, Waiting, Done)
 - **Content**: Item list with search capability
 - **Detail**: Selected item editor with rich formatting
 */
struct Main: View {
    /// App's `AppModel` shared instance
    @EnvironmentObject internal var appModel: AppModel

    /// Initialise the top-level View for creating the Main window's content
    /// - Parameters:
    ///   - root: Item from which all `Item`s rendered in this view are descendants of.
    ///   - route: binding to the route assigned to  the view  by `WindowGroup(id:for:content)`
    init(with root: Item, route: Binding<Main.WindowGroupRoutingOpt?>) {
        _itemsAllFromFetchRequest = AppModel.fetchRequestForChildrenOf(root)
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
            route: $windowGroupRoute,
            searchTextAll: $searchTextAll,
            searchTextDone: $searchTextDone,
            searchTextWaiting: $searchTextWaiting
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
                .toolbar(content: toolbar)
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
    
    /// Search text for filtering the All items list
    @SceneStorage("searchTextAll") internal var searchTextAll: String = ""
    
    /// Search text for filtering the Done items list  
    @SceneStorage("searchTextDone") internal var searchTextDone: String = ""
    
    /// Search text for filtering the Waiting items list
    @SceneStorage("searchTextWaiting") internal var searchTextWaiting: String = ""
    
    /// Current search text based on the selected sidebar filter
    internal var currentSearchText: Binding<String> {
        switch sideBarFilterSelected {
        case .all:
            return $searchTextAll
        case .done:
            return $searchTextDone
        case .waiting:
            return $searchTextWaiting
        }
    }

    @Environment(\.undoManager) internal var windowUM: UndoManager?
    @Environment(\.openWindow) internal var openWindow: OpenWindowAction

    /// Global count of how many times the Main`View` has been initialised inorder to enable deriving a unique Id for new windows.
    private static var instantiationCount: Int = 0

    /// Binding to the route assigned to  the view in `@main` by `WindowGroup(id:for:content)`
    @Binding private var windowGroupRoute: WindowGroupRoutingOpt?

    /// Unique window Id that is used during the  routing process for the window  to determine if opening a new window or tab is appropriate.
    @State private var winId: Int
}
