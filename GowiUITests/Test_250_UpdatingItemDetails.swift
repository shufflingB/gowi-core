//
//  Test_250_UpdatingItemDetails.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_250_UpdatingItemDetails: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Ensure we only have a single window
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_000_theItemsTitleIsEditableInBothTheContentListAndDetailAreas() throws {
        try app.menubarItemNew.click()

        /**
         Verify linkage between sidebar and detail view.
         NB: Bug in List - SwiftUI integration means impossible to select and enter text with tests in anything but empty title in sidebar TextFields
         https://stackoverflow.com/questions/66460596/textfield-inside-a-list-in-swiftui-on-macos-editing-not-working-well
          */
        /// Sidebar => Detail
        let sidebarEnteredTitle = "sidebar entered test title"
        try app.contentRowTextField(0).click()
        try app.contentRowTextField(0).typeText(sidebarEnteredTitle)
        XCTAssertEqual(try app.detailTitleValue(), sidebarEnteredTitle,
                       "The same title entered in the SideBar area should be present in the window's Detail area")

        /// Detail => Sidebar
        let additionalDetailEnteredTitle = " plus some more from detail"
        try app.detailTitle().click()
        try app.detailTitle().typeKey(.rightArrow, modifierFlags: [.command])
        try app.detailTitle().typeText(additionalDetailEnteredTitle)
        XCTAssertEqual(try app.contentRowTextFieldValue(0), sidebarEnteredTitle + additionalDetailEnteredTitle,
                       "Changes made to the item's title information in the Detail area should show up in its SideBar entry area")
    }

  

    func test_600_whenEditingTheItemsNotesUsesATextSpecificUndoAndRedoProcess() throws {
        /// ...  And not single characters
        app.shortcutItemNew()
        let notesAtStart = (try? app.detailNotesValue()) ?? ""
        let lorem = "Some test text to be removed by a single undo"
        try app.detailNotes().click()
        app.typeText(lorem)
        XCTAssertEqual((try? app.detailNotesValue()) ?? "", lorem,
                       "When I type in the Notes area it should that should be added to Item")

        app.shortcutUndo()
        XCTAssertEqual((try? app.detailNotesValue()) ?? "", notesAtStart,
                       "And after using the Undo Shortcut it should be removed")
    }
}
