//
//  Set+RawRepresentable.swift
//  Gowi
//
//  Created by Jonathan Hume on 02/12/2022.
//

import Foundation

/// `Set` extended with `RawRepresentable` so that the set of ID's selected by the content view can be persisted in `@SceneStorage`
extension Set: RawRepresentable where Element == UUID {
    public init?(rawValue: String) {
        self = Set(rawValue.components(separatedBy: ",").compactMap { str in
            guard let id: UUID = UUID(uuidString: str) else {
                return nil
            }
            return id
        })
    }

    public var rawValue: String {
        let val = map({ "\($0.uuidString)" }).joined(separator: ",")
        return val
    }
}
