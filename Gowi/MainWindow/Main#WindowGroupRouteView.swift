//
//  Main#WindowGroupRouteView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/**
 ## Window Routing and URL Handling for Main Window
 
 This file implements the sophisticated routing system that enables Main windows to:
 - Handle deep linking via custom gowi:// URLs
 - Support multi-window coordination and state management
 - Manage window creation, restoration, and tab grouping
 - Coordinate search state across different filter views
 
 ### Routing Architecture:
 The system uses a three-layer approach:
 1. **WindowGroupRoutingOpt**: Defines available routes and their parameters
 2. **WindowGroupRouteView**: Handles routing logic and URL processing
 3. **SwiftUI WindowGroup**: Manages window lifecycle and route coordination
 
 ### Key Features:
 - **Smart Window Management**: Reuses existing windows when possible
 - **URL Deep Linking**: Converts gowi:// URLs to internal routing
 - **Search State Persistence**: Maintains separate search text per filter
 - **Undo Integration**: Coordinates with UndoManager for reliable state
 */
extension Main {
    /// Defines the available routing options for Main windows
    ///
    /// This enum encapsulates all the ways a Main window can be configured,
    /// whether through internal navigation, URL deep linking, or new window creation.
    ///
    /// ### Route Types:
    /// - **showItems**: Display specific items with optional search filtering
    /// - **newItem**: Create a new item and show it in the window
    ///
    /// ### Window Creation Logic:
    /// When `openNewWindow` is false, the system will reuse existing windows that
    /// already display the requested route. When true, it always creates new windows.
    enum WindowGroupRoutingOpt: Hashable, Codable {
        /// Display items with specific filter and selection state
        /// - Parameters:
        ///   - openNewWindow: Force new window creation vs reusing existing
        ///   - sideBarFilterSelected: Which filter tab to show (All/Waiting/Done)
        ///   - contentItemIdsSelected: Set of item IDs to select
        ///   - searchText: Optional search text to apply to the filter
        case showItems(openNewWindow: Bool, sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>, searchText: String? = nil)
        
        /// Create a new item and display it
        /// - Parameter sideBarFilterSelected: Which filter to use for the new item
        case newItem(sideBarFilterSelected: SidebarFilterOpt)
    }

    /**
      Handles routing for the `Main` window.

      ## Dependencies

      1. `WindowGroup(id:for:content:)` view factory in `@main` must be used to inject routing options  into the view.
      2. `WindowGroup`s `content`  needs to  have `.handlesExternalEvents(preferring: allowing:)` specified to send all external events
      to the view (rather than forking off its own new windows (this view handles that itself if necessary)

      ## Overview of how routing in this app window works

      - `WindowGroup(id:for:content:)` view.
         - Routes URL handling matching the URLRoot to an instance of this window (which it will create iff necessary)
         - Creates and curates for the duration of the application, a set of routes to all windows of the type it handling
         - Handles request for new routes  for the window type, by examining if the route is current being rendered in and existing window or not.
             - If the route exists it will raise the window.
             - Otherwise, it will:
                 a. Create a new window.
                 b. Render the top-level view.
                 c. And passing a binding to the route that it asked the view to render.

     - `WindowGroupRoutingOpt` defines the available routes that this (Main)  window knows how to handle.

     - `WindowGroupRouteView`  handles routing and URL open requests
         - receives the binding to its `WindowGroup`routing information.
         - handles setting the window up as requested by any new routing informat.
         - keeps the binding to the `WindowGroup`routing information up to date with what is actually being displayed in the window.
         - handles turning open-by-URL requests into the correct app `WindowGroup` routing i.e. routing via URL and internal mechanisms endeavour to share a common code paths.
      */

    /// Main window routing coordinator that handles URL deep linking and window state management
    ///
    /// This view wraps the Main window content and provides sophisticated routing capabilities
    /// including URL handling, multi-window coordination, and state persistence.
    ///
    /// ### Lifecycle Event Handling:
    /// **onAppear**: Initial route processing for new windows or restored sessions
    /// **onChange(windowUM)**: Handles UndoManager-dependent operations like item creation
    /// **onOpenURL**: Processes gowi:// URLs and coordinates window raising/creation
    /// **onChange(state)**: Updates route binding when window state changes
    ///
    /// ### Multi-Window Coordination:
    /// The system intelligently decides whether to:
    /// - Route the current window to handle a request
    /// - Raise an existing window that already shows the requested content
    /// - Create a new window for the request
    ///
    /// ### UndoManager Dependency:
    /// Some operations (like creating new items) require the window's UndoManager.
    /// The system defers these operations until the UndoManager becomes available,
    /// using its availability as a signal that the window is fully initialized.
    struct WindowGroupRouteView<Content: View>: View {

        /// App's `AppModel` shared instance
        @EnvironmentObject var appModel: AppModel

        /// Handles all routing for Main window view.
        /// - Parameters:
        ///   - winId: unique id to associate with the route to this window.
        ///   - sideBarFilterSelected: currently selected filter
        ///   - visibleItemIdsSelected: the filtered for visibility set of selected `Item#ourId`s
        ///   - route: binding to the route assigned to  the view  by `WindowGroup(id:for:content)`
        ///   - searchTextAll: binding to search text for All items
        ///   - searchTextDone: binding to search text for Done items
        ///   - searchTextWaiting: binding to search text for Waiting items
        ///   - content: some View ...
        init(
            winId: Int,
            sideBarFilterSelected: Binding<SidebarFilterOpt>,
            visibleItemIdsSelected: Binding<Set<UUID>>,
            route: Binding<WindowGroupRoutingOpt?>,
            searchTextAll: Binding<String>,
            searchTextDone: Binding<String>,
            searchTextWaiting: Binding<String>,
            @ViewBuilder content: () -> Content
        ) {
            self.winId = winId
            _windowGroupRoute = route
            _sideBarFilterSelected = sideBarFilterSelected
            _visibleItemIdsSelected = visibleItemIdsSelected
            _searchTextAll = searchTextAll
            _searchTextDone = searchTextDone
            _searchTextWaiting = searchTextWaiting
            self.content = content()
        }

        /// Updates the window's UI state to match the specified route
        ///
        /// This method translates route parameters into actual UI state changes,
        /// including filter selection, item selection, and search text application.
        /// For newItem routes, it may create the item immediately or defer creation
        /// until the UndoManager becomes available.
        ///
        /// - Parameter route: The routing configuration to apply to this window
        private func routeWindow(_ route: WindowGroupRoutingOpt) {
            switch route {
            case let .showItems(openNewWindow: _, sideBarFilterSelected: filter, contentItemIdsSelected: items, searchText: searchText):
                sideBarFilterSelected = filter
                visibleItemIdsSelected = items
                
                // Apply search text if provided
                if let searchText = searchText {
                    setSearchText(searchText, for: filter)
                }

            case let .newItem(sideBarFilterSelected: filter):
                // For newItem routes, if we have an UndoManager available, create the item immediately
                // Otherwise, it will be handled in onChange(of: windowUM)
                // For newItem routes, create the item if UndoManager is available
                // Otherwise defer creation until UndoManager becomes available
                if let windowUM = windowUM {
                    log.debug("routeWindow: Creating new item immediately (UndoManager available)")
                    withAnimation {
                        let route = Main.itemAddNew(
                            appModel: appModel, windowUM: windowUM,
                            filterSelected: filter, parent: appModel.systemRootItem,
                            filteredChildren: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                        )
                        visibleItemIdsSelected = route.itemIdsSelected
                        sideBarFilterSelected = filter
                        // Convert to showItems route to allow repeat newItem requests
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: visibleItemIdsSelected)
                    }
                } else {
                    log.debug("routeWindow: UndoManager not available, will handle in onChange(of: windowUM)")
                    // Set filter now, item creation deferred
                    sideBarFilterSelected = filter
                }
            }
        }

        var body: some View {
            content
                .onAppear {
                    guard let route: WindowGroupRoutingOpt = windowGroupRoute else {
                        log.debug("onAppear: not invoking routeWindow")
                        return
                    }
                    log.debug("onAppear: invoking routeWindow")
                    routeWindow(route)
                }

                .onChange(of: windowUM) { newValue in
                    // UndoManager availability signals that the window is fully initialized
                    // and @State variables are ready for use. This is the right time to handle
                    // operations that were deferred during onAppear due to UndoManager dependency.

                    guard let windowUM = newValue else {
                        return
                    }

                    switch windowGroupRoute {
                    case let .newItem(sideBarFilterSelected: filter):
                        // Handle deferred item creation now that UndoManager is available
                        log.debug("onChange(of: windowUM): Creating a new Item and a route to it")
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: windowUM,
                                filterSelected: filter, parent: appModel.systemRootItem,
                                filteredChildren: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )
                            visibleItemIdsSelected = route.itemIdsSelected
                            sideBarFilterSelected = filter
                            // Convert to showItems route to enable repeat newItem operations
                            let currentSearchText = getCurrentSearchText(for: sideBarFilterSelected)
                            windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: visibleItemIdsSelected, searchText: currentSearchText)
                        }

                    default:
                        // Initialize default route for restored windows
                        log.debug("onChange(of: windowUM): Creating a default route")
                        let currentSearchText = getCurrentSearchText(for: sideBarFilterSelected)
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: visibleItemIdsSelected, searchText: currentSearchText)
                    }
                }
                .onOpenURL(perform: { url in
                    // Handle gowi:// URL deep linking (runs on key window)
                    log.debug("onOpenURL: winId = \(winId) is handling \(url)  ")

                    let defaultWinGrpRoute: WindowGroupRoutingOpt = .showItems(
                        openNewWindow: false,
                        sideBarFilterSelected: .waiting, contentItemIdsSelected: [], searchText: nil
                    )

                    let decodedWinGrpRoute: WindowGroupRoutingOpt = Main.urlDecode(url)
                        ?? {
                            log.warning("onOpenURL: Unable to fully decode URL, using default window route")
                            return defaultWinGrpRoute
                        }()

                    if windowGroupRoute == nil {
                        // No existing route: configure this window directly
                        log.debug("onOpenURL: Existing route not set for winId \(winId), updating the window contents directly")
                        routeWindow(decodedWinGrpRoute)
                        windowGroupRoute = decodedWinGrpRoute

                    } else {
                        // Existing route: use WindowGroup system to find/create appropriate window
                        log.debug("onOpenURL: Existing route defined for winId \(winId), using indirect routing to see if this window or any othercan handle or if app needs to open new window")

                        // Dispatch required to ensure window becomes key and raises properly
                        DispatchQueue.main.async {
                            openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: decodedWinGrpRoute)
                        }
                    }
                })
                .onChange(of: visibleItemIdsSelected, perform: { newValue in
                    // Update route when item selection changes
                    if let route = windowGroupRoute {
                        switch route {
                        case let .showItems(_, filterSelected, _, searchText):
                            // Update selection in existing showItems route
                            $windowGroupRoute.wrappedValue = .showItems(openNewWindow: false, sideBarFilterSelected: filterSelected,
                                                                        contentItemIdsSelected: newValue, searchText: searchText)
                        case .newItem(sideBarFilterSelected: _):
                            // newItem routes will be converted to showItems routes when processed
                            break
                        }

                    } else {
                        // Create initial route preserving current search state
                        let currentSearchText = getCurrentSearchText(for: sideBarFilterSelected)
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected,
                                                      contentItemIdsSelected: visibleItemIdsSelected, searchText: currentSearchText)
                    }
                })
                .onChange(of: sideBarFilterSelected, perform: { newValue in
                    // Update route when sidebar filter selection changes
                    if let route = windowGroupRoute {
                        switch route {
                        case let .showItems(_, _, contentItemIdsSelected, searchText):
                            // Update filter in existing showItems route
                            $windowGroupRoute.wrappedValue = .showItems(openNewWindow: false, sideBarFilterSelected: newValue,
                                                                        contentItemIdsSelected: contentItemIdsSelected, searchText: searchText)
                        case .newItem(sideBarFilterSelected: _):
                            // newItem routes will be converted to showItems routes when processed
                            break
                        }

                    } else {
                        // Create initial route preserving current search state
                        let currentSearchText = getCurrentSearchText(for: sideBarFilterSelected)
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected,
                                                      contentItemIdsSelected: visibleItemIdsSelected, searchText: currentSearchText)
                    }
                })
                // Update route when search text changes for any filter
                .onChange(of: searchTextAll) { newValue in
                    updateWindowRouteSearchText(for: .all, searchText: newValue)
                }
                .onChange(of: searchTextDone) { newValue in
                    updateWindowRouteSearchText(for: .done, searchText: newValue)
                }
                .onChange(of: searchTextWaiting) { newValue in
                    updateWindowRouteSearchText(for: .waiting, searchText: newValue)
                }
        }

        /// The sideBar filter being applied
        @Binding private var sideBarFilterSelected: SidebarFilterOpt

        /// The filtered for visibility set of selected `Item#ourId`s
        @Binding private var visibleItemIdsSelected: Set<UUID>

        /// Binding to the route assigned to  the view in `@main` by `WindowGroup(id:for:content)`
        @Binding private var windowGroupRoute: WindowGroupRoutingOpt?
        
        /// Binding to search text for All items
        @Binding private var searchTextAll: String
        
        /// Binding to search text for Done items
        @Binding private var searchTextDone: String
        
        /// Binding to search text for Waiting items
        @Binding private var searchTextWaiting: String

        @Environment(\.openWindow) private var openWindow

        /// SwiftUI's per-window instance default `UndoManager`
        @Environment(\.undoManager) private var windowUM: UndoManager?

        private let winId: Int
        private let content: Content
        
        /// Sets the search text for the specified filter type
        /// - Parameters:
        ///   - searchText: The search text to set
        ///   - filter: The filter type to update
        private func setSearchText(_ searchText: String, for filter: SidebarFilterOpt) {
            switch filter {
            case .all:
                searchTextAll = searchText
            case .done:
                searchTextDone = searchText
            case .waiting:
                searchTextWaiting = searchText
            }
        }
        
        /// Gets the current search text for the specified filter type
        /// - Parameter filter: The filter type to get search text for
        /// - Returns: Current search text for the filter, or nil if empty
        private func getCurrentSearchText(for filter: SidebarFilterOpt) -> String? {
            let searchText: String
            switch filter {
            case .all:
                searchText = searchTextAll
            case .done:
                searchText = searchTextDone
            case .waiting:
                searchText = searchTextWaiting
            }
            return searchText.isEmpty ? nil : searchText
        }
        
        /// Updates the window route when search text changes for the currently active filter
        ///
        /// This method ensures that route state stays synchronized with search text changes,
        /// but only updates the route when the changed search text corresponds to the
        /// currently active sidebar filter. This prevents unnecessary route updates when
        /// users have different search text for different filters.
        ///
        /// - Parameters:
        ///   - filter: The filter type that had its search text changed
        ///   - searchText: The new search text value
        private func updateWindowRouteSearchText(for filter: SidebarFilterOpt, searchText: String) {
            // Only update the route if this filter is currently active
            guard filter == sideBarFilterSelected else { return }
            
            // Update the route with the new search text, preserving other route parameters
            if let route = windowGroupRoute {
                switch route {
                case let .showItems(_, sideBarFilter, contentItemIdsSelected, _):
                    let newSearchText = searchText.isEmpty ? nil : searchText
                    windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilter,
                                                  contentItemIdsSelected: contentItemIdsSelected, searchText: newSearchText)
                case .newItem:
                    // newItem routes don't need search text updates
                    break
                }
            }
        }
    }
}
