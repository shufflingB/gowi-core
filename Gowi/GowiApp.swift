//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/10/2022.
//

import SwiftUI

@main
struct GowiApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
