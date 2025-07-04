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
    
    /// Available data test modes
    /// - options:
    ///
    public enum TestModeData {
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

    /// Adds `GOWI_TESTMODE == 1` test data to the system.
    fileprivate func testMode1() {
        let root = systemRootItem
        log.debug("\(#function) adding test data")

        let numItemsToDo = 10
        (1 ... numItemsToDo).forEach { idx in

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

        saveToCoreData()
    }
}
