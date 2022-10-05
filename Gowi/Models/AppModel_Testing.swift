//
//  AppModel_Testing.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 02/08/2022.
//

import Foundation
import os
fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

extension AppModel {
    enum TestModeData {
        case one
    }

    func addTestData(_ testMode: TestModeData) {
        switch testMode {
        case .one: // Same as inMemory
            testMode1()
            break
        }
    }

    static let testingMode1ourIdPresent = UUID(uuidString: "70BF1680-CA95-48B5-BD0E-FCEAF7FEC4DD")!
    fileprivate func testMode1() {
        let root = systemRootItem
        log.debug("In testMode1  systemRootItem = \(self.systemRootItem.description)")

        let numItemsToDo = 10
        viewContext.performAndWait { (1 ... numItemsToDo).forEach { idx in
            print("Idx = \(idx)")
            let item = Self.itemCreate(viewContext, parent: root)
            item.title = "title for item \(idx)"
            item.notes = "notes for item \(idx)"
            item.priority = Double(idx)

            // Bit of a hack to ensure always have this ID present for the URL routing tests
            if idx == numItemsToDo {
                item.ourIdS = Self.testingMode1ourIdPresent
            }
        }
        }
        saveToCoreData()
    }
}
