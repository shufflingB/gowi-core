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

        
        /* Workaround; SwiftUI - bless it's little macOS must die socks so it can be reinvented in
        iPadOS - treats key window status and focus separately. So it doesn't matter if you've
        just opened a new window on your app and can merrily keyboard navigate around one of its
        windows. That Window will not update any of its SwiftUI Focused values until at least one
         of its internal inputs has actively experienced a focusing event (macOS == clicked on,
         typed into). Hence here, we end up faking that by using onAppear make the app's focusedValue
         event fire which is useful for letting things like the menubar know if it's got a Window to work with, what state that Window is in etc ...
         
         (the alternative is to forget about using focusedValues and try and keep track in the app's
         model, which would be a pity)
         */
        @FocusState private var isInitiallyFocused: Bool
        
        @FocusedValue(\.undoWfa) private var wfa: UndoWorkFocusArea?

        var body: some View {
            Layout(selections: stateView.$itemIdsSelected, items: stateView.contentItems, onMovePerform: stateView.contentOnMovePerform, contextMenu: contextMenu)
                .searchable(text: stateView.currentSearchText, prompt: searchPrompt)
                .focusedValue(\.undoWfa, .content)
                .focused($isInitiallyFocused)
                .onAppear {
                    isInitiallyFocused = true
                }
        }
        
        /// Dynamic search prompt text based on current sidebar filter
        private var searchPrompt: Text {
            switch stateView.sideBarFilterSelected {
            case .all:
                return Text("Search All Items")
            case .done:
                return Text("Search Done Items")
            case .waiting:
                return Text("Search Waiting Items")
            }
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
                    contentItemIdsSelected: itemIdsToActOn,
                    searchText: nil
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
