//
//  Test_255_UpdatingItemCompletionDates.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 18/08/2022.
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
        app.sidebarAllList().click()
        app.contentRowTextField(3).click()
        XCTAssertFalse(app.detailCompletionCheckBoxValue(),
                       "When an Item that is incomplete")

        app.detailCompletionCheckBox().click()
        let completionClickDate: Date = Date()

        XCTAssertTrue(app.detailCompletionCheckBoxValue(),
                      "Has its completion checkbox clicked on it is marked as complete")

        let dateDisplayedInPicker = app.detailCompletedDatePickerValueAsDate()
        let deltaDateDisplayedAndSet = Calendar
            .current
            .dateComponents([.second], from: completionClickDate, to: dateDisplayedInPicker)
        XCTAssertLessThan(deltaDateDisplayedAndSet.second!, 60,
                          "And the Item's completion date matches to the nearest minute when the check box was clicked")

        app.menubarUndo.click()
        XCTAssertFalse(app.detailCompletionCheckBoxValue(),
                       "And if the completion is undone then completion checkbox is unmarked")

        app.menubarRedo.click()
        XCTAssertTrue(app.detailCompletionCheckBoxValue(),
                      "And if the completion is redone then completion checkbox is marked")

        let dateDisplayedInPickerAfterRedoing = app.detailCompletedDatePickerValueAsDate()
        XCTAssertEqual(dateDisplayedInPickerAfterRedoing, dateDisplayedInPicker
                       , "And the original date is restored")
    }

    func test_550_itemCanBeMarkCompletedInDetailAreaWithAProvidedDate() throws {
        app.sidebarAllList().click()
        app.contentRowTextField(3).click()

        let dateToSet = app.detailCompletedDateFormatter.date(from: "1945-12-25 12:12")!
        app.detailCompletedDatePickerSet(dateToSet)
        app.detailCompletionCheckBox().click()

        XCTAssertTrue(app.detailCompletionCheckBoxValue(),
                      "When the Item's completion checkbox is clicked it is marked as complete")

        let dateDisplayedInPicker = app.detailCompletedDatePickerValueAsDate()
        let deltaDateDisplayedAndSet = Calendar
            .current
            .dateComponents([.second], from: dateToSet, to: dateDisplayedInPicker)
        XCTAssertLessThan(deltaDateDisplayedAndSet.second!, 1,
                          "And the completion date that the user supplied for the Item is set")
    }

    func test_560_itemCompletionDataCanBeAdjustedAfterCompletionUsingKeyboardAndIsUndoable() throws {
        app.sidebarAllList().click()
        app.contentRowTextField(3).click()

        let dateToAdjustTo = app.detailCompletedDateFormatter.date(from: "1945-12-25 12:12")!
        app.detailCompletionCheckBox().click()
        XCTAssertTrue(app.detailCompletionCheckBoxValue(),
                      "When an Item is marked as completed")

        let originalDate = app.detailCompletedDatePickerValueAsDate()

        app.detailCompletedDatePickerSet(dateToAdjustTo)

        let dateDisplayedInPicker = app.detailCompletedDatePickerValueAsDate()

        XCTAssertEqual(dateDisplayedInPicker, dateToAdjustTo,
                       "Its completion date can subsequently be altered")

        let dateFromButton = app.detailCompletedValueAsDate()
        XCTAssertEqual(dateFromButton, dateDisplayedInPicker,
                       "And the value returned by Copy Date to Clipboard button matches that set in the picker")

        app.menubarUndo.click()
        app.menubarUndo.click()
        app.menubarUndo.click()
        app.menubarUndo.click()
        app.menubarUndo.click()

        let dateDisplayedInPickerAfterUndo = app.detailCompletedDatePickerValueAsDate()
        XCTAssertEqual(dateDisplayedInPickerAfterUndo, originalDate,
                       "And after the date adjustment is undone the original date set is restored")
    }
}
