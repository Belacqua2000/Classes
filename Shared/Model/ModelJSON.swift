//
//  ModelJSON.swift
//  Classes
//
//  Created by Nick Baughan on 23/09/2020.
//

import Foundation

struct LessonJSON: Codable {
    
    var version: Int = 2
    
    let lessonData: [LessonData]
    
    struct LessonData: Codable {
        let date: Date?
        let location: String?
        let notes: String?
        let teacher: String?
        let title: String?
        let type: String?
        let watched: Bool
        
        let ilo: [ILOJSON]
        
        let resource: [ResourceJSON]
        
        init(lesson: Lesson) {
            date = lesson.date
            location = lesson.location
            notes = lesson.notes
            teacher = lesson.teacher
            title = lesson.title
            type = lesson.type
            watched = lesson.watched
            
            var ilos = [ILOJSON]()
            for ilo in lesson.ilo?.allObjects as! [ILO] {
                ilos.append(ILOJSON(index: ilo.index, title: ilo.title ?? "Untitled", written: ilo.written))
            }
            ilo = ilos
            
            var resources = [ResourceJSON]()
            for resource in lesson.resource?.allObjects as! [Resource] {
                resources.append(ResourceJSON(name: resource.name ?? "Untitled", url: resource.url))
            }
            resource = resources
        }
        
        struct ILOJSON: Codable {
            let index: Int16
            let title: String
            let written: Bool
        }
        
        struct ResourceJSON: Codable {
            let name: String
            let url: URL?
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
