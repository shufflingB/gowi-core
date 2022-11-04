//
//  ItemList.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 27/09/2022.
//

import SwiftUI

struct Content: View {
    @Binding var selections: Set<UUID>
    let items: Array<Item>
    let onMovePerform: (_ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) -> Void

    var body: some View {
        List(selection: $selections) {
            ForEach(items, id: \.ourIdS) { item in
                Row(item: item)
            }
            .onMove(perform: { sourceIndices, tgtIdxsEdge in
                withAnimation {
                    onMovePerform(sourceIndices, tgtIdxsEdge)
                }
            })
        }
    }
}

extension Content {
    private struct Row: View {
        @ObservedObject var item: Item
        var body: some View {
            HStack {
                TextField(
                    "",
                    text: $item.titleS
                )
            }
        }
    }
}

struct ItemList_Previews: PreviewProvider {
    @StateObject static var appModel = AppModel.sharedInMemoryWithTestData
    @State static var selections: Set<UUID> = [AppModel.testingMode1ourIdPresent]

    static var previews: some View {
        Content(
            selections: $selections,
            items: Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet),
            onMovePerform: { _, _ in }
        )
    }
}
