//
//  SideBar.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 27/09/2022.
//

import SwiftUI

struct SideBar: View {
    let stateView: Main

    enum TabOption: Int {
        case waiting, done, all
    }

    var body: some View {
        Layout(
            tabSelected: stateView.$sideBarTabSelected,
            itemsSelected: stateView.$sideBarItemSelections,
            itemsWaiting: stateView.sideBarItemsListWaiting,
            itemsDone: stateView.sideBarItemsListDone,
            itemsAll: stateView.sideBarItemsListAll,
            onMoveOfWaitingItems: stateView.sideBarOnMoveOfWaitingItems
        )
    }
}

extension SideBar {
    struct Layout: View {
        
        @EnvironmentObject var appModel: AppModel
        @Binding var tabSelected: SideBar.TabOption
        @Binding var itemsSelected: Set<UUID>
        let itemsWaiting: Array<Item>
        let itemsDone: Array<Item>
        let itemsAll: Array<Item>
        let onMoveOfWaitingItems: (_ waitingItems: Array<Item>, _ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) -> Void

        var body: some View {
            return VStack {
                TabView(selection: $tabSelected) {
                    SideBarItemList(
                        selections: $itemsSelected,
                        items: itemsWaiting,
                        onMovePerform: {
                            sourceIndices, tgtIdxsEdge in
                            onMoveOfWaitingItems(itemsWaiting, sourceIndices, tgtIdxsEdge
                            )
                        }
                    )
                    .tabItem {
                        Text("Todo")
                    }
                    .tag(SideBar.TabOption.waiting)

                    SideBarItemList(selections: $itemsSelected, items: itemsDone, onMovePerform: { _, _ in })
                        .tabItem {
                            Text("Done")
                        }
                        .tag(SideBar.TabOption.done)

                    
                    SideBarItemList(selections: $itemsSelected, items: itemsAll , onMovePerform: { _, _ in })
                        .tabItem {
                            Text("All")
                        }
                        .tag(SideBar.TabOption.all)
                }
            }
        }
    }
}

 struct Sidebar_Previews: PreviewProvider {
    @StateObject static var am = AppModel.sharedInMemoryWithTestData
    @State static var itemsSelected: Set<UUID> = []
    @State static var tabSelected: SideBar.TabOption = .waiting



    static var previews: some View {
        SideBar.Layout(
            tabSelected: $tabSelected,
            itemsSelected: $itemsSelected,
            itemsWaiting: Main.sideBarItemsListWaiting(am.systemRootItem.childrenListAsSet),
            itemsDone: Main.sideBarItemsListDone(am.systemRootItem.childrenListAsSet),
            itemsAll: Main.sideBarItemsListAll(am.systemRootItem.childrenListAsSet),
            onMoveOfWaitingItems: {_,_,_ in}
        )
    }
 }
