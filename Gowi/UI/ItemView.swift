//
//  Detail.ItemView.swift
//  GowiApp
//
//  Created by Jonathan Hume on 03/10/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

struct ItemView: View {
    let stateView: Main
    @ObservedObject var item: Item



    var body: some View {
        Layout(item: item, urlForItem: itemURL, onItemCompletes: { _ in })
    }

    private var itemURL: URL {
        let routingOpts: Main.WindowGroupRoutingOpt = .showItems(sideBarFilterSelected: stateView.sideBarFilterSelected, contentItemIdsSelected: [item.ourIdS])
        return Main.urlEncode(routingOpts)!
    }
    
    struct Layout: View {
        @ObservedObject var item: Item
        let urlForItem: URL
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

                routingRow()
                    .padding(.horizontal)
            }
        }

        private func routingRow() -> some View {
            return
                HStack {
                    Button {
                        log.debug("Trigged copy of ID to clipboard")
                        item.ourIdS.uuidString.copyToPasteboard()

                    } label: {
                        Text("ID:")
                    }

                    .accessibilityIdentifier(AccessId.MainWindowDetailId.rawValue)
                    .help("Copy Item's unique identifier to the clipboard")

                    Text(item.ourIdS.uuidString)

                    Spacer()

                    Button {
                        log.debug("Trigged copy URL to clipboard")
                        urlForItem.absoluteString.copyToPasteboard()

                    } label: {
                        Image(systemName: "link")
                    }

                    .accessibilityIdentifier(AccessId.MainWindowDetailItemURL.rawValue)
                    .help("Copy Item's URL to the clipboard")
                }
                .padding(7)
                .overlay(RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.secondary, lineWidth: 0.5))
        }
    }
}
