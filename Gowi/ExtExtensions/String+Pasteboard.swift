//
//  String+Pasteboard.swift
//  Gowi
//
//  Created by Jonathan Hume on 04/11/2022.
//

import SwiftUI
extension String {
    static let pasteboard = NSPasteboard.general
    
    func copyToPasteboard() {
        Self.pasteboard.clearContents()
        Self.pasteboard.setString(self, forType: .string)
    }
}
