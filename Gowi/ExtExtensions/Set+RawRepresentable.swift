//
//  Set+RawRepresentable.swift
//  Set+RawRepresentable
//
//  Created by Jonathan Hume on 07/10/2021.
//

import Foundation

extension Set: RawRepresentable where Element == UUID {
    public init?(rawValue: String) {
        self = Set(rawValue.components(separatedBy: ",").compactMap { str in
            guard let id: UUID = UUID(uuidString: str) else {
//                print("Failing to restore id from ")
                return nil
            }

//            print("Restoring as id = \(id)")
            return id
        })
    }

    public var rawValue: String {
//        print("\(self)")
        let val = map({ "\($0.uuidString)" }).joined(separator: ",")
        return val
    }
}