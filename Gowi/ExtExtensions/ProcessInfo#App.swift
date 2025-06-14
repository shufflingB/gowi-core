//
//  ProcessInfo#App.swift
//  Gowi
//
//  Created by Jonathan Hume on 14/06/2025.
//

import Foundation

extension ProcessInfo {
    var isRunningUITests: Bool {
        environment["XCTestConfigurationFilePath"] != nil
    }
}
