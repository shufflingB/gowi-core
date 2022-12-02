//
//  Main#WindowGroupRouteView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension Main {
    /// `WindowGroupRoutingOpt` defines the routes that this Window (Group) supports
    ///  Options available:
    ///     - `showItem(openNewWindow:sideBarFilterSelected: contentItemIdsSelected)`:  A route to a window that if possible, displays the `Item` specified.
    ///         When `openNewWindow` is
    ///         `false` -  it will only create a new window if there no existing app windows visibly rendering that route.
    ///         `true` - it will always open a new window, regardless of any existing windows displaying the app.
    ///
    enum WindowGroupRoutingOpt: Hashable, Codable {
        case showItems(openNewWindow: Bool, sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>)
        case newItem(sideBarFilterSelected: SidebarFilterOpt)
    }

    /// Handles routing for the `Main` window `View`.
    ///
    /// ## Dependencies
    ///
    /// 1. `WindowGroup(id:for:content:)` view factory in `@main` must be used to inject routing options  into the view.
    /// 2. `WindowGroup`s `content`  needs to  have `.handlesExternalEvents(preferring: allowing:)` specified to send all external events to the view (rather
    ///  than forking off its own new windows (this view handles that itself if necessary)
    ///
    /// ## Overview
    ///
    /// - `WindowGroupRoutingOpt` defines the available routes that this (main) window knows how to handle.
    ///
    /// - `WindowGroup(id:for:content:)` factory view maintains for the duration of the application's runtime a list of the routes in its window group.
    ///     -  Requests for routes  are routed to the relevant `WindowGroup` and then if there is a View:
    ///         - That  `WindowGroup` believes  is rendering the route it will raise (make `keyWindow`) that Window (and not create a new window)
    ///         - Otherwise, it will:
    ///             a. Create a new window.
    ///             b. Render the top-level view
    ///             c. Passing a binding to the route that it asked the view to render.
    ///
    /// - `WindowGroupRouteView`  handles routing and URL open requests
    ///     - receives the binding to its `WindowGroup`routing information.
    ///     - handles setting the window up as requested by new routing informat.
    ///     - keeps the binding to the `WindowGroup`routing information up to date with what is actually being displayed in the window.
    ///     - handles turning open by URL requests into app `WindowGroup` routing requests i.e. routing via URL and internal mechanisms endeavour to share a common
    ///     code paths.
    ///
    /// ## Content modifiers
    ///
    /// - `onAppear`
    ///     - Is the first thing that runs for the `View`
    ///     - If the View has been:
    ///         - Instantiated by the WindowGroup mechanism, say as the result of `openWindow`  or via the homebrewed openTab mechanism then the `View` will have been
    ///         passed a route for the Window AND we need to update the contents of the Window to be in alignment with that route. NB: Does not handle new window routing
    ///         requests, bc no access to the Window's `UndoManager` when this runs (see next comment for more on that).
    ///         - Created via the Window restore mechanism, say as a result on being started, then it may  have no  route assigned to it and in that case we do nothing here and
    ///         instead create a route for the window when the `@State` vars  become available for use, as proxied by  the `onChange(of: SwiftUIsWindowUndoManager)`
    ///
    /// - `onChange(of: windowUM)`
    ///     - Gets run after `onAppear` when the window's `UndoManager` has been setup and is injected into the `View`
    ///     - Used to handle:
    ///         1. New item routing requests  that can't be done  in the onAppear handler because the `UndoManager` is not available.
    ///         2. Setting up the route for any window that has been restored on restart.
    ///
    /// - `onOpenURL`
    ///     - Only gets run on one of the app's Windows (keyWindow?) to handle a URL request.
    ///     - Handles decoding the routing information from the URL or if that fails sets up a sensible default
    ///     - Then:
    ///         - If there is no route configured for the current window; it will directly route the window itself.
    ///         - Else, it will use openWindow to either raise a different existing  window  from the app that contains the desired route.  Or create a new one if no existing window
    ///         in the app matches the route requested.
    ///
    /// - Other onChange(of:) ...
    ///     Used to keep the window's route up to date.
    struct WindowGroupRouteView<Content: View>: View {
        @EnvironmentObject var appModel: AppModel
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

        private func routeWindow(_ route: WindowGroupRoutingOpt) {
            switch route {
            case let .showItems(openNewWindow: _, sideBarFilterSelected: filter, contentItemIdsSelected: items):
                sideBarFilterSelected = filter
                visibleItemIdsSelected = items

            case .newItem(sideBarFilterSelected: _):
                // This gets handled when we have a window undo mananager, as want to make it undoable, and when
                // onAppear runs that undoManager is defined as nil
                break
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
                    // Has nothing really to do with windowUM, but detecting when SWiftUI defines it is a convenient place
                    // to detect when both the View has appeared AND the SwiftUI @State has been injected and is ready
                    // for processings.

                    guard let windowUM = newValue else {
                        return
                    }

                    switch windowGroupRoute {
                    case let .newItem(sideBarFilterSelected: filter):
                        log.debug("onChange(of: windowUM): Creating a new Item and a route to it")
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: windowUM,
                                tabSelected: filter, parent: appModel.systemRootItem,
                                list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
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
                    // Decode the URL into a RoutingOpt (only runs on the keyWindow)
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

        private let winId: Int
        @Binding private var sideBarFilterSelected: SidebarFilterOpt
        @Binding private var visibleItemIdsSelected: Set<UUID>
        @Binding private var windowGroupRoute: WindowGroupRoutingOpt?
        private let content: Content
        @Environment(\.openWindow) private var openWindow
        @Environment(\.undoManager) private var windowUM: UndoManager?
    }
}
