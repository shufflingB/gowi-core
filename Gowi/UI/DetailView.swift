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
        Layout(items: stateView.detailItems, onItemCompletes: {_ in} )
    }
}

extension Detail {
    struct Layout: View {
        let items: Array<Item>
        let onItemCompletes: (_ item: Item) -> Void

        var body: some View {
            if items.count == 0 {
                Text("No items selected")
            } else {
                ZStack {
                    ForEach(items.indices, id: \.self) { idx in
                        if items.count == 1 {
                            Detail.ItemView(item: items[idx], onItemCompletes: onItemCompletes)
                        } else {
                            Detail.ItemView(item: items[idx], onItemCompletes: onItemCompletes)
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
