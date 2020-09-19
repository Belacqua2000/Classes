//
//  Lesson.swift
//  Classes
//
//  Created by Nick Baughan on 07/09/2020.
//

import Foundation
import CoreData

extension Lesson {
    enum LessonType: String, CaseIterable, Identifiable {
        var id: String { return rawValue }
        case lecture = "Lecture"
        case tutorial = "Tutorial"
        case pbl = "PBL"
        case cbl = "CBL"
        case lab = "Lab"
        case clinical = "Clinical Skills"
        case selfStudy = "Self Study"
        case other = "Other"
    }
    
    static func lessonTypePlural(type: String?) -> String {
        switch LessonType(rawValue: type ?? "none") {
        case .some(.lecture):
            return "Lectures"
        case .some(.tutorial):
            return "Tutorials"
        case .some(.pbl):
            return "PBL"
        case .some(.cbl):
            return "CBL"
        case .some(.lab):
            return "Labs"
        case .some(.clinical):
            return "Clinical Skills"
        case .some(.other):
            return "Other"
        case .some(.selfStudy):
            return "Self Study"
        case .none:
            return "book"
        }
    }
    
    static func lessonIcon(type: String?) -> String {
        switch LessonType(rawValue: type ?? "none") {
        case .some(.lecture):
            return "studentdesk"
        case .some(.tutorial):
            return "person.3"
        case .some(.pbl):
            return "doc.plaintext"
        case .some(.cbl):
            return "doc.richtext"
        case .some(.lab):
            return "eyedropper"
        case .some(.clinical):
            return "stethoscope"
        case .some(.other):
            return "ellipsis.circle"
        case .some(.selfStudy):
            return "text.book.closed.fill"
        case .none:
            return "book"
        }
    }
    
    func changeType(context managedObjectContext: NSManagedObjectContext, newType: LessonType) {
        type = newType.rawValue
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func toggleWatched(context managedObjectContext: NSManagedObjectContext) {
        watched.toggle()
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func delete(context managedObjectContext: NSManagedObjectContext) {
        managedObjectContext.delete(self)
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    static func create(in managedObjectContext: NSManagedObjectContext, title: String, type: Lesson.LessonType, teacher: String, date: Date, location: String, watched: Bool, save: Bool, tags: [Tag], notes: String) {
        let lesson = Lesson(context: managedObjectContext)
        lesson.id = UUID()
        lesson.title = title
        lesson.date = date
        lesson.teacher = teacher
        lesson.location = location
        lesson.watched = watched
        lesson.type = type.rawValue
        lesson.notes = notes
        for newTag in tags {
            lesson.addToTag(newTag)
        }
        if save {
            do {
                try managedObjectContext.save()
            } catch {
                print("Unable to save due to Error: \(error)")
            }
        }
    }
    
    func update(in managedObjectContext: NSManagedObjectContext, title: String, type: Lesson.LessonType, teacher: String, date: Date, location: String, watched: Bool, tags: [Tag], notes: String) {
        self.title = title
        self.date = date
        self.teacher = teacher
        self.location = location
        self.watched = watched
        self.type = type.rawValue
        self.notes = notes
        // Removes all current tags
        if let tag = tag {
            removeFromTag(tag)
        }
        // Adds tags passed in through method
        for newTag in tags {
            self.addToTag(newTag)
        }
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to save due to Error: \(error)")
        }
    }
    
    func updateILOIndices(in managedObjectContext: NSManagedObjectContext, save: Bool) {
        var currentIndex: Int16 = 0
        for ilo in ilo?.sortedArray(using: [NSSortDescriptor(key: "index", ascending: true)]) as? [ILO] ?? [] {
            ilo.index = currentIndex
            currentIndex += 1
        }
        if save {
            do {
                try managedObjectContext.save()
            } catch {
                print("Unable to save due to Error: \(error)")
            }
        }
    }
}
