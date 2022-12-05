//
//  Menubar.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import AppKit
import os
import SwiftUI

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

/// Builds the App's main Menubar.
struct Menubar: Commands {
    /*
     Why do we need appModel (when mainStateView#appModel is also present)?

     Bc mainStateView is only available when there is a Main window being rendered and
     focused. And the problem with that is that some of menubar commands need access to
     the AppModel's capabilities when there may be no Main windows. e.g. `New Item`
     commands would be expected to work even when just the app's menubar remains
     visible.
     */

    /// App's `AppModel` shared instance
    @ObservedObject var appModel: AppModel

    /// Currently focused ``Main`` view.
    @FocusedValue(\.mainStateView) var mainStateView: Main?

    @Environment(\.openWindow) internal var openWindow

    var body: some Commands {
        fileCommands
        itemCommands
        windowCommands
    }
}
