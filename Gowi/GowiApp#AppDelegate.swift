//
//  GowiApp#AppDelegate.swift
//  Gowi
//
//  Created by Jonathan Hume on 05/12/2022.
//

import os
import SwiftUI
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension GowiApp {
    /**
     Enable access to `AppKit` functionallity that currently has no equivalent in `SwiftUI`

     > Warning:  The class's instance property ``appModel`` must be defined, i.e. not `nil`,  before this delegate will function correctly (use either the parent's `onAppear` or
     `onChange(of: appModel, perform:)` methods to do this)

     > Note: Why not `init(appModel:AppMmodel)`?  Bc unable to determine how to get `@NSApplicationDelegateAdaptor` to forward arguments to the init method.
     */

    class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
        /**
         Shared instance of the App's ``AppModel`` that must be set after it is available in the parent in either the parent's `onAppear` or `onChange(of: appModel, perform:)`
         methods.

         */
        var appModel: AppModel?

        /**
         Delegate that gets run when the application is about to exit. In this app runs a modal dialogue to determine what to do when the user attempts to exit the app with unsaved data.

         Modal provides the options to either:
         - Save and exit.
         - Exit without saving.
         - Cancel exit
         */
        func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
            guard let appModel = appModel else {
                log.fault("\(#function) expected appModel has not been set prior to being called; unable to check for unsaved data before app exit")
                return .terminateNow
            }
            /*
                Why directly run the modal dialogue here and not via SwiftUI?

                Because:
                    1. There are no SwiftUI native options for detecting when the application is about to exit and stopping it iff
                    necessary.
                    2. When the app is exited there may be no windows and all of the SwiffUI options for displaying a confirmation
                    dialogue rely on having an existing window. i.e. if didn't use `NSAlert` here would have to resort to hacky open zero
                    sized window type code.

                    => Less hacky.
             */
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
