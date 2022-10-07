//
//  Test000_SystemInit.swift
//  GowiTests
//
//  Created by Jonathan Hume on 07/10/2022.
//

@testable import Gowi
import XCTest

final class Test000_System_Init: XCTestCase {
    var appModel = AppModel.sharedInMemoryNoTestData
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
        appModel = AppModel.sharedInMemoryNoTestData
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test100_inMemory_no_test_data_GOWI_TESTMODE_0() throws {
        appModel = AppModel.sharedInMemoryNoTestData
        let rootItem = appModel.systemRootItem

        let eDate = Date()
        XCTAssertNotNil(appModel.systemRootItem,
                        "When a new appModel is instantiated it automatically creates a new system Root item")

        XCTAssertTrue(rootItem.ourId != nil,
                      "And it should have a valid ID")

        XCTAssertTrue(rootItem.root,
                      "And it should be marked as such")

        XCTAssertEqual(rootItem.created!.timeIntervalSince1970, eDate.timeIntervalSince1970, accuracy: 1.0,
                       "With a matching created date attribute ")

        XCTAssertEqual(rootItem.parentListAsSet.count, 0,
                       "No parent items")

        XCTAssertEqual(rootItem.childrenListAsSet.count, 0,
                       "And initially no child items")
    }

    func test100_inMemory_with_test_data_GOWI_TESTMODE_1() throws {
        appModel = AppModel.sharedInMemoryWithTestData
        let rootItem = appModel.systemRootItem

        let eDate = Date()

        XCTAssertNotNil(appModel.systemRootItem,
                        "When a new appModel is instantiated it automatically creates a new system Root item")

        XCTAssertTrue(rootItem.ourId != nil,
                      "And it should have a valid ID")

        XCTAssertTrue(rootItem.root,
                      "And it should be marked as such")

        XCTAssertEqual(rootItem.created!.timeIntervalSince1970, eDate.timeIntervalSince1970, accuracy: 1.0,
                       "With a matching created date attribute ")

        XCTAssertEqual(rootItem.parentListAsSet.count, 0,
                       "No parent items")

        XCTAssertEqual(rootItem.childrenListAsSet.count, 10,
                       "And initially have 10 child items")
    }
}
