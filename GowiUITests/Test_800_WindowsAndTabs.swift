//
//  Test_800_WindowsAndTabs.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_800_WindowsAndTabs: XCTestCase {
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

    func test_100_canOpenANewWindowDisplayingAnItemFromTheMenubar() throws {
        app.sidebarWaitingList().click()
        app.contentRowTextField(4).click()
        let itemId = app.detailIDValue()
        let windowCount = app.windows.count

        app.menubarItemOpenInNewWindow.click()
        XCTAssertEqual(app.windows.count, windowCount + 1,
                       "When the app menubar item open in new window is clicked the app opens a new window"
        )
        XCTAssertEqual(app.detailIDValue(win: app.win2), itemId,
                       "And shows the same item as the one in the original window")
    }

    func test_110_canOpenANewWindowDisplayingAnItemFromTheContentContextMenu() throws {
        app.sidebarWaitingList().click()
        app.contentRowTextField(4).click()
        let itemId = app.detailIDValue()
        let windowCount = app.windows.count

        app.contentRowTextField(4).rightClick()
        app.contentContextMenuOpenInNewWindow(4).click()

        XCTAssertEqual(app.windows.count, windowCount + 1,
                       "When the app menubar item open in new window is clicked the app opens a new window"
        )
        XCTAssertEqual(app.detailIDValue(win: app.win2), itemId,
                       "And shows the same item as the one in the original window")
    }

    func test_150_canOpenANewTabDisplayingAnItemFromTheMenubar() throws {
        app.sidebarWaitingList().click()
        app.contentRowTextField(4).click()
        let itemId = app.detailIDValue()
        let windowCount = app.windows.count

        app.menubarItemOpenInNewTab.click()
        XCTAssertEqual(app.windows.count, windowCount,
                       "When the app menubar item open in new window is clicked the app opens a new tab"
        )
        XCTAssertEqual(app.detailIDValue(win: app.win2), itemId,
                       "And shows the same item as the one in the original window")
    }

    func test_160_canOpenANewTabDisplayingAnItemFromTheContentContextMenu() throws {
        app.sidebarWaitingList().click()
        app.contentRowTextField(4).click()
        let itemId = app.detailIDValue()
        let windowCount = app.windows.count

        app.contentRowTextField(4).rightClick()
        app.contentContextMenuOpenInNewTab(4).click()
        XCTAssertEqual(app.windows.count, windowCount,
                       "When the app menubar item open in new window is clicked the app opens a new tab"
        )
        XCTAssertEqual(app.detailIDValue(win: app.win2), itemId,
                       "And shows the same item as the one in the original window")
    }
}
