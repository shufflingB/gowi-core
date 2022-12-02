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

struct Menubar: Commands {
    @ObservedObject var appModel: AppModel
    @Environment(\.openWindow) internal var openWindow
    @FocusedValue(\.mainStateView) var mainStateView: Main?

    var body: some Commands {
        fileCommands
        itemCommands
        windowCommands
    }
}
