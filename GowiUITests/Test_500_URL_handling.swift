//
//  Test_500_URL_handling.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import XCTest

class Test_500_URL_handling: XCTestCase {
    let app = XCUIApplication()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // Specify launch the app with in memory db and some dummy test data to plaw with
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_000_aDefaultUrlRouteExistsToTheWaitingList() throws {
        // Check default routing is the Waiting todo items list creates a new window when no other is present
        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        let url: URL = urlEncodeShowItems(sidebarFilter: nil, itemIdsSelected: nil, searchFilter: nil)!
        let num_windows = app.openVia(url: url.absoluteString)
        XCTAssertEqual(num_windows, 1,
                       "When the default URL route \(url) is opened a new window is created")
        XCTAssertTrue(try app.sidebarWaitingList(win: try app.win2).isSelected,
                      " And it displays the list of Waiting items"
        )
    }

    func test_010_aUrlRouteExistsToTheWaitingItemsList() {
        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        let url: URL = urlEncodeShowItems(sidebarFilter: .waiting, itemIdsSelected: nil, searchFilter: nil)!
        let num_windows = app.openVia(url: url.absoluteString)
        XCTAssertEqual(num_windows, 1,
                       "When the URL route \(url) to the Waiting Items is opened a new window is created")
        XCTAssertTrue(try app.sidebarWaitingList(win: try app.win2).isSelected,
                      " And it displays the list of Waiting Items"
        )
    }

    func test_020_aUrlRouteExistsToTheItemsDoneList() {
        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        let url: URL = urlEncodeShowItems(sidebarFilter: .done, itemIdsSelected: nil, searchFilter: nil)!
        let num_windows = app.openVia(url: url.absoluteString)

        XCTAssertEqual(num_windows, 1,
                       "When the URL route \(url) to the Done Items is opened a new window is created")
        XCTAssertTrue(try app.sidebarDoneList(win: try app.win2).isSelected,
                      " And it displays the list of Done Items"
        )
    }

    func test_030_aUrlRouteExistsToTheListOfAllItems() {
        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        let url: URL = urlEncodeShowItems(sidebarFilter: .all, itemIdsSelected: nil, searchFilter: nil)!
        let num_windows = app.openVia(url: url.absoluteString)
        XCTAssertEqual(num_windows, 1,
                       "When the URL route \(url) to All Items is opened a new window is created")
        XCTAssertTrue(try app.sidebarAllList(win: try app.win2).isSelected,
                      " And it displays the list of All Items"
        )
    }

    func test_040_canCreateAUrlRouteToASpecificItemThatOpensAWindow() throws {
        // Get hold of an extant item id  from the test data (NB: if there is search filter than can knacker this)
        try app.sidebarAllList().click()
        try app.contentRowTextField(3).click()
        let itemId: String = try app.detailIDValue()!

        app.shortcutWindowsCloseAll()
        XCTAssertEqual(app.windows.count, 0, "With no other windows open")

        let url = urlEncodeShowItems(sidebarFilter: .all, itemIdsSelected: [UUID(uuidString: itemId)!], searchFilter: nil)!
        let num_windows = app.openVia(url: url.absoluteString)

        XCTAssertEqual(num_windows, 1,
                       "When the URL route \(url) to a specific Item is opened a new window is created")
        XCTAssertTrue(try app.sidebarAllList(win: try app.win2).isSelected,
                      " And it displays that Item"
        )
    }


    func test_100_urlRoutesToStatusListRaiseEquivalentIfExists() throws {
        try checkOpenedURLsRaiseEquivalentWindowsRatherThanCreatNewOnes(
            scenarioName: #function,
            sidebarFilter: .all,
            itemIdSelected: false,
            searchFor: nil
        )
    }

    func test_102_test_urlRoutesToItemInStatusListRaiseEquivalentIfExists() throws {
        try checkOpenedURLsRaiseEquivalentWindowsRatherThanCreatNewOnes(
            scenarioName: #function,
            sidebarFilter: .waiting,
            itemIdSelected: true,
            searchFor: nil
        )
    }

    func test_104_urlRoutesToItemInFilteredStatusListRaiseEquivalentIfExists() throws {
        try checkOpenedURLsRaiseEquivalentWindowsRatherThanCreatNewOnes(
            scenarioName: #function,
            sidebarFilter: .waiting,
            itemIdSelected: true,
            searchFor: "5"
        )
    }

    func test_200_aNewItemRouteExistsThatCreatesNewItemsInNewWindows() throws {
        try app.sidebarAllList().click()


        let url: URL = urlEncodeNewItem()!
        
        let itemCount = try app.contentRows().count
        let winCount = app.windows.count

        let num_windows = app.openVia(url: url.absoluteString, waitForNumOfWindows: winCount + 1)

        XCTAssertEqual(try app.contentRows().count, itemCount + 1,
                       "When the new Item URL route is used it will always add a new Item"
        )
        XCTAssertEqual(num_windows, winCount + 1,
                       "That to avoid disrupting the users workflow will always be displayed in a new Window "
        )

        NSWorkspace.shared.open(url)
        XCTAssertEqual(try app.contentRows().count, itemCount + 2)
        XCTAssertEqual(app.windows.count, winCount + 2)
    }
}
