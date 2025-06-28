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
