//
//  Tag.swift
//  Shared
//
//  Created by Nick Baughan on 12/09/2020.
//

import SwiftUI
import CoreData

#if !os(macOS)
extension Tag {
    var swiftUIColor: Color? {
        guard let color = color as? UIColor else { return nil }
        return Color(color)
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, name: String, color: Color) {
        let tag = Tag(context: managedObjectContext)
        tag.name = name
        tag.color = UIColor(color)
        tag.id = UUID()
        do {
            try managedObjectContext.save()
        } catch  {
            fatalError("Failed to save due to \(error)")
        }
    }
}
#endif

#if os(macOS)
extension Tag {
    var swiftUIColor: Color? {
        guard let color = color as? NSColor else { return nil }
        return Color(color)
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, name: String, color: Color) {
        let tag = Tag(context: managedObjectContext)
        tag.id = UUID()
        tag.name = name
        tag.color = NSColor(color)
        do {
            try managedObjectContext.save()
        } catch  {
            fatalError("Failed to save due to \(error)")
        }
    }
}
#endif

extension Tag {
    func delete(context managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.delete(self)
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
}
