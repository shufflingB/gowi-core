//
//  XCUIApplication#Detail.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

import XCTest

extension XCUIApplication {
    static let detailDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()

    var detailCompletedDateFormatter: DateFormatter {
        let displayedPickerDateFmt = DateFormatter()
        // TODO: Make this resistant to locale changes
        displayedPickerDateFmt.dateFormat = "yyyy-MM-dd HH:mm"
        return displayedPickerDateFmt
    }


    func detailTitle(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = try win == nil ? win1 : win!
        let titleField = winS.textFields[AccessId.MainWindowDetailTitleField.rawValue].firstMatch
        guard titleField.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail title field failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.MainWindowDetailTitleField.rawValue
            ])
        }
        return titleField
    }

    func detailTitleValue(win: XCUIElement? = nil) throws -> String {
        return try detailTitle(win: win).value as! String
    }


    func detailIDButtonCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = try win == nil ? win1 : win!
        let idButton = winS.buttons[AccessId.MainWindowDetailId.rawValue].firstMatch
        guard idButton.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail ID button failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.MainWindowDetailId.rawValue
            ])
        }
        return idButton
    }

    func detailIDValue(win: XCUIElement? = nil) throws -> String? {
        try detailIDButtonCopyToPasteBoard(win: win).click()
        return NSPasteboard.general.string(forType: .string)
        
    }

    
    func detailItemURLButtonCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement =  try win == nil ? win1 : win!
        let urlButton = winS.buttons[AccessId.MainWindowDetailItemURL.rawValue]
        guard urlButton.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail URL copy button failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.MainWindowDetailItemURL.rawValue
            ])
        }
        
        return urlButton
    }

    func detailItemURLValue(win: XCUIElement? = nil) throws -> String? {
        try detailItemURLButtonCopyToPasteBoard(win: win).click()
        return NSPasteboard.general.string(forType: .string)
    }
    
    
    func detailCreateDateButtonToCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement =  try win == nil ? win1 : win!
        let createDateButton = winS.buttons[AccessId.MainWindowDetailCreatedDate.rawValue]
        guard createDateButton.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail created date copy button failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.MainWindowDetailCreatedDate.rawValue
            ])
        }
        return createDateButton
    }


    func detailCreateDateValue(win: XCUIElement? = nil) throws-> String {
        try detailCreateDateButtonToCopyToPasteBoard(win: win).click()
        return NSPasteboard.general.string(forType: .string)!
    }
    
    
    func detailCreateDateValueAsDate(win: XCUIElement? = nil) throws -> Date {
        let buttonDateValue: String = try detailCreateDateValue(win: win)
        return Self.detailDateFormatter.date(from: buttonDateValue)!
    }

    
    
    func detailCompletedDateButtonToCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = try win == nil ? win1 : win!
        let completedDateButton = winS.buttons[AccessId.MainWindowDetailCompletedDate.rawValue]
        guard completedDateButton.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail completed date button failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.MainWindowDetailCompletedDate.rawValue
            ])
        }
        return completedDateButton
    }


    func detailCompletedDateValue(win: XCUIElement? = nil) throws -> String {
        try detailCompletedDateButtonToCopyToPasteBoard(win: win).click()
        guard let dateString = NSPasteboard.general.string(forType: .string) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Failed to get completed date string from pasteboard after clicking completed date button"
            ])
        }
        return dateString
    }

    func detailCompletedValueAsDate(win: XCUIElement? = nil) throws -> Date {
        let buttonDateValue: String = try detailCompletedDateValue(win: win)
        guard let date = Self.detailDateFormatter.date(from: buttonDateValue) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Failed to parse completed date from string: \(buttonDateValue)"
            ])
        }
        return date
    }

    func detailCompletionCheckBox(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = try win == nil ? win1 : win!
        let checkBox = winS.checkBoxes[AccessId.OptionalDatePickerDoneToggle.rawValue]
       
        guard checkBox.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail completion checkbox failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.OptionalDatePickerDoneToggle.rawValue
            ])
        }
        return checkBox
    }


    func detailCompletionCheckBoxValue(win: XCUIElement? = nil) throws -> Bool {
        let checkBox = try detailCompletionCheckBox(win: win)
        return checkBox.value as! Bool
    }


    /// Returns the outter element of the picker.
    ///
    func detailCompletedDatePicker(win: XCUIElement? = nil) throws -> XCUIElement {
        // Don't appear to be able to select components of the date
        // individually on macOS. Seems to always land on YYYY
        let winS: XCUIElement = try win == nil ? win1 : win!
        let datePicker = winS.datePickers.element
        guard datePicker.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail completed date picker failed to exist within timeout",
                "timeout": "3 seconds"
            ])
        }
        return datePicker
    }

    func detailCompletedDatePickerValue(win: XCUIElement? = nil) throws -> String {
        let picker = try detailCompletedDatePicker(win: win)
        return picker.value as! String
    }

    func detailCompletedDatePickerValueAsDate(win: XCUIElement? = nil) throws -> Date {
        let pickerVal: String = try detailCompletedDatePickerValue(win: win)

        /// PickerVal comes back with e.g. "Unsafe value, description '1945-12-25 12:12:27 +0000''"
        let pattern = #"(\d+-\d+-\d+ \d+:\d+)"#
        let matches = pickerVal.testingMatch(pattern)

        print("PickerVal = '\(pickerVal)', match = \(matches)")
        guard let capturedDateStr = matches.first?.first else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Failed to extract date string from picker value: \(pickerVal)"
            ])
        }
        guard let date = detailCompletedDateFormatter.date(from: capturedDateStr) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Failed to parse date from string: \(capturedDateStr)"
            ])
        }
        return date
    }


    func detailCompletedDatePickerOpenDialogue(win: XCUIElement? = nil) throws -> XCUIElement {
        let picker = try detailCompletedDatePicker(win: win)
        let dialogueElement = picker.steppers.children(matching: .decrementArrow).element
        guard dialogueElement.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail completed date picker dialogue failed to exist within timeout",
                "timeout": "3 seconds"
            ])
        }
        return dialogueElement
    }

//    func detailCompletedDatePickerOpenDialogue_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
//        detailCompletedDatePicker_NON_THROWING(win: win).steppers.children(matching: .decrementArrow).element
//    }

    func detailCompletedDatePickerSet(win: XCUIElement? = nil, _ date: Date) {
        // TODO: Fix the fragile code that assumes:
        // 1) Picker date format is always "dd/MM/yyyy, HH:mm"
        // 2) If possible, clicking on the picker always focuses on the yyyy part of the date
        // (currently no known way to specify individual selection of individual parts directly)
        let dateFormatter = DateFormatter()

        // Adjust date from left to right in the UI display as normally happens when user works on.
        // Select day part ...
        // Opens the mouse driven date selection dialogue
        do {
            try detailCompletedDatePicker(win: win).click()
        } catch {
            // Fall back to non-throwing approach for compatibility
            return
        }
        typeKey(.tab, modifierFlags: [.shift]) // onto MM
        typeKey(.tab, modifierFlags: [.shift]) // once more to put on dd

        do { // Day of month setting
            dateFormatter.dateFormat = "dd"
            let dayStr = dateFormatter.string(from: date)
            typeText(dayStr)
        }

        typeKey(.tab, modifierFlags: []) // onto MM

        do { // Month setting
            dateFormatter.dateFormat = "MM"
            let monthStr = dateFormatter.string(from: date)
            typeText(monthStr)
        }

        typeKey(.tab, modifierFlags: []) // onto YYYY

        do { // Year setting
            dateFormatter.dateFormat = "yyyy"
            let yearStr = dateFormatter.string(from: date)
            typeText(yearStr)
        }

        typeKey(.tab, modifierFlags: []) // onto HH

        do { // Hour setting
            dateFormatter.dateFormat = "HH"
            let hourStr = dateFormatter.string(from: date)
            typeText(hourStr)
        }

        typeKey(.tab, modifierFlags: []) // onto mm

        do { // Minute setting
            dateFormatter.dateFormat = "mm"
            let minuteStr = dateFormatter.string(from: date)
            typeText(minuteStr)
        }

        typeKey(.tab, modifierFlags: [])
    }

    func detailNotes(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = try win == nil ? win1 : win!
        let notesElement = winS.textViews[AccessId.MainWindowDetailTextEditor.rawValue]

        guard notesElement.waitForExistence(timeout: 3) else {
            throw XCTestError(.failureWhileWaiting, userInfo: [
                "description": "Detail notes text view failed to exist within timeout",
                "timeout": "3 seconds",
                "accessibilityIdentifier": AccessId.MainWindowDetailTextEditor.rawValue
            ])
        }
        return notesElement
    }

    func detailNotesValue(win: XCUIElement? = nil) throws -> String {
        let notesElement = try detailNotes(win: win)
        return notesElement.value as! String
    }
}
