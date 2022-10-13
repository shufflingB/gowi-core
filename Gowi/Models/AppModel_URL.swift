//
//  AppModel_Routing.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 24/03/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension AppModel {
 

//    static func createURL(_ routingOpts: RoutingOpts) -> URL? {
//        var components = URLComponents()
//        components.scheme = Self.UrlOpts.schemeName
//
//        components.host = UrlOpts.Host.main.rawValue
//
//        if routingOpts.getEmpty {
//            components.path = UrlOpts.Path.getEmpty.rawValue
//        } else {
//            switch routingOpts.list {
//            case .all:
//                components.path = UrlOpts.Path.all.rawValue
//            case .incomplete:
//                components.path = UrlOpts.Path.incomplete.rawValue
//            case .complete:
//                components.path = UrlOpts.Path.complete.rawValue
//            default:
//                components.path = ""
//            }
//
//            var query: [URLQueryItem] = []
//
//            if let id = routingOpts.selectId {
//                query.append(URLQueryItem(name: UrlOpts.Query.id.rawValue, value: id.uuidString))
//            }
//
//            components.queryItems = query.count > 0 ? query : nil
//        }
//        guard let url = components.url else {
//            log.warning("Failed to construct openNewWindowURL")
//            return nil
//        }
//
//        return url
//    }
//
//    static func decodeUrl(_ url: URL) -> AppModel.RoutingOpts? {
//        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
//            log.warning("Attempt to decode URL that cannot be resolved")
//            return nil
//        }
//
//        log.debug("\(#function) -  url = \(url)")
//
//        if components.path.lowercased() == AppModel.UrlOpts.Path.getEmpty.rawValue.lowercased() {
//            return AppModel.RoutingOpts(getEmpty: true)
//        } else {
//            let tab: AppModel.RoutingOpts.ListSelected = {
//                switch components.path {
//                case _ where components.path.lowercased() == AppModel.UrlOpts.Path.all.rawValue.lowercased():
//                    log.debug("Setting tab selected = all")
//                    return .all
//                case _ where components.path.lowercased() == AppModel.UrlOpts.Path.incomplete.rawValue.lowercased():
//                    log.debug("Setting tab selected = incomplete")
//                    return .incomplete
//                case _ where components.path.lowercased() == AppModel.UrlOpts.Path.complete.rawValue.lowercased():
//                    log.debug("Setting tab selected = complete")
//                    return .complete
//                default:
//                    log.warning("Opened url with no matching route, \(components.path), settting default \(AppModel.RoutingOpts.ListSelected.all.rawValue)")
//                    return .all
//                }
//            }()
//
//            let selectedId: UUID? = {
//                guard let queryItems = components.queryItems else {
//                    return nil
//                }
//
//                guard let idStr: String = queryItems[AppModel.UrlOpts.Query.id.rawValue] else { return nil }
//
//                guard let id: UUID = UUID(uuidString: idStr) else { return nil }
//
//                return id
//
//            }()
//
//            return AppModel.RoutingOpts(list: tab, selectId: selectedId)
//        }
//    }
}
