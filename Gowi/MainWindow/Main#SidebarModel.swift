//
//  Main#SidebarModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

// The Main window's intents for its NavigationSplitView Sidebar
extension Main {
    /// Displayed Item filtering options and their corresponding label text
    enum SidebarFilterOpt: String, CaseIterable, Codable {
        case waiting = "Waiting", done = "Done", all = "All"
    }

    /// List of all available Item filtering options
    var sideBarAvailableFilters: Array<SidebarFilterOpt> {
        Array(SidebarFilterOpt.allCases)
    }
}
