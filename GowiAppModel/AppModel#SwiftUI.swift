//
//  AppModel#SwiftUI.swift
//  GowiAppModel
//
//  Created by Jonathan Hume on 04/07/2025.
//

import SwiftUI
import CoreData

import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)


/**
 ## AppModel SwiftUI Integration
 
 This extension provides SwiftUI-specific functionality for AppModel, particularly
 factory methods for creating properly configured FetchRequest instances.
 
 ### Purpose:
 - **Separation of Concerns**: Keeps SwiftUI-specific code separate from core business logic
 - **Encapsulation**: Hides CoreData predicate construction details from UI layer
 - **Maintainability**: Centralizes FetchRequest configuration in one location
 - **Testability**: Enables unit testing of fetch logic independently
 */
extension AppModel {
    
    /// Configuration structure for FetchRequest that exposes predicate and sort descriptors for testing
    public struct FetchRequestConfiguration {
        public let predicate: NSPredicate?
        public let sortDescriptors: [NSSortDescriptor]
        
        internal init(predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]) {
            self.predicate = predicate
            self.sortDescriptors = sortDescriptors
        }
    }
    
    /// Creates the predicate and sort descriptors for fetching children of a specific root item
    ///
    /// This method provides the CoreData configuration for child item fetching.
    /// It's primarily intended for testing purposes, where you need access to the 
    /// predicate and sort descriptors directly.
    ///
    /// - Parameter root: The parent Item whose children should be fetched
    /// - Returns: A configuration object with predicate and sort descriptors
    ///
    /// ### Configuration:
    /// - **Predicate**: Fetches items where `parentList CONTAINS root`
    /// - **Sort Descriptors**: unordered
    public static func makeFetchRequestConfigForChildrenOf(_ parent: Item) -> FetchRequestConfiguration {
        return FetchRequestConfiguration(
            predicate: NSPredicate(format: "parentList CONTAINS %@", parent as CVarArg),
            sortDescriptors: []
        )
    }
    
    /// Creates a properly configured FetchRequest for fetching children of a specific root item
    ///
    /// This factory method encapsulates the CoreData predicate and sort descriptor logic
    /// required to fetch child items, providing a clean interface for SwiftUI views
    /// while maintaining separation between the data layer and UI layer.
    ///
    /// - Parameter root: The parent Item whose children should be fetched
    /// - Returns: A configured FetchRequest ready for use with SwiftUI's @FetchRequest based on makeFetchRequestConfigForChildrenOf setup
    ///
    /// ### Usage:
    /// ```swift
    /// // In SwiftUI view initialization:
    /// _itemsFromRoot = AppModel.fetchRequestForChildrenOf(rootItem)
    /// ```
    ///
    /// ### Configuration:
    /// - **Predicate**: Fetches items where `parentList CONTAINS root`
    /// - **Sort Descriptors**: Orders by priority descending (highest priority first)
    /// - **Animation**: Uses default SwiftUI animation for changes
    public static func fetchRequestForChildrenOf(_ parent: Item) -> FetchRequest<Item> {
        let config = makeFetchRequestConfigForChildrenOf(parent)
        return FetchRequest<Item>(
            sortDescriptors: config.sortDescriptors,
            predicate: config.predicate,
            animation: .default
        )
    }
        
    /// Pass-through undo operations boiler-plate
    private static func undoPreFlight(externalUM: UndoManager?, contextUM: UndoManager?)
    -> (externalUM: UndoManager, contextUM: UndoManager)? {
        guard let externalUM = externalUM else {
            log.debug("\(#function), Not reordering, externalUM is nil")
            return nil
        }
        
        guard let contextUM = contextUM else {
            log.debug("\(#function), Not reordering, contextUM is nil")
            return nil
        }
        return (externalUM, contextUM)
    }
    
    
    /**
     Registers a pass-through undo from one external undo manager that triggers an undo with another.
     - Parameters:
     - externalUM: The external `UndoManager` that the pass-through is to be registered with
     - undoableTgtUM: The  `UndoManager` (usually`AppModel#viewContext` (and possibly needs to be))  that will actually perform the undo and redo operations.
     - withTarget:  ..
     - actionName: The base action name to assign (shows up in the `Undo` and `Redo` App Menubar entries).
     - action: A closure containing the action tthat is to be made undoable by the `undoableTgtUM`
      */

    static func registerPassThroughUndo(
        with externalUM: UndoManager?, passingTo undoableTgtUM: UndoManager?, withTarget: AnyObject,
        setActionName actionName: String, action: @escaping () -> Void
    ) {
        //
        guard let (externalUM, undoableTgtUM) = Self.undoPreFlight(externalUM: externalUM, contextUM: undoableTgtUM) else {
            log.warning("\(#function) can't make undoable as externalUM is nil ")
            action()
            return
        }
        let extUMgroupsByEventStash = externalUM.groupsByEvent
        externalUM.groupsByEvent = false

        externalUM.beginUndoGrouping()

        // Carry out the action that can the undoableTgtUM "knows" how to to undo.
        undoableTgtUM.beginUndoGrouping()

        action()

        undoableTgtUM.endUndoGrouping()

        externalUM.registerUndo(withTarget: withTarget) { (targetInstance: AnyObject) in
            log.debug(" SwiftUI UndoManager undo call triggered running of pass-through to viewContext's UndoManager")
            withAnimation {
                undoableTgtUM.undo()
            }

            /// Register how to Redo the Undo if necessary
            externalUM.registerUndo(withTarget: targetInstance) { _ in
                log.debug("SwiftUI UndoManager undo call triggered running of its registered redo operation")
                withAnimation {
                    registerPassThroughUndo(with: externalUM, passingTo: undoableTgtUM, withTarget: withTarget, setActionName: actionName, action: action)
                }
            }
        }
        externalUM.setActionName(actionName)
        externalUM.endUndoGrouping()
        externalUM.groupsByEvent = extUMgroupsByEventStash
    }
}

