//
//  AppModel#Testing.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation
import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// AppModel public functionallity specifically associated with setting up test data
extension AppModel {
    
    /// Available test data configurations for development and testing
    ///
    /// Used in conjunction with `GOWI_TESTMODE` environment variable to provide
    /// consistent test datasets across different testing scenarios.
    public enum TestModeData {
        /// Creates 10 test items with predictable content and one fixed UUID
        /// 
        /// **Test Data Structure:**
        /// - 10 items with titles "title for item 1" through "title for item 10"
        /// - Sequential priority values (1.0 through 10.0)
        /// - Notes follow pattern "notes for item N"
        /// - Item #10 has fixed UUID: `70BF1680-CA95-48B5-BD0E-FCEAF7FEC4DD`
        /// 
        /// **Use Cases:**
        /// - UI testing that needs predictable item selection
        /// - URL routing tests requiring known item IDs
        /// - Performance testing with consistent data sets
        case one
    }

    public func addTestData(_ testMode: TestModeData) {
        switch testMode {
        case .one: // Same as inMemory
            testMode1()
            break
        }
    }

    /// The `UUID`  of an `Item#ourId` that will always be present in `GOWI_TESTMODE == 1` test data.
    static let testingMode1ourIdPresent = UUID(uuidString: "70BF1680-CA95-48B5-BD0E-FCEAF7FEC4DD")!

    /// Creates test dataset for `GOWI_TESTMODE == 1`
    ///
    /// **Implementation Details:**
    /// - All items are children of `systemRootItem`
    /// - Uses `itemAddNewTo` to ensure proper ItemLink relationships
    /// - Priority values create natural sort order (highest priority = item 10)
    /// - Final item gets predictable UUID for test targeting
    ///
    /// **Testing Strategy:**
    /// - Provides enough items for pagination testing (10 items)
    /// - Known UUID enables reliable deep link testing
    /// - Sequential priorities test ordering algorithms
    fileprivate func testMode1() {
        let root = systemRootItem
        log.debug("\(#function) adding test data")

        let numItemsToDo = 10
        for idx in (1...10) { 

            let item = self.itemAddNewTo(
                externalUM: nil,
                parents: [root],
                title: "title for item \(idx)",
                priority: Double(idx),
                complete: nil,
                notes: "notes for item \(idx)",
                children: []
            )

            // Bit of a hack to ensure always have this ID present for the URL routing tests
            if idx == numItemsToDo {
                item.ourIdS = Self.testingMode1ourIdPresent
            }
        }

        saveToBackend()
    }
}
