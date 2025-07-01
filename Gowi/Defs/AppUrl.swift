//
//  AppDefs.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation

/**
 ## Application URL Scheme Definitions
 
 Defines the custom URL scheme structure for deep linking into the Gowi application.
 These definitions are shared between the main app and testing targets to ensure
 consistent URL handling across the application.
 
 ### URL Structure:
 `gowi://host/path?query`
 
 - **Scheme**: `gowi` (registered custom scheme)
 - **Host**: Identifies target window type (e.g., `main`)
 - **Path**: Specifies the route within that window
 - **Query**: Parameters for the route (filter, items, search)
 
 ### Deep Linking Capabilities:
 - Navigate to specific filter views (All/Waiting/Done)
 - Select specific items by UUID
 - Apply search filters
 - Create new items
 
 ### Usage:
 Both encoding and decoding functions are provided to translate between
 internal app state and URL representations for consistent deep linking behavior.
 */

// TODO: Extract AppUrlScheme automatically from build target configuration
/// The registered custom URL scheme for the Gowi application
///
/// This scheme enables deep linking from external sources (browser, other apps)
/// into specific parts of the Gowi application interface.
///
/// > Important: Must match the URL scheme defined in the app's build target
let AppUrlScheme: String = "gowi"

/// Maps URL host values to specific window types in the application
///
/// The host component of URLs determines which window type should handle
/// the deep link request. Currently only Main windows are supported.
enum AppUrlHost: String {
    /// Main todo list window that displays items with filtering capabilities
    case mainWindow = "main"
}

/// Maps URL path values to specific routes within Main windows
///
/// The path component specifies what action should be taken within the Main window.
/// Version prefix (v1) allows for future API evolution while maintaining compatibility.
enum AppMainUrlPath: String {
    /// Display existing items with optional filtering and selection
    case showItems = "/v1/showitems"
    
    /// Create a new item and display it ready for editing
    case newItem = "/v1/newItem"
}

/// Maps URL query parameter names to their semantic meaning for Main window routes
///
/// Query parameters provide additional context for routing within Main windows,
/// enabling precise navigation to specific application states.
enum AppMainUrlQuery: String {
    /// UUID of specific item(s) to select (can appear multiple times)
    case itemId = "id"
    
    /// Filter to apply: "All", "Waiting", or "Done"
    case filterId = "fid"
    
    /// Search text to apply to the current filter
    case searchText = "search"
}

/// Encodes a URL for displaying specific items in the Main window
///
/// Creates a deep link URL that navigates to the Main window with specified
/// filter, selection, and search state. This enables bookmarking and sharing
/// of specific application views.
///
/// - Parameters:
///   - sidebarFilter: Which filter tab to show (All/Waiting/Done)
///   - itemIdsSelected: Set of item UUIDs to select
///   - searchFilter: Search text to apply to the filter
/// - Returns: Encoded URL or nil if encoding fails
func urlEncodeShowItems(sidebarFilter: SidebarFilterOpt?, itemIdsSelected: Set<UUID>?, searchFilter: String?) -> URL? {
    var components = URLComponents()
    components.scheme = AppUrlScheme
    components.host = AppUrlHost.mainWindow.rawValue
    components.path = AppMainUrlPath.showItems.rawValue

    var query: Array<URLQueryItem> = []

    if let sidebarFilter = sidebarFilter {
        query.append(
            URLQueryItem(name: AppMainUrlQuery.filterId.rawValue, value: sidebarFilter.rawValue)
        )
    }

    // Add multiple id parameters for multi-selection support
    if let itemIdsSelected = itemIdsSelected {
        for id in itemIdsSelected {
            query.append(
                URLQueryItem(name: AppMainUrlQuery.itemId.rawValue, value: id.uuidString)
            )
        }
    }

    // Include search text only if non-empty after trimming whitespace
    if let searchText = searchFilter, !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        query.append(
            URLQueryItem(name: AppMainUrlQuery.searchText.rawValue, value: searchText)
        )
    }

    components.queryItems = query.count > 0 ? query : nil
    return components.url
}

/// Encodes a URL for creating a new item in the Main window
///
/// Creates a deep link URL that opens the Main window and immediately
/// creates a new todo item ready for user input.
///
/// - Returns: Encoded URL for new item creation
func urlEncodeNewItem() -> URL? {
    var components = URLComponents()
    components.scheme = AppUrlScheme
    components.host = AppUrlHost.mainWindow.rawValue
    components.path = AppMainUrlPath.newItem.rawValue
    return components.url
}
