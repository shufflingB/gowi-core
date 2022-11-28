//
//  Item.swift
//  macOSToDo
//
//  Created by Jonathan Hume on 26/10/2021.
//

import CoreData
import os
// import Foundation

fileprivate let log = Logger(subsystem: Bundle.main.bundleIdentifier!, category: URL(fileURLWithPath: #file).deletingPathExtension().lastPathComponent)

// class Item: NSManagedObject, Codable {  /// ObjservableObject coformance is redundant bc  it is already part of NSManagedObject
//    /**
//     Fully automated code generation for the Core Data Item has been turned off in order to allow the use of Codable's Decodable protocol for JSON etc.
//     This has to be done bc Core Data's auto generated class definitions are incompatible with the `convenience init(from: Decoder)` that the  Decodable protocol requires.
//     To work around this in Xcode the Core Data  Item entity codegen is set as `Module = Current Product Module`, and the the `Codegen = Category/Extension`.
//     There's a good explanation of this here https://www.donnywals.com/using-codable-with-core-data-and-nsmanagedobject/
//     */
//
//    private enum CodingKeys: String, CodingKey { case id, completed, created, sortOrder, root, notes, title, childrenList, parentList }
//
//    var importId: String? = nil
//    var importParentIds: Array<String> = []
//    var importChildrenIds: Array<String> = []
//
//    required convenience init(from decoder: Decoder) throws {
//        guard let context = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
//            throw DecoderConfigurationError.missingManagedObjectContext
//        }
//
//        self.init(context: context)
//
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        created = try container.decode(Date.self, forKey: .created)
//        completed = try container.decodeIfPresent(Date.self, forKey: .completed)
//        sortOrder = try container.decodeIfPresent(Date.self, forKey: .sortOrder)
//        title = try container.decode(String.self, forKey: .title)
//        notes = try container.decode(String.self, forKey: .notes)
//
//        /** Do not directly do anything with these just yet bc what should be done will vary depending on if doing a Backup Restore vs Import */
//        importId = try container.decode(String.self, forKey: .id)
//        importParentIds = try container.decode(Array<String>.self, forKey: .parentList)
//        importChildrenIds = try container.decode(Array<String>.self, forKey: .childrenList)
//    }
//
//    var parentListAsSet: Set<Item> {
//        parentList as? Set<Item> ?? []
//    }
//
//    var parentListAsArray: Array<Item> {
//        parentListAsSet.sorted(by: { $0.sortOrder! < $1.sortOrder! })
//    }
//
//    var childrenListAsSet: Set<Item> {
//        return childrenList as? Set<Item> ?? []
//    }
//
//    var childrenListAsArray: Array<Item> {
//        // For sanity's sake this isorted in same order as the View's fetch request does - i.e. with newest date/largest since Apple epoc
//        // value first and the oldest last
//        childrenListAsSet.sorted(by: { $0.sortOrder! < $1.sortOrder! })
//    }
//
//    var idAsString: String? {
//        id?.uuidString
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(idAsString, forKey: .id)
//        try container.encode(root, forKey: .root)
//        try container.encode(title, forKey: .title)
//        try container.encode(created, forKey: .created)
//        try container.encode(completed, forKey: .completed)
//        try container.encode(sortOrder, forKey: .sortOrder)
//        try container.encode(notes, forKey: .notes)
//        try container.encode(childrenListAsArray.map({ $0.id }), forKey: .childrenList)
//
//        try container.encode(parentListAsArray.map({ $0.id }), forKey: .parentList)
//    }
// }
//
// extension CodingUserInfoKey {
//    static let managedObjectContext = CodingUserInfoKey(rawValue: "managedObjectContext")!
// }
//
// enum DecoderConfigurationError: Error {
//    case missingManagedObjectContext
// }

import SwiftUI

extension Item {
    var ourIdS: UUID {
        get { ourId ?? UUID() }

        set(nv) { ourId = nv }
    }

    var titleS: String {
        get { title ?? "" }

        set(nv) {
            if nv != title {
//                log.debug("Title being set to \(nv)")
                title = nv
                /// Need this to workaround  "Binding<String> action tried to update multiple times per frame" bug and to ensure the title  displayed in the Sidebar
                /// and Detail stay properly in sync. See  macOSToDo://main/v1/all?id=08C85195-4871-4011-867A-23E8CF2415B2 for more on that.
                objectWillChange.send()
            }
        }
    }

    var notesS: String {
        get { notes ?? "" }

        set(nv) {
            if nv != notes {
//            print("Notes being set")
                notes = nv
            }
        }
    }

    var parentListAsSet: Set<Item> {
        parentList as? Set<Item> ?? []
    }

    var childrenListAsSet: Set<Item> {
        childrenList as? Set<Item> ?? []
    }

//    var childrenFetchRequestAll: FetchRequest<Item> {
//        FetchRequest(
//            fetchRequest: Self.childrenFetchRequest(for: self, sortedBy: [NSSortDescriptor(key: "priority", ascending: true)] )
//        )
//    }
//
//    private static func childrenFetchRequest(for parent: Item, sortedBy sortDescriptors: Array<NSSortDescriptor>, addingOther otherPredicates: Array<NSPredicate> = []) -> NSFetchRequest<Item> {
//        let parentPredicate = NSPredicate(format: "parentList CONTAINS %@", parent as CVarArg)
//        let combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [parentPredicate] + otherPredicates)
//        let request = NSFetchRequest<Item>(entityName: String(describing: Item.self))
//        request.sortDescriptors = sortDescriptors
//
//        request.predicate = combinedPredicate
//        return request
//    }
}
