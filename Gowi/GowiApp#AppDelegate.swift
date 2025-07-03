//
//  GowiApp#AppDelegate.swift
//  Gowi
//
//  Created by Jonathan Hume on 05/12/2022.
//

import os
import SwiftUI
import Foundation
import GowiAppModel
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension GowiApp {
    /**
     ## AppKit Integration Delegate
     
     Provides access to AppKit functionality that has no SwiftUI equivalent, particularly
     application lifecycle events that require AppKit's NSApplicationDelegate.
     
     ### Key Responsibilities:
     - **Application Termination**: Handles `applicationShouldTerminate` to check for unsaved changes
     - **Modal Dialogs**: Displays save/discard/cancel dialog when exiting with unsaved data
     - **AppKit Bridge**: Enables AppKit features not available in pure SwiftUI
     
     ### Architecture Notes:
     - Uses late binding for `appModel` since `@NSApplicationDelegateAdaptor` doesn't support constructor injection
     - Must be configured via `appModel` property assignment in parent's `onAppear`
     - Integrates with SwiftUI lifecycle while providing AppKit-specific functionality
     
     > Warning: The `appModel` property must be set before delegate methods are called, 
     > typically in the parent's `onAppear` handler.
     */
    class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
        /// Late-bound reference to the application's model
        ///
        /// This property is set by the parent app during the `onAppear` phase since
        /// `@NSApplicationDelegateAdaptor` doesn't support dependency injection through initializers.
        var appModel: AppModel?

        /// Handles application termination with unsaved data protection
        ///
        /// Called when the user attempts to quit the application. If there are unsaved changes,
        /// presents a modal dialog with three options:
        /// - **Save & Exit**: Persists changes and terminates
        /// - **Exit**: Discards changes and terminates  
        /// - **Cancel Exit**: Returns to application without terminating
        ///
        /// - Parameter sender: The NSApplication instance requesting termination
        /// - Returns: TerminateReply indicating whether to proceed with termination
        func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
            guard let appModel = appModel else {
                log.fault("\(#function) expected appModel has not been set prior to being called; unable to check for unsaved data before app exit")
                return .terminateNow
            }
            /*
             ## Why Use NSAlert Instead of SwiftUI Dialog?
             
             NSAlert is used here instead of SwiftUI's native dialog system because:
             
             1. **No SwiftUI Exit Detection**: SwiftUI has no native way to intercept and cancel 
                application termination
             2. **Window Independence**: App termination may occur when no windows are open, 
                but SwiftUI dialogs require an existing window context
             3. **Modal Blocking**: NSAlert provides true modal behavior that blocks the termination
                process until user responds
             4. **Less Complexity**: Avoids hacky workarounds like creating invisible windows 
                just to host SwiftUI dialogs
                
             This AppKit solution is cleaner and more reliable for this specific use case.
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
