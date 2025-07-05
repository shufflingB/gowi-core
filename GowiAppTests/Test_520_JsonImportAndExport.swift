//
//  Test_700_JsonImportAndExport.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 05/07/2025.
//

import XCTest

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
        app.launch()
        
        /**
         with no items select in the window there should be a menubar entry under File for JSON export, but it should be greyed.
         */
        XCTFail("Test not implemented")
    
    }
    
    func test_020_jsonExport() throws {
        app.launchEnvironment = ["GOWI_TESTMODE": "1"]
        app.launch()
        
        /**
         0) If necessary setup a temporary directory where output  files can be written and ensure that there are no artefacts from previous runs of this test present (such as test_020.json )
         1) Pick an Item to export
            - Click All in sidebar
            - Click row 3 in content rows
            - Mark the item selected as completed
         2) Capture the  Item's Title, Creation date, Completion Date, and Notes.
         3) Open the File menu and their should be a JSON export entry.
         4) Select the JSON entry, this should open a modal file save dialogue.
         5) Modal dialogue should suggest a default filename that ends with the sufficx ".json"
         6) Change the  filename to be test_020.json and update the save directory path  to be under the  temporary testing location.
         7) Click the proceed button
         8) After one second verify that the requested file has been created in the output directory.
         9) Check the output format of the file is valid JSON
         10) Verify that it  contains keys and values that correspond to those of the exported Item (captured in 2) )
         
            
         */
        XCTFail("Test not implemented")
    
    }

}
