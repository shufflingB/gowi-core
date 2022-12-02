//
//  GowiApp.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

@main
struct GowiApp: App {
    enum WindowGroupId: String {
        case Main
    }

    @StateObject var appModel = AppModel.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup(id: WindowGroupId.Main.rawValue, for: Main.WindowGroupRoutingOpt.self) { $route in

            // See comments about how routing is handled in WindowGroupRouteView
            Main(with: appModel.systemRootItem, route: $route)
                .environmentObject(appModel)
                .environment(\.managedObjectContext, appModel.container.viewContext)
                .handlesExternalEvents(preferring: [Main.UrlRoot.absoluteString], allowing: ["*"])
                .onAppear {
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

extension GowiApp {
    /// Class to enable the App to access `AppKit` functionallity that currently has no sensible equivalent in `SwiftUI`
    ///
    /// Currently provides the following delegates methods:
    ///
    /// - ``applicationShouldTerminate(_:)`` - to detect when the App is about to exit  with unsaved data and to offer the user a choice of options about how to proceed.
    ///
    class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
        /// Shared instance of the App's `AppModel`
        /// - Precondition Must be set before anything in this `NSAppicationDelegate` class is likely to work.
        ///
        var appModel: AppModel?

        /// Delegate that gets run when the application is about to exit and checks what the user wants to do if there is any unsaved data
        /// - Warning  The `appModel` property must be initialised prior to invocation or the method will always just allow the app to exit regardless
        ///
        /// If `appModel.hasUnPushedChanges` is used to detect if the are any changes pending. If there are it runs up a modal `NSAlert` that ask how the user wishes to
        /// proceed. It uses this approach because:
        ///  1. There are no SwiftUI native options for detecting when the application is about to exit.
        ///  1. When the app is exited there may be no windows and all of the SwiffUI oprtions for displayaing a confirmation dialogue rely on having an existing window. i.e.
        ///  if didn't use `NSAlert` would have to resort to hacky open zero sized window type code, which is far more of a hack than this.
        func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
            guard let appModel = appModel else {
                log.fault("\(#function) expected appModel has not been set prior to being called; unable to check for unsaved data before app exit")
                return .terminateNow
            }
            if appModel.hasUnPushedChanges {
                let alert = NSAlert()
                alert.messageText = "About to exit with unsaved data"
                alert.informativeText = "all unsaved changes will be lost"
                alert.addButton(withTitle: "Save & Exit")
                alert.addButton(withTitle: "Exit")
                alert.addButton(withTitle: "Cancel Exit")
                alert.alertStyle = .warning

                let modalResponse = alert.runModal()

                switch modalResponse {
                case .alertFirstButtonReturn:
                    appModel.saveToCoreData()
                    return .terminateNow
                case .alertSecondButtonReturn:

                    return .terminateNow
                case .alertThirdButtonReturn:
                    return .terminateCancel
                default:
                    return .terminateCancel
                }

            } else {
                return .terminateNow
            }
        }
    }
}
