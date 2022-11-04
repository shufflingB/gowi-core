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
        Layout(item: item, urlForItem: itemURL, itemSetCompletionDate: { nv in
            withAnimation {
                item.completed = nv
                stateView.appModel.objectWillChange.send()
            }

        })
    }

    private var itemURL: URL {
        let routingOpts: Main.WindowGroupRoutingOpt = .showItems(sideBarFilterSelected: stateView.sideBarFilterSelected, contentItemIdsSelected: [item.ourIdS])
        return Main.urlEncode(routingOpts)!
    }

    struct Layout: View {
        @ObservedObject var item: Item
        let urlForItem: URL
        let itemSetCompletionDate: (Date?) -> Void

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

                dateRow()
                    .padding(.horizontal)

                TextEditor(text: $item.notesS)
                    .accessibilityIdentifier(AccessId.MainWindowDetailTextEditor.rawValue)
                    .cornerRadius(4)
                    .font(.title3)
                    .padding()
            }
            .shadow(radius: 2)
            .frame(alignment: .leading)
        }

        private func routingRow() -> some View {
            return
                HStack {
                    Button {
                        item.ourIdS.uuidString.copyToPasteboard()

                    } label: {
                        Text("ID:")
                    }

                    .accessibilityIdentifier(AccessId.MainWindowDetailId.rawValue)
                    .help("Copy Item's unique identifier to the clipboard")

                    Text(item.ourIdS.uuidString)

                    Spacer()

                    Button {
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

        private func dateRow() -> some View {
            var dFmt: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter
            }

            var createdDate: String {
                if let created = item.created {
                    return dFmt.string(from: created)
                } else {
                    return "No date set"
                }
            }

            var completedDate: String {
                if let completed = item.completed {
                    return dFmt.string(from: completed)
                } else {
                    let baseStr = "Incomplete"
                    return baseStr.padding(toLength: 17, withPad: " ", startingAt: 0)
                }
            }

            return HStack {
                Button {
                    createdDate.copyToPasteboard()
                } label: {
                    Label("Created:", systemImage: "calendar")
                }
                .accessibilityIdentifier(AccessId.MainWindowDetailCreatedDate.rawValue)
                .help("Copy the Item's creation date to the clipboard")
                Text(createdDate)

                Spacer()
                Button {
                    completedDate.copyToPasteboard()
                } label: {
                    Label("Completed:", systemImage: "calendar")
                }
                .accessibilityIdentifier(AccessId.MainWindowDetailCompletedDate.rawValue)
                .help("Copy the Item's completion date to the the clipboard")

                OptionalDatePickerView(
                    setLabel: "Done:",
                    id: item.ourIdS,
                    externalDate: item.completed,
                    externalDateUpdate: { nv in
                        itemSetCompletionDate(nv)
                    }
                )
            }
            .padding(5)
            .overlay(RoundedRectangle(cornerRadius: 4)
                .stroke(Color.secondary, lineWidth: 0.5))
        }
    }
}
