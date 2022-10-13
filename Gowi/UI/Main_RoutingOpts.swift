//
//  AppModel_MainOpts.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 01/04/2022.
//
import SwiftUI

import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension Main {
    enum RoutingOpt: Hashable, Codable {
        case showItems(msgId: UUID, sideBarFilterSelected: SideBar.ListFilterOption, contentItemIdsSelected: Set<UUID>)
    }
}

extension Main { /// URL defs
    enum UrlPath: String {
        case showItems = "/v1/showitems"
//        case all = "/v1/all"
//        case waiting = "/v1/waiting"
//        case done = "/v1/done"
        case getEmpty = "/v1/getnew"
    }

    enum UrlHost: String {
        case main
    }

    enum UrlQuery: String {
        case itemId = "id"
        case filterId = "fid"
    }

    static func urlEncode(_ routingOpts: RoutingOpt) -> URL? {
        var components = URLComponents()

        components.scheme = GowiApp.URLScheme
        components.host = UrlHost.main.rawValue
       

        switch routingOpts {
        case let .showItems(msgId, sideBarFilterSelected, contentItemIdsSelected):
            _ = msgId
            components.path = UrlPath.showItems.rawValue
            
            let queryFilterSelected = URLQueryItem(
                name: UrlQuery.filterId.rawValue, value: sideBarFilterSelected.rawValue
            )

            let queryItems: Array<URLQueryItem> = contentItemIdsSelected.map { id in
                URLQueryItem(name: UrlQuery.itemId.rawValue, value: id.uuidString)
            }
            
            let query = [queryFilterSelected] + queryItems
//            let query = queryItems

            components.queryItems = query.count > 0 ? query : nil
        }

        guard let url = components.url else {
            log.warning("Failed to construct openNewWindowURL")
            return nil
        }
        print("URL = \(url)")
        return url
    }
    
    
    static func urlDecode(_ URL) -> RoutingOpt {

    }
}
