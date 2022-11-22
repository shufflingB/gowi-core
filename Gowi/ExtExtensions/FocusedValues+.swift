//
//  FocusedValues_.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 06/04/2022.
//

import SwiftUI

struct MainStateView: FocusedValueKey {
    typealias Value = Main
}


struct UndoWorkFocusAreaKey: FocusedValueKey {
    typealias Value = Main.UndoWorkFocusArea
}

extension FocusedValues {
    
    var mainStateView: MainStateView.Value? {
        get { self[MainStateView.self] }
        set {
            self[MainStateView.self] = newValue
        }
    }
    
    var undoWfa: UndoWorkFocusAreaKey.Value? {
        get { self[UndoWorkFocusAreaKey.self] }
        set {
            self[UndoWorkFocusAreaKey.self] = newValue
        }
    }
}
