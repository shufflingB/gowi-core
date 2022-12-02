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
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            return components.url!
        }()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the default URL route \(url) is opened a new window is created")
        XCTAssertTrue(app.sidebarWaitingList(win: app.win2).isSelected,
                      " And it displays the list of Waiting items"
        )
    }

    func test_010_aUrlRouteExistsToTheWaitingItemsList() {
        app.shortcutWindowsCloseAll()
        let url: URL = {
            var components = URLComponents()
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            components.path = AppDefs.MainUrlPath.showItems.rawValue
            components.queryItems = [URLQueryItem(name: AppDefs.MainUrlQuery.filterId.rawValue, value: "Waiting")]
            return components.url!
        }()

        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to the Waiting Items is opened a new window is created")
        XCTAssertTrue(app.sidebarWaitingList(win: app.win2).isSelected,
                      " And it displays the list of Waiting Items"
        )
    }

    func test_020_aUrlRouteExistsToTheItemsDoneList() {
        app.shortcutWindowsCloseAll()
        let url: URL = {
            var components = URLComponents()
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            components.path = AppDefs.MainUrlPath.showItems.rawValue
            components.queryItems = [URLQueryItem(name: AppDefs.MainUrlQuery.filterId.rawValue, value: "Done")]
            return components.url!
        }()

        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to the Done Items is opened a new window is created")
        XCTAssertTrue(app.sidebarDoneList(win: app.win2).isSelected,
                      " And it displays the list of Done Items"
        )
    }

    func test_030_aUrlRouteExistsToTheListOfAllItems() {
        app.shortcutWindowsCloseAll()
        let url: URL = {
            var components = URLComponents()
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            components.path = AppDefs.MainUrlPath.showItems.rawValue
            components.queryItems = [URLQueryItem(name: AppDefs.MainUrlQuery.filterId.rawValue, value: "All")]
            return components.url!
        }()

        XCTAssertEqual(app.windows.count, 0, "With no other windows open")
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to All Items is opened a new window is created")
        XCTAssertTrue(app.sidebarAllList(win: app.win2).isSelected,
                      " And it displays the list of All Items"
        )
    }

    func test_040_canCreateAUrlRouteToASpecificItem() {
        app.sidebarAllList().click()
        app.contentRowTextField(3).click()

        let itemId: String = app.detailIDValue()!

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            components.path = AppDefs.MainUrlPath.showItems.rawValue
            components.queryItems = [
                URLQueryItem(name: AppDefs.MainUrlQuery.filterId.rawValue, value: "All"),
                URLQueryItem(name: AppDefs.MainUrlQuery.itemId.rawValue, value: itemId),
            ]
            return components.url!
        }()
        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, 1,
                       "When the URL route \(url) to a specific Item is opened a new window is created")
        XCTAssertTrue(app.sidebarAllList(win: app.win2).isSelected,
                      " And it displays that Item"
        )
    }

    func test_100_ifNotNewItemRouteWillPrefertToRaiseExistingWindowInsteadOfCreatingNew() {
        
        // And not create new ones
        app.sidebarAllList().click()
        app.contentRowTextField(5).click()

        let itemId: String = app.detailIDValue()!

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            components.path = AppDefs.MainUrlPath.showItems.rawValue
            components.queryItems = [
                URLQueryItem(name: AppDefs.MainUrlQuery.filterId.rawValue, value: "All"),
                URLQueryItem(name: AppDefs.MainUrlQuery.itemId.rawValue, value: itemId),
            ]
            return components.url!
        }()

        // Now open a new window and set its route to something different
        app.shortcutWindowOpenNew()
        assert(app.isKeyFrontWindow(app.win2))
        app.sidebarDoneList(win: app.win2).click()

        // Attempt to open route we setup in window 1 to verify it just raises rather than creating new window
        let winCount = app.windows.count
        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.windows.count, winCount,
                       "When a url route is being displayed in an existing window it will not create new Windows")
        XCTAssertTrue(app.isKeyFrontWindow(app.win1),
                      "And it will just raise the existing window")
        XCTAssertEqual(itemId, app.detailIDValue(),
                       "Displaying the previous information"
        )
    }

    func test_200_aNewItemRouteExistsThatCreatesNewItemsInNewWindows() {
        app.sidebarAllList().click()

        let url: URL = {
            var components = URLComponents()
            components.scheme = AppDefs.URLScheme
            components.host = AppDefs.UrlHost.mainWindow.rawValue
            components.path = AppDefs.MainUrlPath.newItem.rawValue
            return components.url!
        }()

        let itemCount = app.contentRows().count
        let winCount = app.windows.count

        NSWorkspace.shared.open(url)

        XCTAssertEqual(app.contentRows().count, itemCount + 1,
                       "When the new Item URL route is used it will always add a new Item"
        )
        XCTAssertEqual(app.windows.count, winCount + 1,
                       "That it will display in a new Window"
        )

        NSWorkspace.shared.open(url)
        XCTAssertEqual(app.contentRows().count, itemCount + 2)
        XCTAssertEqual(app.windows.count, winCount + 2)
    }
}
