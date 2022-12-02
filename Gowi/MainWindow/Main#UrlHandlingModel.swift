//
//  Main#UrlHandlingModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//
import SwiftUI

import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// URL defs
extension Main {
    ///
    ///

    static let UrlRoot: URL = {
        var components = URLComponents()
        components.scheme = AppDefs.URLScheme
        components.host = AppDefs.UrlHost.mainWindow.rawValue
        return components.url!
    }()

    static func urlEncode(_ routingOpts: WindowGroupRoutingOpt) -> URL? {
        var components = URLComponents()
        components.scheme = AppDefs.URLScheme
        components.host = AppDefs.UrlHost.mainWindow.rawValue

        switch routingOpts {
        case let .showItems(_, sideBarFilterSelected, contentItemIdsSelected):

            components.path = AppDefs.MainUrlPath.showItems.rawValue

            let queryFilterSelected = URLQueryItem(
                name: AppDefs.MainUrlQuery.filterId.rawValue, value: sideBarFilterSelected.rawValue
            )

            let queryItems: Array<URLQueryItem> = contentItemIdsSelected.map { id in
                URLQueryItem(name: AppDefs.MainUrlQuery.itemId.rawValue, value: id.uuidString)
            }

            let query = [queryFilterSelected] + queryItems

            components.queryItems = query.count > 0 ? query : nil
        case .newItem(sideBarFilterSelected: _):
            // TODO: Add new item URL encoding
            break
        }

        guard let url = components.url else {
            log.warning("Failed to construct openNewWindowURL")
            return nil
        }
        return url
    }

    static func urlDecode(_ url: URL) -> WindowGroupRoutingOpt? {
        // log.debug("\(#function) -   url = \(url)")

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            log.warning("Failed URL decode, unable to resolve into components")
            return nil
        }

        guard components.scheme == AppDefs.URLScheme else {
            log.warning("Failed URL decode; received unknowm scheme name (\(components.scheme ?? "nil"))  does not match that supported (\(AppDefs.URLScheme)) ")
            return nil
        }

        if components.host != AppDefs.UrlHost.mainWindow.rawValue {
            log.warning("Failed URL decode; received request for unknown host window type (\(components.host ?? "nil"))")
            return nil

        } else {
            switch components.path {
            case AppDefs.MainUrlPath.showItems.rawValue:
                return decodeShowItems(queryItems: components.queryItems)
            case AppDefs.MainUrlPath.newItem.rawValue:
                return .newItem(sideBarFilterSelected: .waiting)
            default:
                log.warning("Failed URL decode; received request for unknown route path (\(components.path))")
                return nil
            }
        }
    }

    private static func decodeShowItems(queryItems: [URLQueryItem]?) -> WindowGroupRoutingOpt? {
        guard let queryItems = queryItems else {
            log.warning("Failed URL decode; received request with no info about filter to use or items to show")
            return nil
        }

        var sidebarSelected: SidebarFilterOpt = .all // Safe default
        var itemsSelected: Set<UUID> = [] // Safe default

        queryItems.forEach { (qi: URLQueryItem) in
            switch qi.name {
            case AppDefs.MainUrlQuery.filterId.rawValue:
                let qiVal: String? = qi.value

                switch qiVal {
                case SidebarFilterOpt.done.rawValue:
                    sidebarSelected = .done
                case SidebarFilterOpt.waiting.rawValue:
                    sidebarSelected = .waiting

                case SidebarFilterOpt.all.rawValue:
                    fallthrough
                default:
                    sidebarSelected = .all
                }
            case AppDefs.MainUrlQuery.itemId.rawValue:
                if let qiVal = qi.value, let id = UUID(uuidString: qiVal) {
                    itemsSelected.insert(id)
                }
            default:
                log.warning("URL decode; \(#function) received request to decode query unknown query itemt (\(qi.name))")
            }
        }

        return .showItems(openNewWindow: false, sideBarFilterSelected: sidebarSelected, contentItemIdsSelected: itemsSelected)
    }
}
