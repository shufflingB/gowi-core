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
        WindowGroup(id: WindowGroupId.Main.rawValue) {
            Main(with: appModel.systemRootItem)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.container.viewContext)
                
        }
        .commands {
            Main_MenuBar(appModel: appModel)
        }
    }
}
