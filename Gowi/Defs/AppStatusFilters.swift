//
//  AppStatuses.swift
//  Gowi
//
//  Created by Jonathan Hume on 28/06/2025.
//

/// Displayed Item filtering options and their corresponding label text
enum SidebarFilterOpt: String, CaseIterable, Codable {
    case waiting = "Waiting", done = "Done", all = "All"
}
