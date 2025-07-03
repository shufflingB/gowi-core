//
//  Main#DetailView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
import GowiAppModel

/**
 ## Detail View - Right Pane of Main Window
 
 The DetailView renders the right pane of the NavigationSplitView, displaying detailed
 information for selected todo items. It provides a sophisticated multi-selection
 interface with visual stacking effects.
 
 ### Selection States:
 - **No Selection**: Shows a placeholder message when no items are selected
 - **Single Selection**: Displays the item's detail view cleanly
 - **Multi-Selection**: Uses a visual stacking effect with rotation and borders
 
 ### Multi-Selection Design:
 When multiple items are selected, the view creates a "stacked cards" effect:
 - Each item is rendered as a separate card with accent color borders
 - Cards are slightly rotated (2° per item) to create depth
 - Z-index ensures proper layering with the most recent selection on top
 - Padding prevents cards from overlapping completely
 
 ### Architecture:
 The view uses a generic Layout component that accepts ViewBuilder closures
 for maximum flexibility in how "no selection" and "item" states are rendered.
 This enables comprehensive SwiftUI previews and testing scenarios.
 */
extension Main {
    /// Creates the Detail view component of the Main Window's `NavigationSplitView`
    struct DetailView: View {
        let stateView: Main

        var body: some View {
            Layout(items: stateView.detailItems,
                   nothingSelectedView: {
                       VStack {
                           Text("No items selected")
                               .background(.background)
                       }
                   },
                   itemView: { (item: Item) in
                       ItemView(stateView: stateView, item: item)
                   }
            )
        }

        /// Generic layout component for rendering item detail views
        ///
        /// This component handles the three possible selection states:
        /// 1. No items selected → shows placeholder view
        /// 2. Single item selected → clean detail view
        /// 3. Multiple items selected → stacked cards effect
        ///
        /// Generic parameters allow for flexible content rendering while maintaining
        /// consistent selection state logic across different detail view implementations.
        fileprivate struct Layout<NSContent: View, IContent: View>: View {
            /// Array of items to display in detail view
            let items: Array<Item>
            
            /// View to show when no items are selected
            @ViewBuilder let nothingSelectedView: NSContent
            
            /// Factory for creating individual item detail views
            @ViewBuilder let itemView: (_: Item) -> IContent

            var body: some View {
                if items.count == 0 {
                    nothingSelectedView
                } else {
                    ZStack { // Use the ZStack to show if the user has multiple Items selected
                        ForEach(items.indices, id: \.self) { idx in
                            if items.count == 1 {
                                // Single selection: clean presentation
                                itemView(items[idx])
                                    .background(.background)
                            } else {
                                // Multi-selection: stacked cards effect
                                itemView(items[idx])
                                    .background(.background)
                                    .border(Color.accentColor)
                                    .padding(.all)
                                    .zIndex(-Double(idx)) // Reverse z-order for proper stacking
                                    .rotationEffect(.degrees(Double(idx) * 2.0)) // 2° rotation per item
                            }
                        }
                    }
                }
            }
        }
    }
}

import SwiftUI

// MARK: - Mock Views

private func noItemMockView() -> some View {
    Text("No items selected")
        .frame(width: 200, height: 200)
}

private func itemMockView(_ item: Item) -> some View {
    VStack(alignment: .leading) {
        Text("ItemView Mock")
            .font(.title3)
            .padding(.bottom)
        Text("Title: \"\(item.titleS)\"")
        Text("Notes: \"\(item.notesS)\"")
    }
    .padding()
    .frame(width: 200, height: 200)
}

// MARK: - Previews

#Preview("No Items selected") {
    Main.DetailView.Layout(
        items: [],
        nothingSelectedView: noItemMockView,
        itemView: itemMockView
    )
}

#Preview("Multiple Items selected") {
    @Previewable @StateObject var appModel = AppModel.sharedInMemoryWithTestData

    Main.DetailView.Layout(
        items: Array(appModel.systemRootItem.childrenListAsSet).dropLast(7),
        nothingSelectedView: noItemMockView,
        itemView: itemMockView
    )
}

#Preview("Single Item selected") {
    @Previewable @StateObject var appModel = AppModel.sharedInMemoryWithTestData

    Main.DetailView.Layout(
        items: [appModel.systemRootItem.childrenListAsSet.first!],
        nothingSelectedView: noItemMockView,
        itemView: itemMockView
    )
}
