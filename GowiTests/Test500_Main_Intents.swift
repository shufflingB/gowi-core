//
//  Test500_Main_Intents.swift
//  GowiTests
//
//  Created by Jonathan Hume on 07/10/2022.
//
@testable import Gowi
import XCTest

final class Test500_Main_Intents: XCTestCase {
    var appModel = AppModel.sharedInMemoryWithTestData

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        appModel = AppModel.sharedInMemoryWithTestData
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


}
