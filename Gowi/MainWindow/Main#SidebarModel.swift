//
//  Main#SidebarModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

// The Main window's intents for its NavigationSplitView Sidebar
extension Main {

    /// List of all available Item filtering options
    var sideBarAvailableFilters: Array<SidebarFilterOpt> {
        Array(SidebarFilterOpt.allCases)
    }
}
