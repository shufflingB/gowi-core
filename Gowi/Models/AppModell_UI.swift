//
//  Dummy.swift
//  Dummy
//
//  Created by Jonathan Hume on 27/09/2021.
//

import os
import SwiftUI

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension AppModel {
    #if canImport(AppKit)
        static func openNewTab() -> NSWindow? {
            if let currentWindow = NSApplication.shared.keyWindow {
                if let wc = currentWindow.windowController {
                    wc.newWindowForTab(nil)

                    if let newWindow = NSApplication.shared.keyWindow, currentWindow != newWindow {
                        log.debug("\(#function) - currentWindow = \(currentWindow.debugDescription)")
                        log.debug("\(#function) - newWindow = \(newWindow.debugDescription)")

                        currentWindow.addTabbedWindow(newWindow, ordered: .above)
                        return newWindow
                    }
                }
            }
            return nil
        }

//        static func openItemInNewMainWindow(_ item: Item) {
//            if let id = item.id {
//                Self.openItemInNewMainWindow(id)
//            } else {
//                log.warning("\(#function) - failed to obtain a id for item ")
//            }
//        }
//
//        static func openItemInNewMainWindow(_ id: UUID) {
//            guard let url = createURL(RoutingOpts(list: .all, selectId: id)) else {
//                log.warning("\(#function) - failed to create a URL ")
//                return
//            }
//            NSWorkspace.shared.open(url)
//        }

    #else
        #error("Unsupported platform - openItemInNewMainWindow and openItemInNewMainWindowTab  not defined")
    #endif

//    static func findNSWindow(_ windowIdentifier: String, existingInstances: Array<NSWindow>?) -> NSWindow? {
    ////        Array(NSApplication.shared.windows)
//
//        let foundWindows: Array<NSWindow> = NSApplication.shared.windows.filter { nsWindow in
//            guard let winId = nsWindow.identifier else {
//                return false
//            }
//
//            return winId.rawValue.contains(windowIdentifier)
//        }
//
//        let foundSansExistingInstances: Array<NSWindow> = {
//            guard let existingInstances = existingInstances else {
//                return foundWindows
//            }
//            return foundWindows.filter({ !existingInstances.contains($0) })
//
//        }()
//
//        if foundSansExistingInstances.count > 1 {
//            // For some
//            log.warning("Window identifier not unique, more than one window found matching viewString = \(windowIdentifier), will return last. Found window details follow ...")
//            foundSansExistingInstances.forEach { win in
//                log.warning("Number = \(win.windowNumber), identifier = \(win.identifier.debugDescription)")
//            }
//        } else if foundSansExistingInstances.count == 0 {
//            log.warning("Unable to match any windows using viewString = \(windowIdentifier)")
//        }
//
//        return foundSansExistingInstances.last
//    }
//
//    func saveChanges() {
//        AppModel.saveToCoreData(viewContext)
//    }
//
//    internal static func itemsOpenInNewWindow(items: Array<Item>) {
//        items.forEach { item in
//            AppModel.openItemInNewMainWindow(item)
//        }
//    }
//
//    internal func itemsOpenInNewTab(items: Array<Item>) {
//        items.forEach { item in
//            if let newWindow = AppModel.openItemInNewMainWindowTab(item) {
//                log.debug("Adding open in new tab for item \(item.titleS)")
//                let options = AppModel.RoutingOpts(selectId: item.id)
//                winRouteMsgAdd(windowNumber: newWindow.windowNumber, options: options)
//            }
//        }
//    }
//
//    static let umGroupClosePublisher = NotificationCenter.default
//        .publisher(for: .NSUndoManagerDidCloseUndoGroup)
//        .eraseToAnyPublisher()
//
//    func takeUndoOwnershipOf(_ item: Item, with newOwner: UndoManager) {
//        if let oldOwner = itemSuiUndoManagers[item] {
//            guard oldOwner != newOwner else {
//                return
//            }
//            resignUndoOwnershipOf(item, from: oldOwner)
//        }
//
//        log.debug("UM \(newOwner), setting as the owner of item with title = \(item.titleS)")
//        itemSuiUndoManagers[item] = newOwner
//    }
//
//    func resignAllUndoOwnershipFor(_ resigningUm: UndoManager) {
//        log.debug("UM \(resigningUm), looking to resign all ownership of Items")
//
//        let itemsOwnedByResigner = itemSuiUndoManagers
//            .filter({ _, val in
//                val == resigningUm
//            })
//
//        itemsOwnedByResigner.forEach { item, um in
//            resignUndoOwnershipOf(item, from: um)
//        }
//    }
//
//    func resignUndoOwnershipOf(_ item: Item, from resigningUm: UndoManager) {
//        guard let oldOwner = itemSuiUndoManagers[item] else {
//            log.debug("UM \(resigningUm), not resigning ownership, nothing registered as owning Item title \(item.titleS)")
//            return
//        }
//
//        guard oldOwner == resigningUm else {
//            log.debug("UM \(resigningUm), not resigning ownership, does not own Item title \(item.titleS),  (actual owner \(oldOwner))")
//            return
//        }
//
//        log.debug("UM \(resigningUm), resigning ownersship id = \(oldOwner))")
//        oldOwner.removeAllActions()
//        itemSuiUndoManagers[item] = nil
//    }

    /*
         func openWindow(inTab: Bool = false, routingOpts: RoutingOpts) {
             // TODO: Convert this over to full SwiftUI approach when it becomes available.
             /// As of Sep 2021, SwiftUI's macOS window management is a bit poop -  see  https://www.swiftui-lab.com/random-lessons#window-1
             ///
             /// **How this workaround works**
             /// Based on https://jujodi.medium.com/adding-a-new-tab-keyboard-shortcut-to-a-swiftui-macos-application-56b5f389d2e6
             /// This creates a new window and optionally adds it as  a tab by:
             /// If the The app has a key then  it
             /// 1.  Triggers the built in @IBAction  newWindowForTab  action the system uses for the "+"  on the tabBar. That action effectively forks
             /// the entire state.
             /// 2.  It then uses the fact that the new window has keyboard focus i.e. is ===  NSApp.keyWindow to get hold of the new window
             /// 3. Before assigning the newWindow as a tab to the current window. NB: if it's not assigned then the new window just exists as a current window
             ///
             /// else (because I couldn't figure out how to trigger creation of a new window when no keyWindow without a hack ...
             ///
             /// Open the the app via it's registered url handling regime which kicks the system into creating at least one new key window
             ///
             /// **NOTES**
             /// 1. Can't newWindow.contentView? = NSHostingView(rootView: ContentView ) - It generates a fuckton of warnings about using SwiftUI stuff such as SceneStorage outside
             ///  of the SwiftUI app lifecydle and others.
             ///
     //        log.debug("openWindow got routing options = \(String(describing: routingOpts))")

             if let currentWindow = NSApp.keyWindow {
                 if let wc = currentWindow.windowController {
                     wc.newWindowForTab(nil)

                     if let newWindow = NSApp.keyWindow, currentWindow != newWindow {
                         if inTab == true {
                             currentWindow.addTabbedWindow(newWindow, ordered: .above)
                         }
                         appModel.appRouter?.route(routingOpts)
                     }
                 }
             } else { /// App is running but has no (main) windows open to fork from via newWindowForTab and creating manually is horrible, so fire up the hack -
                 /// anyone know of a better way to do this let me know.
                 // TODO: Remove HACK when SwiftUI does a better job of handling windows on macOS (or at least documents it)
                 /// Background - Unable to find and figure our how to persuade the app to trigger the "create me a new default" keyWindow functionallity i.e. the functionallity that
                 /// that must be present because clicking on the dock item for the app triggers exactly what's needed. To work around this we use the app's deeplinking
                 /// capabilities to achieve something, that to the outside world will look  identical as long as enough deep linking feature parity exists.
                 ///

                 log.debug("Using openURL hack to trigger reoppening of key windows")
                 if let url = Self.createRoutingURL(routingOpts) {
                     Self.openURL(url)
                 }
             }
         }
          */
}
