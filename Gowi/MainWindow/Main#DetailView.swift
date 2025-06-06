//
//  Main#DetailView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

extension Main {
    /// Creates the Content view component of the Main Window's `NavigationSplitView`
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

        fileprivate struct Layout<NSContent: View, IContent: View>: View {
            let items: Array<Item>
            @ViewBuilder let nothingSelectedView: NSContent
            @ViewBuilder let itemView: (_: Item) -> IContent

            var body: some View {
                if items.count == 0 {
                    nothingSelectedView
                } else {
                    ZStack { // Use the ZStack to show if the user has multiple Items selected
                        ForEach(items.indices, id: \.self) { idx in
                            if items.count == 1 {
                                itemView(items[idx])
                                    .background(.background)
                            } else {
                                itemView(items[idx])
                                    .background(.background)
                                    .border(Color.accentColor)
                                    .padding(.all)
                                    .zIndex(-Double(idx))
                                    .rotationEffect(.degrees(Double(idx) * 2.0))
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
