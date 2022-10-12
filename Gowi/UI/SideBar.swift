//
//  SideBar.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 27/09/2022.
//

import SwiftUI

struct SideBar: View {
    let stateView: Main

    enum ListFilterOptions: String, CaseIterable {
        case waiting = "Waiting", done = "Done", all = "All"
    }

    var body: some View {
        Layout(
            listSelected: stateView.$sideBarFilterSelected , listOfAvailableFilters: stateView.sideBarAvailableFilters
        )
    }
}

extension SideBar {
    struct Layout: View {
        @Binding var listSelected: ListFilterOptions
        let listOfAvailableFilters: Array<ListFilterOptions>

        var body: some View {
            List(listOfAvailableFilters, id:\.self, selection: $listSelected) { filterByItem in
                Text(filterByItem.rawValue)
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
