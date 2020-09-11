//
//  ILO.swift
//  Classes
//
//  Created by Nick Baughan on 07/09/2020.
//

import Foundation
import CoreData

extension ILO {
    
    static func create(in managedObjectContext: NSManagedObjectContext, title: String, index: Int, lesson: Lesson) {
        let ilo = ILO(context: managedObjectContext)
        ilo.lesson = lesson
        ilo.id = UUID()
        ilo.index = Int16(index)
        ilo.title = title
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func update(in managedObjectContext: NSManagedObjectContext, text: String, index: Int16, lesson: Lesson) {
        self.title = text
        self.index = index
        self.lesson = lesson
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func toggleWritten(context managedObjectContext: NSManagedObjectContext) {
        written.toggle()
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
