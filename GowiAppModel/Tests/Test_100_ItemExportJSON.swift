//
//  Test020_AppModel_Item_Deletion.swift
//  GowiTests
//
//  Created by Jonathan Hume on 02/12/2022.
//


@testable import GowiAppModel
import XCTest

final class Test_100_ItemExportJSON: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        continueAfterFailure = false
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func test_010_SuccessfullyExportsAnItemAsJSON() throws {
        ///  Item export to JSON
        let appModel = AppModel.sharedInMemoryWithTestData
        
        // 1. Get any item from test data via root item children
        let rootItem = appModel.systemRootItem
        let items = Array(rootItem.childrenListAsSet)
        XCTAssertGreaterThan(items.count, 0, "Test data should contain items")
        
        let testItem = items.first!
        
        // 2. Export item to JSON
        let jsonData = try testItem.exportAsJSON()
        XCTAssertGreaterThan(jsonData.count, 0, "JSON data should not be empty")
        
        // 3. Verify it's valid JSON
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        let jsonDict = try XCTUnwrap(jsonObject as? [String: Any], "JSON should be a dictionary")
        
        // 4. Verify JSON structure contains expected fields
        XCTAssertNotNil(jsonDict["title"], "JSON should contain 'title' field")
        XCTAssertNotNil(jsonDict["creationDate"], "JSON should contain 'creationDate' field")
        XCTAssertNotNil(jsonDict["completionDate"], "JSON should contain 'completionDate' field")
        XCTAssertNotNil(jsonDict["notes"], "JSON should contain 'notes' field")
        XCTAssertNotNil(jsonDict["ourId"], "JSON should contain 'ourId' field")
        
        // 5. Verify content matches item properties
        XCTAssertEqual(jsonDict["title"] as? String, testItem.titleS, 
                      "JSON title should match item title")
        XCTAssertEqual(jsonDict["ourId"] as? String, testItem.ourIdS.uuidString, 
                      "JSON ourId should match item ourId")
        XCTAssertEqual(jsonDict["notes"] as? String, testItem.notesS, 
                      "JSON notes should match item notes")
        
        // 6. Verify date formats are ISO8601 strings
        let creationDateString = try XCTUnwrap(jsonDict["creationDate"] as? String, 
                                             "Creation date should be a string")
        XCTAssertNotNil(ISO8601DateFormatter().date(from: creationDateString), 
                       "Creation date should be valid ISO8601 format")
        
        // 7. Verify completion date handling
        let completionDateString = try XCTUnwrap(jsonDict["completionDate"] as? String, 
                                               "Completion date should be a string")
        
        if testItem.completed != nil {
            // If item is completed, should have valid ISO8601 date
            XCTAssertNotNil(ISO8601DateFormatter().date(from: completionDateString), 
                           "Completed item should have valid ISO8601 completion date")
        } else {
            // If item is not completed, should have null or special value
            XCTAssertTrue(completionDateString.isEmpty || completionDateString == "null", 
                         "Incomplete item should have empty or null completion date")
        }
        
        // 8. Verify creation date matches item's actual creation date
        let formatter = ISO8601DateFormatter()
        if let parsedCreationDate = formatter.date(from: creationDateString),
           let itemCreatedDate = testItem.created {
            XCTAssertEqual(parsedCreationDate.timeIntervalSince1970, 
                          itemCreatedDate.timeIntervalSince1970, 
                          accuracy: 1.0, 
                          "Parsed creation date should match item's creation date")
        } else {
            XCTFail("Should be able to parse creation date and item should have creation date")
        }
    }
    func test_020_SuccessfullyExportsAnItemAsJsonToAFile() throws {
        /// Happy path export of an Item's JSON to nominated file path.
        let appModel = AppModel.sharedInMemoryWithTestData
        
        // 1. Get test item from data
        let rootItem = appModel.systemRootItem
        let items = Array(rootItem.childrenListAsSet)
        XCTAssertGreaterThan(items.count, 0, "Test data should contain items")
        
        let testItem = items.first!
        
        // 2. Setup temporary file path
        let tempDir = FileManager.default.temporaryDirectory
        let outputFilePath = tempDir.appendingPathComponent("test_020_export.json")
        
        // 3. Clean up any existing file from previous test runs
        try? FileManager.default.removeItem(at: outputFilePath)
        XCTAssertFalse(FileManager.default.fileExists(atPath: outputFilePath.path), 
                      "Test file should not exist before export")
        
        // 4. Export JSON to file
        let jsonData = try testItem.exportAsJSON()
        try jsonData.write(to: outputFilePath)
        
        // 5. Verify file was created
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputFilePath.path), 
                     "JSON file should be created at specified path")
        
        // 6. Verify file has content
        let fileAttributes = try FileManager.default.attributesOfItem(atPath: outputFilePath.path)
        let fileSize = fileAttributes[.size] as! Int
        XCTAssertGreaterThan(fileSize, 0, "JSON file should have content")
        
        // 7. Read file and verify it contains valid JSON
        let readData = try Data(contentsOf: outputFilePath)
        let jsonObject = try JSONSerialization.jsonObject(with: readData, options: [])
        let jsonDict = try XCTUnwrap(jsonObject as? [String: Any], "File should contain valid JSON dictionary")
        
        // 8. Verify content matches original item properties
        XCTAssertEqual(jsonDict["title"] as? String, testItem.titleS, 
                      "File JSON title should match item title")
        XCTAssertEqual(jsonDict["ourId"] as? String, testItem.ourIdS.uuidString, 
                      "File JSON ourId should match item ourId")
        XCTAssertEqual(jsonDict["notes"] as? String, testItem.notesS, 
                      "File JSON notes should match item notes")
        
        // 9. Verify all required fields are present
        XCTAssertNotNil(jsonDict["creationDate"], "File JSON should contain creation date")
        XCTAssertNotNil(jsonDict["completionDate"], "File JSON should contain completion date")
        
        // 10. Verify date format is ISO8601
        let creationDateString = try XCTUnwrap(jsonDict["creationDate"] as? String)
        XCTAssertNotNil(ISO8601DateFormatter().date(from: creationDateString), 
                       "Creation date in file should be valid ISO8601 format")
        
        // 11. Cleanup - remove test file
        try FileManager.default.removeItem(at: outputFilePath)
        XCTAssertFalse(FileManager.default.fileExists(atPath: outputFilePath.path), 
                      "Test file should be cleaned up after test")
    }
}
