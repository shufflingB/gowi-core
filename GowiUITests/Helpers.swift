//
//  Helpers.swift
//  macOSToDoUITests
//
//  Created by Jonathan Hume on 03/06/2022.
//

import Foundation

func fixtureData(for fixture: String) throws -> Data {
    try Data(contentsOf: fixtureUrl(for: fixture))
}

func fixtureUrl(for fixture: String) -> URL {
    fixturesDirectory().appendingPathComponent(fixture)
}

func fixturesDirectory(path: String = #file) -> URL {
    let url = URL(fileURLWithPath: path)
    let testsDir = url.deletingLastPathComponent()
    let res = testsDir.appendingPathComponent("Fixture")
    return res
}

extension String {
    /// Wow fair to say Swift's regex currently makes you want to 😢 . This extension from from https://stackoverflow.com/questions/27880650/swift-extract-regex-matches  makes it slightly less horrific
    /// Usage ...
    ///  - First element of sub-array is the match
    /// - All subsequent elements are the capture groups

    func testingMatch(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0 ..< match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}
