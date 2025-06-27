//
//  Main#WindowGroupRouteView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// Routing for the Main Window
extension Main {
    /**
     Defines the routes that the Main window supports

     Options available:
        1. `showItem(openNewWindow:sideBarFilterSelected: contentItemIdsSelected)`:  A route to a window that displays the `Item` specified.
            If `openNewWindow` is
                1. `false` -  it will only create a new window if there no existing app windows visibly rendering the route requested.
                2. `true` - it will always open a new window, regardless of if any existing window is displaying the route in the app.
        2. `newItem(sideBarFilterSelected: SidebarFilterOpt)` -  a new empty Item  in a new Window.
     */
    enum WindowGroupRoutingOpt: Hashable, Codable {
        case showItems(openNewWindow: Bool, sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>)
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

    struct WindowGroupRouteView<Content: View>: View {
        /*
         ## What each of the content modifiers are used to handle

          - `onAppear`
            - Is the first thing that runs for the `View`
            - If the View has been:
                - Instantiated by the `WindowGroup` mechanism, say as the result of `openWindow`  or via the homebrewed `openTab` mechanism then the `View` will
                have been passed a route for the Window AND it  updates the contents of the Window to be in alignment with that route. NB: Does not handle new window
                routing requests, bc there is no access to the Window's `UndoManager` when `onAppear`runs (see next comment for more on that).
            - Created via the Window restore mechanism, say as a result on being started and has picked up its initial settings from `@SceneStorage` then it will have a default  route
            assigned to it that does not reflect the windows actual route state. And in that case we do nothing here and instead create an updated route for the window when the `@State` vars
            become available for use, as signalled to the app  through the conveniece proxy of detecting `onChange(of: SwiftUIsWindowUndoManager)`

         - `onChange(of: windowUM)`
            - Gets run after `onAppear` when the window's `UndoManager` has been setup and is injected into the `View`
            - Used to handle:
                1. New item routing requests  that can't be done  in the onAppear handler because the `UndoManager` is not available.
                2. Setting up the route for any window that has been restored on restart.

         - `onOpenURL`
            - Only gets run on one of the app's Windows (keyWindow?) to handle a URL request.
            - Handles decoding the routing information from the URL or if that fails sets up a sensible default
            - Then:
                - If there is no route configured for the current window; it will directly route the window itself.
                - Else, it will use openWindow to either raise a different existing  window  from the app that contains the desired route.  Or create a new one if no existing window
                in the app matches the route requested.

         - Other onChange(of:) ...
            Used to update individual attributes of the `WindowGroup`'s  route up to date.
         */

        /// App's `AppModel` shared instance
        @EnvironmentObject var appModel: AppModel

        /// Handles all routing for Main window view.
        /// - Parameters:
        ///   - winId: unique id to associate with the route to this window.
        ///   - sideBarFilterSelected: currently selected filter
        ///   - visibleItemIdsSelected: the filtered for visibility set of selected `Item#ourId`s
        ///   - route: binding to the route assigned to  the view  by `WindowGroup(id:for:content)`
        ///   - content: some View ...
        init(
            winId: Int,
            sideBarFilterSelected: Binding<SidebarFilterOpt>,
            visibleItemIdsSelected: Binding<Set<UUID>>,
            route: Binding<WindowGroupRoutingOpt?>,
            @ViewBuilder content: () -> Content
        ) {
            self.winId = winId
            _windowGroupRoute = route
            _sideBarFilterSelected = sideBarFilterSelected
            _visibleItemIdsSelected = visibleItemIdsSelected
            self.content = content()
        }

        /// Update the view to be in alignment with the suppliedrouting options.
        /// - Parameter route: routing options to update the view with.
        private func routeWindow(_ route: WindowGroupRoutingOpt) {
            switch route {
            case let .showItems(openNewWindow: _, sideBarFilterSelected: filter, contentItemIdsSelected: items):
                sideBarFilterSelected = filter
                visibleItemIdsSelected = items

            case let .newItem(sideBarFilterSelected: filter):
                // For newItem routes, if we have an UndoManager available, create the item immediately
                // Otherwise, it will be handled in onChange(of: windowUM)
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
                        // Update the route so that the newItem route can be triggered again if required.
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: visibleItemIdsSelected)
                    }
                } else {
                    log.debug("routeWindow: UndoManager not available, will handle in onChange(of: windowUM)")
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
                    // Has nothing really to do with windowUM per-se, but detecting when SWiftUI defines it is a convenient place
                    // to detect when both the View has appeared AND the SwiftUI @State has been injected and is ready
                    // for processings. And since we new need the window's `UndoManager` we'll use that point.

                    guard let windowUM = newValue else {
                        return
                    }

                    switch windowGroupRoute {
                    case let .newItem(sideBarFilterSelected: filter):
                        log.debug("onChange(of: windowUM): Creating a new Item and a route to it")
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: windowUM,
                                filterSelected: filter, parent: appModel.systemRootItem,
                                filteredChildren: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )
                            visibleItemIdsSelected = route.itemIdsSelected
                            sideBarFilterSelected = filter
                            // Update the route so that the newItem route can be triggered again if required.
                            windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: visibleItemIdsSelected)
                        }

                    default:
                        log.debug("onChange(of: windowUM): Creating a default route")
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: visibleItemIdsSelected)
                    }
                }
                .onOpenURL(perform: { url in
                    // Decode the URL into a RoutingOpt (only runs on the keyWindow and the @Main's setup )
                    log.debug("onOpenURL: winId = \(winId) is handling \(url)  ")

                    let defaultWinGrpRoute: WindowGroupRoutingOpt = .showItems(
                        openNewWindow: false,
                        sideBarFilterSelected: .waiting, contentItemIdsSelected: []
                    )

                    let decodedWinGrpRoute: WindowGroupRoutingOpt = Main.urlDecode(url)
                        ?? {
                            log.warning("onOpenURL: Unable to fully decode URL, using default window route")
                            return defaultWinGrpRoute
                        }()

                    if windowGroupRoute == nil {
                        log.debug("onOpenURL: Existing route not set for winId \(winId), updating the window contents directly")
                        routeWindow(decodedWinGrpRoute)
                        windowGroupRoute = decodedWinGrpRoute

                    } else {
                        log.debug("onOpenURL: Existing route defined for winId \(winId), using indirect routing to see if this window or any othercan handle or if app needs to open new window")

                        // NB: Have to use dispatch, bc without SwiftUI will not make the window it finds or creates the keyWindow, i.e.
                        // raise it above the others and make it prominent to the user.
                        DispatchQueue.main.async {
                            openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: decodedWinGrpRoute)
                        }
                    }
                })
                .onChange(of: visibleItemIdsSelected, perform: { newValue in
                    if let route = windowGroupRoute {
                        switch route {
                        case let .showItems(_, filterSelected, _):
//                            print("Is UPDATING route for window = \(winId)   because of selection")
                            $windowGroupRoute.wrappedValue = .showItems(openNewWindow: false, sideBarFilterSelected: filterSelected,
                                                                        contentItemIdsSelected: newValue)
                        case .newItem(sideBarFilterSelected: _):
                            // Don't care because on arrival will create new and change route type
                            break
                        }

                    } else {
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected,
                                                      contentItemIdsSelected: visibleItemIdsSelected)
                    }
                })
                .onChange(of: sideBarFilterSelected, perform: { newValue in
                    if let route = windowGroupRoute {
                        switch route {
                        case let .showItems(_, _, contentItemIdsSelected):
//                            print("Is UPDATING route for window = \(winId)  with  because of filter")
                            $windowGroupRoute.wrappedValue = .showItems(openNewWindow: false, sideBarFilterSelected: newValue,
                                                                        contentItemIdsSelected: contentItemIdsSelected)
                        case .newItem(sideBarFilterSelected: _):
                            // Don't care because on arrival will create new and change route type
                            break
                        }

                    } else {
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected,
                                                      contentItemIdsSelected: visibleItemIdsSelected)
                    }
                })
        }

        /// The sideBar filter being applied
        @Binding private var sideBarFilterSelected: SidebarFilterOpt

        /// The filtered for visibility set of selected `Item#ourId`s
        @Binding private var visibleItemIdsSelected: Set<UUID>

        /// Binding to the route assigned to  the view in `@main` by `WindowGroup(id:for:content)`
        @Binding private var windowGroupRoute: WindowGroupRoutingOpt?

        @Environment(\.openWindow) private var openWindow

        /// SwiftUI's per-window instance default `UndoManager`
        @Environment(\.undoManager) private var windowUM: UndoManager?

        private let winId: Int
        private let content: Content
    }
}
