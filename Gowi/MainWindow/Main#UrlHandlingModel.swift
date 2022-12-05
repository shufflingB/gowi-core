//
//  Main#UrlHandlingModel.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//
import SwiftUI

import os

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/*
 Defines how URL's for the Main window are:
    1) mapped from incomming URLs to their actions and routes. As well as how
    2) created for existing routes.
 */

extension Main {
    /// Default root URL for the Main window view.
    static let UrlRoot: URL = {
        var components = URLComponents()
        components.scheme = AppUrlScheme
        components.host = AppUrlHost.mainWindow.rawValue
        return components.url!
    }()

    /// Encodes the window routing options for the apps Main window as a corresponding URL
    /// - Parameter routingOpts: options that need encoding
    /// - Returns: URL containing the encoded data
    static func urlEncode(_ routingOpts: WindowGroupRoutingOpt) -> URL? {
        var components = URLComponents()
        components.scheme = AppUrlScheme
        components.host = AppUrlHost.mainWindow.rawValue

        switch routingOpts {
        case let .showItems(_, sideBarFilterSelected, contentItemIdsSelected):

            components.path = AppMainUrlPath.showItems.rawValue

            let queryFilterSelected = URLQueryItem(
                name: AppMainUrlQuery.filterId.rawValue, value: sideBarFilterSelected.rawValue
            )

            let queryItems: Array<URLQueryItem> = contentItemIdsSelected.map { id in
                URLQueryItem(name: AppMainUrlQuery.itemId.rawValue, value: id.uuidString)
            }

            let query = [queryFilterSelected] + queryItems

            components.queryItems = query.count > 0 ? query : nil
        case .newItem(sideBarFilterSelected: _):
            break
        }

        guard let url = components.url else {
            log.warning("Failed to construct openNewWindowURL")
            return nil
        }
        return url
    }

    /// Entry point for decoding  a URL for the Main window into the app's equivalent routing information.
    /// - Parameter url: url for decoding
    /// - Returns: decoded routing options.
    static func urlDecode(_ url: URL) -> WindowGroupRoutingOpt? {
        // log.debug("\(#function) -   url = \(url)")

        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            log.warning("Failed URL decode, unable to resolve into components")
            return nil
        }

        guard components.scheme == AppUrlScheme else {
            log.warning("Failed URL decode; received unknowm scheme name (\(components.scheme ?? "nil"))  does not match that supported (\(AppUrlScheme)) ")
            return nil
        }

        if components.host != AppUrlHost.mainWindow.rawValue {
            log.warning("Failed URL decode; received request for unknown host window type (\(components.host ?? "nil"))")
            return nil

        } else {
            switch components.path {
            case AppMainUrlPath.showItems.rawValue:
                return decodeShowItems(queryItems: components.queryItems)
            case AppMainUrlPath.newItem.rawValue:
                return .newItem(sideBarFilterSelected: .waiting)
            default:
                log.warning("Failed URL decode; received request for unknown route path (\(components.path))")
                return nil
            }
        }
    }

    /// Decodes URL requests to showItems
    private static func decodeShowItems(queryItems: [URLQueryItem]?) -> WindowGroupRoutingOpt? {
        guard let queryItems = queryItems else {
            log.warning("Failed URL decode; received request with no info about filter to use or items to show")
            return nil
        }

        var sidebarSelected: SidebarFilterOpt = .all // Safe default
        var itemsSelected: Set<UUID> = [] // Safe default

        queryItems.forEach { (qi: URLQueryItem) in
            switch qi.name {
            case AppMainUrlQuery.filterId.rawValue:
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
            case AppMainUrlQuery.itemId.rawValue:
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
