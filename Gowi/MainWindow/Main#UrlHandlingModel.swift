//
//  Main#UrlHandlingModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//
import SwiftUI

import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/**
 ## URL Handling for Main Window Deep Linking
 
 This extension implements bidirectional URL conversion for Main windows,
 enabling deep linking into specific application states and creating shareable
 URLs from current window configurations.
 
 ### Capabilities:
 - **URL Decoding**: Converts gowi:// URLs into internal routing structures
 - **URL Encoding**: Creates URLs from current window state for sharing/bookmarking
 - **Route Validation**: Ensures URLs contain valid parameters and fallback gracefully
 
 ### URL Format:
 `gowi://main/v1/showitems?fid=Waiting&id=UUID&search=text`
 `gowi://main/v1/newItem`
 
 ### Error Handling:
 Comprehensive validation with logging for debugging URL issues.
 Invalid URLs gracefully degrade to safe defaults where possible.
 */

extension Main {
    /// Base URL for Main window without any specific route parameters
    ///
    /// This URL represents the Main window type without specifying a particular
    /// route or parameters. Used as a foundation for URL composition and as a
    /// default when more specific routing information is not available.
    static let UrlRoot: URL = {
        var components = URLComponents()
        components.scheme = AppUrlScheme
        components.host = AppUrlHost.mainWindow.rawValue
        return components.url!
    }()

    /// Converts internal window routing state into a shareable URL
    ///
    /// This method enables the creation of deep link URLs from current window state,
    /// allowing users to bookmark specific views or share links to particular
    /// item selections and filter configurations.
    ///
    /// - Parameter routingOpts: Current window routing configuration to encode
    /// - Returns: URL representing the routing state, or nil if encoding fails
    static func urlEncode(_ routingOpts: WindowGroupRoutingOpt) -> URL? {
        switch routingOpts {
        case let .showItems(_, sideBarFilterSelected, contentItemIdsSelected, searchText):
            // Encode current view state with filter, selection, and search
            return urlEncodeShowItems(
                sidebarFilter: sideBarFilterSelected, 
                itemIdsSelected: contentItemIdsSelected, 
                searchFilter: searchText
            )
            
        case .newItem(sideBarFilterSelected: _):
            // newItem routes always use the same URL regardless of filter
            return urlEncodeNewItem()
        }
    }
    

    /// Converts a deep link URL into internal window routing configuration
    ///
    /// This method parses gowi:// URLs and translates them into the internal
    /// routing structures used by the window system. It provides comprehensive
    /// validation and error handling for malformed URLs.
    ///
    /// - Parameter url: The URL to decode (must use gowi:// scheme)
    /// - Returns: Parsed routing configuration, or nil if URL is invalid
    static func urlDecode(_ url: URL) -> WindowGroupRoutingOpt? {
        // Uncomment for URL debugging: log.debug("\(#function) -   url = \(url)")

        // Parse URL into components for validation and processing
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            log.warning("Failed URL decode, unable to resolve into components")
            return nil
        }

        // Validate that this is a gowi:// URL
        guard components.scheme == AppUrlScheme else {
            log.warning("Failed URL decode; received unknown scheme name (\(components.scheme ?? "nil"))  does not match that supported (\(AppUrlScheme)) ")
            return nil
        }

        // Validate host and route to appropriate window type
        if components.host != AppUrlHost.mainWindow.rawValue {
            log.warning("Failed URL decode; received request for unknown host window type (\(components.host ?? "nil"))")
            return nil

        } else {
            // Route based on path component
            switch components.path {
            case AppMainUrlPath.showItems.rawValue:
                return decodeShowItems(queryItems: components.queryItems)
            case AppMainUrlPath.newItem.rawValue:
                // newItem routes always default to waiting filter
                return .newItem(sideBarFilterSelected: .waiting)
            default:
                log.warning("Failed URL decode; received request for unknown route path (\(components.path))")
                return nil
            }
        }
    }

    /// Parses query parameters for showItems URL requests
    ///
    /// Extracts filter selection, item IDs, and search text from URL query parameters.
    /// Provides safe defaults for missing or invalid parameters to ensure the URL
    /// still results in a usable window state.
    ///
    /// - Parameter queryItems: Array of URL query parameters to parse
    /// - Returns: Configured showItems route or nil if no valid parameters found
    private static func decodeShowItems(queryItems: [URLQueryItem]?) -> WindowGroupRoutingOpt? {
        guard let queryItems = queryItems else {
            log.warning("Failed URL decode; received request with no info about filter to use or items to show")
            return nil
        }

        // Initialize with safe defaults in case parameters are missing or invalid
        var sidebarSelected: SidebarFilterOpt = .all  // Show all items by default
        var itemsSelected: Set<UUID> = []              // No selection by default  
        var searchText: String? = nil                  // No search filter by default

        // Process each query parameter and extract relevant values
        queryItems.forEach { (qi: URLQueryItem) in
            switch qi.name {
            case AppMainUrlQuery.filterId.rawValue:
                // Parse sidebar filter selection
                let qiVal: String? = qi.value
                switch qiVal {
                case SidebarFilterOpt.done.rawValue:
                    sidebarSelected = .done
                case SidebarFilterOpt.waiting.rawValue:
                    sidebarSelected = .waiting
                case SidebarFilterOpt.all.rawValue:
                    fallthrough
                default:
                    sidebarSelected = .all  // Default for invalid/missing filter
                }
                
            case AppMainUrlQuery.itemId.rawValue:
                // Parse item UUID (can appear multiple times for multi-selection)
                if let qiVal = qi.value, let id = UUID(uuidString: qiVal) {
                    itemsSelected.insert(id)
                }
                
            case AppMainUrlQuery.searchText.rawValue:
                // Extract search text (can be nil/empty)
                searchText = qi.value
                
            default:
                log.warning("URL decode; \(#function) received request to decode unknown query item (\(qi.name))")
            }
        }

        // Create routing configuration with parsed parameters
        return .showItems(
            openNewWindow: false, 
            sideBarFilterSelected: sidebarSelected, 
            contentItemIdsSelected: itemsSelected, 
            searchText: searchText
        )
    }
}
