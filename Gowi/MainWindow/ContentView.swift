//
//  ItemList.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 27/09/2022.
//

import SwiftUI

extension Main {
    struct ContentView: View {
        let stateView: Main

        var body: some View {
            Layout(selections: stateView.$contentItemIdsSelected, items: stateView.contentItems, onMovePerform: stateView.contentOnMovePerform, contextMenu: contextMenu)
        }

        func contextMenu(_ item: Item) -> some View {
            let itemsToActOn = stateView.contentContextItemsToActOn(onRightClick: item)

            return
                Button(
                    "Delete",
                    action: {
                        withAnimation {
                            _ = Main.itemsDelete(
                                appModel: stateView.appModel,
                                windoUM: stateView.windowUM,
                                currentlyShowing: stateView.contentItems,
                                previousListSelectionsGoingDown: true,
                                deleteItems: itemsToActOn
                            )
                        }
                    }
                )
        }
    }
}

extension Main.ContentView {
    struct Layout<CtxMenu: View>: View {
        @Binding var selections: Set<UUID>
        let items: Array<Item>
        let onMovePerform: (_ sourceIndices: IndexSet, _ tgtIdxsEdge: Int) -> Void
        let contextMenu: (_ item: Item) -> CtxMenu

        var body: some View {
            List(selection: $selections) {
                ForEach(items, id: \.ourIdS) { item in
                    Row(item: item)
                        .contextMenu(menuItems: { contextMenu(item) })
                }
                .onMove(perform: { sourceIndices, tgtIdxsEdge in
                    withAnimation {
                        onMovePerform(sourceIndices, tgtIdxsEdge)
                    }
                })
            }
        }

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
}

// struct Content_Previews: PreviewProvider {
//    @StateObject static var appModel = AppModel.sharedInMemoryWithTestData
//    @State static var selections: Set<UUID> = [AppModel.testingMode1ourIdPresent]
//
//    static var previews: some View {
//        Main.ContentView.Layout(
//            selections: $selections,
//            items: Main.contentItemsListWaiting(appModel.systemRootItem.childrenListAsSet),
//            onMovePerform: { _, _ in }, contextMenu: {Text("Hello") }
//        )
//    }
// }
