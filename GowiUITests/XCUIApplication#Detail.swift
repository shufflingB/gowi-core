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

    func detailIDButtonCopyToPasteBoard_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.buttons[AccessId.MainWindowDetailId.rawValue].firstMatch
    }

    func detailIDValue_NON_THROWING(win: XCUIElement? = nil) -> String? {
//        _ = detailIDButtonCopyToPasteBoard(win: win).waitForExistence(timeout: 2)
        detailIDButtonCopyToPasteBoard_NON_THROWING(win: win).click()
        return NSPasteboard.general.string(forType: .string)
    }

    func detailItemURLButtonCopyToPasteBoard_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.buttons[AccessId.MainWindowDetailItemURL.rawValue]
    }

    func detailItemURLValue_NON_THROWING(win: XCUIElement? = nil) -> String? {
//        _ = detailItemURLButtonCopyToPasteBoard.waitForExistence(timeout: 2)
        detailItemURLButtonCopyToPasteBoard_NON_THROWING(win: win).click()
        return NSPasteboard.general.string(forType: .string)
    }

    func detailCreateDateButtonToCopyToPasteBoard_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.buttons[AccessId.MainWindowDetailCreatedDate.rawValue]
    }

    func detailCreateDateValue_NON_THROWING(win: XCUIElement? = nil) -> String {
//        _ = detailCreateDateButtonToCopyToPasteBoard().waitForExistence(timeout: 2)
        detailCreateDateButtonToCopyToPasteBoard_NON_THROWING(win: win).click()
        return NSPasteboard.general.string(forType: .string)!
    }

    func detailCreateDateValueAsDate_NON_THROWING(win: XCUIElement? = nil) -> Date {
        let buttonDateValue: String = detailCreateDateValue_NON_THROWING(win: win)
        return Self.detailDateFormatter.date(from: buttonDateValue)!
    }

    func detailCompletedDateButtonToCopyToPasteBoard_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.buttons[AccessId.MainWindowDetailCompletedDate.rawValue]
    }

    func detailCompletedDateValue_NON_THROWING(win: XCUIElement? = nil) -> String {
//        _ = detailCompletedDateButtonToCopyToPasteBoard.waitForExistence(timeout: 2)
        detailCompletedDateButtonToCopyToPasteBoard_NON_THROWING(win: win).click()
        return NSPasteboard.general.string(forType: .string)!
    }

    func detailCompletedValueAsDate_NON_THROWING(win: XCUIElement? = nil) -> Date {
        let buttonDateValue: String = detailCompletedDateValue_NON_THROWING(win: win)

        return Self.detailDateFormatter.date(from: buttonDateValue)!
    }

    func detailCompletionCheckBox_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.checkBoxes[AccessId.OptionalDatePickerDoneToggle.rawValue]
    }

    func detailCompletionCheckBoxValue_NON_THROWING(win: XCUIElement? = nil) -> Bool {
//        _ = detailCompletionCheckBox.waitForExistence(timeout: 2)
        return detailCompletionCheckBox_NON_THROWING(win: win).value as! Bool
    }

    /// Returns the outter element of the picker.
    ///
    func detailCompletedDatePicker_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        // Don't appear to be able to select components of the date
        // individually on macOS. Seems to always land on YYYY
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!

        return winS.datePickers.element
    }

    func detailCompletedDatePickerValue_NON_THROWING(win: XCUIElement? = nil) -> String {
        return detailCompletedDatePicker_NON_THROWING(win: win).value as! String
    }

    func detailCompletedDatePickerValueAsDate_NON_THROWING(win: XCUIElement? = nil) -> Date {
        let pickerVal: String = detailCompletedDatePickerValue_NON_THROWING(win: win)

        /// PickerVal comes back with e.g. "Unsafe value, description '1945-12-25 12:12:27 +0000''"
        let pattern = #"(\d+-\d+-\d+ \d+:\d+)"#
        let matches = pickerVal.testingMatch(pattern)

        print("PickerVal = '\(pickerVal)', match = \(matches)")
        let capturedDateStr: String = (matches.first?.first)!
        return detailCompletedDateFormatter.date(from: capturedDateStr)!
    }

    func detailCompletedDatePickerOpenDialogue_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        detailCompletedDatePicker_NON_THROWING(win: win).steppers.children(matching: .decrementArrow).element
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
        detailCompletedDatePickerOpenDialogue_NON_THROWING(win: win).click()
        // Close it so can use keyboard entry
        detailCompletedDatePickerOpenDialogue_NON_THROWING(win: win).click()
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

        typeKey(.return, modifierFlags: []) // close picker diaglogue
    }

    func detailNotes_NON_THROWING(win: XCUIElement? = nil) -> XCUIElement {
        let winS: XCUIElement = win == nil ? win1_NON_THROWING : win!
        return winS.scrollViews[AccessId.MainWindowDetailTextEditor.rawValue].children(matching: .textView).element
    }

    func detailNotesValue_NON_THROWING(win: XCUIElement? = nil) -> String {
        detailNotes_NON_THROWING(win: win).value as! String
    }
}
