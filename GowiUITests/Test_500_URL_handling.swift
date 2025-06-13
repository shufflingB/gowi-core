//
//  Test_500_URL_handling.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Darwin
import XCTest

class Test_500_URL_handling: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_000_aDefaultUrlRouteExistsToTheWaitingList() throws {
        // Check default routing is the Waiting todo items list creates a new window when no other is present
        app.shortcutWindowsCloseAll()

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            return components.url!
        }()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the default URL route \(url) is opened a new window is created")
        XCTAssertTrue(app.sidebarWaitingList_NON_THROWING(win: app.win2_NON_THROWING).isSelected,
                      " And it displays the list of Waiting items"
        )
    }

    func test_010_aUrlRouteExistsToTheWaitingItemsList() {
        app.shortcutWindowsCloseAll()
        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            components.path = AppMainUrlPath.showItems.rawValue
            components.queryItems = [URLQueryItem(name: AppMainUrlQuery.filterId.rawValue, value: "Waiting")]
            return components.url!
        }()

        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to the Waiting Items is opened a new window is created")
        XCTAssertTrue(app.sidebarWaitingList_NON_THROWING(win: app.win2_NON_THROWING).isSelected,
                      " And it displays the list of Waiting Items"
        )
    }

    func test_020_aUrlRouteExistsToTheItemsDoneList() {
        app.shortcutWindowsCloseAll()
        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            components.path = AppMainUrlPath.showItems.rawValue
            components.queryItems = [URLQueryItem(name: AppMainUrlQuery.filterId.rawValue, value: "Done")]
            return components.url!
        }()

        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to the Done Items is opened a new window is created")
        XCTAssertTrue(app.sidebarDoneList_NON_THROWING(win: app.win2_NON_THROWING).isSelected,
                      " And it displays the list of Done Items"
        )
    }

    func test_030_aUrlRouteExistsToTheListOfAllItems() {
        app.shortcutWindowsCloseAll()
        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            components.path = AppMainUrlPath.showItems.rawValue
            components.queryItems = [URLQueryItem(name: AppMainUrlQuery.filterId.rawValue, value: "All")]
            return components.url!
        }()

        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to All Items is opened a new window is created")
        XCTAssertTrue(app.sidebarAllList_NON_THROWING(win: app.win2_NON_THROWING).isSelected,
                      " And it displays the list of All Items"
        )
    }

    func test_040_canCreateAUrlRouteToASpecificItem() {
        app.sidebarAllList_NON_THROWING().click()
        app.contentRowTextField_NON_THROWING(3).click()

        let itemId: String = app.detailIDValue_NON_THROWING()!

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            components.path = AppMainUrlPath.showItems.rawValue
            components.queryItems = [
                URLQueryItem(name: AppMainUrlQuery.filterId.rawValue, value: "All"),
                URLQueryItem(name: AppMainUrlQuery.itemId.rawValue, value: itemId),
            ]
            return components.url!
        }()
        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to a specific Item is opened a new window is created")
        XCTAssertTrue(app.sidebarAllList_NON_THROWING(win: app.win2_NON_THROWING).isSelected,
                      " And it displays that Item"
        )
    }

    func test_100_ifNotNewItemRouteWillPrefertToRaiseExistingWindowInsteadOfCreatingNew() {
        
        // And not create new ones
        app.sidebarAllList_NON_THROWING().click()
        app.contentRowTextField_NON_THROWING(5).click()

        let itemId: String = app.detailIDValue_NON_THROWING()!

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            components.path = AppMainUrlPath.showItems.rawValue
            components.queryItems = [
                URLQueryItem(name: AppMainUrlQuery.filterId.rawValue, value: "All"),
                URLQueryItem(name: AppMainUrlQuery.itemId.rawValue, value: itemId),
            ]
            return components.url!
        }()

        // Now open a new window and set its route to something different
        app.shortcutWindowOpenNew()
        assert(app.isKeyFrontWindow(app.win2_NON_THROWING))
        app.sidebarDoneList_NON_THROWING(win: app.win2_NON_THROWING).click()

        // Attempt to open route we setup in window 1 to verify it just raises rather than creating new window
        let winCount = app.windows.count
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, winCount,
                       "When a url route is being displayed in an existing window it will not create new Windows")
        XCTAssertTrue(app.isKeyFrontWindow(app.win1_NON_THROWING),
                      "And it will just raise the existing window")
        XCTAssertEqual(itemId, app.detailIDValue_NON_THROWING(),
                       "Displaying the previous information"
        )
    }

    func test_200_aNewItemRouteExistsThatCreatesNewItemsInNewWindows() {
        app.sidebarAllList_NON_THROWING().click()

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppUrlScheme
            components.host = AppUrlHost.mainWindow.rawValue
            components.path = AppMainUrlPath.newItem.rawValue
            return components.url!
        }()

        let itemCount = app.contentRows_NON_THROWING().count
        let winCount = app.windows.count

        NSWorkspace.shared.open(url)

        XCTAssertEqual(app.contentRows_NON_THROWING().count, itemCount + 1,
                       "When the new Item URL route is used it will always add a new Item"
        )
        XCTAssertEqual(app.windows.count, winCount + 1,
                       "That it will display in a new Window"
        )

        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.contentRows_NON_THROWING().count, itemCount + 2)
        XCTAssertEqual(app.windows.count, winCount + 2)
    }
}
