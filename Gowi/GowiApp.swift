//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import SwiftUI




@main
struct GowiApp: App {
    static let URLScheme: String = "gowi" // As per target's registered URL Types URL Scheme
    
    enum WindowGroupId: String {
        case Main
    }

    @StateObject var appModel = AppModel.sharedInMemoryWithTestData

    var body: some Scene {
        WindowGroup(id: WindowGroupId.Main.rawValue, for: Main.RoutingOpt.self) { $fart in
//            _ = print("Fart = \(fart)")
            Main(with: appModel.systemRootItem, routing: fart)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.container.viewContext)
                .handlesExternalEvents(preferring: ["gowi://main/"], allowing: ["*"])
        }
        .handlesExternalEvents(matching: ["gowi://main/"])

        .commands {
            Main_MenuBar(appModel: appModel)
        }
    }
}

