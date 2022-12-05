//
//  Main#ContentView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Main {
    /// Creates the Content view component of the Main Window's `NavigationSplitView`
    struct ContentView: View {
        let stateView: Main

        @FocusedValue(\.undoWfa) private var wfa: UndoWorkFocusArea?

        var body: some View {
            Layout(selections: stateView.$itemIdsSelected, items: stateView.contentItems, onMovePerform: stateView.contentOnMovePerform, contextMenu: contextMenu)
                .focusedValue(\.undoWfa, .content)
        }
    }
}

extension Main.ContentView {
    /// Builds the context menu of available options for the Content list
    /// - Parameter rhClickItem: the `Item` on which the Right Hand click event occurred.
    /// - Returns: Context menu of actions that can be performed on one or more `Items` within the current set of selected `Items`. Or on the individual `Item` under the right click event.
    ///
    /// Actions in menu occur to `Item`s either:
    /// - Selected from the list  **iff** the `Item` on which the right hand click event occured is within the selection.
    /// - Or to the `Item` on which the righ hand click event occured outside of the selection.
    ///
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

    fileprivate struct Layout<CtxMenu: View>: View {
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
