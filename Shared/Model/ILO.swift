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
}
