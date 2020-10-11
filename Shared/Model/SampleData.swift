//
//  SampleData.swift
//  Classes
//
//  Created by Nick Baughan on 26/09/2020.
//


import Foundation
import CoreData

extension Lesson {
    
    static func sampleData(context: NSManagedObjectContext) -> [Lesson] {
        var lessons = [Lesson]()
        for i in 1 ..< 6 {
            let lesson = Lesson(context: context)
            lesson.id = UUID()
            lesson.title = "This is a very long title which I need to handle"
            lesson.location = "Location \(i)"
            lesson.teacher = "Teacher \(i)"
            lesson.date = Date(timeIntervalSinceNow: -Double(i*10))
            lesson.type = "Lecture"
            lesson.addSampleILO(context: context)
            
            lessons.append(lesson)
        }
        return lessons
    }
    
    func addSampleILO(context: NSManagedObjectContext) {
        for i in 1..<2 {
            let ilo = ILO(context: context)
            ilo.lesson = self
            ilo.id = UUID()
            ilo.index = Int16(i - 1)
            ilo.title = "ILO \(i)"
        }
    }
}
