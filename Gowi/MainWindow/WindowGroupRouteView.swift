//
//  Routing.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/11/2022.
//

import SwiftUI

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension Main {
    enum WindowGroupRoutingOpt: Hashable, Codable {
        case showItems(openNewWindow: Bool, sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>)
        case newItem(sideBarFilterSelected: SidebarFilterOpt)
    }

    struct WindowGroupRouteView<Content: View>: View {
        @EnvironmentObject var appModel: AppModel
        init(
            winId: Int,
            sideBarFilterSelected: Binding<SidebarFilterOpt>,
            contentItemIdsSelected: Binding<Set<UUID>>,
            route: Binding<WindowGroupRoutingOpt?>,
            @ViewBuilder content: () -> Content
        ) {
            self.winId = winId
            _windowGroupRoute = route
            _sideBarFilterSelected = sideBarFilterSelected
            _contentItemIdsSelected = contentItemIdsSelected
            self.content = content()
        }

        // Logic is
        /// 1) if onAppear with route set then save a reference to that and take options from it and set the window up accordingly.
        /// 2) When user makes changes either update the reference to the existing route OR if not existing, create a new route i.e. defined route ref => user configured and should not alter
        /// 3) When onOpenUrl, if no route reference, then:
        ///     a) If no route reference, then  update the window AND store a new route ref to indicate window has been routed.
        ///     b) openWindow, to either create a new window instance, or to raise an existing one if one matches the requested route

        func routeWindow(_ route: WindowGroupRoutingOpt) {
            switch route {
            case let .showItems(openNewWindow: newWin, sideBarFilterSelected: filter, contentItemIdsSelected: items):
                sideBarFilterSelected = filter
                contentItemIdsSelected = items

            case .newItem(sideBarFilterSelected: _):
                // This gets handled when we have a window undo mananager, as want to make it undoable, and when
                // onAppear runs that undoManager is defined as nil
                break
            }
        }

        var body: some View {
            content
                .onAppear {
                    if let route: WindowGroupRoutingOpt = windowGroupRoute {
                        routeWindow(route)
                    }
                }

                .onChange(of: contentItemIdsSelected, perform: { newValue in
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
                                                      contentItemIdsSelected: contentItemIdsSelected)
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
                                                      contentItemIdsSelected: contentItemIdsSelected)
                    }
                })
                .onOpenURL(perform: { url in
                    // Decode the URL into a RoutingOpt (only runs on the keyWindow)
                    print("onOpenURL handling \(url) for windowId = \(winId)")

                    let defaultWinGrpRoute: WindowGroupRoutingOpt = .showItems(
                        openNewWindow: false,
                        sideBarFilterSelected: .waiting, contentItemIdsSelected: []
                    )

                    let decodedWinGrpRoute: WindowGroupRoutingOpt = Main.urlDecode(url)
                        ?? {
                            log.warning("Unable to fully decode URL, using default window route")
                            return defaultWinGrpRoute
                        }()

                    if windowGroupRoute != nil {
                        print("Using openWindow to indirect route")

                        DispatchQueue.main.async { // <- Without this it will not make the new window the keyWindow, i.e. raise it
                            openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: decodedWinGrpRoute)
                        }

                    } else {
                        print("Routing directly")
                        routeWindow(decodedWinGrpRoute)
                        windowGroupRoute = decodedWinGrpRoute
                    }
                })
                .onChange(of: windowUM) { newValue in
                    // Has nothing really to do with windowUM, but detecting when SWiftUI defines it is a convenient place
                    // to detect when both the View has appeared AND the @SwiftUI state has been injected and is ready
                    // for processings.

                    guard let windowUM = newValue else {
                        return
                    }

                    switch windowGroupRoute {
                    case let .newItem(sideBarFilterSelected: filter):
                        log.debug("Creating a new Item and a route to it")
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: windowUM,
                                tabSelected: filter, parent: appModel.systemRootItem,
                                list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )
                            contentItemIdsSelected = route.itemIdsSelected
                            sideBarFilterSelected = filter
                            // Update the route so that the newItem route can be triggered again if required.
                            windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: contentItemIdsSelected)
                        }

                    default:
                        log.debug("Creating a default route")
                        windowGroupRoute = .showItems(openNewWindow: false, sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: contentItemIdsSelected)
                        return
                    }
                }
        }

        private let winId: Int
        @Binding private var sideBarFilterSelected: SidebarFilterOpt
        @Binding private var contentItemIdsSelected: Set<UUID>
        @Binding private var windowGroupRoute: WindowGroupRoutingOpt?
        private let content: Content
        @Environment(\.openWindow) internal var openWindow
        @Environment(\.undoManager) internal var windowUM: UndoManager?
    }
}
