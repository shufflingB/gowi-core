//
//  FocusedValues_.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 06/04/2022.
//

import SwiftUI

struct WindowUndoManager: FocusedValueKey {
    typealias Value = UndoManager
}

extension FocusedValues {
    var windowUndoManager: WindowUndoManager.Value? {
        get { self[WindowUndoManager.self] }
        set {
//            print("Setting keyWindowUndoManager = \(newValue.debugDescription)")
            self[WindowUndoManager.self] = newValue
        }
    }
}
