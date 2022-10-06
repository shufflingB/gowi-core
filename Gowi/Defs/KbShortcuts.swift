//
//  KeyBoardShortcut.swift
//  KeyBoardShortcut
//
//  Created by Jonathan Hume on 18/08/2021.
//

import SwiftUI

/**
 Defaults impletement in the App aim to go for what most people are familiar before adopting shortcuts from more specialised apps that
 I admire for their usability. More concretely this shapes up as what does:
 -  Finder do
 - Notes ...
 - Xcode
 - Things
 */



struct KbShortcuts{
    static let fileSaveChanges = KeyboardShortcut("s", modifiers: .command)

    static let itemsNew = KeyboardShortcut("n", modifiers: .command) /// As A's in Reminders
    static let itemsDuplicate = KeyboardShortcut("d", modifiers: .command) /// As in Finder and other's Duplicate binding
    static let itemsDelete = KeyboardShortcut(.delete, modifiers: .command) /// As in Finder, idea with extra modifier is to prevent accidental.
    static let itemsMarkComplete = KeyboardShortcut("c", modifiers: [.command, .shift]) /// As in A's Reminders
    static let itemsMarkOpen = KeyboardShortcut("c", modifiers: [.option, .shift]) /// As in A's Reminders

    static let itemsOpenInNewWindow = KeyboardShortcut("o", modifiers: [.command, .option])
    static let itemsOpenInNewTab = KeyboardShortcut("o", modifiers: [.command])

    static let itemsSelectedMoveUpInList = KeyboardShortcut(.upArrow, modifiers: [.command, .control]) // As in A's Notes
    static let itemsSelectedMoveDownInList = KeyboardShortcut(.downArrow, modifiers: [.command, .control]) // As in A's Notes

    static let windowOpenTab = KeyboardShortcut("t", modifiers: [.command]) // As in A's Xcode, Safari etc
    static let windowOpenNew = KeyboardShortcut("t", modifiers: [.command, .shift]) // As ub A's Xcode

    // TODO: static let jumpToDetailTextEditor = KeyboardShortcut("j", modifiers: [.command]) // As in what A uses in Xcode
}

extension KbShortcuts { // Apple default defined shortcuts - only used in the UI testing
    /**
     Shortcuts that are  built in to SwiftUI default configuration, i.e. this App's code does not implement. I've definied them here because the small increase in the app's code size
     by having them is  outweighed by the reduced risk of wtf moments occuring in the future from accidentally defining conflicting shortcuts in the app and testing code bases.
     */

    static let appQuit = KeyboardShortcut("q", modifiers: [.command])
    static let windowClose = KeyboardShortcut("w", modifiers: [.command])
    static let windowsCloseAll = KeyboardShortcut("w", modifiers: [.command, .option])
    static let windowsMoveFocusToNext = KeyboardShortcut("`", modifiers: [.command])

    static let selectHeadOfList = KeyboardShortcut(.upArrow, modifiers: [.option])
    static let selectEndOfList = KeyboardShortcut(.downArrow, modifiers: [.option])
    static let NSPanelsOpenGoToPathEntryPanel = KeyboardShortcut("g", modifiers: [.command, .shift]) // Same for open and save, hence name ...

    static let undo = KeyboardShortcut("z", modifiers: [.command])
    static let redo = KeyboardShortcut("z", modifiers: [.command, .shift])
}
