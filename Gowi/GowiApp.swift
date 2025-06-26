//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

@main
struct GowiApp: App {
    /// The unique identities of the Window *(Scene)*  types that the app is able to manage the routing for
    ///
    ///
    enum WindowGroupId: String {
        case Main
    }
    
    init() {
         // CommandLine parsing here
         if CommandLine.arguments.contains("--uitesting-reset-state") {
             // Clear UserDefaults
             if let bundleID = Bundle.main.bundleIdentifier {
                 UserDefaults.standard.removePersistentDomain(forName: bundleID)
                 UserDefaults.standard.synchronize()
             }
             // Add any other state-reset logic here (e.g., delete files, clear caches)
         }
     }
    

    /*
     Why `AppModel.shared`? A shared  single instance of the ``AppModel`` is used here as well as `@StateObject` (which nominally does the
     same thing) bc the `@StateObject` magic do not work everywhere where it might be required. Specifically it didn't function in
     SwiftUI's Command builders (such as ``Menubar``) or outside of SwiftUI om things like ``and so on.
      */

    /// The app's  instance of the ``AppModel``
    @StateObject var appModel = AppModel.shared

    /// The app's instance of the AppKit `NSApplicationDelegate` ``AppDelegate-swift.class``
    @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup(id: WindowGroupId.Main.rawValue, for: Main.WindowGroupRoutingOpt.self) { $route in
            // See comments about how routing is handled in WindowGroupRouteView
            Main(with: appModel.systemRootItem, route: $route)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.viewContext)
                .handlesExternalEvents(preferring: [Main.UrlRoot.absoluteString], allowing: ["*"]) // Anything that starts with this URL gets handled by this window.
                .onAppear {
                    // Assign the appModel to the delegate. Must do this here bc been unable to figure out how to do it at delegate init.
                    appDelegate.appModel = appModel
                }
        }
        .handlesExternalEvents(matching: [Main.UrlRoot.absoluteString])
        .commands {
            Menubar(appModel: appModel)
            TextEditingCommands()
            SidebarCommands()
            ToolbarCommands()
        }
    }
}
