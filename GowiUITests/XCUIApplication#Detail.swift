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
        return try validateElement(titleField, description: "Detail title field", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.MainWindowDetailTitleField.rawValue
        ])
    }

    func detailTitleValue(win: XCUIElement? = nil) throws -> String {
        return try detailTitle(win: win).value as! String
    }


    func detailIDButtonCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement = try win == nil ? win1 : win!
        let idButton = winS.buttons[AccessId.MainWindowDetailId.rawValue].firstMatch
        return try validateElement(idButton, description: "Detail ID button", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.MainWindowDetailId.rawValue
        ])
    }

    func detailIDValue(win: XCUIElement? = nil) throws -> String? {
        try detailIDButtonCopyToPasteBoard(win: win).click()
        return NSPasteboard.general.string(forType: .string)
        
    }

    
    func detailItemURLButtonCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement =  try win == nil ? win1 : win!
        let urlButton = winS.buttons[AccessId.MainWindowDetailItemURL.rawValue]
        return try validateElement(urlButton, description: "Detail URL copy button", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.MainWindowDetailItemURL.rawValue
        ])
    }

    func detailItemURLValue(win: XCUIElement? = nil) throws -> String? {
        try detailItemURLButtonCopyToPasteBoard(win: win).click()
        return NSPasteboard.general.string(forType: .string)
    }
    
    
    func detailCreateDateButtonToCopyToPasteBoard(win: XCUIElement? = nil) throws -> XCUIElement {
        let winS: XCUIElement =  try win == nil ? win1 : win!
        let createDateButton = winS.buttons[AccessId.MainWindowDetailCreatedDate.rawValue]
        return try validateElement(createDateButton, description: "Detail created date copy button", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.MainWindowDetailCreatedDate.rawValue
        ])
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
        return try validateElement(completedDateButton, description: "Detail completed date button", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.MainWindowDetailCompletedDate.rawValue
        ])
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
        return try validateElement(checkBox, description: "Detail completion checkbox", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.OptionalDatePickerDoneToggle.rawValue
        ])
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
        return try validateElement(datePicker, description: "Detail completed date picker")
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
        return try validateElement(dialogueElement, description: "Detail completed date picker dialogue")
    }

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
        return try validateElement(notesElement, description: "Detail notes text view", additionalUserInfo: [
            "accessibilityIdentifier": AccessId.MainWindowDetailTextEditor.rawValue
        ])
    }

    func detailNotesValue(win: XCUIElement? = nil) throws -> String {
        let notesElement = try detailNotes(win: win)
        return notesElement.value as! String
    }
}
