//
//  Lesson+CoreDataProperties.swift
//  Classes
//
//  Created by Nick Baughan on 12/09/2020.
//
//

import Foundation
import CoreData


extension Lesson {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lesson> {
        return NSFetchRequest<Lesson>(entityName: "Lesson")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var iloCount: Int16
    @NSManaged public var location: String?
    @NSManaged public var teacher: String?
    @NSManaged public var title: String?
    @NSManaged public var type: String?
    @NSManaged public var watched: Bool
    @NSManaged public var ilo: NSSet?
    @NSManaged public var resource: NSSet?
    @NSManaged public var tag: NSSet?

}

// MARK: Generated accessors for ilo
extension Lesson {

    @objc(addIloObject:)
    @NSManaged public func addToIlo(_ value: ILO)

    @objc(removeIloObject:)
    @NSManaged public func removeFromIlo(_ value: ILO)

    @objc(addIlo:)
    @NSManaged public func addToIlo(_ values: NSSet)

    @objc(removeIlo:)
    @NSManaged public func removeFromIlo(_ values: NSSet)

}

// MARK: Generated accessors for resource
extension Lesson {

    @objc(addResourceObject:)
    @NSManaged public func addToResource(_ value: Resource)

    @objc(removeResourceObject:)
    @NSManaged public func removeFromResource(_ value: Resource)

    @objc(addResource:)
    @NSManaged public func addToResource(_ values: NSSet)

    @objc(removeResource:)
    @NSManaged public func removeFromResource(_ values: NSSet)

}

// MARK: Generated accessors for tag
extension Lesson {

    @objc(addTagObject:)
    @NSManaged public func addToTag(_ value: Tag)

    @objc(removeTagObject:)
    @NSManaged public func removeFromTag(_ value: Tag)

    @objc(addTag:)
    @NSManaged public func addToTag(_ values: NSSet)

    @objc(removeTag:)
    @NSManaged public func removeFromTag(_ values: NSSet)

}

extension Lesson : Identifiable {

}
