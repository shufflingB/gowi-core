//
//  Test_060_ItemInformationInUI.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_060_ItemInformationInUI: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()

        NSPasteboard.general.clearContents()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_000_theItemsDetailAreaDisplaysItsTitleIdCreatedAndCompletionDatesAndNotes() throws {
        try app.menubarItemNew.click()
        let title = "\(#function) some other text"
        try app.detailTitle().click()
        app.typeText(title)

        XCTAssertEqual(try app.detailTitleValue(), title,
                      "The app's detail area should contain the item's title")

        XCTAssertNotNil(try? app.detailIDButtonCopyToPasteBoard(),
                        "And a button to copy the item's ID to the system clipboard")

        XCTAssertTrue(try app.detailItemURLButtonCopyToPasteBoard().waitForExistence(timeout: 1),
                      "And a button to copy a URL to the Item to the system clipboard")

        XCTAssertTrue(try app.detailCreateDateButtonToCopyToPasteBoard().waitForExistence(timeout: 1),
                      "And a button to copy the Item creation date to the system clipboard")

        XCTAssertNotNil(try? app.detailCompletedDateButtonToCopyToPasteBoard(),
                        "And a button to copy the Item completion date to the system clipboard")

        XCTAssertNotNil(try? app.detailCompletionCheckBox(),
                        "And a Checkbox to mark the item as completed")
    }

    func test_050_itemsAreDisplayedInTheWaitingDoneAndAllListsAccordingToTheirCompletionStatus() throws {
        // Create a new item
        try app.sidebarDoneList().click() // Ensure in a list that should not show newly created items by default
        try app.menubarItemNew.click()

        let titleStr = "\(#function) dummy test item"
        try app.detailTitle().click()

        app.typeText(titleStr)

        // Check newly minted items are visible by default

        XCTAssertEqual(try app.contentRowTextFieldValue(0), titleStr,
                       "Sidebar list which would not show the new item should get updated so that the new item is shown as its top item ")

        // ... visible in the All list
        try app.sidebarAllList().click()
        XCTAssertEqual(try app.contentRowTextFieldValue(0), titleStr,
                       "When the All items list is selected, the SideBar should show the title of the new item as its top item")

        // ... not visible in the Done list
        try app.sidebarDoneList().click()
        let foundInDoneCount: Int = try app.contentRows().reduce(0) { currentCount, row in
            if row.value as! String == titleStr {
                return currentCount + 1
            } else {
                return currentCount
            }
        }

        XCTAssertEqual(foundInDoneCount, 0,
                       "When the Done list is selected, the SideBar should NOT show the new item in any row")

        // ... and finally that the incomplete item is visible in the todo list
        try app.sidebarWaitingList().click()
        XCTAssertEqual(try app.contentRowTextFieldValue(0), titleStr,
                       "When the Todo items list is selected, the SideBar should show the new item as its top item ")

        //
        //
        //
        // Next, mark the item as done and check the completed item is showing up as expected
        //
        try app.sidebarWaitingList().click() // Ensure in a list that will not show a completed item unless correct business logic
        try app.detailCompletionCheckBox().click()
        let foundInDoneCount1: Int = try app.contentRows().reduce(0) { currentCount, row in
            if row.value as! String == titleStr {
                return currentCount + 1
            } else {
                return currentCount
            }
        }

        XCTAssertEqual(foundInDoneCount1, 0,
                       "After the Item is marked as complete it does not show up in the Waiting list")

        try app.sidebarDoneList().click()
        XCTAssertEqual(try app.contentRowTextFieldValue(0), titleStr,
                       "And instead now shows up as the most recent Item completed in the Done list")

        XCTAssertTrue((try? app.detailCompletionCheckBoxValue()) ?? false,
                      "Where it is marked as completed")

        // ... completed is visible in the All items list
        try app.sidebarAllList().click()
        XCTAssertEqual(try app.contentRowTextFieldValue(0), titleStr,
                       "And it also remains visible in the All Items list")
    }

    func test_100_detailAreaProvidesButtonToCopyTheItemIdToClipboard() throws {
        try app.menubarItemNew.click()
        XCTAssertNotNil(try? app.detailIDButtonCopyToPasteBoard(),
                        "The window's detail area should contain a button that displays the item's unique ID")

        let possibleUUIDString = try app.detailIDValue()

        XCTAssertNotNil(possibleUUIDString,
                        "And that button should be copy the item's id to the clipboard")

        XCTAssertNotNil(UUID(uuidString: possibleUUIDString!),
                        "and that string should be a UUID string")
    }

    func test_110_detailAreaProvidesButtonToCopyCreationDateToClipboard() throws {
        try app.menubarItemNew.click()
        XCTAssertTrue(try app.detailCreateDateButtonToCopyToPasteBoard().waitForExistence(timeout: 1),
                      "The window's detail area should contain a button that displays the item's creation date")

        XCTAssertNotNil(XCUIApplication.detailDateFormatter.date(from: try app.detailCreateDateValue()),
                        "And that button should copy the creation date to the clipboard")
    }

    func test_120_detailAreaProvidesButtonToCopyCompletedDateToClipboard() throws {
        try app.menubarItemNew.click()
        XCTAssertNotNil(try? app.detailCompletedDateButtonToCopyToPasteBoard(),
                        "The window's detail area should contain a button that displays the item's completion date")

        XCTAssertTrue((try? app.detailCompletedDateValue())?.contains("Incomplete") ?? false,
                      "When the item is incomplete, clicking on the button will set 'Incomplete' as the pasteboard string")

        try app.detailCompletionCheckBox().click()
        try app.sidebarDoneList().click()
        try app.contentRowTextField(0).click()
        do {
            let dateString = try app.detailCompletedDateValue()
            XCTAssertNotNil(XCUIApplication.detailDateFormatter.date(from: dateString),
                            "And when the item is completed, clicking on the same button causes a date to be copied to the pasteboard")
        } catch {
            XCTFail("Failed to get completed date value: \(error)")
        }
    }

    func test_130_detailAreaProvidesButtonToCopyURLToClipboard() throws {
        try app.menubarItemNew.click()
        let title = "\(#function)"
        try app.detailTitle().click()
        app.typeText(title)

        XCTAssertTrue(try app.detailItemURLButtonCopyToPasteBoard().exists,
                      "The detail area should contain a button to copy a URL for the item to the OS's clipboard")

        XCTAssertNotNil(try app.detailItemURLValue(),
                        "Should be able to use the detail areas link button to copy a string representation of the item's URL to the clipboard")

        let possibbleURL = URL(string: try app.detailItemURLValue()!)
        XCTAssertNotNil(possibbleURL, "and that string looks like a valid URL")

        app.shortcutWindowsCloseAll()

        NSWorkspace.shared.open(possibbleURL!)
        XCTAssertEqual(app.windows.count, 1, "and when there is no window displaying it and it it is opened it creates a new window")
        XCTAssertEqual(try app.detailTitleValue(win: try app.win2), title, "that is displaying the Item just created")
    }
}
