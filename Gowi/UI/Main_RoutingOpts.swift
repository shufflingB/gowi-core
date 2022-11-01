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
//        typealias RawValue = URL?

        case showItems(msgId: UUID, sideBarFilterSelected: SideBar.ListFilterOption, contentItemIdsSelected: Set<UUID>)

//        init?(rawValue: URL?) {
//
//            guard let url = rawValue, let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
//                log.warning("Attempt to decode URL '\(rawValue?.absoluteString ?? "nil")' that cannot be resolved")
//                return nil
//            }
//
//
//            switch components.path {
//            case Main.UrlPath.showItems.rawValue:
//                log.debug("show items")
//
//            default:
//                log.warning("Received request to handle URL of unknown path \(url)")
//                return nil
//            }
//        }
//
//
//
//        var rawValue: URL? {
//            var components = URLComponents()
//
//            components.scheme = GowiApp.URLScheme
//            components.host = UrlHost.main.rawValue
//
//            guard let url = components.url else {
//                log.warning("Failed to construct openNewWindowURL")
//                return nil
//            }
//            return url
//        }
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
        log.debug("URL = \(url)")
        return url
    }

    static func urlDecode(_ url: URL) -> RoutingOpt? {
        return nil
//        log.debug("\(#function) -  url = \(url)")

//        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
//            log.warning("Attempt to decode URL that cannot be resolved")
//            return nil
//        }
//
//        var routing: RoutingOpt?
//
//        switch components.path {
//        case UrlPath.showItems.rawValue:
//            log.debug("")
//            // Find the filter first
//            components.queryItems?.first(where: { (qItem: URLQueryItem) in
//                if qItem.name ==
//            })
//
//        default:
//            log.warning("Received request to handle URL of unknown structure")
//            return nil
//        }
    }
}
