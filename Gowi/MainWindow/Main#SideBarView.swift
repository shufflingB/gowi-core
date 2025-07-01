//
//  Main#SidebarView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import SwiftUI

/**
 ## Sidebar Navigation View - Left Pane of Main Window
 
 The SidebarView provides the primary navigation interface for filtering todo items
 by completion status. It renders as the left pane of the NavigationSplitView and
 drives the content filtering logic.
 
 ### Filter Options:
 - **All**: Shows all items regardless of completion status
 - **Waiting**: Shows only incomplete items (the default working view)
 - **Done**: Shows only completed items for review
 
 ### Features:
 - **Single Selection**: Only one filter can be active at a time
 - **Keyboard Navigation**: Full keyboard accessibility with arrow keys
 - **Accessibility**: Each filter option has proper accessibility identifiers
 - **State Persistence**: Filter selection persists across app sessions
 
 ### Design Notes:
 The view is intentionally minimal to maintain focus on the content area.
 Filter options use their raw string values for both display and accessibility,
 ensuring consistency between what users see and what UI tests can target.
 */
extension Main {
    /// Creates the Sidebar view component of the Main Window's `NavigationSplitView`
    struct SidebarView: View {
        let stateView: Main

        var body: some View {
            Layout(
                listSelected: stateView.$sideBarFilterSelected, listOfAvailableFilters: stateView.sideBarAvailableFilters
            )
        }

        /// Internal layout component that renders the filter list
        ///
        /// Separated into its own struct to enable SwiftUI previews and testing
        /// without requiring the full Main StateView dependency chain.
        struct Layout: View {
            /// Currently selected filter option (bound to parent state)
            @Binding var listSelected: SidebarFilterOpt
            
            /// Available filter options to display in the sidebar
            let listOfAvailableFilters: Array<SidebarFilterOpt>

            var body: some View {
                List(listOfAvailableFilters, id: \.self, selection: $listSelected) { filterByItem in
                    Text(filterByItem.rawValue)
                        .accessibilityIdentifier(filterByItem.rawValue)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var tabSelected: SidebarFilterOpt = .waiting
    
    Main.SidebarView.Layout(
        listSelected: $tabSelected,
        listOfAvailableFilters: Array(SidebarFilterOpt.allCases))

}
