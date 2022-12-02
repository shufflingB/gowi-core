//
//  Main#SidebarModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI
extension Main {
    var sideBarAvailableFilters: Array<SidebarFilterOpt> {
        withAnimation {
            Array(SidebarFilterOpt.allCases)
        }
    }
}
