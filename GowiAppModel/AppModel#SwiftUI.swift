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
    
    public static func nsFetchRequestForChildLinks(of parent: Item) -> NSFetchRequest<ItemLink> {
        let request = NSFetchRequest<ItemLink>(entityName: "ItemLink")
        request.predicate = NSPredicate(format: "parent == %@", parent)
        request.sortDescriptors = [NSSortDescriptor(key: "priority", ascending: true)]
        return request
    }
    
    public static func fetchRequestForChildLinks(of parent: Item) -> FetchRequest<ItemLink> {
        let nsRequest = nsFetchRequestForChildLinks(of: parent)
        
        return FetchRequest<ItemLink>(
            sortDescriptors: nsRequest.sortDescriptors ?? [],
            predicate: nsRequest.predicate,
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

