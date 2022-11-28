//
//  AppDefs.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/11/2022.
//

import Foundation

struct AppDefs {
    static let URLScheme: String = "gowi" // As per target's registered URL Types URL Scheme
    
    // This maps to the Window scene to open
    enum UrlHost: String {
        case mainWindow = "main"
    }

    // Pay and Query are Window specific bc hopelly it'll makes exhaustive case handling easier
    // if add another Window that want routing.
    enum MainUrlPath: String {
        case showItems = "/v1/showitems"
        case newItem = "/v1/newItem"
    }

    enum MainUrlQuery: String {
        case itemId = "id"
        case filterId = "fid"
    }
    
    
}
