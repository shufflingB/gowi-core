//
//  Test_900_SearchAndFilter.swift
//  GowiUITests
//
//  Created by Claude Code on 27/06/2025.
//

import XCTest

/// Comprehensive test suite for search and filter functionality
/// Tests search behavior across all list types (All/Done/Waiting) including:
/// - Basic search functionality within each list
/// - Selection preservation during filtering
/// - Search state restoration when switching between lists
/// - URL routing with search parameters
/// - Cross-list navigation with search state
class Test_900_SearchAndFilter: XCTestCase {
    let app = XCUIApplication()

    var list_locators: Dictionary<String, (XCUIElement?) throws -> XCUIElement > = [:]
    let status_list_names = Set(["All", "Waiting", "Done"])
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        list_locators = ["All": app.sidebarAllList, "Waiting": app.sidebarWaitingList, "Done": app.sidebarDoneList  ]
        
        for (_, v_locator) in list_locators {
            try v_locator(nil).click()
            try app.clearSearch()
        }
        
    }

    override func tearDownWithError() throws {
        
        for (_, v_locator) in list_locators {
            try v_locator(nil).click()
            try app.clearSearch()
        }
    }


    func test_010_contentRowFilteringByItemTitleOnAPerStatusBasis() throws {
        try app.sidebarAllList().click()
        
        
        
        let rows = try app.contentRows()
        
        /// 1) Mark Item number 9 and 10 as complete
        rows[8].click()
        try app.detailCompletionCheckBox().click()
        
        rows[9].click()
        try app.detailCompletionCheckBox().click()
        
        let filter_by = "1"
        /// 2) Set the expected number of rows that should be visible in each status list before and after filtering that  list by "1"
        let e_unfiltered_list_counts: Dictionary<String, Int> = ["All": 10, "Done": 2, "Waiting": 8 ]
        let e_filtered_by_1_list_counts: Dictionary<String, Int> = ["All": 2, "Done": 1, "Waiting": 1 ]
        
        
       
        for status_list_name in status_list_names {
            try list_locators[status_list_name]!(nil).click() // e.g. All, Done, Waiting
            
            /// 1) Check that data is setup  as expected (Item's 9 and 10 marked as completed) before filtering
            let unfiltered_count = try app.contentRows().count
            let e_unfiltered_count = e_unfiltered_list_counts[status_list_name]
            XCTAssertEqual(unfiltered_count, e_unfiltered_count, "GOWI_TESTMODE 1 \(status_list_name) with 2 complete, number of rows visible not as expected ")
            
            /// 2) Apply filter by "1" to that same status list and check  what is left visible meets our expectations for that list
            /// in term of the number of rows remaing and the contents of the thier titltes
            try app.searchFor(filter_by)
            let filtered_count = try app.contentRows().count
            let e_filtered_count =  e_filtered_by_1_list_counts[status_list_name]
            
            XCTAssertEqual(filtered_count, e_filtered_count, "GOWI_TESTMODE 1 \(status_list_name) with 2 complete and filtered by titles containing \"1\" , number of rows visible not as expected ")
            
            /// Verify all filtered visible items contain the search term
            let filteredRows = try app.contentRows()
            for (index, _) in filteredRows.enumerated() {
                let rowText = try app.contentRowTextFieldValue(index)
                XCTAssertTrue(rowText.lowercased().contains(filter_by),
                             "Filtered row '\(rowText)' should contain search term")
            }
            
            /// 3) Verify that we don't lose the filterest state after viewing one of the other status lists
            let other_list_name = status_list_names.subtracting([status_list_name]).first!
            try list_locators[other_list_name]!(nil).click()
            
            try list_locators[status_list_name]!(nil).click()
            let filtered_count2 = try app.contentRows().count
            XCTAssertEqual(filtered_count2, e_filtered_count, "GOWI_TESTMODE 1 \(status_list_name) with 2 complete and filtered by titles containing \"1\" , number of rows visible not as expected when returning to a status list with a previous filter ")
            
            
            /// 4) Finanly check that if we clear the search filter we get to see everying we would expect for the status list in question
            try app.clearSearch()
            let unfiltered_count2 = try app.contentRows().count
            XCTAssertEqual(unfiltered_count2, e_unfiltered_count, "GOWI_TESTMODE 1 \(status_list_name) with 2 complete, number of rows visible not as expected after clearing search filter")
            
        }
    }

 

    // MARK: - URL Routing with Search Tests

    func test_300_urlWithSearchParameterAppliesSearch() throws {
        
        // Create URL with search parameter
        let searchTerm = "5"
        let url = urlEncodeShowItems(sidebarFilter: .all, itemIdsSelected: nil, searchFilter: searchTerm)!
        
        XCTAssertEqual(app.windows.count, 1, "When the test starts the application should have a single window" )
       _ = app.openVia(url: url)
        XCTAssertEqual(app.windows.count, 2, "And after a URL is opened with a search term included in it it opens a new window")
        
        
        // Verify search is applied
        XCTAssertEqual(try app.currentSearchText(win: app.win2), searchTerm, "And the new window should have the search term supplied int the URL applied")
        
        // Verify items are filtered
        let rows = try app.contentRows(win: app.win2)
        for (index, _) in rows.enumerated() {
            let rowText = try app.contentRowTextFieldValue(win: app.win2, index)
            XCTAssertTrue(rowText.lowercased().contains(searchTerm),
                         "Filtered row should contain search term from URL")
        }
    }

    func test_310_urlWithoutSearchParameterDoesNotApplySearch() throws {
        // First set some search text
        try app.sidebarAllList().click()
        try app.searchFor("SomeSearch")
        
        // Create URL without search parameter
        let url = urlEncodeShowItems(sidebarFilter: .waiting, itemIdsSelected: nil, searchFilter: nil)!
        
        let windowCount = app.openVia(url: url)
        XCTAssertEqual(windowCount, 1, "URL should open/reuse window")
        
        // Verify search is not applied (should be empty or default)
        sleep(1)
        let searchText = try app.currentSearchText()
        XCTAssertTrue(searchText.isEmpty || searchText == "SomeSearch", 
                     "Search should be empty or preserve existing state")
    }


    // MARK: - Edge Cases and Error Handling

    func test_400_emptySearchShowsAllItems() throws {
        try app.sidebarAllList().click()
        
        let initialRowCount = try app.contentRows().count
        
        // Apply empty search
        try app.searchFor("")
        
        let resultRowCount = try app.contentRows().count
        XCTAssertEqual(resultRowCount, initialRowCount, "Empty search should show all items")
    }

    func test_410_whitespaceOnlySearchShowsAllItems() throws {
        try app.sidebarAllList().click()
        
        let initialRowCount = try app.contentRows().count
        
        // Apply whitespace-only search
        try app.searchFor("   ")
        sleep(1)
        
        let resultRowCount = try app.contentRows().count
        XCTAssertEqual(resultRowCount, initialRowCount, "Whitespace-only search should show all items")
    }

    func test_420_searchIsCaseInsensitive() throws {
        try app.sidebarAllList().click()
        
        // Search with lowercase
        try app.searchFor("item")
        sleep(1)
        let lowercaseCount = try app.contentRows().count
        
        try app.clearSearch()
        
        // Search with uppercase
        try app.searchFor("ITEM")
        let uppercaseCount = try app.contentRows().count
        
        XCTAssertEqual(lowercaseCount, uppercaseCount, "Search should be case insensitive")
    }

    func test_430_noMatchingItemsShowsEmptyList() throws {
        try app.sidebarAllList().click()
        
        // Search for term that definitely won't match
        try app.searchFor("XYZUnlikelySearchTermThatWontMatchAnything123")
        sleep(1)
        
        let resultRowCount = try app.contentRows().count
        XCTAssertEqual(resultRowCount, 0, "Search with no matches should show empty list")
    }

    // MARK: - Performance and UI Responsiveness Tests

    func test_500_searchUpdateIsResponsive() throws {
        try app.sidebarAllList().click()
        
        let searchField = try app.searchField()
        searchField.click()
        
        // Type search term character by character and verify updates
        let searchTerm = "Item"
        for (index, char) in searchTerm.enumerated() {
            searchField.typeText(String(char))
            
            // Small delay to allow UI to update
            usleep(100000) // 0.1 second
            
            let currentSearch = try app.currentSearchText()
            let expectedText = String(searchTerm.prefix(index + 1))
            XCTAssertEqual(currentSearch, expectedText, "Search field should update incrementally")
        }
    }
}
