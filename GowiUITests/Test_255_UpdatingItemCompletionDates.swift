//
//  Test_255_UpdatingItemCompletionDates.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_255_UpdatingItemCompletionDates: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
    }


    func test_500_itemCanBeMarkCompletedInDetailAreaUsingADefaultDate() throws {
        try app.sidebarAllList().click()
        try app.contentRowTextField(3).click()
        XCTAssertFalse((try? app.detailCompletionCheckBoxValue()) ?? true,
                       "When an Item that is incomplete")

        try app.detailCompletionCheckBox().click()
        let completionClickDate: Date = Date()

        XCTAssertTrue((try? app.detailCompletionCheckBoxValue()) ?? false,
                      "Has its completion checkbox clicked on it is marked as complete")

        let dateDisplayedInPicker = try app.detailCompletedDatePickerValueAsDate()
        let deltaDateDisplayedAndSet = Calendar
            .current
            .dateComponents([.second], from: completionClickDate, to: dateDisplayedInPicker)
        XCTAssertLessThan(deltaDateDisplayedAndSet.second!, 60,
                          "And the Item's completion date matches to the nearest minute when the check box was clicked")

        try app.menubarUndo.click()
        XCTAssertFalse((try? app.detailCompletionCheckBoxValue()) ?? true,
                       "And if the completion is undone then completion checkbox is unmarked")

        try app.menubarRedo.click()
        XCTAssertTrue((try? app.detailCompletionCheckBoxValue()) ?? false,
                      "And if the completion is redone then completion checkbox is marked")

        let dateDisplayedInPickerAfterRedoing = try app.detailCompletedDatePickerValueAsDate()
        XCTAssertEqual(dateDisplayedInPickerAfterRedoing, dateDisplayedInPicker
                       , "And the original date is restored")
    }

    func test_550_itemCanBeMarkCompletedInDetailAreaWithAProvidedDate() throws {
        try app.sidebarAllList().click()
        try app.contentRowTextField(3).click()

        let dateToSet = app.detailCompletedDateFormatter.date(from: "1945-12-25 12:12")!
        app.detailCompletedDatePickerSet(dateToSet)
        try app.detailCompletionCheckBox().click()

        XCTAssertTrue((try? app.detailCompletionCheckBoxValue()) ?? false,
                      "When the Item's completion checkbox is clicked it is marked as complete")

        let dateDisplayedInPicker = try app.detailCompletedDatePickerValueAsDate()
        let deltaDateDisplayedAndSet = Calendar
            .current
            .dateComponents([.second], from: dateToSet, to: dateDisplayedInPicker)
        XCTAssertLessThan(deltaDateDisplayedAndSet.second!, 1,
                          "And the completion date that the user supplied for the Item is set")
    }

    func test_560_itemCompletionDataCanBeAdjustedAfterCompletionUsingKeyboardAndIsUndoable() throws {
        try app.sidebarAllList().click()
        try app.contentRowTextField(3).click()

        let dateToAdjustTo = app.detailCompletedDateFormatter.date(from: "1945-12-25 12:12")!
        try app.detailCompletionCheckBox().click()
        XCTAssertTrue((try? app.detailCompletionCheckBoxValue()) ?? false,
                      "When an Item is marked as completed")

        let originalDate = try app.detailCompletedDatePickerValueAsDate()

        app.detailCompletedDatePickerSet(dateToAdjustTo)

        let dateDisplayedInPicker = try app.detailCompletedDatePickerValueAsDate()

        XCTAssertEqual(dateDisplayedInPicker, dateToAdjustTo,
                       "Its completion date can subsequently be altered")

        let dateFromButton = try app.detailCompletedValueAsDate()
        XCTAssertEqual(dateFromButton, dateDisplayedInPicker,
                       "And the value returned by Copy Date to Clipboard button matches that set in the picker")

        try app.menubarUndo.click()
        try app.menubarUndo.click()
        try app.menubarUndo.click()
        try app.menubarUndo.click()
        try app.menubarUndo.click()

        let dateDisplayedInPickerAfterUndo = try app.detailCompletedDatePickerValueAsDate()
        XCTAssertEqual(dateDisplayedInPickerAfterUndo, originalDate,
                       "And after the date adjustment is undone the original date set is restored")
    }
}
