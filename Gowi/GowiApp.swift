//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import SwiftUI

@main
struct GowiApp: App {
    enum WindowGroupId: String {
        case Main
    }

    @StateObject var appModel = AppModel.sharedInMemoryWithTestData

    var body: some Scene {
        WindowGroup(id: WindowGroupId.Main.rawValue, for: Main.WindowGroupRoutingOpt.self) { $route in
            Main(with: appModel.systemRootItem, route: $route)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.container.viewContext)
                .handlesExternalEvents(preferring: ["gowi://main/"], allowing: ["*"])
        }
        .handlesExternalEvents(matching: ["gowi://main/"])

        .commands {
            Menubar(appModel: appModel)
        }
    }
}
