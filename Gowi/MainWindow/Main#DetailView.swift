//
//  Main#DetailView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

struct DetailView: View {
    let stateView: Main

    var body: some View {
        Layout(stateView: stateView, items: stateView.detailItems)
    }

    struct Layout: View {
        let stateView: Main
        let items: Array<Item>

        var body: some View {
            if items.count == 0 {
                Text("No items selected")
                    .background(.background)
            } else {
                ZStack {
                    ForEach(items.indices, id: \.self) { idx in
                        if items.count == 1 {
                            ItemView(stateView: stateView, item: items[idx])
                                .background(.background)
                        } else {
                            ItemView(stateView: stateView, item: items[idx])
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
