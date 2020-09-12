//
//  Resource.swift
//  Classes (iOS)
//
//  Created by Nick Baughan on 12/09/2020.
//

import Foundation
import CoreData

extension Resource {
    static func create(in managedObjectContext: NSManagedObjectContext, title: String, lesson: Lesson, url: URL) {
        let resource = Resource(context: managedObjectContext)
        resource.lesson = lesson
        resource.id = UUID()
        resource.name = title
        resource.url = url
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func update(in managedObjectContext: NSManagedObjectContext, name: String, lesson: Lesson, url: URL) {
        self.name = name
        self.lesson = lesson
        self.name = name
        self.url = url
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func delete(context managedObjectContext: NSManagedObjectContext, save: Bool) {
        managedObjectContext.delete(self)
        if save {
            do {
                try managedObjectContext.save()
            } catch {
                print("Unable to save due to Error: \(error)")
            }
        }
    }
}
