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
            .onMove(perform: { a, b in
                withAnimation {
                    onMovePerform(a, b)
                }
            })
        }
    }
}

// struct ItemList_Previews: PreviewProvider {
//    static var previews: some View {
//        SideBarItemList(selections: .constant(["Venus", "Earth"]), items: Array(Test_Data), onMovePerform: { _, _ in })
//    }
// }
