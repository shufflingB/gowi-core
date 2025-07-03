//
//  ItemView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import os
import SwiftUI
import GowiAppModel
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/**
 ## Individual Item Detail View Component
 
 Displays and enables editing of a single todo item's complete details including
 title, notes, dates, and metadata. This component provides the primary interface
 for item interaction within the detail pane.
 
 ### Features:
 - **Inline Editing**: Direct text editing of title and notes
 - **Date Management**: Creation and completion date display with editing
 - **Metadata Access**: Item ID and shareable URL generation
 - **Undo Integration**: Proper undo work focus area management
 - **Clipboard Support**: Easy copying of IDs, URLs, and dates
 
 ### Architecture:
 Uses the standard StateView + Layout pattern where the main struct handles
 dependency injection and the Layout struct contains the pure UI implementation.
 This enables comprehensive SwiftUI previews and testing.
 
 ### Focus Management:
 Implements sophisticated focus handling with multiple undo work focus areas
 for different types of edits (title, date, notes) to provide appropriate
 undo granularity and user experience.
 */
struct ItemView: View {
    let stateView: Main
    @ObservedObject var item: Item
    @Environment(\.undoManager) private var windowUM: UndoManager?

    var body: some View {
        Layout(
            item: item, 
            urlForItem: itemURL, 
            itemSetCompletionDate: { nv in
                withAnimation {
                    stateView.appModel.itemsSetCompletionDate(externalUM: windowUM, items: [item], date: nv)
                }
            }
        )
    }

    /// Generates a shareable deep link URL for this specific item
    ///
    /// Creates a gowi:// URL that will navigate directly to this item when opened.
    /// The URL preserves the current filter context to maintain user expectations
    /// about where the item appears in the interface.
    private var itemURL: URL {
        let routingOpts: Main.WindowGroupRoutingOpt = .showItems(
            openNewWindow: false, 
            sideBarFilterSelected: stateView.sideBarFilterSelected, 
            contentItemIdsSelected: [item.ourIdS], 
            searchText: nil
        )
        return Main.urlEncode(routingOpts)!
    }
}

extension ItemView {
    /// Pure UI layout component for item detail display and editing
    ///
    /// This component implements the complete item editing interface with proper
    /// focus management and undo work focus area coordination. It's designed as
    /// a separate struct to enable SwiftUI previews without StateView dependencies.
    fileprivate struct Layout: View {
        /// The item being displayed and edited
        @ObservedObject var item: Item
        
        /// Shareable URL for this item
        let urlForItem: URL
        
        /// Callback for updating the item's completion date
        let itemSetCompletionDate: (Date?) -> Void

        /// Tracks keyboard focus for navigation between fields
        @FocusState private var focus: FocusField?
        
        /// Current undo work focus area (for debugging/coordination)
        @FocusedValue(\.undoWfa) private var wfa: Main.UndoWorkFocusArea?

        /// Available focus targets within the item view
        enum FocusField {
            case title
        }

        var body: some View {
            VStack {
                // Item title field with focus management
                HStack {
                    TextField(
                        "Title",
                        text: $item.titleS
                    )
                    .focused($focus, equals: .title)
                }
                .accessibilityIdentifier(AccessId.MainWindowDetailTitleField.rawValue)
                .focusedValue(\.undoWfa, .detailTitle)
                .cornerRadius(8)
                .font(.title)
                .padding()

                // Metadata row (ID and URL)
                routingRow()
                    .padding(.horizontal)

                // Date information and completion controls
                dateRow()
                    .focusedValue(\.undoWfa, .detailCompletedDate)
                    .padding(.horizontal)

                // Main notes editing area
                TextEditor(text: $item.notesS)
                    .accessibilityIdentifier(AccessId.MainWindowDetailTextEditor.rawValue)
                    .focusedValue(\.undoWfa, .detailNotes)
                    .cornerRadius(4)
                    .font(.title3)
                    .padding()
                    .onExitCommand {
                        // Escape key returns focus to title for keyboard navigation
                        focus = .title
                    }
            }
            .shadow(radius: 2)
            .frame(alignment: .leading)
        }

        /// Displays item metadata with clipboard copy functionality
        ///
        /// Shows the item's unique identifier and provides buttons to copy both
        /// the UUID and the shareable deep link URL to the clipboard.
        private func routingRow() -> some View {
            return
                HStack {
                    // Copy item UUID button
                    Button {
                        item.ourIdS.uuidString.copyToPasteboard()
                    } label: {
                        Text("ID:")
                    }
                    .accessibilityIdentifier(AccessId.MainWindowDetailId.rawValue)
                    .help("Copy Item's unique identifier to the clipboard")

                    // Display the UUID (read-only)
                    Text(item.ourIdS.uuidString)

                    Spacer()

                    // Copy shareable URL button
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

        /// Displays creation and completion dates with copy and edit functionality
        ///
        /// Shows formatted creation date (read-only) and completion status with
        /// an interactive date picker for marking items complete or incomplete.
        private func dateRow() -> some View {
            // Shared date formatter for consistent display
            var dFmt: DateFormatter {
                let formatter = DateFormatter()
                formatter.dateStyle = .short
                formatter.timeStyle = .short
                return formatter
            }

            // Formatted creation date display
            var createdDate: String {
                if let created = item.created {
                    return dFmt.string(from: created)
                } else {
                    return "No date set"
                }
            }

            // Formatted completion status display
            var completedDate: String {
                if let completed = item.completed {
                    return dFmt.string(from: completed)
                } else {
                    let baseStr = "Incomplete"
                    // Pad for consistent alignment with completed dates
                    return baseStr.padding(toLength: 17, withPad: " ", startingAt: 0)
                }
            }

            return HStack {
                // Creation date (read-only with copy)
                Button {
                    createdDate.copyToPasteboard()
                } label: {
                    Label("Created:", systemImage: "calendar")
                }
                .accessibilityIdentifier(AccessId.MainWindowDetailCreatedDate.rawValue)
                .help("Copy the Item's creation date to the clipboard")
                Text(createdDate)

                Spacer()
                
                // Completion date (read-only with copy)
                Button {
                    completedDate.copyToPasteboard()
                } label: {
                    Label("Completed:", systemImage: "calendar")
                }
                .accessibilityIdentifier(AccessId.MainWindowDetailCompletedDate.rawValue)
                .help("Copy the Item's completion date to the clipboard")

                // Interactive completion date picker
                OptionalDatePickerView(
                    ourId: item.ourIdS,
                    setLabel: "Done:",
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


// MARK: - Previews


#Preview("Item Detail with dummy data") {
    @Previewable @StateObject var appModel = AppModel.sharedInMemoryWithTestData
    
    @Previewable @Environment(\.undoManager) var windowUm: UndoManager?
    
    let item: Item = appModel.systemRootItem.childrenListAsSet.first!
    let url = Main.urlEncode(
        .showItems(openNewWindow: false, sideBarFilterSelected: .waiting, contentItemIdsSelected: [item.ourIdS], searchText: nil)
    )!
    
    
    ItemView.Layout(item: item, urlForItem: url, itemSetCompletionDate: { nv in
        withAnimation {
            appModel.itemsSetCompletionDate(externalUM: windowUm, items: [item], date: nv)
        }
    })
}
