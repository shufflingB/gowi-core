//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import SwiftUI

@main
struct GowiApp: App {
    @StateObject var appModel = AppModel.sharedInMemoryWithTestData

    var body: some Scene {
        WindowGroup {
            Main(with: appModel.systemRootItem)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.container.viewContext)
        }
        .commands {
            Main_MenuBar(appModel: appModel)
        }
    }
}
