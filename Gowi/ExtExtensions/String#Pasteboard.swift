//
//  String#Pasteboard.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import SwiftUI

/**
 ## String Pasteboard Extension
 
 Provides convenient pasteboard (clipboard) operations for String values.
 This extension simplifies copying text to the system clipboard for sharing
 item IDs, URLs, and other text content with external applications.
 
 ### Usage:
 ```swift
 "some text".copyToPasteboard()
 ```
 
 ### Integration:
 Used throughout the app for:
 - Copying item UUIDs from detail views
 - Copying deep link URLs for sharing
 - Copying formatted dates for external use
 */
extension String {
    /// Shared reference to the system's general pasteboard
    static let pasteboard = NSPasteboard.general
    
    /// Copies this string to the system clipboard
    ///
    /// Clears existing clipboard contents and sets this string as the new
    /// clipboard content. The string will be available for pasting in other
    /// applications until replaced by new clipboard content.
    func copyToPasteboard() {
        Self.pasteboard.clearContents()
        Self.pasteboard.setString(self, forType: .string)
    }
}
