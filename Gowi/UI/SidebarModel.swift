//
//  Main_SideBarModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 12/10/2022.
//

import SwiftUI
extension Main {
    var sideBarAvailableFilters: Array<Sidebar.ListFilterOption> {
        withAnimation {
            Array(Sidebar.ListFilterOption.allCases)
        }
    }
}
