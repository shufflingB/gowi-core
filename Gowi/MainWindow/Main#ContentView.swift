//
//  Main#ContentView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Main {
    /**
     ## Content Area View - Center Pane of Main Window
     
     The ContentView renders the middle pane of the NavigationSplitView, displaying a filterable
     and searchable list of todo items. It provides the primary interaction area for item management.
     
     ### Features:
     - **Item List**: Displays items filtered by sidebar selection and search text
     - **Search Integration**: Uses SwiftUI's `.searchable()` for real-time filtering
     - **Multi-Selection**: Supports multiple item selection with keyboard and mouse
     - **Drag & Drop**: Enables reordering items within the list
     - **Context Menus**: Right-click access to item operations
     - **Keyboard Navigation**: Full keyboard accessibility for power users
     
     ### Focus Management:
     Implements a SwiftUI/macOS workaround for proper focus handling in multi-window scenarios.
     The focused values don't update properly when new windows open until a click occurs,
     so this view forces initial focus to ensure menu bar commands work correctly.
     */
    struct ContentView: View {
        /// Reference to parent StateView for accessing state and intents
        let stateView: Main

        /// SwiftUI focus workaround for macOS multi-window focus handling
        ///
        /// macOS treats key window status and focus separately. New windows don't properly
        /// update SwiftUI @FocusedValue until user interaction occurs. This property forces
        /// initial focus on window appearance to ensure menu commands work immediately.
        ///
        /// Alternative would be tracking focus state manually in AppModel, but that would
        /// break the clean separation between view state and business logic.
        @FocusState private var isInitiallyFocused: Bool
        
        /// Tracks current focus area for menu command coordination
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
