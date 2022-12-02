//
//  Main#ContentView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Main {
    struct ContentView: View {
        let stateView: Main

        @FocusedValue(\.undoWfa) var wfa: UndoWorkFocusArea?

        var body: some View {
            Layout(selections: stateView.$contentItemIdsSelected, items: stateView.contentItems, onMovePerform: stateView.contentOnMovePerform, contextMenu: contextMenu)
                .focusedValue(\.undoWfa, .content)
        }

        func contextMenu(_ rhClickItem: Item) -> some View {
            var itemsToActOn: Array<Item> { stateView.contentItemsSelected.contains(rhClickItem)
                ? stateView.contentItemsSelected
                : [rhClickItem]
            }
            var itemIdsToActOn: Set<UUID> {
                Set(itemsToActOn.map({ $0.ourIdS }))
            }

            return Group {
                Button("Open in New Tab") {
                    Main.openNewTab(
                        openWindow: stateView.openWindow,
                        sideBarFilterSelected: stateView.sideBarFilterSelected,
                        contentItemIdsSelected: itemIdsToActOn
                    )
                }
                .accessibilityIdentifier(AccessId.MainWindowContentContextOpenInNewTab.rawValue)

                Button("Open in New Window") {
                    let route = Main.WindowGroupRoutingOpt.showItems(
                        openNewWindow: true,
                        sideBarFilterSelected: stateView.sideBarFilterSelected,
                        contentItemIdsSelected: itemIdsToActOn
                    )
                    stateView.openWindow(id: GowiApp.WindowGroupId.Main.rawValue, value: route)
                }
                .accessibilityIdentifier(AccessId.MainWindowContentContextOpenInNewWindow.rawValue)

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
                .accessibilityIdentifier(AccessId.MainWindowContentContextDelete.rawValue)
            }
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
                    .accessibilityIdentifier(AccessId.MainWindowContentTitleField.rawValue)
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