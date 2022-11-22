//
//  KbShortcuts.swift
//  KbShortcuts
//
//  Created by Jonathan Hume on 18/08/2021.
//

import SwiftUI

/*
 The default keybindings used in this app.

 The aim here is to setup definitions for the App what most people are familiar with, dropping back to adopting
 shortcuts from more specialised apps that I admire for their usability, before finally falling back to fully
 bespoke.
 
 More concretely this shapes up as:
 - Finder do
 - Notes, Reminders,
 - Xcode, Mail
 - Things
 - bespoke concoction

 For the less obivous shortcut definitions, where it originates from is marked in a comment.
 
 */

struct KbShortcuts {
    static let fileSaveChanges = KeyboardShortcut("s", modifiers: .command)

    static let itemsNew = KeyboardShortcut("n", modifiers: .command) // Reminders'
    static let itemsDuplicate = KeyboardShortcut("d", modifiers: .command) // Finder and other

    static let itemsDelete = KeyboardShortcut(.delete, modifiers: .command) // Finder but with extra modifier to prevent accidental.
    static let itemsMarkComplete = KeyboardShortcut("c", modifiers: [.command, .shift]) // Reminders
    static let itemsMarkOpen = KeyboardShortcut("c", modifiers: [.option, .shift]) // Reminders

    static let itemsOpenInNewWindow = KeyboardShortcut("o", modifiers: [.command, .option])
    static let itemsOpenInNewTab = KeyboardShortcut("o", modifiers: [.command])

    static let itemsSelectedNudgePriorityUp = KeyboardShortcut(.upArrow, modifiers: [.command, .control]) // Notes
    static let itemsSelectedNudgePriorityDown = KeyboardShortcut(.downArrow, modifiers: [.command, .control]) // Notes

    static let windowOpenTab = KeyboardShortcut("t", modifiers: [.command]) // Xcode, Safari etc
    static let windowOpenNew = KeyboardShortcut("t", modifiers: [.command, .shift]) // Xcode

    // TODO: static let jumpToDetailTextEditor = KeyboardShortcut("j", modifiers: [.command]) // As in what A uses in Xcode
}

/*
 This extension contains kShortcuts that are  built in to SwiftUI default configuration but that are not used in app,
 i.e. deleting them will not cause the app to stop compiling (it may break the compilation of the tests though).

 They're I've definied here as shared dependency between the app and its tests because in my judgement the small
 increase in the app's code size is outweighed by the reduced risk of wtf moments occuring in the future from accidentally defining conflicting shortcuts in the app and
 testing code bases.
 */
extension KbShortcuts { // Apple default defined shortcuts - only used in the UI testing
    static let appQuit = KeyboardShortcut("q", modifiers: [.command])
    static let onExit = KeyboardShortcut(.escape)
    static let windowClose = KeyboardShortcut("w", modifiers: [.command])
    static let windowsCloseAll = KeyboardShortcut("w", modifiers: [.command, .option])
    static let windowsMoveFocusToNext = KeyboardShortcut("`", modifiers: [.command])
    static let selectHeadOfList = KeyboardShortcut(.upArrow, modifiers: [.option])
    static let selectEndOfList = KeyboardShortcut(.downArrow, modifiers: [.option])

    // A uses the same shortcut for opening the entry panel with its open and save dialogues, hence name ...
    static let NSPanelsOpenGoToPathEntryPanel = KeyboardShortcut("g", modifiers: [.command, .shift])
    static let undo = KeyboardShortcut("z", modifiers: [.command])
    static let redo = KeyboardShortcut("z", modifiers: [.command, .shift])
}
