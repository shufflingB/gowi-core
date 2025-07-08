//
//  Test_700_JsonImportAndExport.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 05/07/2025.
//

import XCTest
import SwiftUI

/**
 ## JSON Export Functionality UI Testing
 
 This test class validates the complete end-to-end JSON export workflow from user interaction
 through file creation and content validation. JSON export is a key data portability feature
 that allows users to extract their todo items in a standardized format.
 
 ### Testing Strategy:
 - **Complete UI Workflow**: Tests from menu interaction through save dialog automation
 - **File System Operations**: Validates actual file creation with proper content
 - **Cross-Format Validation**: Compares UI display formats with JSON export formats
 - **Menu State Management**: Ensures export commands are properly enabled/disabled
 
 ### Key Test Scenarios:
 - **Disabled State**: Export menu is grayed out when no items selected
 - **Export Workflow**: Complete item selection → menu command → save dialog → file creation
 - **Content Validation**: JSON structure matches expected item data
 - **Date Format Handling**: UI (.short) vs JSON (ISO8601) date format consistency
 
 ### Technical Challenges:
 - **Save Dialog Automation**: Complex modal dialog interaction using specialized XCUIApplication extensions
 - **Timezone Handling**: Date comparisons account for timezone differences between UI and export
 - **File System Testing**: Temporary directories and cleanup for isolated test execution
 - **Format Validation**: Parsing and validating JSON structure and content
 
 ### Integration Points:
 - **Menu System**: Tests @FocusedValue-based menu command availability
 - **NSSavePanel**: Tests save dialog automation and file path specification
 - **Item Export**: Tests Encodable protocol implementation for Item data
 - **Date Formatting**: Tests consistent date handling across UI and export systems
 
 ### Test Data Context:
 Uses `GOWI_TESTMODE` environment variable to control test data:
 - Mode 0: Clean slate for testing disabled states
 - Mode 1: Pre-populated items for export testing
 */
final class Test_520_JsonImportAndExport: XCTestCase {
    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        
    }
    
    override func tearDownWithError() throws {
        // Clean up any help windows that might be open
        app.terminate()
    }
    
    func test_000_jsonExportMenuBarEntryGreyedOut() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "0"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        // Open File menu to make menu items accessible
        try app.menubarFileMenu.click()
        
        // Check that Export JSON menu item exists
        let exportJSONItem = try app.menubarFileExportJSON
        XCTAssertTrue(exportJSONItem.exists, "Export JSON menu item should exist in File menu")
        
        // Check that it's disabled when no items are selected
        XCTAssertFalse(exportJSONItem.isEnabled, "Export JSON menu item should be disabled when no items are selected")
        
        // Close the menu by clicking elsewhere
        try app.win1.click()
    }
    
    func test_020_jsonExport() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launchAndSanitiseWindowsAndIdentifiers()
        
        // 0) Setup temporary directory and clean up any artifacts from previous runs
        let tempDir = createTempDirectory()
        let outputFilePath = tempDir.appendingPathComponent("test_020.json")
        
        // Remove any existing file from previous test runs
        try? FileManager.default.removeItem(at: outputFilePath)
        
        // 1) Pick an Item to export
        // Click All in sidebar
        try app.sidebarAllList().click()
        
        // Click row 3 in content rows (assuming at least 4 items exist in test mode)
        let contentRows = try app.contentRows()
        XCTAssertGreaterThanOrEqual(contentRows.count, 4, "Test mode should have at least 4 items for row 3 to exist")
        
        try app.contentRowTextField(3).click()
        
        // Mark the item selected as completed
        try app.detailCompletionCheckBox().click()
        
        // 2) Capture the Item's Title, Creation date, Completion Date, and Notes
        let capturedData = try captureItemData()
        
        // 3) Open the File menu and verify JSON export entry exists
        try app.menubarFileMenu.click()
        let exportJSONItem = try app.menubarFileExportJSON
        XCTAssertTrue(exportJSONItem.exists, "Export JSON menu item should exist in File menu")
        XCTAssertTrue(exportJSONItem.isEnabled, "Export JSON menu item should be enabled when an item is selected")
        
        // 4) Select the JSON entry - this should open a modal file save dialogue
        exportJSONItem.click()

        
        // 5) Modal dialogue should suggest a default filename that ends with ".json"
        let defaultFileName = try app.savePanelSaveAsTextFieldValue
        XCTAssertTrue(defaultFileName.hasSuffix(".json"), "Default filename should end with .json, got: \(defaultFileName)")
        
        // 6) Change the filename to be test_020.json and update the save directory path
        
        let fileLocationShortcut = KeyboardShortcut("g", modifiers: [.command, .shift])
        app.typeKeyboardShortcut(fileLocationShortcut)
        app.typeText(outputFilePath.path())
        app.typeKey(.return, modifierFlags: [])
        
        // 7) Save the file
        try app.savePanelSaveButton.click()
    
        XCTAssertTrue(FileManager.default.fileExists(atPath: outputFilePath.path),
                      "JSON file should be created at: \(outputFilePath.path)")
        
        
        // 9) Check the output format of the file is valid JSON
        let jsonData = try Data(contentsOf: outputFilePath)
        let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
        XCTAssertNotNil(jsonObject, "File should contain valid JSON")
        
        // 10) Verify that it contains keys and values that correspond to those of the exported Item
        try validateJSONContent(jsonObject, expectedData: capturedData)
    }
    
}


// MARK: - Helper Methods
extension Test_520_JsonImportAndExport {
    
    /// Data structure to hold captured item properties for validation
    struct CapturedItemData {
        let title: String
        let creationDate: String
        let completionDate: String
        let notes: String
        let ourId: String
    }
    
    /// Creates a temporary directory for test file operations
    /// - Returns: URL pointing to the temporary directory
    func createTempDirectory() -> URL {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent("GowiJsonExportTests")
            .appendingPathComponent(UUID().uuidString)
        
        try! FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        return tempDir
    }
    
    /// Captures the current item's data from the detail view
    /// - Returns: CapturedItemData containing all relevant item properties
    func captureItemData() throws -> CapturedItemData {
        let title = try app.detailTitleValue()
        let creationDate = try app.detailCreateDateValue()
        let completionDate = try app.detailCompletedDateValue()
        let notes = try app.detailNotesValue()
        let ourId = try app.detailIDValue() ?? ""
        
        return CapturedItemData(
            title: title,
            creationDate: creationDate,
            completionDate: completionDate,
            notes: notes,
            ourId: ourId
        )
    }
    
    /// Validates that the JSON content matches the expected item data
    /// - Parameters:
    ///   - jsonObject: The parsed JSON object from the exported file
    ///   - expectedData: The captured item data to validate against
    func validateJSONContent(_ jsonObject: Any, expectedData: CapturedItemData) throws {
        guard let jsonDict = jsonObject as? [String: Any] else {
            XCTFail("JSON should be a dictionary/object")
            return
        }
        
        // Validate title
        if let title = jsonDict["title"] as? String {
            XCTAssertEqual(title, expectedData.title, "JSON title should match captured title")
        } else {
            XCTFail("JSON should contain 'title' field")
        }
        
        // Validate creation date - convert both formats to Date objects for comparison
        if let jsonCreationDateString = jsonDict["creationDate"] as? String {
            // Parse the JSON date (ISO8601 format)
            let iso8601Formatter = ISO8601DateFormatter()
            guard let jsonCreationDate = iso8601Formatter.date(from: jsonCreationDateString) else {
                XCTFail("JSON creation date should be valid ISO8601 format: \(jsonCreationDateString)")
                return
            }
            
            // Parse the UI captured date (.short format) - UI uses local timezone
            let uiDateFormatter = DateFormatter()
            uiDateFormatter.dateStyle = .short
            uiDateFormatter.timeStyle = .short
            uiDateFormatter.timeZone = TimeZone.current // Explicit local timezone
            guard let uiCreationDate = uiDateFormatter.date(from: expectedData.creationDate) else {
                XCTFail("UI creation date should be valid .short format: \(expectedData.creationDate)")
                return
            }
            
            // Compare dates with tolerance for timing differences and timezone conversion
            let timeDifference = abs(jsonCreationDate.timeIntervalSince(uiCreationDate))
            XCTAssertLessThanOrEqual(timeDifference, 60.0, 
                                   "JSON creation date (\(jsonCreationDateString)) should match UI date (\(expectedData.creationDate)) within 60 seconds (accounting for timezone and timing differences)")
        } else {
            XCTFail("JSON should contain 'creationDate' field")
        }
        
        // Validate completion date - handle both completed and incomplete items
        if let jsonCompletionDateString = jsonDict["completionDate"] as? String {
            if jsonCompletionDateString == "null" || jsonCompletionDateString.isEmpty {
                // Item is incomplete - UI should show "Incomplete" or similar
                XCTAssertTrue(expectedData.completionDate.contains("Incomplete") || expectedData.completionDate.isEmpty,
                            "Incomplete item should show 'Incomplete' in UI, got: \(expectedData.completionDate)")
            } else {
                // Item is completed - parse and compare dates
                let iso8601Formatter = ISO8601DateFormatter()
                guard let jsonCompletionDate = iso8601Formatter.date(from: jsonCompletionDateString) else {
                    XCTFail("JSON completion date should be valid ISO8601 format: \(jsonCompletionDateString)")
                    return
                }
                
                // Parse the UI captured date (.short format) - UI uses local timezone
                let uiDateFormatter = DateFormatter()
                uiDateFormatter.dateStyle = .short
                uiDateFormatter.timeStyle = .short
                uiDateFormatter.timeZone = TimeZone.current // Explicit local timezone
                guard let uiCompletionDate = uiDateFormatter.date(from: expectedData.completionDate) else {
                    XCTFail("UI completion date should be valid .short format: \(expectedData.completionDate)")
                    return
                }
                
                // Compare dates with tolerance for timing differences and timezone conversion
                let timeDifference = abs(jsonCompletionDate.timeIntervalSince(uiCompletionDate))
                XCTAssertLessThanOrEqual(timeDifference, 60.0, 
                                       "JSON completion date (\(jsonCompletionDateString)) should match UI date (\(expectedData.completionDate)) within 60 seconds (accounting for timezone and timing differences)")
            }
        } else {
            XCTFail("JSON should contain 'completionDate' field")
        }
        
        // Validate notes
        if let notes = jsonDict["notes"] as? String {
            XCTAssertEqual(notes, expectedData.notes, "JSON notes should match captured notes")
        } else {
            XCTFail("JSON should contain 'notes' field")
        }
        
        // Validate ourId
        if let ourId = jsonDict["ourId"] as? String {
            XCTAssertEqual(ourId, expectedData.ourId, "JSON ourId should match captured ourId")
        } else {
            XCTFail("JSON should contain 'ourId' field")
        }
    }
}
