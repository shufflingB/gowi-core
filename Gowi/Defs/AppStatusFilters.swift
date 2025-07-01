//
//  AppStatuses.swift
//  Gowi
//
//  Created by Jonathan Hume on 28/06/2025.
//

/**
 ## Sidebar Filter Options
 
 Defines the three filter categories available in the application sidebar for organizing
 and viewing todo items by completion status.
 
 ### Filter Types:
 - **All**: Shows all items regardless of completion status
 - **Waiting**: Shows only incomplete/pending items
 - **Done**: Shows only completed items
 
 ### Technical Details:
 - `String` raw values match the display labels in the UI
 - `CaseIterable` enables iteration for programmatic access
 - `Codable` supports URL encoding/decoding for deep linking
 - Used in routing, search state management, and UI filtering
 */
enum SidebarFilterOpt: String, CaseIterable, Codable {
    case waiting = "Waiting", done = "Done", all = "All"
}
