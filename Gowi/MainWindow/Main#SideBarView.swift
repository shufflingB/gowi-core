//
//  Main#SidebarView.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import SwiftUI

extension Main {
    /// Creates the Sidebar view component of the Main Window's `NavigationSplitView`
    struct SidebarView: View {
        let stateView: Main

        var body: some View {
            Layout(
                listSelected: stateView.$sideBarFilterSelected, listOfAvailableFilters: stateView.sideBarAvailableFilters
            )
        }

        struct Layout: View {
            @Binding var listSelected: SidebarFilterOpt
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
    @Previewable @State var tabSelected: Main.SidebarFilterOpt = .waiting
    
    Main.SidebarView.Layout(
        listSelected: $tabSelected,
        listOfAvailableFilters: Array(Main.SidebarFilterOpt.allCases))

}
