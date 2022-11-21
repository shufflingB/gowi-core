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
        case showItems(sideBarFilterSelected: SidebarFilterOpt, contentItemIdsSelected: Set<UUID>)
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
            case let .showItems(sideBarFilterSelected: filter, contentItemIdsSelected: items):
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
//                        print("Route opened for \(winId)")
                        routeWindow(route)
                    }
                }

                .onChange(of: contentItemIdsSelected, perform: { newValue in
                    if let route = windowGroupRoute {
                        switch route {
                        case let .showItems(filterSelected, _):
//                            print("Is UPDATING route for window = \(winId)   because of seletction")
                            $windowGroupRoute.wrappedValue = .showItems(sideBarFilterSelected: filterSelected,
                                                                        contentItemIdsSelected: newValue)
                        case .newItem(sideBarFilterSelected: _):
                            // Don't care because on arrival will create new and change route type
                            break
                        }

                    } else {
                        windowGroupRoute = .showItems(sideBarFilterSelected: sideBarFilterSelected,
                                                      contentItemIdsSelected: contentItemIdsSelected)
                    }
                })
                .onChange(of: sideBarFilterSelected, perform: { newValue in
                    if let route = windowGroupRoute {
                        switch route {
                        case let .showItems(_, contentItemIdsSelected):
//                            print("Is UPDATING route for window = \(winId)  with  because of filter")
                            $windowGroupRoute.wrappedValue = .showItems(sideBarFilterSelected: newValue,
                                                                        contentItemIdsSelected: contentItemIdsSelected)
                        case .newItem(sideBarFilterSelected: _):
                            // Don't care because on arrival will create new and change route type
                            break
                        }

                    } else {
                        windowGroupRoute = .showItems(sideBarFilterSelected: sideBarFilterSelected,
                                                      contentItemIdsSelected: contentItemIdsSelected)
                    }
                })
                .onOpenURL(perform: { url in
                    // Decode the URL into a RoutingOpt (only runs on the keyWindow)
                    print("onOpenURL handling \(url) for windowId = \(winId)")
                    if let decodedWinGrpRoute = Main.urlDecode(url) {
                        if windowGroupRoute != nil { // => User has made +ve routing choices that should not be overriden
//                            print("Using openWindow to indirect route")

                            DispatchQueue.main.async { // <- Without this it will not make the new window the keyWindow, i.e. raise it
                                openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: decodedWinGrpRoute)
                            }

                        } else {
//                            print("Routing directly")
                            routeWindow(decodedWinGrpRoute)
                            windowGroupRoute = decodedWinGrpRoute
                        }

                    } else {
                        print("TODO: Handle the default case")
                    }
                })
                .onChange(of: windowUM) { newValue in
                    guard let windowUM = newValue else {
                        return
                    }

                    switch windowGroupRoute {
                    case let .newItem(sideBarFilterSelected: filter):
                        withAnimation {
                            let route = Main.itemAddNew(
                                appModel: appModel, windowUM: windowUM,
                                tabSelected: filter, parent: appModel.systemRootItem,
                                list: Main.contentItemsListAll(appModel.systemRootItem.childrenListAsSet)
                            )
                            contentItemIdsSelected = route.itemIdsSelected
                            sideBarFilterSelected = filter
                            // Twiddle the route so that the old one is avaiable again
                            windowGroupRoute = .showItems(sideBarFilterSelected: sideBarFilterSelected, contentItemIdsSelected: contentItemIdsSelected)
                        }

                    default:
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
