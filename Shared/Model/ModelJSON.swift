//
//  ModelJSON.swift
//  Classes
//
//  Created by Nick Baughan on 23/09/2020.
//

import Foundation

struct LessonJSON: Codable {
    
    var version: Int = 1
    
    let lessonData: [LessonData]
    
    struct LessonData: Codable {
        let date: Date?
        let location: String?
        let notes: String?
        let teacher: String?
        let title: String?
        let type: String?
        let watched: Bool
        
        init(lesson: Lesson) {
            date = lesson.date
            location = lesson.location
            notes = lesson.notes
            teacher = lesson.teacher
            title = lesson.title
            type = lesson.type
            watched = lesson.watched
        }
    }
    
    init(lessons: [Lesson]) {
        var data = [LessonData]()
        for lesson in lessons {
            data.append(LessonData(lesson: lesson))
        }
        lessonData = data
    }
    
}
