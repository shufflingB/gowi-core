//
//  Test_500_URL_handling#helpers.swift
//  Gowi
//
//  Created by Jonathan Hume on 29/06/2025.
//
import Darwin
import XCTest

extension Test_500_URL_handling {
    /// Tests whether URL routing correctly raises existing windows instead of creating new ones
    ///
    /// This is a comprehensive test helper that validates the core URL routing behavior: when a URL
    /// is opened that matches the state of an existing window, that window should be raised to the
    /// front rather than creating a duplicate window.
    ///
    /// ## Test Flow (6-Step Process):
    /// 1. **Setup**: Start with a single window and clear any existing search state
    /// 2. **Configure Target State**: Set the desired sidebar filter, item selection, and search text
    /// 3. **URL Generation**: Create a URL that encodes the current window state
    /// 4. **Window Creation**: Create a second window with *different* state to ensure proper window identification
    /// 5. **URL Routing Test**: Open the URL and verify it raises the first window (not the second)
    /// 6. **State Validation**: Confirm the raised window displays the correct item and search state
    ///
    /// ## Parameters:
    /// - `scenarioName`: Test function name for error messages (typically `#function`)
    /// - `sidebarFilter`: Which sidebar list to select (All/Waiting/Done), or nil for default
    /// - `itemIdSelected`: Whether to select a specific item (uses row 5 as test item)
    /// - `searchFor`: Search text to apply, or nil for no search
    ///
    /// ## Key Behaviors Tested:
    /// - **Window Raising**: Existing windows with matching state are raised, not duplicated
    /// - **Search Integration**: URLs with search parameters correctly match windows with active searches
    /// - **State Preservation**: Raised windows maintain their item selection and search state
    /// - **Multi-Window Handling**: Correct window identification when multiple windows exist
    ///
    /// ## Usage:
    /// ```swift
    /// func test_urlRoutesToItemInFilteredStatusListRaiseEquivalentIfExists() throws {
    ///     try checkOpenedURLsRaiseEquivalentWindowsRatherThanCreatNewOnes(
    ///         scenarioName: #function,
    ///         sidebarFilter: .waiting,
    ///         itemIdSelected: true,
    ///         searchFor: "5"
    ///     )
    /// }
    /// ```
    func checkOpenedURLsRaiseEquivalentWindowsRatherThanCreatNewOnes(
        scenarioName: String,
        sidebarFilter: SidebarFilterOpt?,
        itemIdSelected: Bool,
        searchFor: String?
        
    ) throws {
        print("Testing scenario: \(scenarioName)")
        
        // Step 0: Setup target state in the key window
        XCTAssertEqual(app.windows.count, 1, "[\(scenarioName)] Test requires the app to have a single window")
        
        // Step 1: Clear search filter to ensure clean state
        try app.clearSearch()
        
        // Select the required sidebar filter
        if let sidebarFilter = sidebarFilter {
            switch sidebarFilter {
            case .all:
                try app.sidebarAllList().click()
            case .done:
                try app.sidebarDoneList().click()
            case .waiting:
                try app.sidebarWaitingList().click()
            }
        }
        
        // Select an item if wanted and capture its Id
        let itemIds: Set<UUID>?
        if itemIdSelected {
            try app.contentRowTextField(5).click()
            let itemId = try app.detailIDValue()!
            itemIds = Set([UUID(uuidString: itemId)!])
        } else {
            itemIds = nil
        }
        
        // Enter something in the search filter
        if let searchFor = searchFor {
            try app.searchFor(searchFor)
        }
        
        // Step 3: Generate URL encoding of target state
        
        let targetURL = urlEncodeShowItems(sidebarFilter: sidebarFilter, itemIdsSelected: itemIds, searchFilter: searchFor)!
        
        /// Step 4: So that cam specificially see that we are raising the correct window of the app, rather than just the app as whole we need to create a second window
        /// in front of out orginal, i.e. a new key window, make sure to put it into a different state so that it doesn't match.
        try app.menubarWindowNew.click()
        let w2 = try app.win2
        
        XCTAssertEqual(app.windows.count, 2,
                       "[\(scenarioName)]: Test requires the creating of a second window.")
        XCTAssert(app.isKeyFrontWindow(w2), "[\(scenarioName)] Test requires that the second window is in front of our first window (the one with target state that we are going to check gets raised)")
        // NB, Intentionally set a different sidebar filter state on the new Window compared to what we previously set
        if let sidebarFilter = sidebarFilter {
            switch sidebarFilter {
            case .all:
                try app.sidebarDoneList(win: w2).click()
            case .done:
                try app.sidebarWaitingList(win: w2).click()
            case .waiting:
                try app.sidebarDoneList(win: w2).click()
            }
        } else {
            try app.sidebarDoneList(win: w2).click()
        }
        
        // Step 4: Test URL routing - should raise existing window, not create new
        _ = app.openVia(url: targetURL)
        
        // Step 5: Verify the first window was raised, not created
        XCTAssertEqual(app.windows.count, 2,
                       "[\(scenarioName)] When there is a pre-existing window with equivalent state to the URL route \(targetURL.absoluteString) then the app should not create a new window")
        XCTAssertTrue(app.isKeyFrontWindow(try app.win1),
                      "[\(scenarioName)] And instead the original window with the equivalent state to the the url \(targetURL.absoluteString) should have been raised to the the front")
        
        // Step 6: Verify the item is selected
        if itemIdSelected {
            let itemID: String = (itemIds?.first!.uuidString)!
            XCTAssertEqual(try app.detailIDValue(), itemID, "[\(scenarioName)]: And the raised original window should be displaying the same Item \((itemIds?.first!.uuidString)!)")
        }
    }
}
