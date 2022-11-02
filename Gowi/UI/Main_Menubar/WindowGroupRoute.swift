//
//  Routing.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/11/2022.
//

import SwiftUI
extension Main {
    struct WindowGroupRoute<Content: View>: View {
        init(
            winId: Int,
            sideBarFilterSelected: Binding<SideBar.ListFilterOption>,
            contentItemIdsSelected: Binding<Set<UUID>>,
            route: Binding<RoutingOpt?>,
            @ViewBuilder content: () -> Content
        ) {
            self.winId = winId
            _route = route
            _sideBarFilterSelected = sideBarFilterSelected
            _contentItemIdsSelected = contentItemIdsSelected
            self.content = content()
        }

        var body: some View {
            content
                .onAppear {
                    guard let route: Main.RoutingOpt = route else {
                        print("No routing for window = \(winId) ")
                        return
                    }
                    switch route {
                    case let .showItems(filterSelected, contentItemIdsSelected):
                        print("Is routing window = \(winId)")
                        self.sideBarFilterSelected = filterSelected
                        self.contentItemIdsSelected = contentItemIdsSelected
                    }
                }

                .onChange(of: contentItemIdsSelected, perform: { newValue in
                    guard let route = route else {
                        print("No route set for window so nothing to UPDATE = \(winId) ")
                        return
                    }
                    switch route {
                    case let .showItems(filterSelected, _):
                        print("Is UPDATING route for window = \(winId)   because of seletction")
                        $route.wrappedValue = .showItems(sideBarFilterSelected: filterSelected,
                                                         contentItemIdsSelected: newValue)
                    }
                })
                .onChange(of: sideBarFilterSelected, perform: { newValue in
                    guard let route = route else {
                        print("No route set for window so nothing to UPDATE = \(winId) ")
                        return
                    }
                    switch route {
                    case let .showItems(_, contentItemIdsSelected):
                        print("Is UPDATING route for window = \(winId)  with  because of filter")
                        $route.wrappedValue = .showItems(sideBarFilterSelected: newValue,
                                                         contentItemIdsSelected: contentItemIdsSelected)
                    }
                })
        }

        private let winId: Int
        @Binding private var sideBarFilterSelected: SideBar.ListFilterOption
        @Binding private var contentItemIdsSelected: Set<UUID>
        @Binding private var route: RoutingOpt?
        private let content: Content
    }
}
