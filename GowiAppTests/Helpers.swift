//
//  Helpers.swift
//  GowiUITests
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation

/**
 ## Test Fixture and Utility Functions
 
 This file provides utilities for working with test fixtures and string matching in UI tests.
 
 ### Fixture Management
 The fixture functions provide a standardized way to access test data files:
 - `fixtureData(for:)` - Loads fixture file content as Data
 - `fixtureUrl(for:)` - Gets URL for a fixture file
 - `fixturesDirectory()` - Locates the Fixture directory relative to test files
 
 ### String Testing Extensions
 Provides regex matching functionality for test validation:
 - `String.testingMatch(_:)` - Swift-friendly regex matching with capture groups
 */

/// Loads test fixture data from the Fixture directory
/// - Parameter fixture: Name of the fixture file to load
/// - Returns: Data content of the fixture file
/// - Throws: File system errors if fixture doesn't exist or can't be read
func fixtureData(for fixture: String) throws -> Data {
    try Data(contentsOf: fixtureUrl(for: fixture))
}

/// Gets URL for a fixture file in the test Fixture directory
/// - Parameter fixture: Name of the fixture file
/// - Returns: Full URL path to the fixture file
func fixtureUrl(for fixture: String) -> URL {
    fixturesDirectory().appendingPathComponent(fixture)
}

/// Locates the Fixture directory relative to the test files
/// - Parameter path: Source file path (defaults to current file)
/// - Returns: URL of the Fixture directory within the test bundle
func fixturesDirectory(path: String = #file) -> URL {
    let url = URL(fileURLWithPath: path)
    let testsDir = url.deletingLastPathComponent()
    let res = testsDir.appendingPathComponent("Fixture")
    return res
}

extension String {
    /// Performs regex matching with capture group extraction for testing purposes
    /// 
    /// This extension provides Swift-friendly regex matching functionality specifically designed for test validation.
    /// Based on solution from https://stackoverflow.com/questions/27880650/swift-extract-regex-matches
    /// 
    /// - Parameter regex: Regular expression pattern to match against
    /// - Returns: Array of matches, where each match is an array of strings:
    ///   - First element of each sub-array is the full match
    ///   - Subsequent elements are the capture groups (if any)
    /// 
    /// ## Usage Example:
    /// ```swift
    /// let dateString = "Date: 2023-12-25 14:30"
    /// let matches = dateString.testingMatch(#"(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})"#)
    /// // matches[0][0] = "2023-12-25 14:30" (full match)
    /// // matches[0][1] = "2023" (year capture group)
    /// // matches[0][2] = "12" (month capture group)
    /// // etc.
    /// ```
    func testingMatch(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0 ..< match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}



