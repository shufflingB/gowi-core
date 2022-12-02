//
//  Main#SidebarView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Main {
    enum SidebarFilterOpt: String, CaseIterable, Codable {
        case waiting = "Waiting", done = "Done", all = "All"
    }

    struct SidebarView: View {
        let stateView: Main

        var body: some View {
            Layout(
                listSelected: stateView.$sideBarFilterSelected, listOfAvailableFilters: stateView.sideBarAvailableFilters
            )
        }

        struct Layout: View {
            @Binding var listSelected: SidebarFilterOpt
            let listOfAvailableFilters: Array<SidebarFilterOpt>

            var body: some View {
                List(listOfAvailableFilters, id: \.self, selection: $listSelected) { filterByItem in
                    Text(filterByItem.rawValue)
                        .accessibilityIdentifier(filterByItem.rawValue)
                }
            }
        }
    }
}

// struct Sidebar_Previews: PreviewProvider {
//    @StateObject static var am = AppModel.sharedInMemoryWithTestData
//    @State static var itemsSelected: Set<UUID> = []
//    @State static var tabSelected: SideBar.TabOption = .waiting
//
//
//
//    static var previews: some View {
//        SideBar.Layout(
//            tabSelected: $tabSelected,
//            itemsSelected: $itemsSelected,
//            itemsWaiting: Main.sideBarItemsListWaiting(am.systemRootItem.childrenListAsSet),
//            itemsDone: Main.sideBarItemsListDone(am.systemRootItem.childrenListAsSet),
//            itemsAll: Main.sideBarItemsListAll(am.systemRootItem.childrenListAsSet),
//            onMoveOfWaitingItems: {_,_,_ in}
//        )
//    }
// }
