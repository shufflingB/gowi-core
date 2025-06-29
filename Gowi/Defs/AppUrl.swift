//
//  AppDefs.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation

// App level URL definitons useful to both both built and testing targets

// TODO: Would be nice to extract AppUrlScheme automatically
/// The registered URL Scheme for the app.
///
/// > Important:  Should be set to match that defined for the build target.
let AppUrlScheme: String = "gowi"

/// Describes how the URL host's value map to available app windows
///
enum AppUrlHost: String {
    case mainWindow = "main"
}

/// Describes how the URL path values  for the ``AppUrlHost/mainWindow`` to the available routes for the ``Main`` window.
enum AppMainUrlPath: String {
    case showItems = "/v1/showitems"
    case newItem = "/v1/newItem"
}

/// Describes how tthe URL query strings values maps to their route counterparts for the ``Main`` window.
enum AppMainUrlQuery: String {
    case itemId = "id"
    case filterId = "fid"
    case searchText = "search"
}

/// Encode a URL that shows things in  GOWI
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

    if let itemIdsSelected = itemIdsSelected {
        for id in itemIdsSelected {
            query.append(
                URLQueryItem(name: AppMainUrlQuery.itemId.rawValue, value: id.uuidString)
            )
        }
    }

    if let searchText = searchFilter, !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
        query.append(
            URLQueryItem(name: AppMainUrlQuery.searchText.rawValue, value: searchText)
        )
    }

    components.queryItems = query.count > 0 ? query : nil
    return components.url
}

func urlEncodeNewItem() -> URL? {
    var components = URLComponents()
    components.scheme = AppUrlScheme
    components.host = AppUrlHost.mainWindow.rawValue
    components.path = AppMainUrlPath.newItem.rawValue
    return components.url
}
