//
//  Detail_OneItem.swift
//  tabViewPlay
//
//  Created by Jonathan Hume on 03/10/2022.
//

import SwiftUI

extension Detail {
    struct ItemView: View {
        @ObservedObject var item: Item
        let onItemCompletes: (_ item: Item) -> Void
        var body: some View {
            Layout(item: item, onItemCompletes: onItemCompletes)
        }

        struct Layout: View {
            @ObservedObject var item: Item
            let onItemCompletes: (_ item: Item) -> Void

            var body: some View {
                VStack {
                    HStack {
                        TextField(
                            "Title",
                            text: $item.titleS
                        )
                    }
                    .accessibilityIdentifier(AccessId.MainWindowDetailTitleField.rawValue)
                    .cornerRadius(8)
                    .font(.title)
                    .padding()
                }
            }

//            private func routingRow() -> some View {
//                let routingOpts = AppModel.RoutingOpts(list: .all, selectId: item.idS)
//                let url: URL = AppModel.createURL(routingOpts)!
//                let pasteboard = NSPasteboard.general
//                return
//                    HStack {
//                        Button {
//                            log.debug("Trigged copy of ID to clipboard")
//                            pasteboard.clearContents()
//                            pasteboard.setString(item.idS.uuidString, forType: .string)
//
//                        } label: {
//                            Text("ID:")
//                        }
//                        .focused(focus, equals: .detailIdCopyButton)
//                        .accessibilityIdentifier(AI.mainWindowDetailId)
//                        .help("Copy Item's unique identifier to the clipboard")
//
//                        Text("\(item.idS)")
//
//                        Spacer()
//
//                        Button {
//                            log.debug("Trigged copy URL to clipboard")
//                            pasteboard.clearContents()
//                            pasteboard.setString(url.absoluteString, forType: .string)
//
//                        } label: {
//                            Image(systemName: "link")
//                        }
//                        .focused(focus, equals: .detailLinkCopyButton)
//                        .accessibilityIdentifier(AI.mainWindowDetailItemURL)
//                        .help("Copy Item's URL to the clipboard")
//                    }
//                    .padding(7)
//                    .overlay(RoundedRectangle(cornerRadius: 4)
//                        .stroke(Color.secondary, lineWidth: 0.5))
//            }
        }
    }
}
