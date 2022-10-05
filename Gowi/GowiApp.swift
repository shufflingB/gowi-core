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
            Main()
                .environmentObject(appModel)
        }
    }
}
