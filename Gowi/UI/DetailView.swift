//
//  Detail.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 27/09/2022.
//

import SwiftUI

struct Detail: View {
    let stateView: Main

    var body: some View {
        Layout(stateView: stateView, items: stateView.detailItems)
    }
}

extension Detail {
    struct Layout: View {
        let stateView: Main
        let items: Array<Item>

        var body: some View {
            if items.count == 0 {
                Text("No items selected")
            } else {
                ZStack {
                    ForEach(items.indices, id: \.self) { idx in
                        if items.count == 1 {
                            ItemView(stateView: stateView, item: items[idx])
                        } else {
                            ItemView(stateView: stateView, item: items[idx])
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

//struct Previews_Detail: PreviewProvider {
//    @StateObject static var am = AppModel(items: Test_Data)
//
//    static var previews: some View {
//        let items: Array<Item> = Main.detailItems(contenList: Array(am.items), contentSelected: [am.items.first!.id])
//
//        Detail.Layout(items: items, onItemCompletes: { _ in am.objectWillChange.send() })
//    }
//}
