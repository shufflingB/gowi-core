//
//  Test_500_URL_handling#helpers.swift
//  Gowi
//
//  Created by Jonathan Hume on 29/06/2025.
//
import Darwin
import XCTest

extension Test_500_URL_handling {
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
        _ = app.openVia(url: targetURL.absoluteString)
        
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
