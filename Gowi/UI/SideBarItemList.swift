//
//  ItemList.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 27/09/2022.
//

import SwiftUI

struct SideBarItemList: View {
    @Binding var selections: Set<UUID>
    let items: Array<Item>
    let onMovePerform: (_ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) -> Void

    var body: some View {
        List(selection: $selections) {
            ForEach(items, id: \.ourIdS) { item in
                HStack {
                    Text(item.titleS)
                }
            }
            .onMove(perform: { sourceIndices, tgtIdxsEdge in
                withAnimation {
                    onMovePerform(sourceIndices, tgtIdxsEdge)
                }
            })
        }
    }
}

struct ItemList_Previews: PreviewProvider {
    @StateObject static var appModel = AppModel.sharedInMemoryWithTestData
    @State static var selections: Set<UUID> = [AppModel.testingMode1ourIdPresent]

    static var previews: some View {
        SideBarItemList(
            selections: $selections,
            items: Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet),
            onMovePerform: { srcIdxs, tgtEdge in
                Main.sideBarOnMoveOfWaitingItems(
                    withTarget: appModel,
                    externalUM: nil,
                    context: appModel.viewContext,
                    items: Main.sideBarItemsListWaiting(appModel.systemRootItem.childrenListAsSet),
                    sourceIndices: srcIdxs,
                    tgtIdxsEdge: tgtEdge
                )
            }
        )
    }
}
